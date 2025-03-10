//
//  FlashcardViewModel.swift
//  Flashcards
//
//  Created by Denis Haritonenko on 9.03.25.
//

import SwiftUI
import RealmSwift
import Combine

class FlashcardViewModel: ObservableObject {
    @Published var flashcards: [Flashcard] = []
    private let realmService = RealmManager()

    init() {
        loadFlashcards()
    }

    func loadFlashcards() {
        let realmFlashcards = realmService.getFlashcards()
        flashcards = realmFlashcards.map { Flashcard(value: $0) }
    }

    func addFlashcard(name: String, imagePath: String, userId: String?) {
        let newCard = Flashcard()
        newCard.id = ObjectId.generate()
        newCard.name = name
        newCard.imagePath = imagePath
        newCard.createdAt = Date()
        
        realmService.addFlashcard(newCard)
        loadFlashcards()
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
            print("Image saved at path: \(fileURL.path)")
            return fileName
        } catch {
            print("Error saving image to file system: \(error)")
            return nil
        }
    }

    

}
