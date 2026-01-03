//
//  CloudinaryUploader.swift
//  Skill-Link
//
//  Created by BP-36-201-23 on 27/12/2025.
//

import Foundation
import UIKit

// Handles image uploads to cloudinary
final class CloudinaryUploader {

    // Shared instance used app wide
    static let shared = CloudinaryUploader()

    // Cloudinary cloud name
    private let cloudName = "dgamwyki7"

    // Preset used for unsigned upload
    private let uploadPreset = "mobile_unsigned"

    // Private init so only one instance exist
    private init() {}

    // Uploads image and returns url string
    func uploadImage(
        _ image: UIImage,
        completion: @escaping (Result<String, Error>) -> Void
    ) {
        // Convert image to jpeg data
        guard let imageData = image.jpegData(compressionQuality: 0.8) else {
            completion(.failure(NSError(domain: "ImageError", code: 0)))
            return
        }

        // Build cloudinary upload url
        let urlString = "https://api.cloudinary.com/v1_1/\(cloudName)/image/upload"
        guard let url = URL(string: urlString) else { return }

        // Setup post request
        var request = URLRequest(url: url)
        request.httpMethod = "POST"

        // Boundary for multipart data
        let boundary = UUID().uuidString
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")

        // Data body for request
        var body = Data()

        // Add upload preset value
        body.append("--\(boundary)\r\n")
        body.append("Content-Disposition: form-data; name=\"upload_preset\"\r\n\r\n")
        body.append("\(uploadPreset)\r\n")

        // Add image file data
        body.append("--\(boundary)\r\n")
        body.append("Content-Disposition: form-data; name=\"file\"; filename=\"image.jpg\"\r\n")
        body.append("Content-Type: image/jpeg\r\n\r\n")
        body.append(imageData)
        body.append("\r\n")

        // Close body data
        body.append("--\(boundary)--\r\n")

        request.httpBody = body

        // Send request to cloudinary
        URLSession.shared.dataTask(with: request) { data, _, error in
            if let error = error {
                completion(.failure(error))
                return
            }

            // Read response and extract image url
            guard
                let data = data,
                let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
                let secureURL = json["secure_url"] as? String
            else {
                completion(.failure(NSError(domain: "CloudinaryError", code: 0)))
                return
            }

            // Return the uploaded image url
            completion(.success(secureURL))
        }.resume()
    }
}

// Helps add string data into body
private extension Data {
    mutating func append(_ string: String) {
        if let data = string.data(using: .utf8) {
            append(data)
        }
    }
}
