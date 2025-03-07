//
//  FlipCardView.swift
//  Flashcards
//
//  Created by Denis Haritonenko on 7.03.25.
//

import SwiftUI

struct FlipCardView: View {
    @State private var isFlipped = false
    
    var body: some View {
        ZStack {
            if isFlipped {
                BackCardView()
                    .rotation3DEffect(.degrees(180), axis: (x: 0, y: 1, z: 0))
            } else {
                FrontCardView()
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
    var body: some View {
        GeometryReader { geometry in
            VStack {
                Image("cardImage")
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: geometry.size.width, height: geometry.size.height)
                    .clipped()
            }
            .background(Color.random)
            .clipShape(RoundedRectangle(cornerRadius: 20))
        }
    }
}

struct BackCardView: View {
    var body: some View {
        VStack {
            Text("Card Back")
                .foregroundStyle(.white)
                .font(.title)
                .bold()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.random)
        .clipShape(RoundedRectangle(cornerRadius: 20))
    }
}

extension Color {
    static var random: Color {
        return Color(
            red: .random(in: 0...1),
            green: .random(in: 0...1),
            blue: .random(in: 0...1)
        )
    }
}

#Preview {
    FlipCardView()
}
