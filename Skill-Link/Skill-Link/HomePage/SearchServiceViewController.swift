//
//  SearchServiceViewController.swift
//  Skill-Link
//
//  Created by BP-36-201-14 on 28/12/2025.
//

import UIKit
import FirebaseFirestore

final class SearchServiceViewController: BaseViewController {

    // MARK: - Outlets
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var recentTableView: UITableView!
    @IBOutlet weak var suggestedContainer: UIView!   // ✅ add this outlet

    // MARK: - State
    private var currentFilters: SearchFilters = FiltersStore.load()
    private var recentSearches: [String] = []

    // Temporary category search restore
    private var shouldRestoreCategoriesAfterReturn = false
    private var originalCategoriesBeforeTempSearch: [String]?

    // ✅ Categories fetched from Firebase (no hardcoding)
    private var firestoreCategories: [String] = []

    // Firestore
    private let db = Firestore.firestore()

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
        fetchCategoriesAndBuildSuggestedButtons()
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

    // MARK: - Firebase Categories

    private func fetchCategoriesAndBuildSuggestedButtons() {
        // metadata/service_categories { categories: [...] }
        db.collection("metadata")
            .document("service_categories")
            .getDocument { [weak self] snap, err in
                guard let self else { return }

                if let err {
                    self.showSimpleAlert(title: "Firebase Error", message: err.localizedDescription)
                    return
                }

                let arr = snap?.data()?["categories"] as? [String] ?? []
                // Clean + stable ordering
                self.firestoreCategories = arr
                    .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
                    .filter { !$0.isEmpty }
                    .sorted()

                self.buildSuggestedButtons()
            }
    }

    private func buildSuggestedButtons() {
        // Clear previous buttons
        suggestedContainer.subviews.forEach { $0.removeFromSuperview() }

        // Choose what to show (simple: first 4)
        let suggested = Array(firestoreCategories.prefix(4))
        guard !suggested.isEmpty else { return }

        // Layout: 2 rows x 2 columns using vertical stack of horizontal stacks
        let vStack = UIStackView()
        vStack.axis = .vertical
        vStack.distribution = .fillEqually
        vStack.spacing = 12
        vStack.translatesAutoresizingMaskIntoConstraints = false

        suggestedContainer.addSubview(vStack)
        NSLayoutConstraint.activate([
            vStack.leadingAnchor.constraint(equalTo: suggestedContainer.leadingAnchor),
            vStack.trailingAnchor.constraint(equalTo: suggestedContainer.trailingAnchor),
            vStack.topAnchor.constraint(equalTo: suggestedContainer.topAnchor),
            vStack.bottomAnchor.constraint(equalTo: suggestedContainer.bottomAnchor)
        ])

        var idx = 0
        while idx < suggested.count {
            let hStack = UIStackView()
            hStack.axis = .horizontal
            hStack.distribution = .fillEqually
            hStack.spacing = 12

            let leftTitle = suggested[idx]
            let leftBtn = makeSuggestedButton(title: leftTitle)
            hStack.addArrangedSubview(leftBtn)
            idx += 1

            if idx < suggested.count {
                let rightTitle = suggested[idx]
                let rightBtn = makeSuggestedButton(title: rightTitle)
                hStack.addArrangedSubview(rightBtn)
                idx += 1
            } else {
                // Fill empty slot if odd count
                let spacer = UIView()
                hStack.addArrangedSubview(spacer)
            }

            vStack.addArrangedSubview(hStack)
        }
    }

    private func makeSuggestedButton(title: String) -> UIButton {
        let b = UIButton(type: .system)
        b.setTitle(title, for: .normal)
        b.setTitleColor(.black, for: .normal)
        b.backgroundColor = UIColor(white: 0.90, alpha: 1.0)
        b.layer.cornerRadius = 8
        b.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        b.addTarget(self, action: #selector(suggestedButtonPressed(_:)), for: .touchUpInside)
        return b
    }

    @objc private func suggestedButtonPressed(_ sender: UIButton) {
        let title = (sender.title(for: .normal) ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
        guard !title.isEmpty else { return }
        openResultsTemporarilyForCategory(title)
    }

    // MARK: - IBActions

    @IBAction func filtersTapped(_ sender: UIButton) {
        performSegue(withIdentifier: "toFilters", sender: self)
    }

    /// Search button behavior:
    /// - If empty text: open results (using current saved filters if any; otherwise all)
    /// - If text typed: save to recents always, match to category; if matched show results TEMPORARILY (no persistence)
    @IBAction func searchTapped(_ sender: UIButton) {
        searchBar.resignFirstResponder()

        let term = (searchBar.text ?? "").trimmingCharacters(in: .whitespacesAndNewlines)

        // If user didn't type, just open results (don't modify filters)
        if term.isEmpty {
            openSearchResults()
            return
        }

        runSearch(term: term)
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

    /// Show category results BUT do NOT persist category into filters.
    private func openResultsTemporarilyForCategory(_ category: String) {
        var filters = FiltersStore.load()

        // Save original categories so we can restore later
        originalCategoriesBeforeTempSearch = filters.selectedCategories
        shouldRestoreCategoriesAfterReturn = true

        // Temporary category ONLY
        filters.selectedCategories = [category]
        FiltersStore.save(filters)

        openSearchResults()
    }

    // MARK: - Navigation

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

    // MARK: - Matching (Firebase categories + typo tolerance)

    private func matchCategory(for input: String) -> String? {
        let q = normalize(input)
        guard !q.isEmpty else { return nil }

        // If categories not loaded yet, fail safely
        guard !firestoreCategories.isEmpty else { return nil }

        // Exact / prefix / contains on normalized strings
        if let exact = firestoreCategories.first(where: { normalize($0) == q }) { return exact }
        if let prefix = firestoreCategories.first(where: { normalize($0).hasPrefix(q) }) { return prefix }
        if let contains = firestoreCategories.first(where: { normalize($0).contains(q) }) { return contains }

        // Typo tolerance: choose closest if very near
        var best: (cat: String, dist: Int)?
        for cat in firestoreCategories {
            let d = levenshtein(q, normalize(cat))
            if best == nil || d < best!.dist {
                best = (cat, d)
            }
        }

        // Safe threshold: <=2 to avoid gibberish matching
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

    // MARK: - Filters segue (ONLY place filters persist)

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toFilters",
           let vc = segue.destination as? FiltersViewController {

            vc.filters = currentFilters

            // ✅ ONLY this path persists filters
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
