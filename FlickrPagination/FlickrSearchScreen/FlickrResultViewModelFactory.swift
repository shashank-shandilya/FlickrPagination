import Foundation

protocol FlickrResultViewModelCreator {
    func createResultViewModel(item: Photo) -> FlickrResultViewable
}

struct FlickrResultViewModelFactory: FlickrResultViewModelCreator {
    func createResultViewModel(item: Photo) -> FlickrResultViewable {
        return FlickrResultViewModel(photo: item)
    }
}
