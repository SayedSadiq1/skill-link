//
//  ServiceReportManager.swift
//  Skill-Link
//
//  Created by BP-36-212-19 on 03/01/2026.
//

import Foundation
import FirebaseFirestore

class ServiceReportManager {
    private let db = Firestore.firestore()
    private let collectionName = "Report"
    
    // MARK: - Save Report
    func saveReport(_ report: ServiceReport, completion: @escaping (Result<String, Error>) -> Void) {
        do {
            let reportToSave = report
            if report.id == nil {
                reportToSave.id = UUID().uuidString
            }
            
            let documentRef = db.collection(collectionName).document(reportToSave.id!)
            try documentRef.setData(from: reportToSave) { error in
                if let error = error {
                    completion(.failure(error))
                } else {
                    completion(.success(reportToSave.id!))
                }
            }
        } catch {
            completion(.failure(error))
        }
    }
    
    // MARK: - Get Report By Id
    func fetchReport(by id: String, completion: @escaping (Result<ServiceReport, Error>) -> Void) {
        db.collection(collectionName).document(id).getDocument { snapshot, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let snapshot = snapshot, snapshot.exists else {
                completion(.failure(NSError(domain: "", code: 404, userInfo: [NSLocalizedDescriptionKey: "Service not found"])))
                return
            }
            
            do {
                let report = try snapshot.data(as: ServiceReport.self)
                completion(.success(report))
            } catch {
                completion(.failure(error))
            }
        }
    }
    
    // MARK: - Get All Reports
    func fetchAllReports(completion: @escaping (Result<[ServiceReport], Error>) -> Void) {
        db.collection(collectionName).getDocuments { snapshot, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let documents = snapshot?.documents else {
                completion(.success([]))
                return
            }
            
            let reports = documents.compactMap { doc -> ServiceReport? in
                try? doc.data(as: ServiceReport.self)
            }
            completion(.success(reports))
        }
    }
}
