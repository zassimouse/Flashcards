//
//  FlashcardsApp.swift
//  Flashcards
//
//  Created by Denis Haritonenko on 7.03.25.
//

import SwiftUI
import Firebase

@main
struct FlashcardsApp: App {
    
    init() {
        FirebaseApp.configure()
    }
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
