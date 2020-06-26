import SDWebImage
import UIKit

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
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.widthAnchor.constraint(equalToConstant: Constants.imageWidth).isActive = true
        imageView.heightAnchor.constraint(equalToConstant: Constants.imageHeight).isActive = true
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

    var viewModel: FlickrResultViewable? {
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
        contentView.layer.borderColor = UIColor.separator.cgColor
        contentView.layer.borderWidth = 1.0
    }

    private func updateViewForViewModel() {
        label.text = viewModel?.title
        imageView.sd_setImage(with: viewModel?.imageUrl, placeholderImage: loadingImage)
    }
}

private struct Constants {
    static let imageWidth: CGFloat = 170
    static let imageHeight: CGFloat = 100
}
