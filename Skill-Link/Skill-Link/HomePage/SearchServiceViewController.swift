//
//  SearchServiceViewController.swift
//  Skill-Link
//
//  Created by BP-36-201-14 on 28/12/2025.
//

import UIKit

final class SearchServiceViewController: BaseViewController {

    // MARK: - Outlets
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var recentTableView: UITableView!

    // MARK: - State
    private var currentFilters: SearchFilters = FiltersStore.load()
    private var recentSearches: [String] = []

    // Temporary category search restore
    private var shouldRestoreCategoriesAfterReturn = false
    private var originalCategoriesBeforeTempSearch: [String]?

    // Real categories (must match exactly your Category screen + Service.category)
    private let knownCategories: [String] = [
        "Plumbing",
        "Electrician",
        "Landscaping",
        "Tutoring",
        "UI/UX Design",
        "Coding"
    ]

    // Aliases for “near match” terms
    private let categoryAliases: [String: String] = [
        "plumb": "Plumbing",
        "plumber": "Plumbing",
        "plumbing": "Plumbing",
        "pipe": "Plumbing",
        "pipes": "Plumbing",

        "electr": "Electrician",
        "electric": "Electrician",
        "electrician": "Electrician",
        "electrical": "Electrician",
        "electricity": "Electrician",
        "wiring": "Electrician",
        "wire": "Electrician",

        "landscape": "Landscaping",
        "landscaping": "Landscaping",
        "garden": "Landscaping",
        "gardening": "Landscaping",

        "tutor": "Tutoring",
        "tutoring": "Tutoring",
        "teacher": "Tutoring",
        "teaching": "Tutoring",

        "ui": "UI/UX Design",
        "ux": "UI/UX Design",
        "uiux": "UI/UX Design",
        "design": "UI/UX Design",

        "code": "Coding",
        "coding": "Coding",
        "program": "Coding",
        "programming": "Coding",
        "developer": "Coding",
        "dev": "Coding"
    ]

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()

        searchBar.delegate = self
        searchBar.autocapitalizationType = .none
        searchBar.returnKeyType = .search

        recentTableView.dataSource = self
        recentTableView.delegate = self
        recentTableView.tableFooterView = UIView()

