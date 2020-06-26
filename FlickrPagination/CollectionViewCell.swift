import SDWebImage
import UIKit

struct FlickrResultCellViewModel {
    let text: String
    let imageUrl: URL?
}

class FlickrResultCell: UICollectionViewCell {
    private let label: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textAlignment = .center
        label.numberOfLines = 2
        label.textColor = .label
        label.font = UIFont.preferredFont(forTextStyle: .caption1)
        label.adjustsFontForContentSizeCategory = true
        return label
    }()

    private let imageView: SDAnimatedImageView = {
        let imageView = SDAnimatedImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFit
        imageView.widthAnchor.constraint(equalToConstant: 150).isActive = true
        imageView.heightAnchor.constraint(equalToConstant: 100).isActive = true
        return imageView
    }()

    private let stackView: UIStackView = {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.alignment = .fill
        stackView.axis = .vertical
        stackView.spacing = 5.0
        return stackView
    }()

    private let loadingImage: UIImage? = {
        guard let url = Bundle.main.url(forResource: "loading", withExtension: "gif"), let data = try? Data(contentsOf: url) else {
            return nil
        }

        return UIImage(data: data)
    }()

    var viewModel: FlickrResultCellViewModel? {
        didSet {
            updateViewForViewModel()
        }
    }

    override init(frame: CGRect) {
        super.init(frame: .zero)
        setupSubviews()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupSubviews() {
        stackView.addArrangedSubview(imageView)
        stackView.addArrangedSubview(label)
        contentView.addSubview(stackView)
        var constraints: [NSLayoutConstraint] = []
        constraints.append(stackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor))
        constraints.append(stackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor))
        constraints.append(stackView.topAnchor.constraint(equalTo: contentView.topAnchor))
        constraints.append(stackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor))
        NSLayoutConstraint.activate(constraints)
    }

    private func updateViewForViewModel() {
        label.text = viewModel?.text
        imageView.sd_setImage(with: viewModel?.imageUrl, placeholderImage: loadingImage)
    }
}
