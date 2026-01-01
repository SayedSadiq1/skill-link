import FirebaseFirestore

class ServiceManager {
    private let db = Firestore.firestore()
    private let collectionName = "services"
    
    // MARK: - Save Service
    func saveService(_ service: Service, completion: @escaping (Result<String, Error>) -> Void) {
        do {
            var serviceToSave = service
            if service.id == nil {
                serviceToSave.id = UUID().uuidString
            }
            
            let documentRef = db.collection(collectionName).document(serviceToSave.id!)
            try documentRef.setData(from: serviceToSave) { error in
                if let error = error {
                    completion(.failure(error))
                } else {
                    completion(.success(serviceToSave.id!))
                }
            }
        } catch {
            completion(.failure(error))
        }
    }
    
    // MARK: - Update Service
    func updateService(_ service: Service, completion: @escaping (Result<Void, Error>) -> Void) {
        guard let documentID = service.id else {
            completion(.failure(NSError(domain: "", code: 400, userInfo: [NSLocalizedDescriptionKey: "Service must have an ID to update"])))
            return
        }
        
        do {
            let documentRef = db.collection(collectionName).document(documentID)
            try documentRef.setData(from: service) { error in
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
    
    // MARK: - Fetch Single Service
    func fetchService(by id: String, completion: @escaping (Result<Service, Error>) -> Void) {
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
                let service = try snapshot.data(as: Service.self)
                completion(.success(service))
            } catch {
                completion(.failure(error))
            }
        }
    }
    
    // MARK: - Fetch All Services
    func fetchAllServices(completion: @escaping (Result<[Service], Error>) -> Void) {
        db.collection(collectionName).getDocuments { snapshot, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let documents = snapshot?.documents else {
                completion(.success([]))
                return
            }
            
            let services = documents.compactMap { doc -> Service? in
                try? doc.data(as: Service.self)
            }
            completion(.success(services))
        }
    }
}
