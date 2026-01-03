//
//  FirebaseService.swift
//  Skill-Link
//
//  Created by BP-36-201-23 on 27/12/2025.
//

import Foundation
import FirebaseAuth
import FirebaseFirestore

// Handles firebase auth and user data calls
final class FirebaseService {

    // Shared instance used everywhere
    static let shared = FirebaseService()

    // Private init to block new instances
    private init() {}

    // Firestore database reference
    private let db = Firestore.firestore()

    // Sign in user using email and password
    func signIn(email: String, password: String, completion: @escaping (Result<User, Error>) -> Void) {
        Auth.auth().signIn(withEmail: email, password: password) { result, error in
            if let error = error {
                completion(.failure(error))
                return
            }

            // Make sure user object exist
            guard let user = result?.user else {
                completion(.failure(NSError(domain: "Auth", code: -1)))
                return
            }

            // Return signed in user
            completion(.success(user))
        }
    }

    // Fetch user profile from firestore
    func fetchUserProfile(uid: String, completion: @escaping (Result<UserProfile, Error>) -> Void) {
        db.collection("User").document(uid).getDocument { snapshot, error in
            if let error = error {
                completion(.failure(error))
                return
            }

            // Check if document exist
            guard let snapshot = snapshot, snapshot.exists else {
                completion(.failure(
                    NSError(
                        domain: "Profile",
                        code: 404,
                        userInfo: [NSLocalizedDescriptionKey: "Profile not found"]
                    )
                ))
                return
            }

            // Log raw firestore data for debug
            print("Raw Firestore data for user \(uid): \(snapshot.data() ?? [:])")

            do {
                // Decode snapshot into user profile model
                let profile = try snapshot.data(as: UserProfile.self)
                completion(.success(profile))
            } catch {
                // Return decoding error if mapping fails
                completion(.failure(error))
            }
        }
    }
}
