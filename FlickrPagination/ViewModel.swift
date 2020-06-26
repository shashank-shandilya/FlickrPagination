import Foundation

protocol ViewControllerDelegate: class {
    func appendItems(items: [FlickrResultViewable], hasMore: Bool)
    func showError(errorMessage: String)
    func fetchMoreFailed()
}

protocol PhotosViewable {
    func fetchItems(searchString: String?)
    func reachingEndOfList()
}

class FlickrSearchViewModel: PhotosViewable {
    weak var delegate: ViewControllerDelegate?
    private let photoFetcher: PhotoFetcher
    private var page: Int
    private let perPage: Int
    private let pageItemViewModelFactory: PageItemViewModelCreator
    private var lastSearchedString: String
    private var urlSessionTask: URLSessionTask?

    init(photoFetcher: PhotoFetcher = PhotoFetcher(),
         pageItemViewModelFactory: PageItemViewModelCreator = PageItemViewModelFactory(),
         page: Int = 0,
         perPage: Int = 10,
         lastSearchedString: String = "") {
        self.photoFetcher = photoFetcher
        self.pageItemViewModelFactory = pageItemViewModelFactory
        self.perPage = perPage
        self.page = page
        self.lastSearchedString = lastSearchedString
    }

    func fetchItems(searchString: String?) {
        page = 0
        urlSessionTask?.cancel()
        guard let searchString = searchString else {
            return
        }

        self.lastSearchedString = searchString
        if searchString.count == 0 {
            return
        }

        let request = PhotoFetchRequest(searchQuery: searchString, perPage: perPage, page: page)
        urlSessionTask = photoFetcher.fetchImages(request: request) { [weak self] (result) in
            guard let strongSelf = self else { return }
            strongSelf.urlSessionTask = nil
            switch result {
            case .failure(let error):
                strongSelf.delegate?.showError(errorMessage: error.localizedDescription)
            case .success(let response):
                strongSelf.handleResponse(response: response)
            }
        }
    }

    func reachingEndOfList() {
        if urlSessionTask != nil || lastSearchedString.count == 0 {
            return
        }

        let request = PhotoFetchRequest(searchQuery: lastSearchedString, perPage: perPage, page: page)
        urlSessionTask = photoFetcher.fetchImages(request: request) { [weak self] (result) in
            guard let strongSelf = self else { return }
            strongSelf.urlSessionTask = nil
            switch result {
            case .failure(_):
                strongSelf.delegate?.fetchMoreFailed()
                break
            case .success(let response):
                strongSelf.handleResponse(response: response)
            }
        }
    }

    private func handleResponse(response: PhotoResponse) {
        let list: [FlickrResultViewable] = response.photos.photo.map {
            return pageItemViewModelFactory.createItemViewModel(item: $0)
        }
        delegate?.appendItems(items: list, hasMore: response.photos.page < response.photos.pages)
        page = response.photos.page + 1
    }
}
