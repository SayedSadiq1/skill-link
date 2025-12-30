//
//  Service.swift
//  Skill-Link
//
//  Created by BP-36-201-21 on 30/12/2025.
//

import Foundation

class Service2 {
    var id: UUID
    let title: String
    let description: String
    let category: String
    let priceBD: Double
    let priceType: PriceType
    let rating: Double
    let provider: UserProfile
    let available: Bool
    let disclaimers: [String]
    let durationMinHours: Double
    let durationMaxHours: Double
    
    init(id: UUID, title: String, description: String, category: String, priceBD: Double, priceType: PriceType, rating: Double, provider: UserProfile, available: Bool, disclaimers: [String], durationMinHours: Double, durationMaxHours: Double) {
        self.id = id
        self.title = title
        self.description = description
        self.category = category
        self.priceBD = priceBD
        self.priceType = priceType
        self.rating = rating
        self.provider = provider
        self.available = available
        self.disclaimers = disclaimers
        self.durationMinHours = durationMinHours
        self.durationMaxHours = durationMaxHours
    }
}

enum PriceType: String {
    case fixed
    case hourly
}
