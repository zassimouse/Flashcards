//
//  FlipCardView.swift
//  Flashcards
//
//  Created by Denis Haritonenko on 7.03.25.
//

import SwiftUI

struct FlipCardView: View {
    let flashcard: Flashcard
    @State private var isFlipped = false

    init(_ flashcard: Flashcard) {
        self.flashcard = flashcard
    }

    var body: some View {
        ZStack {
            if isFlipped {
                BackCardView(text: flashcard.name)
                    .rotation3DEffect(.degrees(180), axis: (x: 0, y: 1, z: 0))
            } else {
                FrontCardView(flashcard: flashcard)
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

    private static func loadImage(from path: String) -> UIImage? {
        let fileURL = URL(fileURLWithPath: path)
        return UIImage(contentsOfFile: fileURL.path)
    }
}

struct FrontCardView: View {
    let flashcard: Flashcard

    var body: some View {
        GeometryReader { geometry in
            VStack {
                if let image = loadImage(from: flashcard.imagePath) {
                    Image(uiImage: image)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: geometry.size.width, height: geometry.size.height)
                        .clipped()
                } else {
                    Image("photo.badge.plus")
                        .resizable()
                        .scaledToFit()
                        .frame(width: geometry.size.width * 0.25, height: geometry.size.height * 0.25)
                        .foregroundColor(Color(UIColor.secondaryLabel))
                }
            }
            .background(Color.gray.opacity(0.3))
            .clipShape(RoundedRectangle(cornerRadius: 20))
        }
    }

    func loadImage(from relativePath: String) -> UIImage? {
        let fileManager = FileManager.default
        guard let documentsDirectory = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first else {
            return nil
        }
        
        let fileURL = documentsDirectory.appendingPathComponent(relativePath)
        
        if fileManager.fileExists(atPath: fileURL.path) {
            print("Image found at path: \(fileURL.path)")
            return UIImage(contentsOfFile: fileURL.path)
        } else {
            print("Image not found at path: \(fileURL.path)") 
            return nil
        }
    }
}

struct BackCardView: View {
    let text: String

    var body: some View {
        VStack {
            Text(text)
                .font(.title)
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

#Preview {
    FlipCardView(Flashcard(value: ["name": "Sample Text", "imagePath": ""]))
}
