//
//  FlashcardViewModel.swift
//  Flashcards
//
//  Created by Denis Haritonenko on 9.03.25.
//

import SwiftUI
import RealmSwift
import FirebaseAuth

class FlashcardViewModel: ObservableObject {
    @Published var flashcards: [Flashcard] = []
    private let realmService = RealmManager()
    private let firebaseManager = FirebaseManager()
    
    init() {
        loadFlashcards()
    }

    func loadFlashcards() {
        if Auth.auth().currentUser != nil {
            fetchFromFirebase()
        } else {
            fetchFromLocal()
        }
    }

    private func fetchFromFirebase() {
        firebaseManager.fetchFlashcards { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let fetchedFlashcards):
                    self.flashcards = fetchedFlashcards
                case .failure(let error):
                    print("Error fetching flashcards from Firebase: \(error)")
                    self.fetchFromLocal()
                }
            }
        }
    }
    
    private func fetchFromLocal() {
        let realmFlashcards = realmService.getFlashcards()
        flashcards = realmFlashcards.map { Flashcard(value: $0) }
    }

    func addFlashcard(name: String, imageData: Data) {
        let newCard = Flashcard()
        newCard.id = ObjectId.generate()
        newCard.name = name
        newCard.createdAt = Date()

        if let user = Auth.auth().currentUser {
            firebaseManager.addFlashcard(newCard, imageData: imageData) { result in
                DispatchQueue.main.async {
                    switch result {
                    case .success:
                        self.loadFlashcards()
                    case .failure(let error):
                        print("Error adding flashcard to Firebase: \(error)")
                    }
                }
            }
        } else {
            saveLocally(flashcard: newCard, imageData: imageData)
        }
    }

    private func saveLocally(flashcard: Flashcard, imageData: Data) {
        if let fileName = saveImageToFileSystem(imageData: imageData) {
            flashcard.imagePath = fileName
            realmService.addFlashcard(flashcard)
            loadFlashcards()
        }
    }

    func saveImageToFileSystem(imageData: Data) -> String? {
        let fileManager = FileManager.default
        guard let documentsDirectory = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first else {
            return nil
        }
        
        let fileName = UUID().uuidString + ".jpg"
        let fileURL = documentsDirectory.appendingPathComponent(fileName)

        do {
            try imageData.write(to: fileURL)
            return fileName
        } catch {
            print("Error saving image: \(error)")
            return nil
        }
    }
}
