//
//  FlipCardView.swift
//  Flashcards
//
//  Created by Denis Haritonenko on 7.03.25.
//

import SwiftUI

struct FlipCardView: View {
    let flashcard: Flashcard
    let image: UIImage?
    @State private var isFlipped = false

    init(flashcard: Flashcard, image: UIImage? = nil) {
        self.flashcard = flashcard
        self.image = image
    }

    var body: some View {
        ZStack {
            if isFlipped {
                BackCardView(text: flashcard.name)
                    .rotation3DEffect(.degrees(180), axis: (x: 0, y: 1, z: 0))
            } else {
                FrontCardView(flashcard: flashcard, image: image)
            }
        }
        .aspectRatio(1, contentMode: .fit)
        .frame(minHeight: 150)
        .rotation3DEffect(.degrees(isFlipped ? 180 : 0), axis: (x: 0, y: 1, z: 0))
        .animation(.easeInOut, value: isFlipped)
        .onTapGesture {
            isFlipped.toggle()
        }
    }
}

struct FrontCardView: View {
    let flashcard: Flashcard
    let image: UIImage?

    var body: some View {
        GeometryReader { geometry in
            VStack {
                if let image = image {
                    Image(uiImage: image)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .clipped()
                } else {
                    RoundedRectangle(cornerRadius: 10)
                        .fill(Color.gray.opacity(0.3))
                        .frame(width: geometry.size.width, height: geometry.size.height)
                        .shimmer(true)
                }
            }
            .frame(width: geometry.size.width, height: geometry.size.height)
            .background(Color.gray.opacity(0.3))
            .clipShape(RoundedRectangle(cornerRadius: 20))
        }
    }
}


struct BackCardView: View {
    let text: String

    var body: some View {
        VStack {
            Text(text)
                .font(.headline)
                .bold()
                .foregroundColor(.white)
                .multilineTextAlignment(.center)
                .padding()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.blue)
        .clipShape(RoundedRectangle(cornerRadius: 20))
    }
}


