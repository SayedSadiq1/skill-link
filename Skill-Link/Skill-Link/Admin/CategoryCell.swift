//
//  CategoryCell.swift
//  Skill-Link
//
//  Created by sayed sadiq on 24/12/2025.
//

import UIKit

class CategoryCell: UITableViewCell {

    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var editButton: UIButton!
    @IBOutlet weak var deleteButton: UIButton!

    var onEditTapped: (() -> Void)?
    var onDeleteTapped: (() -> Void)?

    @IBAction func editTapped(_ sender: UIButton) {
        onEditTapped?()
    }

    @IBAction func deleteTapped(_ sender: UIButton) {
        onDeleteTapped?()
    }
}
