//
//  FiltersStore.swift
//  Skill-Link
//
//  Created by BP-36-201-24 on 30/12/2025.
//



import Foundation

enum FiltersStore {

    // ✅ Bump version so old broken data is ignored
    private static let key = "search_filters_v2"

    static func save(_ filters: SearchFilters) {
        do {
            let data = try JSONEncoder().encode(filters)
            UserDefaults.standard.set(data, forKey: key)
        } catch {
            print("FiltersStore.save error:", error)
        }
    }

    static func load() -> SearchFilters {
        guard let data = UserDefaults.standard.data(forKey: key) else {
            return SearchFilters()
        }

        do {
            return try JSONDecoder().decode(SearchFilters.self, from: data)
        } catch {
            // ✅ If decode fails, clear and return empty (prevents “always empty” forever)
            print("FiltersStore.load decode failed, clearing saved filters:", error)
            clear()
            return SearchFilters()
        }
    }

    static func clear() {
        UserDefaults.standard.removeObject(forKey: key)
    }
}
