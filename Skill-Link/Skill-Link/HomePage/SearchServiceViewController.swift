//
//  SearchServiceViewController.swift
//  Skill-Link
//
//  Created by BP-36-201-14 on 28/12/2025.
//





import UIKit

final class SearchServiceViewController: BaseViewController {

    private var currentFilters: SearchFilters = FiltersStore.load()

    override func viewDidLoad() {
        super.viewDidLoad()

        // ✅ Remove the white navigation bar title/area
        navigationItem.title = ""
        navigationController?.navigationBar.topItem?.title = ""

        // If you still see a bar, you can hide it completely:
        // navigationController?.setNavigationBarHidden(true, animated: false)
    }

    @IBAction func filtersTapped(_ sender: UIButton) {
        performSegue(withIdentifier: "toFilters", sender: nil)
    }

    @IBAction func searchTapped(_ sender: UIButton) {
        performSegue(withIdentifier: "toSearchResults", sender: nil)
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {

        if segue.identifier == "toFilters",
           let vc = segue.destination as? FiltersViewController {

            vc.filters = currentFilters

            vc.onApply = { [weak self] updated in
                guard let self = self else { return }
                self.currentFilters = updated
                FiltersStore.save(updated)
            }
        }

        if segue.identifier == "toSearchResults",
           let vc = segue.destination as? SearchResultViewController {

            vc.currentFilters = currentFilters

            // ✅ so SearchResult can notify SearchService when user removes a chip
            vc.onFiltersChanged = { [weak self] updated in
                self?.currentFilters = updated
                FiltersStore.save(updated)
            }
        }
    }
}
