//
//  RateFormController.swift
//  Skill-Link
//
//  Created by Sayed on 20/12/2025.
//

import UIKit
import FirebaseAuth
import FirebaseFirestore

final class RateFormController: BaseViewController {

    @IBOutlet weak var reviewField: UITextView!
    @IBOutlet weak var submitButton: UIButton!

    @IBOutlet weak var star1: UIButton!
    @IBOutlet weak var star2: UIButton!
    @IBOutlet weak var star3: UIButton!
    @IBOutlet weak var star4: UIButton!
    @IBOutlet weak var star5: UIButton!

    private let db = Firestore.firestore()

    var serviceID: String?

    private var userName: String = ""
    private var rating: Int = 0

    private var stars: [UIButton] { [star1, star2, star3, star4, star5] }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        loadUserName()
        print("✅ RateFormController received serviceID:", serviceID ?? "nil")
    }

    private func setupUI() {
        reviewField.layer.cornerRadius = 24
        reviewField.layer.borderWidth = 2
        reviewField.layer.borderColor = UIColor.black.cgColor

        submitButton.backgroundColor = UIColor(hex: "#182E61")
        submitButton.layer.cornerRadius = 12

        setStarsImage(buttonNumber: 0)
    }

    private func loadUserName() {
        guard let uid = Auth.auth().currentUser?.uid else { return }

        Task { [weak self] in
            guard let self else { return }
            let name = await getUserField(from: uid, field: "fullName") as? String
            await MainActor.run {
                self.userName = name ?? ""
                print("✅ Username:", self.userName)
            }
        }
    }

    private func getUserField(from userID: String, field: String) async -> Any? {
        do {
            let doc = try await db.collection("User").document(userID).getDocument()
            return doc.data()?[field]
        } catch {
            print("❌ Error fetching user field: \(error)")
            return nil
        }
    }

    // MARK: - Stars
    private func setStarsImage(buttonNumber: Int) {
        for i in 0..<5 {
            let imageName = i < buttonNumber ? "starfill" : "star"
            stars[i].setImage(UIImage(named: imageName), for: .normal)
        }
        rating = buttonNumber
    }

    @IBAction func buttonTapped(_ sender: UIButton) {
        guard let index = stars.firstIndex(of: sender) else { return }
        setStarsImage(buttonNumber: index + 1)
    }

    // MARK: - Submit
    @IBAction func submitTapped(_ sender: UIButton) {
        guard let serviceID = serviceID, !serviceID.isEmpty else {
            showAlert("Missing Service ID")
            return
        }

        guard rating > 0 else {
            showAlert("Please select a rating")
            return
        }

        let text = reviewField.text.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !text.isEmpty else {
            showAlert("Please write a review")
            return
        }

        submitButton.isEnabled = false

        Task { [weak self] in
            guard let self else { return }
            do {
                try await ReviewController.shared.makeReview(
                    senderName: self.userName,
                    ServiceID: serviceID,
                    content: text,
                    rating: self.rating
                )

                await MainActor.run {
                    self.navigationController?.popViewController(animated: true)
                }
            } catch {
                await MainActor.run {
                    self.submitButton.isEnabled = true
                    self.showAlert("Failed: \(error.localizedDescription)")
                }
            }
        }
    }

    private func showAlert(_ message: String) {
        let alert = UIAlertController(title: nil, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}