        reloadRecents()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        currentFilters = FiltersStore.load()
        reloadRecents()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        // Restore categories AFTER returning from Results (so temp category doesn't persist)
        if shouldRestoreCategoriesAfterReturn, let original = originalCategoriesBeforeTempSearch {
            var filters = FiltersStore.load()
            filters.selectedCategories = original
            FiltersStore.save(filters)

            shouldRestoreCategoriesAfterReturn = false
            originalCategoriesBeforeTempSearch = nil
        }
    }

    private func reloadRecents() {
        recentSearches = RecentSearchesStore.shared.load()
        recentTableView.reloadData()
    }

    // MARK: - IBActions

    @IBAction func filtersTapped(_ sender: UIButton) {
        performSegue(withIdentifier: "toFilters", sender: self)
    }

    /// Search button behavior:
    /// - If empty text: open results (using current saved filters if any; otherwise all)
    /// - If text typed: save to recents always, match to category; if matched show results TEMPORARILY (no persistence)
    @IBAction func searchTapped(_ sender: UIButton) {
        // Force commit of user typing
        searchBar.resignFirstResponder()

        let term = (searchBar.text ?? "").trimmingCharacters(in: .whitespacesAndNewlines)

        // If user didn't type, just open results (don't modify filters)
        if term.isEmpty {
            openSearchResults()
            return
        }

        runSearch(term: term)
    }

    /// Suggested buttons MUST have tags in storyboard:
    /// 1 Plumbing, 2 Electrician, 3 Landscaping, 4 Tutoring, 5 UI/UX Design, 6 Coding
    /// This must ALSO be temporary (no persistence).
    @IBAction func suggestedCategoryTapped(_ sender: UIButton) {
        guard let category = categoryFromTag(sender.tag) else {
            showSimpleAlert(title: "Error", message: "Suggested button tag is not set.")
            return
        }

        openResultsTemporarilyForCategory(category)
    }

    private func categoryFromTag(_ tag: Int) -> String? {
        switch tag {
        case 1: return "Plumbing"
        case 2: return "Electrician"
        case 3: return "Landscaping"
        case 4: return "Tutoring"
        case 5: return "UI/UX Design"
        case 6: return "Coding"
        default: return nil
        }
    }

    // MARK: - Search logic

    private func runSearch(term: String) {
        let cleaned = term.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !cleaned.isEmpty else { return }

        // Always save even gibberish
        RecentSearchesStore.shared.add(cleaned)
        reloadRecents()

        // Navigate only if close to category
        if let matched = matchCategory(for: cleaned) {
            openResultsTemporarilyForCategory(matched)
        } else {
            showNoResultsAlert()
        }
    }

    /// The core requirement: show category results BUT do NOT persist category into filters.
    /// We do a temporary write so Results can read it, then restore when coming back.
    private func openResultsTemporarilyForCategory(_ category: String) {
        var filters = FiltersStore.load()

        // Save the original categories so we can restore later
        originalCategoriesBeforeTempSearch = filters.selectedCategories
        shouldRestoreCategoriesAfterReturn = true

        // Apply temporary category ONLY
        filters.selectedCategories = [category]
        FiltersStore.save(filters)

        openSearchResults()
    }

    // MARK: - Navigation (code-only)

    private func openSearchResults() {
        guard let vc = storyboard?.instantiateViewController(withIdentifier: "SearchResultViewController") as? SearchResultViewController else {
            showSimpleAlert(title: "Error", message: "Missing storyboard ID: SearchResultViewController")
            return
        }

        if let nav = navigationController {
            nav.pushViewController(vc, animated: true)
        } else {
            let nav = UINavigationController(rootViewController: vc)
            nav.modalPresentationStyle = .fullScreen
            present(nav, animated: true)
        }
    }

    // MARK: - Matching (aliases + small typo tolerance)

    private func matchCategory(for input: String) -> String? {
        let q = normalize(input)
        guard !q.isEmpty else { return nil }

        if let alias = categoryAliases[q] { return alias }

        if let prefixHit = knownCategories.first(where: { normalize($0).hasPrefix(q) }) {
            return prefixHit
        }
        if let containsHit = knownCategories.first(where: { normalize($0).contains(q) }) {
            return containsHit
        }

        // Small typo tolerance (<=2)
        let candidates = knownCategories.map { ($0, normalize($0)) }
        var best: (cat: String, dist: Int)?

        for (cat, norm) in candidates {
            let d = levenshtein(q, norm)
            if best == nil || d < best!.dist {
                best = (cat, d)
            }
        }

        if let best, best.dist <= 2 { return best.cat }
        return nil
    }

    private func normalize(_ s: String) -> String {
        let lowered = s.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)
        return String(lowered.filter { $0.isLetter || $0.isNumber })
    }

    private func levenshtein(_ a: String, _ b: String) -> Int {
        let aChars = Array(a)
        let bChars = Array(b)
        let n = aChars.count
        let m = bChars.count
        if n == 0 { return m }
        if m == 0 { return n }

        var dp = Array(repeating: Array(repeating: 0, count: m + 1), count: n + 1)
        for i in 0...n { dp[i][0] = i }
        for j in 0...m { dp[0][j] = j }

        for i in 1...n {
            for j in 1...m {
                let cost = (aChars[i - 1] == bChars[j - 1]) ? 0 : 1
                dp[i][j] = min(
                    dp[i - 1][j] + 1,
                    dp[i][j - 1] + 1,
                    dp[i - 1][j - 1] + cost
                )
            }
        }
        return dp[n][m]
    }

    // MARK: - Alerts

    private func showNoResultsAlert() {
        showSimpleAlert(title: "No Results", message: "No results available for this search.")
    }

    private func showSimpleAlert(title: String, message: String) {
        let ac = UIAlertController(title: title, message: message, preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: "OK", style: .default))
        present(ac, animated: true)
    }

    // MARK: - Filters segue (ONLY place filters should persist)

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toFilters",
           let vc = segue.destination as? FiltersViewController {

            vc.filters = currentFilters

            // ✅ This is the ONLY path that persists filters (as you requested)
            vc.onApply = { [weak self] updated in
                guard let self else { return }
                self.currentFilters = updated
                FiltersStore.save(updated)
            }

            vc.onReset = { [weak self] in
                guard let self else { return }
                self.currentFilters = SearchFilters()
                FiltersStore.clear()
            }
        }
    }
}

// MARK: - UISearchBarDelegate

extension SearchServiceViewController: UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        // Same behavior as Search button
        searchTapped(UIButton())
    }
}

// MARK: - UITableViewDataSource / UITableViewDelegate

extension SearchServiceViewController: UITableViewDataSource, UITableViewDelegate {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        recentSearches.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "RecentSearchCell", for: indexPath)
        cell.textLabel?.text = recentSearches[indexPath.row]
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let term = recentSearches[indexPath.row]
        searchBar.text = term
        runSearch(term: term)
    }
}
