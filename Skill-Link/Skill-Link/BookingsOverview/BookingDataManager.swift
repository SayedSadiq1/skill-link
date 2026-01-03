//
//  BookingDataManager.swift
//  Skill-Link
//
//  Created by BP-36-201-21 on 28/12/2025.
//

import Foundation

class BookingDataManager {
    static let shared = BookingDataManager()
    private init() {}
    
    private var allBookings: [Booking] = [] // Your initial data here
    
    // CRUD Operations
    func getAllBookings() -> [Booking] {
        return allBookings
    }
    
    func getBookings(for state: BookedServiceStatus) -> [Booking] {
        return allBookings.filter { $0.status == state }
    }
    
    func updateBookingState(serviceId: String, newState: BookedServiceStatus) {
        if let index = allBookings.firstIndex(where: { $0.serviceId == serviceId }) {
            // Create a mutable copy
            var booking = allBookings[index]
            booking.status = newState
            allBookings[index] = booking
            
            // Notify observers (tabs) of the change
            NotificationCenter.default.post(
                name: .bookingDataDidChange,
                object: nil
            )
        }
    }
    
    // Add initial data
    func setInitialData(_ bookings: [Booking]) {
        self.allBookings = bookings
    }
}

// Notification name
extension Notification.Name {
    static let bookingDataDidChange = Notification.Name("bookingDataDidChange")
}
