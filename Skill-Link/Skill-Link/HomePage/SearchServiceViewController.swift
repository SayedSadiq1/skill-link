//
//  SearchServiceViewController.swift
//  Skill-Link
//
//  Created by BP-36-201-14 on 28/12/2025.
//
import UIKit
import FirebaseFirestore

final class SearchServiceViewController: BaseViewController {

    // MARK: - Outlets (Changed to ? to stop the Fatal Error)
    @IBOutlet weak var searchBar: UISearchBar?
    @IBOutlet weak var recentTableView: UITableView?
    @IBOutlet weak var suggestedContainer: UIView?

    // MARK: - State
    private var currentFilters: SearchFilters = FiltersStore.load()
    private var recentSearches: [String] = []

    private var shouldRestoreCategoriesAfterReturn = false
    private var originalCategoriesBeforeTempSearch: [String]?

    private var firestoreCategories: [String] = []
    private let db = Firestore.firestore()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Final guard: If this prints, your outlets are not connected in Storyboard
        guard let searchBar = searchBar,
              let recentTableView = recentTableView,
              let suggestedContainer = suggestedContainer else {
            print("⚠️ SearchServiceViewController loaded, but outlets are nil. Check Storyboard connections.")
            return
        }

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
        recentTableView?.reloadData()
    }

    private func fetchCategoriesAndBuildSuggestedButtons() {
        db.collection("metadata")
            .document("service_categories")
            .getDocument { [weak self] snap, err in
                guard let self else { return }

                if let err {
                    print("Firebase Error: \(err.localizedDescription)")
                    return
                }

                let arr = snap?.data()?["categories"] as? [String] ?? []
                self.firestoreCategories = arr
                    .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
                    .filter { !$0.isEmpty }
                    .sorted()

                self.buildSuggestedButtons()
            }
    }

    private func buildSuggestedButtons() {
        guard let suggestedContainer = suggestedContainer else { return }
        suggestedContainer.subviews.forEach { $0.removeFromSuperview() }

        let suggested = Array(firestoreCategories.prefix(4))
        guard !suggested.isEmpty else { return }

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
                hStack.addArrangedSubview(UIView())
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

    @IBAction func filtersTapped(_ sender: UIButton) {
        performSegue(withIdentifier: "toFilters", sender: self)
    }

    @IBAction func searchTapped(_ sender: UIButton) {
        searchBar?.resignFirstResponder()
        let term = (searchBar?.text ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
        if term.isEmpty {
            openSearchResults()
            return
        }
        runSearch(term: term)
    }

    private func runSearch(term: String) {
        let cleaned = term.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !cleaned.isEmpty else { return }

        RecentSearchesStore.shared.add(cleaned)
        reloadRecents()

        if let matched = matchCategory(for: cleaned) {
            openResultsTemporarilyForCategory(matched)
        } else {
            showNoResultsAlert()
        }
    }

    private func openResultsTemporarilyForCategory(_ category: String) {
        var filters = FiltersStore.load()
        originalCategoriesBeforeTempSearch = filters.selectedCategories
        shouldRestoreCategoriesAfterReturn = true
        filters.selectedCategories = [category]
        FiltersStore.save(filters)
        openSearchResults()
    }

    private func openSearchResults() {
        guard let vc = storyboard?.instantiateViewController(withIdentifier: "SearchResultViewController") as? SearchResultViewController else {
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

    private func matchCategory(for input: String) -> String? {
        let q = normalize(input)
        if q.isEmpty || firestoreCategories.isEmpty { return nil }

        if let exact = firestoreCategories.first(where: { normalize($0) == q }) { return exact }
        if let prefix = firestoreCategories.first(where: { normalize($0).hasPrefix(q) }) { return prefix }
        if let contains = firestoreCategories.first(where: { normalize($0).contains(q) }) { return contains }

        var best: (cat: String, dist: Int)?
        for cat in firestoreCategories {
            let d = levenshtein(q, normalize(cat))
            if best == nil || d < best!.dist { best = (cat, d) }
        }
        if let best, best.dist <= 2 { return best.cat }
        return nil
    }

    private func normalize(_ s: String) -> String {
        let lowered = s.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)
        return String(lowered.filter { $0.isLetter || $0.isNumber })
    }

    private func levenshtein(_ a: String, _ b: String) -> Int {
        let aChars = Array(a), bChars = Array(b)
        let n = aChars.count, m = bChars.count
        if n == 0 { return m }
        if m == 0 { return n }

        var dp = Array(repeating: Array(repeating: 0, count: m + 1), count: n + 1)
        for i in 0...n { dp[i][0] = i }
        for j in 0...m { dp[0][j] = j }

        for i in 1...n {
            for j in 1...m {
                let cost = (aChars[i - 1] == bChars[j - 1]) ? 0 : 1
                dp[i][j] = min(dp[i - 1][j] + 1, dp[i][j - 1] + 1, dp[i - 1][j - 1] + cost)
            }
        }
        return dp[n][m]
    }

    private func showNoResultsAlert() {
        let ac = UIAlertController(title: "No Results", message: "No results available for this search.", preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: "OK", style: .default))
        present(ac, animated: true)
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toFilters",
           let vc = segue.destination as? FiltersViewController {
            vc.filters = currentFilters
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

extension SearchServiceViewController: UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchTapped(UIButton())
    }
}

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
        searchBar?.text = term
        runSearch(term: term)
    }
}
