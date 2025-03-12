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
    @Published var images: [String: UIImage] = [:]
    
    private let realmService = RealmManager()
    private let firebaseManager = FirebaseManager()
    
    init() {
        fetchFlashcardsBasedOnAuth()
    }
        
    // MARK: DELETE
    private func syncLocalFlashcardsToFirebase() {
        let localFlashcards = realmService.getFlashcards()
        guard !localFlashcards.isEmpty else { return }

        for flashcard in localFlashcards {
            if let imageData = loadImageFromLocal(imagePath: flashcard.imagePath)?.jpegData(compressionQuality: 0.8) {
                firebaseManager.addFlashcard(flashcard, imageData: imageData) { result in
                    switch result {
                    case .success:
                        self.deleteImage(at: flashcard.imagePath)
                        self.realmService.deleteFlashcard(flashcard)
                    case .failure(let error):
                        print("Error syncing flashcard to Firebase: \(error)")
                    }
                }
            }
        }
    }
    
    private func deleteImage(at fileName: String) {
        let fileManager = FileManager.default
        guard let documentsDirectory = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first else {
            print("Error: Documents directory not found")
            return
        }
        
        let fileURL = documentsDirectory.appendingPathComponent(fileName)

        do {
            if fileManager.fileExists(atPath: fileURL.path) {
                try fileManager.removeItem(at: fileURL)
                print("Image deleted successfully at: \(fileURL.path)")
            } else {
                print("File does not exist at path:", fileURL.path)
            }
        } catch {
            print("Error deleting image:", error)
        }
    }
    
    func deleteFlashcard(_ flashcard: Flashcard) {
        if Auth.auth().currentUser != nil {
            firebaseManager.deleteFlashcardFromFirebase(flashcard) { result in
                switch result {
                case .success:
                    print("Flashcard successfully deleted from Firebase")
                    self.fetchFlashcardsBasedOnAuth()
                case .failure(let error):
                    print("Error deleting flashcard from Firebase:", error)
                }
            }
        } else {
            realmService.deleteFlashcard(flashcard)
            deleteImage(at: flashcard.imagePath)
            fetchFlashcardsBasedOnAuth()
        }
    }


    
    // MARK: FETCH
    func fetchFlashcardsBasedOnAuth() {
        print("fetchcardsbasedonauth")
        if AuthenticationManager.shared.user != nil {
            syncLocalFlashcardsToFirebase()
            fetchFlashcardsFromFirebase()
        } else {
            fetchFlashcardsFromLocal()
        }
    }
    
    private func fetchFlashcardsFromFirebase() {
        firebaseManager.fetchFlashcards { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let fetchedFlashcards):
                    self.flashcards = fetchedFlashcards
                    self.fetchImagesFromFirebase()
                case .failure(let error):
                    print("Error fetching flashcards from Firebase: \(error)")
                    self.fetchFlashcardsFromLocal()
                }
            }
        }
    }
    
    private func fetchFlashcardsFromLocal() {
        let realmFlashcards = realmService.getFlashcards()
        flashcards = realmFlashcards.map { Flashcard(value: $0) }
        fetchImagesFromLocal()
    }
    
    private func fetchImagesFromFirebase() {
        Task {
            do {
                let images = try await ImageManager.shared.downloadImages(for: flashcards)
                DispatchQueue.main.async {
                    for (index, image) in images.enumerated() {
                        if let image = image {
                            self.images[self.flashcards[index].id.stringValue] = image
                        }
                    }
                }
            } catch {
                print("Error readomg images: \(error)")
            }
        }
    }
    
    private func fetchImagesFromLocal() {
        _ = FileManager.default
        for flashcard in flashcards {
            if let image = loadImageFromLocal(imagePath: flashcard.imagePath) {
                images[flashcard.id.stringValue] = image
            }
        }
    }
    
    private func loadImageFromLocal(imagePath: String) -> UIImage? {
        let fileManager = FileManager.default
        guard let documentsDirectory = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first else {
            return nil
        }
        let fileURL = documentsDirectory.appendingPathComponent(imagePath)
        return UIImage(contentsOfFile: fileURL.path)
    }
    
    // MARK: SAVE
    func saveFlashcardBasedOnAuth(name: String, imageData: Data) {
        let newCard = Flashcard()
        newCard.id = ObjectId.generate()
        newCard.name = name
        newCard.createdAt = Date()
        
        if Auth.auth().currentUser != nil {
            firebaseManager.addFlashcard(newCard, imageData: imageData) { result in
                DispatchQueue.main.async {
                    switch result {
                    case .success:
                        self.fetchFlashcardsBasedOnAuth()
                    case .failure(_):
                        self.saveFlashcardToLocal(flashcard: newCard, imageData: imageData)
                    }
                }
            }
        } else {
            saveFlashcardToLocal(flashcard: newCard, imageData: imageData)
        }
    }
    
    func saveFlashcardToLocal(flashcard: Flashcard, imageData: Data) {
        print("saveFlashcardToLocal")
        if let fileName = saveImageLocally(imageData: imageData) {
            flashcard.imagePath = fileName
            flashcard.firestoreDocumentID = nil
            realmService.addFlashcard(flashcard)
            fetchFlashcardsBasedOnAuth()
        }
    }
    
    func saveImageLocally(imageData: Data) -> String? {
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

