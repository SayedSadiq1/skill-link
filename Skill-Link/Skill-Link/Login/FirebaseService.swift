//
//  FirebaseService.swift
//  Skill-Link
//
//  Created by BP-36-201-23 on 27/12/2025.
//


import Foundation
import FirebaseAuth
import FirebaseFirestore

final class FirebaseService {
    static let shared = FirebaseService()
    private init() {}

    private let db = Firestore.firestore()

    func signIn(email: String, password: String, completion: @escaping (Result<User, Error>) -> Void) {
        Auth.auth().signIn(withEmail: email, password: password) { result, error in
            if let error = error { completion(.failure(error)); return }
            guard let user = result?.user else {
                completion(.failure(NSError(domain: "Auth", code: -1)))
                return
            }
            completion(.success(user))
        }
    }

    func fetchUserProfile(uid: String, completion: @escaping (Result<UserProfile, Error>) -> Void) {
        db.collection("users").document(uid).getDocument { snap, error in
            if let error = error { completion(.failure(error)); return }
            guard let data = snap?.data() else {
                completion(.failure(NSError(domain: "Profile", code: 404, userInfo: [NSLocalizedDescriptionKey: "Profile not found"])))
                return
            }

            do {
                let json = try JSONSerialization.data(withJSONObject: data)
                let profile = try JSONDecoder().decode(UserProfile.self, from: json)
                completion(.success(profile))
            } catch {
                completion(.failure(error))
            }
        }
    }
}
