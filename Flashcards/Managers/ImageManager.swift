//
//  ImageManager.swift
//  Flashcards
//
//  Created by Denis Haritonenko on 11.03.25.
//

import Foundation
import Kingfisher
import UIKit

class ImageManager {
    static let shared = ImageManager()

    func downloadImages(for flashcards: [Flashcard]) async throws -> [UIImage?] {
        var images: [UIImage?] = Array(repeating: nil, count: flashcards.count)
        let totalCount = flashcards.count
        let concurrentLimit = 6
        
        try await withThrowingTaskGroup(of: (Int, UIImage?).self) { group in
            for index in 0..<min(concurrentLimit, totalCount) {
                group.addTask { [weak self] in
                    guard let self = self else { return (index, nil) }
                    return try await self.downloadImage(for: flashcards[index], index: index)
                }
            }
            
            var nextIndex = concurrentLimit
            while let result = try await group.next() {
                images[result.0] = result.1
                if nextIndex < totalCount {
                    group.addTask { [weak self, nextIndex] in
                        guard let self = self else { return (nextIndex, nil) }
                        return try await self.downloadImage(for: flashcards[nextIndex], index: nextIndex)
                    }
                    nextIndex += 1
                }
            }
        }
        return images
    }

    private func downloadImage(for flashcard: Flashcard, index: Int) async throws -> (Int, UIImage?) {
        guard let url = URL(string: flashcard.imagePath) else { return (index, nil) }
        do {
            let image = try await KingfisherManager.shared.retrieveImage(with: url)
            return (index, image.image)
        } catch {
            print("Error downloading flashcard \(flashcard.name): \(error)")
            return (index, nil)
        }
    }
}
