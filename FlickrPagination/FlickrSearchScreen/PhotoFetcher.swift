import Foundation

struct PhotoFetchRequest {
    let searchQuery: String
    let perPage: Int
    let page: Int
}

protocol PhotoFetchable {
    func fetchImages(request: PhotoFetchRequest, requestResult: @escaping (Result<PhotoResponse, Error>) -> Void) -> URLSessionTask?
}

class PhotoFetcher: PhotoFetchable {
    private let urlSession: URLSession

    init() {
        let config = URLSessionConfiguration.default
        config.timeoutIntervalForRequest = 10
        urlSession = URLSession(configuration: config, delegate: nil, delegateQueue: .main)
    }

    func fetchImages(request: PhotoFetchRequest, requestResult: @escaping (Result<PhotoResponse, Error>) -> Void) -> URLSessionTask? {
        let queryItems = [URLQueryItem(name: "method", value: "flickr.photos.search"),
                          URLQueryItem(name: "api_key", value: "062a6c0c49e4de1d78497d13a7dbb360"),
                          URLQueryItem(name: "text", value: request.searchQuery),
                          URLQueryItem(name: "format", value: "json"),
                          URLQueryItem(name: "nojsoncallback", value: "1"),
                          URLQueryItem(name: "per_page", value: "\(request.perPage)"),
                          URLQueryItem(name: "page", value: "\(request.page)")
        ]
        guard var urlComponents = URLComponents(string: "https://api.flickr.com/services/rest/") else {
            requestResult(.failure(NSError(domain: "", code: 1, userInfo: ["description": "Error in forming url"])))
            return nil
        }

        urlComponents.queryItems = queryItems
        guard let url = urlComponents.url else {
            requestResult(.failure(NSError(domain: "", code: 1, userInfo: ["description": "Error in forming url"])))
            return nil
        }

        let urlTask = urlSession.dataTask(with: url,
                                          completionHandler: { (data, response, error) in
                                            if let error = error as NSError? {
                                                if error.code == NSURLErrorCancelled {
                                                    return
                                                }
                                                requestResult(.failure(error))
                                                return
                                            }

                                            guard let data = data else {
                                                requestResult(.failure(Constants.nilDataError))
                                                return
                                            }

                                            do {
                                                let photoResponse = try JSONDecoder().decode(PhotoResponse.self, from: data)
                                                requestResult(.success(photoResponse))
                                            } catch {
                                                requestResult(.failure(error))
                                            }
        })
        urlTask.resume()
        return urlTask
    }
}

private struct Constants {
    static let nilDataError = NSError(domain: "", code: 0, userInfo: ["desciption": "Received nil data"])

}
