//
//  ReviewController.swift
//  Skill-Link
//
//  Created by Sayed on 26/12/2025.
//

import FirebaseFirestore

class ReviewController{
    static var shared = ReviewController()
    
    func makeReview(senderName:String,ServiceID:String,content:String,rating:Int) async throws {
        
        let reviewData: [String: Any] = [
            "reviewerName": senderName,
            "content": content,
            "rate": rating,
            "serviceID": ServiceID
        ]
        do{
            try await Firestore.firestore().collection("Review").addDocument(data: reviewData)
        }
    }
    
    func getReviews(serviceID: String) async throws -> [Review] {
        
        let querySnapshot = try await Firestore.firestore().collection("Review").whereField("serviceID", isEqualTo: serviceID).getDocuments()
      
        let reviews = querySnapshot.documents.compactMap { document -> Review? in
            let data = document.data()
            
            guard let name = data["reviewerName"] as? String,
                  let message = data["content"] as? String,
                  let rating = data["rate"] as? Int else {
                return nil
            }
            
            return Review(
                name: name,
                message: message,
                rating: rating
            )
        }
        return reviews
        }

    }


