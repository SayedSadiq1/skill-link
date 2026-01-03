//
//  BookedService.swift
//  Skill-Link
//
//  Created by BP-36-201-21 on 25/12/2025.
//

import Foundation
import FirebaseFirestore

class Booking: Codable {
    @DocumentID var id: String?
    var status: BookedServiceStatus
    let serviceId: String
    let userId: String
    let providerId: String
    let totalPrice: Double
    let location: String
    let date: Date
    let time: String
    
    init(status: BookedServiceStatus = .Pending, serviceId: String, userId: String, providerId: String, totalPrice: Double, location: String, date: Date, time: String) {
        self.status = status
        self.serviceId = serviceId
        self.userId = userId
        self.providerId = providerId
        self.totalPrice = totalPrice
        self.location = location
        self.date = date
        self.time = time
    }
}

enum BookedServiceStatus: String, Codable {
    case Pending
    case Upcoming
    case Completed
    case Canceled
}
