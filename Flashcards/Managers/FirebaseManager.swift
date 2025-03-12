//
//  FirebaseManager.swift
//  Flashcards
//
//  Created by Denis Haritonenko on 11.03.25.
//

import Foundation
import FirebaseFirestore
import FirebaseStorage
import FirebaseAuth
import RealmSwift

class FirebaseManager {
    static let shared = FirebaseManager()
    
    private let db = Firestore.firestore()
    private let storage = Storage.storage()
    
    init() {}
    
    func addFlashcard(_ flashcard: Flashcard, imageData: Data, completion: @escaping (Result<Void, Error>) -> Void) {
        guard let userId = Auth.auth().currentUser?.uid else {
            completion(.failure(NSError(domain: "NoUser", code: 401, userInfo: [NSLocalizedDescriptionKey: "User not authenticated"])))
            return
        }
        
        let imageRef = storage.reference().child("flashcards/\(userId)/\(UUID().uuidString).jpg")
        
        imageRef.putData(imageData, metadata: nil) { _, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            imageRef.downloadURL { url, error in
                if let error = error {
                    completion(.failure(error))
                    return
                }
                
                guard let imageUrl = url?.absoluteString else {
                    completion(.failure(NSError(domain: "InvalidURL", code: 400, userInfo: nil)))
                    return
                }
                
                let flashcardData: [String: Any] = [
                    "name": flashcard.name,
                    "imageUrl": imageUrl,
                    "createdAt": Timestamp(date: flashcard.createdAt)
                ]
                
                self.db.collection("users").document(userId).collection("flashcards").addDocument(data: flashcardData) { error in
                    if let error = error {
                        completion(.failure(error))
                    } else {
                        completion(.success(()))
                    }
                }
            }
        }
    }
    
    func fetchFlashcards(completion: @escaping (Result<[Flashcard], Error>) -> Void) {
        guard let userId = Auth.auth().currentUser?.uid else {
            completion(.failure(NSError(domain: "NoUser", code: 401, userInfo: nil)))
            return
        }
        
        db.collection("users").document(userId).collection("flashcards")
            .order(by: "createdAt", descending: true)
            .getDocuments { snapshot, error in
                if let error = error {
                    completion(.failure(error))
                    return
                }
                
                guard let documents = snapshot?.documents else {
                    completion(.success([]))
                    return
                }
                
                let flashcards = documents.compactMap { doc -> Flashcard? in
                    let data = doc.data()
                    guard let name = data["name"] as? String,
                          let imageUrl = data["imageUrl"] as? String,
                          let timestamp = data["createdAt"] as? Timestamp else { return nil }
                    
                    let flashcard = Flashcard()
                    flashcard.id = ObjectId.generate()
                    flashcard.firestoreDocumentID = doc.documentID
                    flashcard.name = name
                    flashcard.imagePath = imageUrl
                    flashcard.createdAt = timestamp.dateValue()
                    
                    return flashcard
                }
                
                completion(.success(flashcards))
            }
    }
    
    func deleteFlashcardFromFirebase(_ card: Flashcard, completion: @escaping (Result<Void, Error>) -> Void) {
        guard let userId = Auth.auth().currentUser?.uid else {
            completion(.failure(NSError(domain: "NoUser", code: 401, userInfo: [NSLocalizedDescriptionKey: "User not authenticated"])))
            return
        }

        let db = Firestore.firestore()
        
        guard let documentID = card.firestoreDocumentID, !card.imagePath.isEmpty else {
            completion(.failure(NSError(domain: "InvalidCard", code: 400, userInfo: [NSLocalizedDescriptionKey: "Card does not have a valid document ID or image path"])))
            return
        }
        
        let storageRef = storage.reference(forURL: card.imagePath)
        
        storageRef.delete { error in
            if let error = error {
                print("Error deleting image from Storage:", error)
                completion(.failure(error))
                return
            }

            print("Image successfully deleted from Storage")
            
            let cardRef = db.collection("users").document(userId).collection("flashcards").document(documentID)
            
            cardRef.delete { error in
                if let error = error {
                    print("Error deleting flashcard from Firestore:", error)
                    completion(.failure(error))
                } else {
                    print("Flashcard successfully deleted from Firestore")
                    completion(.success(()))
                }
            }
        }
    }

}
