//
//  CloudinaryUploader.swift
//  Skill-Link
//
//  Created by BP-36-201-23 on 27/12/2025.
//

import Foundation
import UIKit

final class CloudinaryUploader {

    static let shared = CloudinaryUploader()

    private let cloudName = "dgamwyki7"
    private let uploadPreset = "mobile_unsigned"

    private init() {}

    func uploadImage(
        _ image: UIImage,
        completion: @escaping (Result<String, Error>) -> Void
    ) {
        guard let imageData = image.jpegData(compressionQuality: 0.8) else {
            completion(.failure(NSError(domain: "ImageError", code: 0)))
            return
        }

        let urlString = "https://api.cloudinary.com/v1_1/\(cloudName)/image/upload"
        guard let url = URL(string: urlString) else { return }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"

        let boundary = UUID().uuidString
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")

        var body = Data()

        // upload preset
        body.append("--\(boundary)\r\n")
        body.append("Content-Disposition: form-data; name=\"upload_preset\"\r\n\r\n")
        body.append("\(uploadPreset)\r\n")

        // image
        body.append("--\(boundary)\r\n")
        body.append("Content-Disposition: form-data; name=\"file\"; filename=\"image.jpg\"\r\n")
        body.append("Content-Type: image/jpeg\r\n\r\n")
        body.append(imageData)
        body.append("\r\n")

        body.append("--\(boundary)--\r\n")

        request.httpBody = body

        URLSession.shared.dataTask(with: request) { data, _, error in
            if let error = error {
                completion(.failure(error))
                return
            }

            guard
                let data = data,
                let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
                let secureURL = json["secure_url"] as? String
            else {
                completion(.failure(NSError(domain: "CloudinaryError", code: 0)))
                return
            }

            completion(.success(secureURL))
        }.resume()
    }
}

// MARK: - Data helper
private extension Data {
    mutating func append(_ string: String) {
        if let data = string.data(using: .utf8) {
            append(data)
        }
    }
}
