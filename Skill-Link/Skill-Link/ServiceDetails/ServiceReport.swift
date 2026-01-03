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
    var userName: String
    var reason: String
    let reportedAt: Date
    var status: ServiceReportStatus
    
    init(reportId: String? = nil, serviceName: String, userName: String, reason: String, reportedAt: Date = Date.now) {
        self.id = reportId
        self.serviceName = serviceName
        self.userName = userName
        self.reason = reason
        self.reportedAt = reportedAt
        self.status = .Pending
    }
}

enum ServiceReportStatus: String, Codable {
    case Pending
    case Resolved
    case Dismissed
}
