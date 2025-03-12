//
//  RealmService.swift
//  Flashcards
//
//  Created by Denis Haritonenko on 10.03.25.
//

import Foundation
import RealmSwift

class RealmManager {
    
    private(set) var localRealm: Realm?
    
    init() {
        openRealm()
    }
    
    func clearRealm() {
        if let localRealm = localRealm {
            do {
                try localRealm.write {
                    localRealm.deleteAll()
                }
            } catch {
                print("Error clearing Realm data:", error)
            }
        }
    }

    
    func openRealm() {
        let config = Realm.Configuration(
            schemaVersion: 2,
            migrationBlock: { migration, oldSchemaVersion in
                if oldSchemaVersion < 2 {
                    migration.enumerateObjects(ofType: Flashcard.className()) { _, newObject in
                        newObject?["firestoreDocumentID"] = nil
                    }
                }
            }
        )

        Realm.Configuration.defaultConfiguration = config

        do {
            localRealm = try Realm()
        } catch {
            print("Error initializing Realm: \(error.localizedDescription)")
        }
    }
    
    func addFlashcard(_ flashcard: Flashcard) {
        if let localRealm = localRealm {
            do {
                try localRealm.write {
                    localRealm.add(flashcard)
                    print("Added new flashcard:", flashcard)
                }
            } catch {
                print("Error adding flashcard to Realm:", error)
            }
        }
    }

    func getFlashcards() -> [Flashcard] {
        guard let localRealm = localRealm else { return [] }
        return Array(localRealm.objects(Flashcard.self).sorted(byKeyPath: "createdAt", ascending: false))
    }

    func deleteFlashcard(_ card: Flashcard) {
        guard let localRealm = localRealm else { return }
        do {
            try localRealm.write {
                localRealm.delete(card)
            }
        } catch {
            print("Error deleting card:", error)
        }
    }
}
