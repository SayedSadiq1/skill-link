//
//  Review.swift
//  Skill-Link
//
//  Created by Sayed on 20/12/2025.
//

struct Review {
    let name: String
    let message: String
    let rating: Int
    
    init(name: String, message: String, rating: Int) {
        self.name = name
        self.message = message
        self.rating = min(max(rating, 1), 5)
    }
}
