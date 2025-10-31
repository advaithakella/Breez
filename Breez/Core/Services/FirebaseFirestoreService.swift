//
//  FirebaseFirestoreService.swift
//  Breez
//
//  Created by Advaith Akella on 9/19/25.
//

import Foundation
import FirebaseFirestore

@MainActor
class FirebaseFirestoreService: ObservableObject {
    static let shared = FirebaseFirestoreService()
    private let db = Firestore.firestore()
    
    // MARK: - Basic CRUD Operations
    
    func createDocument(_ data: [String: Any], in collection: String, documentID: String? = nil) async throws -> String {
        let docRef: DocumentReference
        
        if let documentID = documentID {
            docRef = db.collection(collection).document(documentID)
        } else {
            docRef = db.collection(collection).document()
        }
        
        try await docRef.setData(data)
        return docRef.documentID
    }
    
    func readDocument(from collection: String, documentID: String) async throws -> [String: Any] {
        let docRef = db.collection(collection).document(documentID)
        let document = try await docRef.getDocument()
        
        guard document.exists else {
            throw FirestoreError.documentNotFound
        }
        
        guard let data = document.data() else {
            throw FirestoreError.invalidData
        }
        
        return data
    }
    
    func updateDocument(_ data: [String: Any], in collection: String, documentID: String) async throws {
        let docRef = db.collection(collection).document(documentID)
        try await docRef.setData(data, merge: true)
    }
    
    func deleteDocument(from collection: String, documentID: String) async throws {
        let docRef = db.collection(collection).document(documentID)
        try await docRef.delete()
    }
    
    // MARK: - Query Operations
    
    func readDocuments(from collection: String, where field: String, isEqualTo value: Any) async throws -> [[String: Any]] {
        let query = db.collection(collection).whereField(field, isEqualTo: value)
        let snapshot = try await query.getDocuments()
        
        return snapshot.documents.compactMap { document in
            document.data()
        }
    }
    
    func readDocuments(from collection: String, where field: String, in values: [Any]) async throws -> [[String: Any]] {
        let query = db.collection(collection).whereField(field, in: values)
        let snapshot = try await query.getDocuments()
        
        return snapshot.documents.compactMap { document in
            document.data()
        }
    }
    
    func readDocuments(from collection: String, orderBy field: String, descending: Bool = false, limit: Int? = nil) async throws -> [[String: Any]] {
        var query = db.collection(collection).order(by: field, descending: descending)
        
        if let limit = limit {
            query = query.limit(to: limit)
        }
        
        let snapshot = try await query.getDocuments()
        
        return snapshot.documents.compactMap { document in
            document.data()
        }
    }
    
    // MARK: - Real-time Listeners
    
    func listenToDocument(from collection: String, documentID: String, completion: @escaping (Result<[String: Any], Error>) -> Void) -> ListenerRegistration {
        let docRef = db.collection(collection).document(documentID)
        
        return docRef.addSnapshotListener { document, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let document = document, document.exists else {
                completion(.failure(FirestoreError.documentNotFound))
                return
            }
            
            guard let data = document.data() else {
                completion(.failure(FirestoreError.invalidData))
                return
            }
            
            completion(.success(data))
        }
    }
    
    func listenToCollection(from collection: String, where field: String, isEqualTo value: Any, completion: @escaping (Result<[[String: Any]], Error>) -> Void) -> ListenerRegistration {
        let query = db.collection(collection).whereField(field, isEqualTo: value)
        
        return query.addSnapshotListener { snapshot, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let snapshot = snapshot else {
                completion(.failure(FirestoreError.snapshotNotFound))
                return
            }
            
            let documents = snapshot.documents.compactMap { document in
                document.data()
            }
            completion(.success(documents))
        }
    }
}

// MARK: - Firestore Errors

enum FirestoreError: Error, LocalizedError {
    case documentNotFound
    case snapshotNotFound
    case invalidData
    
    var errorDescription: String? {
        switch self {
        case .documentNotFound:
            return "Document not found"
        case .snapshotNotFound:
            return "Snapshot not found"
        case .invalidData:
            return "Invalid data format"
        }
    }
}
