//
//  Service.swift
//  Skill-Link
//
//  Created by BP-36-201-14 on 28/12/2025.
//

import Foundation
import FirebaseFirestore


class Service: Codable {
    @DocumentID<String> var id: String?
    var title: String
    var description: String
    var category: String
    var priceBD: Double
    var priceType: PriceType
    var rating: Double
    var providerId: String
    var available: Bool
    var disclaimers: [String]
    var durationMinHours: Double
    var durationMaxHours: Double
    var availableAt: String
    
    init(id: UUID, title: String, description: String, category: String, priceBD: Double, priceType: PriceType, rating: Double, providerId: String, available: Bool, disclaimers: [String], durationMinHours: Double, durationMaxHours: Double, availableAt: String = "Morning") {
        self.id = id.uuidString
        self.title = title
        self.description = description
        self.category = category
        self.priceBD = priceBD
        self.priceType = priceType
        self.rating = rating
        self.providerId = providerId
        self.available = available
        self.disclaimers = disclaimers
        self.durationMinHours = durationMinHours
        self.durationMaxHours = durationMaxHours
        self.availableAt = availableAt
    }
}

enum PriceType: String, Codable {
    case Fixed
    case Hourly
}
