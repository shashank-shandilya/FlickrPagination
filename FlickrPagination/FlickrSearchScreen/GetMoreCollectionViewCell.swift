import UIKit

enum GetMoreCellType {
    case retry(() -> Void)
    case loaderIndicator
}

struct GetMoreViewModel {
    let cellType: GetMoreCellType
}

class GetMoreCollectionViewCell: UICollectionViewCell {
    var viewModel: GetMoreViewModel? {
        didSet {
            updateViewForViewModel()
        }
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupSubviews()
        setupConstraints()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private lazy var button: UIButton = {
        let button = UIButton(type: .custom)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("retry", for: .normal)
        button.setTitleColor(.systemBlue, for: .normal)
        button.addTarget(self, action: #selector(tapOnButton(sender:)), for: .touchUpInside)
        return button
    }()

    private let activityIndicator: UIActivityIndicatorView = {
        let activityIndicator = UIActivityIndicatorView(style: .medium)
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        activityIndicator.hidesWhenStopped = true
        return activityIndicator
    }()

    private func updateViewForViewModel() {
        guard let viewModel = viewModel else {
            return
        }

        switch viewModel.cellType {
        case .retry:
            button.isHidden = false
            activityIndicator.isHidden = true
        case .loaderIndicator:
            button.isHidden = true
            activityIndicator.startAnimating()
            activityIndicator.isHidden = false
        }
    }

    private func setupSubviews() {
        contentView.addSubview(button)
        contentView.addSubview(activityIndicator)
    }

    private func setupConstraints() {
        button.widthAnchor.constraint(equalToConstant: 100).isActive = true
        button.topAnchor.constraint(equalTo: contentView.topAnchor).isActive = true
        button.bottomAnchor.constraint(equalTo: contentView.bottomAnchor).isActive = true
        button.centerXAnchor.constraint(equalTo: contentView.centerXAnchor).isActive = true

        activityIndicator.centerXAnchor.constraint(equalTo: contentView.centerXAnchor).isActive = true
        activityIndicator.centerYAnchor.constraint(equalTo: contentView.centerYAnchor).isActive = true
    }

    @objc func tapOnButton(sender: UIButton) {
        if case .retry(let onTap) = viewModel?.cellType {
            onTap()
        }
    }
}
