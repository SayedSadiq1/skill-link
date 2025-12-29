//
//  EditProfileSeekerViewController.swift
//  Skill-Link
//
//  Created by BP-36-201-23 on 28/12/2025.
//

import UIKit
import FirebaseAuth
import FirebaseFirestore

final class EditProfileSeekerViewController: BaseViewController {

    // ✅ ONLY 3 textfields
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var interestsTextField: UITextField!
    @IBOutlet weak var contactTextField: UITextField!

    // image
    @IBOutlet weak var profileImageView: UIImageView!

    var profile: SeekerProfile?
    var onSave: ((SeekerProfile) -> Void)?

    private let db = Firestore.firestore()
    private var photoPicker: PhotoPickerHelper?

    // Cloudinary (same as provider)
    private let cloudName = "dgamwyki7"
    private let uploadPreset = "mobile_unsigned"

    // image state
    private var selectedImageData: Data?
    private var selectedImageURL: String?

    private var isSaving = false

    override func viewDidLoad() {
        super.viewDidLoad()

        // ✅ style textfields (since no container views)
        styleTextField(nameTextField)
        styleTextField(interestsTextField)
        styleTextField(contactTextField)

        // ✅ image tap
        profileImageView.isUserInteractionEnabled = true
        profileImageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(changePhotoTapped)))

        guard let profile = profile else {
            print("❌ EditProfileSeekerViewController: profile is nil (not passed)")
            return
        }

        // fill fields
        nameTextField.text = profile.name
        interestsTextField.text = profile.interests.joined(separator: ", ")
        contactTextField.text = profile.contact

        // image
        selectedImageURL = profile.imageURL
        if let urlString = profile.imageURL, let url = URL(string: urlString) {
            loadImage(from: url)
        } else {
            profileImageView.image = UIImage(systemName: "person.circle.fill")
        }
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        profileImageView.layer.cornerRadius = profileImageView.frame.width / 2
        profileImageView.clipsToBounds = true
        profileImageView.contentMode = .scaleAspectFill
    }

    // MARK: - UITextField styling (no container needed)
    private func styleTextField(_ tf: UITextField) {
        tf.layer.cornerRadius = 8
        tf.layer.borderWidth = 1
        tf.layer.borderColor = UIColor.systemGray4.cgColor
        tf.backgroundColor = .white

        let padding = UIView(frame: CGRect(x: 0, y: 0, width: 12, height: 44))
        tf.leftView = padding
        tf.leftViewMode = .always
    }

    // MARK: - Photo picking
    @objc private func changePhotoTapped() {
        photoPicker = PhotoPickerHelper(presenter: self) { [weak self] image in
            guard let self else { return }
            self.profileImageView.image = image
            self.selectedImageData = image.jpegData(compressionQuality: 0.8)
        }
        photoPicker?.presentPicker()
    }

    // MARK: - Save
    @IBAction func saveTapped(_ sender: UIButton) {
        guard !isSaving else { return }
        guard let uid = Auth.auth().currentUser?.uid else {
            showAlert(title: "Error", message: "No logged in user. Please login again.")
            return
        }

        let fullName = nameTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        let contact = contactTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""

        let interestsArray = (interestsTextField.text ?? "")
            .split(separator: ",")
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { !$0.isEmpty }

        // ✅ validation
        if fullName.isEmpty { showAlert(title: "Missing", message: "Please enter your name."); return }
        if contact.isEmpty { showAlert(title: "Missing", message: "Please enter your contact."); return }
        if interestsArray.isEmpty { showAlert(title: "Missing", message: "Please enter at least one interest (separate by commas)."); return }

        isSaving = true
        setSavingUI(true)

        // 1) new image? upload -> save
        if let imgData = selectedImageData {
            uploadToCloudinary(imageData: imgData) { [weak self] result in
                guard let self else { return }

                switch result {
                case .success(let urlString):
                    self.selectedImageURL = urlString
                    self.saveToFirestore(uid: uid,
                                         fullName: fullName,
                                         contact: contact,
                                         interests: interestsArray,
                                         imageURL: urlString)
                case .failure(let error):
                    DispatchQueue.main.async {
                        self.isSaving = false
                        self.setSavingUI(false)
                        self.showAlert(title: "Upload Failed", message: error.localizedDescription)
                    }
                }
            }
        } else {
            // 2) no new image -> save
            saveToFirestore(uid: uid,
                            fullName: fullName,
                            contact: contact,
                            interests: interestsArray,
                            imageURL: selectedImageURL)
        }
    }

    // MARK: - Firestore save
    private func saveToFirestore(uid: String,
                                 fullName: String,
                                 contact: String,
                                 interests: [String],
                                 imageURL: String?) {

        var data: [String: Any] = [
            "fullName": fullName,
            "contact": contact,
            "interests": interests,
            "profileCompleted": true
        ]

        if let imageURL = imageURL, !imageURL.isEmpty {
            data["imageURL"] = imageURL
        }

        db.collection("User").document(uid).setData(data, merge: true) { [weak self] err in
            guard let self else { return }

            DispatchQueue.main.async {
                self.isSaving = false
                self.setSavingUI(false)

                if let err = err {
                    self.showAlert(title: "Error", message: "Failed to save profile: \(err.localizedDescription)")
                    return
                }

                let updated = SeekerProfile(
                    name: fullName,
                    interests: interests,
                    contact: contact,
                    imageURL: imageURL
                )

                self.onSave?(updated)
                self.navigationController?.popViewController(animated: true)
            }
        }
    }

    // MARK: - Image loader
    private func loadImage(from url: URL) {
        profileImageView.image = UIImage(systemName: "person.circle.fill")

        URLSession.shared.dataTask(with: url) { [weak self] data, _, _ in
            guard let self else { return }
            guard let data, let img = UIImage(data: data) else { return }
            DispatchQueue.main.async { self.profileImageView.image = img }
        }.resume()
    }

    // MARK: - Cloudinary upload (Unsigned)
    private func uploadToCloudinary(imageData: Data, completion: @escaping (Result<String, Error>) -> Void) {
        let url = URL(string: "https://api.cloudinary.com/v1_1/\(cloudName)/image/upload")!

        var request = URLRequest(url: url)
        request.httpMethod = "POST"

        let boundary = "Boundary-\(UUID().uuidString)"
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")

        var body = Data()
        func append(_ string: String) { body.append(string.data(using: .utf8)!) }

        append("--\(boundary)\r\n")
        append("Content-Disposition: form-data; name=\"upload_preset\"\r\n\r\n")
        append("\(uploadPreset)\r\n")

        append("--\(boundary)\r\n")
        append("Content-Disposition: form-data; name=\"file\"; filename=\"profile.jpg\"\r\n")
        append("Content-Type: image/jpeg\r\n\r\n")
        body.append(imageData)
        append("\r\n")
        append("--\(boundary)--\r\n")

        request.httpBody = body

        URLSession.shared.dataTask(with: request) { data, _, error in
            if let error = error { DispatchQueue.main.async { completion(.failure(error)) }; return }
            guard let data = data else { DispatchQueue.main.async { completion(.failure(NSError(domain: "NoData", code: -1))) }; return }

            do {
                let json = try JSONSerialization.jsonObject(with: data) as? [String: Any]
                if let secureURL = json?["secure_url"] as? String {
                    DispatchQueue.main.async { completion(.success(secureURL)) }
                } else {
                    let message = (json?["error"] as? [String: Any])?["message"] as? String ?? "Unknown Cloudinary error"
                    DispatchQueue.main.async {
                        completion(.failure(NSError(domain: "Cloudinary", code: -2,
                                                   userInfo: [NSLocalizedDescriptionKey: message])))
                    }
                }
            } catch {
                DispatchQueue.main.async { completion(.failure(error)) }
            }
        }.resume()
    }

    // MARK: - UI helpers
    private func setSavingUI(_ saving: Bool) {
        view.isUserInteractionEnabled = !saving
        if saving {
            navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Saving...", style: .plain, target: nil, action: nil)
        } else {
            navigationItem.rightBarButtonItem = nil
        }
    }

    private func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}
