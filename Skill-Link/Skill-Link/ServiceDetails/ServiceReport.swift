//
//  ServiceReport.swift
//  Skill-Link
//
//  Created by BP-36-212-19 on 03/01/2026.
//

import Foundation
import FirebaseFirestore

class ServiceReport: Codable {
    @DocumentID<String> var id: String?
    var serviceName: String
    var providerId: String
    var userName: String
    var reason: String
    let reportedAt: Date
    var status: ServiceReportStatus
    
    init(id: String? = nil, serviceName: String, providerId: String, userName: String, reason: String, reportedAt: Date, status: ServiceReportStatus = .Pending) {
        self.id = id
        self.serviceName = serviceName
        self.providerId = providerId
        self.userName = userName
        self.reason = reason
        self.reportedAt = reportedAt
        self.status = status
    }
}

enum ServiceReportStatus: String, Codable {
    case Pending
    case Resolved
    case Dismissed
}
