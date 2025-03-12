//
//  ContentView.swift
//  Flashcards
//
//  Created by Denis Haritonenko on 7.03.25.
//

import SwiftUI

struct ContentView: View {
    @StateObject private var viewModel = FlashcardViewModel()
    
    let columns = [
        GridItem(.flexible()),
        GridItem(.flexible())
    ]
    
    var body: some View {
        NavigationStack {
            ScrollView {
                LazyVGrid(columns: columns, spacing: 10) {
                    ForEach(viewModel.flashcards, id: \.id) { flashcard in
                        if let image = viewModel.images[flashcard.id.stringValue] {
                            FlipCardView(flashcard: flashcard, image: image)
                                .contextMenu {
                                    Button(role: .destructive) {
                                        viewModel.deleteFlashcard(flashcard)
                                    } label: {
                                        Label("Delete", systemImage: "trash")
                                    }
                                }
                        } else {
                            FlipCardView(flashcard: flashcard)
                        }
                    }
                }
                .padding(.horizontal)
            }
            .refreshable {
                viewModel.fetchFlashcardsBasedOnAuth()
            }
            .navigationTitle("Flashcards")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    NavigationLink(destination: AccountView()) {
                        Image(systemName: "gear")
                            .font(.headline)
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    NavigationLink(destination: AddCardView().environmentObject(viewModel)) {
                        Image(systemName: "plus")
                            .font(.headline)
                    }
                }
            }
        }
    }
}


#Preview {
    ContentView()
}

