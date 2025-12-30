//
//  FiltersStore.swift
//  Skill-Link
//
//  Created by BP-36-201-24 on 30/12/2025.
//



import Foundation

enum FiltersStore {
    private static let key = "SearchFilters.saved"

    static func save(_ filters: SearchFilters) {
        do {
            let data = try JSONEncoder().encode(filters)
            UserDefaults.standard.set(data, forKey: key)
            print("✅ Saved to UserDefaults bytes:", data.count)
        } catch {
            print("❌ Save filters failed:", error)
        }
    }

    static func load() -> SearchFilters {
        guard let data = UserDefaults.standard.data(forKey: key) else {
            print("ℹ️ No saved filters found, returning default")
            return SearchFilters()
        }
        do {
            let decoded = try JSONDecoder().decode(SearchFilters.self, from: data)
            print("✅ Loaded filters from UserDefaults:", decoded)
            return decoded
        } catch {
            print("❌ Load filters failed:", error)
            return SearchFilters()
        }
    }
}
