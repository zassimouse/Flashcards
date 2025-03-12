//
//  ShimmerModifier.swift
//  Flashcards
//
//  Created by Denis Haritonenko on 11.03.25.
//

import SwiftUI

struct ShimmerEffect: View {
    @State private var animation = 0.0

    var body: some View {
        RoundedRectangle(cornerRadius: 10)
            .fill(LinearGradient(gradient: Gradient(colors: [Color.gray.opacity(0.2), Color.gray.opacity(0.3), Color.gray.opacity(0.2)]), startPoint: .topLeading, endPoint: .bottomTrailing))
            .rotationEffect(.degrees(30))
            .offset(x: CGFloat(animation), y: 0)
            .animation(Animation.linear(duration: 1.5).repeatForever(autoreverses: false), value: animation)
            .onAppear {
                animation = 2000
            }
            .frame(width: 100, height: 100)
    }
}

public extension View {
    func shimmerEffect(
        isActive: Bool,
        speed: CGFloat = 1,
        colors: [Color] = [],
        cornerRadius: CGFloat = 5
    ) -> some View {
        modifier(ShimmerModifier(
            isActive: isActive,
            speed: speed,
            colors: colors,
            cornerRadius: cornerRadius)
        )
    }
    
    func shimmer(_ isActive: Bool) -> some View {
        modifier(ShimmerModifier(
            isActive: isActive,
            speed: 1,
            colors: [],
            cornerRadius: 5)
        )
    }
}

struct ShimmerModifier: ViewModifier {
    private var isActive: Bool
    private var speed: CGFloat
    private var colors: [Color] = [
        Color(uiColor: .systemGray5),
        Color(uiColor: .systemGray6),
        Color(uiColor: .systemGray5)]
    private var cornerRadius: CGFloat
    
    init(
        isActive: Bool,
        speed: CGFloat,
        colors: [Color],
        cornerRadius: CGFloat
    ) {
        self.isActive = isActive
        self.speed = speed
        self.cornerRadius = cornerRadius
        if !colors.isEmpty {
            self.colors = colors
        }
    }
    
    func body(content: Content) -> some View {
        if isActive {
            content
                .overlay {
                    ShimmerEffectBox(
                        speed: speed,
                        colors: colors
                    ).cornerRadius(cornerRadius)
                }
        }
    }
}

struct ShimmerEffectBox: View {
    @State private var startPoint = UnitPoint(x: -1.8, y: -1.2)
    @State private var endPoint = UnitPoint(x: 0, y: -0.2)
    var speed: CGFloat
    var colors: [Color]
    
    var body: some View {
        LinearGradient(
            colors: colors,
            startPoint: startPoint,
            endPoint: endPoint)
        .onAppear(perform: loopAnimation)
    }
    
    private func loopAnimation() {
        withAnimation(
            .easeInOut(duration: speed)
            .repeatForever(autoreverses: false)
        ) {
            startPoint = .init(x: 1, y: 1)
            endPoint = .init(x: 2.2, y: 2.2)
        }
    }
}
