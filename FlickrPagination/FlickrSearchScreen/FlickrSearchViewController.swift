import UIKit

class FlickrSearchViewController: UIViewController {
    private let viewModel: FlickrSearchViewModel
    private let searchController: UISearchController
    private var results: [FlickrResultViewable]
    private var hasMoreResults: Bool
    private var fetchMoreFailure: Bool
    private var searchTask: DispatchWorkItem?

    private var collectionViewLayout: UICollectionViewFlowLayout = {
        let collectionViewLayout = UICollectionViewFlowLayout()
        collectionViewLayout.minimumInteritemSpacing = Constants.spacingCollectionView
        collectionViewLayout.sectionInset = UIEdgeInsets(top: Constants.spacingCollectionView, left: Constants.spacingCollectionView, bottom: Constants.spacingCollectionView, right: Constants.spacingCollectionView)
        return collectionViewLayout
    }()

    lazy private var collectionView: UICollectionView = {
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: collectionViewLayout)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.prefetchDataSource = self
        collectionView.register(FlickrResultCell.self, forCellWithReuseIdentifier: Constants.photoReuseIdentifier)
        collectionView.register(GetMoreCollectionViewCell.self, forCellWithReuseIdentifier: Constants.getMoreItemReuseIdentifier)
        collectionView.backgroundColor = .systemBackground
        return collectionView
    }()

    init(viewModel: FlickrSearchViewModel = FlickrSearchViewModel()) {
        self.viewModel = viewModel
        searchController = UISearchController(searchResultsController: nil)
        results = []
        hasMoreResults = false
        fetchMoreFailure = false
        super.init(nibName: nil, bundle: nil)
        viewModel.delegate = self
        setupSearchContainer()
        setupSubviews()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        collectionViewLayout.invalidateLayout()
    }

    private func resetProperties() {
        results = []
        hasMoreResults = false
        fetchMoreFailure = false
    }

    private func setupSearchContainer() {
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = NSLocalizedString("Search for images here", comment: "Search for images here")
        navigationItem.searchController = searchController
        searchController.searchBar.showsCancelButton = false
        definesPresentationContext = true
    }

    private func setupSubviews() {
        view.backgroundColor = .systemBackground
        view.addSubview(collectionView)
        let layoutGuide = view.safeAreaLayoutGuide
        var constraints: [NSLayoutConstraint] = []
        constraints.append(collectionView.leadingAnchor.constraint(equalTo: layoutGuide.leadingAnchor))
        constraints.append(collectionView.trailingAnchor.constraint(equalTo: layoutGuide.trailingAnchor))
        constraints.append(collectionView.topAnchor.constraint(equalTo: layoutGuide.topAnchor))
        constraints.append(collectionView.bottomAnchor.constraint(equalTo: layoutGuide.bottomAnchor))
        NSLayoutConstraint.activate(constraints)
    }
}

extension FlickrSearchViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        let searchBar = searchController.searchBar
        searchTask?.cancel()
        let task = DispatchWorkItem { [weak self] in
            guard let strongSelf = self else {
                return
            }
            strongSelf.resetProperties()
            strongSelf.collectionView.reloadData()
            strongSelf.viewModel.fetchItems(searchString: searchBar.text)
        }
        self.searchTask = task
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + Constants.throttlingTime, execute: task)
    }
}

extension FlickrSearchViewController: FlickrViewControllerDelegate {
    func appendItems(items: [FlickrResultViewable], hasMore: Bool) {
        hasMoreResults = hasMore
        results.append(contentsOf: items)
        collectionView.reloadData()
    }

    func fetchMoreFailed() {
        fetchMoreFailure = true
        collectionView.reloadData()
    }

    func showError(errorMessage: String) {
        let alertController = UIAlertController(title: nil, message: errorMessage, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
        navigationController?.present(alertController, animated: true, completion: nil)
    }
}

extension FlickrSearchViewController: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDataSourcePrefetching, UICollectionViewDelegateFlowLayout {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return hasMoreResults ? 2: 1
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if section == 0 {
            return results.count
        }
        return 1
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if indexPath.section == 1 {
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: Constants.getMoreItemReuseIdentifier, for: indexPath) as? GetMoreCollectionViewCell else {
                return UICollectionViewCell()
            }

            if fetchMoreFailure {
                cell.viewModel = GetMoreViewModel(cellType: .retry({ [weak self] in
                    guard let strongSelf = self else {
                        return
                    }
                    strongSelf.fetchMoreFailure = false
                    strongSelf.collectionView.reloadData()
                    strongSelf.viewModel.reachingEndOfList()
                }))
            } else {
                cell.viewModel = GetMoreViewModel(cellType: .loaderIndicator)
                viewModel.reachingEndOfList()
            }
            return cell
        }

        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: Constants.photoReuseIdentifier, for: indexPath) as? FlickrResultCell else {
            return UICollectionViewCell()
        }

        let result = results[indexPath.row]
        cell.viewModel = result
        return cell
    }

    func collectionView(_ collectionView: UICollectionView, prefetchItemsAt indexPaths: [IndexPath]) {
        guard hasMoreResults else {
            return
        }

        let filteredIndexPaths = indexPaths.filter { $0.section == 1 }
        if filteredIndexPaths.count > 0, !fetchMoreFailure {
            viewModel.reachingEndOfList()
        }
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if indexPath.section == 0 {
            return Constants.itemSize
        }

        return CGSize(width: (collectionView.bounds.width - 2 * Constants.spacingCollectionView), height: Constants.getMoreItemHeight)
    }

    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        searchController.searchBar.resignFirstResponder()
    }
}

private struct Constants {
    static let itemSize = CGSize(width: 170, height: 150)
    static let getMoreItemHeight: CGFloat = 44.0
    static let photoReuseIdentifier = "photoReuseIdentifier"
    static let getMoreItemReuseIdentifier = "getMoreItemReuseIdentifier"
    static let throttlingTime = 0.3
    static let spacingCollectionView: CGFloat = 10.0
}
