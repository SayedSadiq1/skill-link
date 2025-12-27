//
//  TransactionsController.swift
//  Skill-Link
//
//  Created by Sayed on 27/12/2025.
//

import FirebaseFirestore
import FirebaseAuth

final class TransactionsController {
    static let shared = TransactionsController()
    private init() {}

    func getTransactions(id: String) async throws -> [Transaction] {

        let currentUser = try await Firestore.firestore()
            .collection("User")
            .document(id)
            .getDocument()

        let transactionsData = currentUser.data()?["transactions"] as? [[String: Any]] ?? []

        return transactionsData.compactMap { item in
            guard
                let amount = item["amount"] as? Double,
                let serviceName = item["serviceName"] as? String,
                let method = item["method"] as? String,
                let ts = item["createdAt"] as? Timestamp
            else {
                return nil
            }
            return Transaction(
                amount: amount,
                serviceName: serviceName,
                method: method,
                createdAt: ts.dateValue()
            )
        }
    }
    
    func createTransaction(id: String, transaction: Transaction) async throws {
        let currentUser = Firestore.firestore().collection("User").document(id)
        
        let newTransaction: [String: Any] = [
            "amount" : transaction.amount,
            "createdAt" : Date(),
            "method" : transaction.method,
            "serviceName" : transaction.serviceName
        ]
        
        do{
            try await currentUser.updateData([
                "transactions" : FieldValue.arrayUnion([newTransaction])
            ])
        }
    }
    
}

