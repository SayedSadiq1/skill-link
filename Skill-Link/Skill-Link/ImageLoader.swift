import UIKit

class ImageDownloader {
    static func downloadImage(from urlString: String) async throws -> UIImage {
        guard let url = URL(string: urlString) else {
            throw NSError(domain: "Invalid URL", code: 400, userInfo: nil)
        }
        
        let (data, response) = try await URLSession.shared.data(from: url)
        
        guard let httpResponse = response as? HTTPURLResponse, (200...299).contains(httpResponse.statusCode) else {
            throw NSError(domain: "Bad response", code: 500, userInfo: nil)
        }
        
        guard let image = UIImage(data: data) else {
            throw NSError(domain: "Invalid image data", code: 422, userInfo: nil)
        }
        
        return image
    }
}
