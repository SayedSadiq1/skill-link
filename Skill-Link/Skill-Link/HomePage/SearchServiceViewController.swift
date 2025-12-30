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
        navigationItem.title = ""
        navigationController?.navigationBar.topItem?.title = ""
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        currentFilters = FiltersStore.load()
    }

    @IBAction func filtersTapped(_ sender: UIButton) {
        performSegue(withIdentifier: "toFilters", sender: nil)
    }

    @IBAction func searchTapped(_ sender: UIButton) {
        currentFilters = FiltersStore.load()

        // ✅ Push SearchResult without segue identifier
        let vc = storyboard?.instantiateViewController(withIdentifier: "SearchResultViewController") as! SearchResultViewController
        vc.currentFilters = currentFilters
        navigationController?.pushViewController(vc, animated: true)
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

            vc.onReset = { [weak self] in
                guard let self = self else { return }
                self.currentFilters = SearchFilters()
                FiltersStore.clear()
            }
        }
    }
}
