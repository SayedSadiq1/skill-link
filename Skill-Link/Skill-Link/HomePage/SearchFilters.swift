//
//  SearchFilters.swift
//  Skill-Link
//
//  Created by BP-36-212-05 on 29/12/2025.
//


import Foundation

struct SearchFilters: Codable {
    var selectedCategories: [String] = []

    // Price: choose one direction or nil
    var priceSort: PriceSort? = nil

    // Rating: can be ON/OFF independently
    var sortByRating: Bool = false

    // user-picked date/time (optional - useful for display/debug)
    var availabilityDate: Date? = nil

    // derived slot shown in chips (Morning/Afternoon/Evening/Night)
    var availabilitySlot: String? = nil
}

enum PriceSort: String, Codable {
    case lowToHigh
    case highToLow
}
