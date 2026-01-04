//
//  ServiceManager.swift
//  Skill-Link
//
//  Created by Sayed on 04/01/2026.
//

import FirebaseFirestore

final class ServiceFetcher {
    
    private let db = Firestore.firestore()

    func getServiceTitle(serviceId: String) async throws -> String {
        let snap = try await db.collection("Service").document(serviceId).getDocument()

        guard let data = snap.data(),
              let title = data["title"] as? String
        else {
            throw NSError(domain: "ServiceManager",
                          code: 404,
                          userInfo: [NSLocalizedDescriptionKey: "Service title not found"])
        }

        return title
    }
}
