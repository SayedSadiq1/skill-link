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
    
    
    
    // Add initial data
    func setInitialData(_ bookings: [Booking]) {
        self.allBookings = bookings
    }
}

// Notification name
extension Notification.Name {
    static let bookingDataDidChange = Notification.Name("bookingDataDidChange")
}
