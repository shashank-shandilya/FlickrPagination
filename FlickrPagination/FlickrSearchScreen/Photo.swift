import Foundation

struct PhotoResponse: Codable {
    let photos: Photos
}

struct Photos: Codable {
    let photo: [Photo]
    let page: Int
    let pages: Int
    let total: String
}

struct Photo: Codable {
    let id: String
    let secret: String
    let server: String
    let farm: Int
    let title: String
}
