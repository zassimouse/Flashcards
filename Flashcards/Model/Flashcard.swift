//
//  Flashcard.swift
//  Flashcards
//
//  Created by Denis Haritonenko on 9.03.25.
//

import Foundation
import RealmSwift

class Flashcard: Object, Identifiable {
    @Persisted(primaryKey: true) var id: ObjectId
    @Persisted var name: String
    @Persisted var imagePath: String
    @Persisted var createdAt: Date
    @Persisted var firestoreDocumentID: String?
}
