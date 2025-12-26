//
//  BookedService.swift
//  Skill-Link
//
//  Created by BP-36-201-21 on 25/12/2025.
//

import Foundation

struct Booking {
    let service: BookedService
    let user: UserProfile
    let provider: UserProfile
}

struct BookedService {
    let id: UUID = UUID.init()
    let state: BookedServiceStatus
    let title: String
    let date: Date
    let time: String
    let location: String
    let totalPrice: Double
}

enum BookedServiceStatus: String {
    case Pending
    case Upcoming
    case Completed
    case Canceled
}
