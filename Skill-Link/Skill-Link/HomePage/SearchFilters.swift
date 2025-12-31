//
//  SearchFilters.swift
//  Skill-Link
//
//  Created by BP-36-212-05 on 29/12/2025.
//


import Foundation

enum PriceSort: String, Codable {
    case lowToHigh
    case highToLow
}

struct SearchFilters: Codable {
    var selectedCategories: [String] = []

    // Price sorting
    var priceSort: PriceSort? = nil

    // Rating sorting
    var sortByRating: Bool = false

    // Availability (optional)
    var availabilityDate: Date? = nil
    var availabilitySlot: String? = nil

    var hasAnyFilter: Bool {
        return !selectedCategories.isEmpty
        || priceSort != nil
        || sortByRating == true
        || availabilityDate != nil
        || (availabilitySlot?.isEmpty == false)
    }
}
