//
//  RecentSearchesStore.swift
//  Skill-Link
//
//  Created by BP-36-201-14 on 31/12/2025.
//

import Foundation

final class RecentSearchesStore {

    static let shared = RecentSearchesStore()

    private let key = "recent_search_terms_v1"
    private let maxCount = 10

    private init() {}

    func load() -> [String] {
        UserDefaults.standard.stringArray(forKey: key) ?? []
    }

    func add(_ term: String) {
        let cleaned = term.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !cleaned.isEmpty else { return }

        var items = load()

        // Remove duplicates (case-insensitive), then add to top
        items.removeAll { $0.caseInsensitiveCompare(cleaned) == .orderedSame }
        items.insert(cleaned, at: 0)

        // Cap size
        if items.count > maxCount {
            items = Array(items.prefix(maxCount))
        }

        UserDefaults.standard.set(items, forKey: key)
    }

    func clear() {
        UserDefaults.standard.removeObject(forKey: key)
    }
}
