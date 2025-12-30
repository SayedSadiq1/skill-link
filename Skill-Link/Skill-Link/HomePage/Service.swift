//
//  Service.swift
//  Skill-Link
//
//  Created by BP-36-201-14 on 28/12/2025.
//

import Foundation


class Service {
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
    
    init(id: UUID, title: String, description: String, category: String, priceBD: Double, priceType: PriceType, rating: Double, provider: UserProfile, available: Bool, disclaimers: [String]) {
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
    }
}

enum PriceType: String {
    case fixed
    case hourly
}
