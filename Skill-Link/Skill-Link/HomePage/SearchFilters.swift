//
//  SearchFilters.swift
//  Skill-Link
//
//  Created by BP-36-212-05 on 29/12/2025.
//

import Foundation

struct SearchFilters {
    var selectedCategories: [String] = []

    // Price: choose one direction or nil
    var priceSort: PriceSort? = nil

    // Rating: can be ON/OFF independently
    var sortByRating: Bool = false

    // If set, we’ll filter to available == true (simple version)
    var availabilityDate: Date? = nil
}

enum PriceSort: String {
    case lowToHigh
    case highToLow
}
