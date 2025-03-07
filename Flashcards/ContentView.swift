//
//  ContentView.swift
//  Flashcards
//
//  Created by Denis Haritonenko on 7.03.25.
//

import SwiftUI

struct ContentView: View {
    let columns = [
        GridItem(.flexible()),
        GridItem(.flexible())
    ]
    
    var body: some View {
        NavigationStack {
            ScrollView {
                LazyVGrid(columns: columns, spacing: 10) {
                    ForEach(0..<10, id: \ .self) { _ in
                        FlipCardView()
                    }
                }
                .padding(.horizontal)
            }
            .navigationTitle("Flashcards")
        }
    }
}

#Preview {
    ContentView()
}
