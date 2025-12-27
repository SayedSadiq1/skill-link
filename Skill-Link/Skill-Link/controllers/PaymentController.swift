//
//  PaymentController.swift
//  Skill-Link
//
//  Created by Sayed on 26/12/2025.
//

import FirebaseFirestore

class PaymentController{
    static var shared = PaymentController()

    func addCard(id:String,cardHolderName:String,cardNumber:String,cvv:String)async throws{
        let currentUser = Firestore.firestore().collection("User").document(id)

            
        let newCard: [String: Any] = [
            "cardNumber" : cardNumber,
            "holderName" : cardHolderName,
            "cvv" : cvv
        ]
        
        do{
            try await currentUser.updateData([
                "cards" : FieldValue.arrayUnion([newCard])
            ])
        }
    }
    
    func getPaymentMethods(id:String) async throws ->[PaymentMethod]{
        
        let currentUser = try await Firestore.firestore()
            .collection("User")
            .document(id)
            .getDocument()
        
        let userCards = currentUser.data()?["cards"] as? [[String: Any]] ?? []

        return userCards.compactMap { item in
            guard
                let cardNumber = item["cardNumber"] as? String
            else { return nil }
            
            return PaymentMethod(
                name : cardNumber,
                imageName : "visa",
                destination : "confirmPayment"
            )
        }
    }
}
