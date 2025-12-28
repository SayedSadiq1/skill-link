//
//  BookedService.swift
//  Skill-Link
//
//  Created by BP-36-201-21 on 25/12/2025.
//

import Foundation

class Booking {
    var service: BookedService
    let user: UserProfile
    let provider: UserProfile
    
    init(service: BookedService, user: UserProfile, provider: UserProfile) {
        self.service = service
        self.user = user
        self.provider = provider
    }
}

class BookedService {
    let id: UUID = UUID.init()
    var state: BookedServiceStatus
    let title: String
    let date: Date
    let time: String
    let location: String
    let totalPrice: Double
    
    init(state: BookedServiceStatus, title: String, date: Date, time: String, location: String, totalPrice: Double) {
        self.state = state
        self.title = title
        self.date = date
        self.time = time
        self.location = location
        self.totalPrice = totalPrice
    }
}

enum BookedServiceStatus: String {
    case Pending
    case Upcoming
    case Completed
    case Canceled
}
