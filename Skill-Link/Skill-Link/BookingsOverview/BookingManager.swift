//
//  BookingManager.swift
//  Skill-Link
//
//  Created by BP-36-201-21 on 03/01/2026.
//

import Foundation
import FirebaseFirestore

class BookingManager {
    private let db = Firestore.firestore()
    private let collectionName = "bookings"
    
    // MARK: - Save Booking
    func saveBooking(_ booking: Booking, completion: @escaping (Result<String, Error>) -> Void) {
        do {
            // Generate document ID if new
            let documentID = UUID().uuidString
            let documentRef = db.collection(collectionName).document(documentID)
            
            try documentRef.setData(from: booking) { error in
                if let error = error {
                    completion(.failure(error))
                } else {
                    completion(.success(documentID))
                }
            }
        } catch {
            completion(.failure(error))
        }
    }
    
    // MARK: - Fetch Single Booking
    func fetchBooking(by id: String, completion: @escaping (Result<Booking, Error>) -> Void) {
        db.collection(collectionName).document(id).getDocument { snapshot, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let snapshot = snapshot, snapshot.exists else {
                completion(.failure(NSError(domain: "", code: 404,
                                            userInfo: [NSLocalizedDescriptionKey: "Booking not found"])))
                return
            }
            
            do {
                let booking = try snapshot.data(as: Booking.self)
                completion(.success(booking))
            } catch {
                completion(.failure(error))
            }
        }
    }
    
    // MARK: - Fetch Bookings for User (Customer)
    func fetchBookingsForUser(_ userId: String, completion: @escaping (Result<[Booking], Error>) -> Void) {
        db.collection(collectionName)
            .whereField("userId", isEqualTo: userId)
            .order(by: "date", descending: true)
            .getDocuments { snapshot, error in
                if let error = error {
                    completion(.failure(error))
                    return
                }
                
                let bookings = snapshot?.documents.compactMap { doc -> Booking? in
                    try? doc.data(as: Booking.self)
                } ?? []
                
                completion(.success(bookings))
            }
    }
    
    // MARK: - Fetch Bookings for Provider
    func fetchBookingsForProvider(_ providerId: String, completion: @escaping (Result<[Booking], Error>) -> Void) {
        db.collection(collectionName)
            .whereField("providerId", isEqualTo: providerId)
            .order(by: "date", descending: true)
            .getDocuments { snapshot, error in
                if let error = error {
                    completion(.failure(error))
                    return
                }
                
                let bookings = snapshot?.documents.compactMap { doc -> Booking? in
                    try? doc.data(as: Booking.self)
                } ?? []
                
                completion(.success(bookings))
            }
    }
    
    // MARK: - Update Booking Status
    func updateBookingStatus(_ bookingId: String, status: BookedServiceStatus, completion: @escaping (Result<Void, Error>) -> Void) {
        db.collection(collectionName).document(bookingId).updateData([
            "status": status.rawValue
        ]) { error in
            if let error = error {
                completion(.failure(error))
            } else {
                completion(.success(()))
            }
        }
    }
    
    // MARK: - Full Update Booking
    func updateBooking(_ booking: Booking, completion: @escaping (Result<Void, Error>) -> Void) {
        guard let bookingId = booking.id else {
            completion(.failure(NSError(domain: "", code: 400,
                                        userInfo: [NSLocalizedDescriptionKey: "Booking must have an ID"])))
            return
        }
        
        do {
            let documentRef = db.collection(collectionName).document(bookingId)
            try documentRef.setData(from: booking, merge: true) { error in
                if let error = error {
                    completion(.failure(error))
                } else {
                    completion(.success(()))
                }
            }
        } catch {
            completion(.failure(error))
        }
    }
}
