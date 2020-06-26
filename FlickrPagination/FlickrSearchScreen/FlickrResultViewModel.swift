import Foundation

protocol FlickrResultViewable {
    var title: String { get }
    var imageUrl: URL? { get }
}

class FlickrResultViewModel: FlickrResultViewable {
    private let photo: Photo
    init(photo: Photo) {
        self.photo = photo
    }

    var title: String {
        return photo.title
    }

    var imageUrl: URL? {
        return URL(string: "https://farm\(photo.farm).staticflickr.com/\(photo.server)/\(photo.id)_\(photo.secret)_m.jpg")
    }
}
