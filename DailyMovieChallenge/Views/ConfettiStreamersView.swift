//
//  ConfettiStreamersView.swift
//  DailyMovieChallenge
//
//  Confetes e serpentinas em caso de acerto.
//

import SwiftUI

/// Uma partícula de confete: posição inicial, cor, tamanho, velocidade e deriva.
private struct ConfettiParticle: Identifiable {
    let id = UUID()
    let initialX: CGFloat
    let color: Color
    let size: CGSize
    let fallSpeed: CGFloat
    let drift: CGFloat
    let delay: CGFloat
    let rotationSpeed: Double
    let depth: CGFloat
}

/// Uma serpentina: tira longa que cai com rotação.
private struct StreamerParticle: Identifiable {
    let id = UUID()
    let initialX: CGFloat
    let color: Color
    let width: CGFloat
    let height: CGFloat
    let fallSpeed: CGFloat
    let drift: CGFloat
    let delay: CGFloat
    let rotationSpeed: Double
    let depth: CGFloat
}

/// View de confetes e serpentinas caindo (para sucesso).
struct ConfettiStreamersView: View {
    var isActive: Bool
    var duration: Double = 4.0
    var width: CGFloat = 400
    var height: CGFloat = 800

    private static let colors: [Color] = [
        .green,
        Color(red: 0.2, green: 0.8, blue: 0.3),
        Color(red: 1.0, green: 0.84, blue: 0.0),
        Color(red: 1.0, green: 0.6, blue: 0.2),
        .orange,
        Color(red: 0.4, green: 0.9, blue: 0.6),
    ]

    @State private var startTime: Date?
    @State private var confetti: [ConfettiParticle] = []
    @State private var streamers: [StreamerParticle] = []

    var body: some View {
        if !isActive { return AnyView(EmptyView()) }

        return AnyView(
            TimelineView(.animation(minimumInterval: 1/45)) { context in
                let elapsed = startTime.map { context.date.timeIntervalSince($0) } ?? 0
                let opacity = elapsed > duration ? max(0, 1 - (elapsed - duration) / 1.5) : 1.0

                ZStack {
                    ForEach(confetti) { p in
                        confettiPosition(particle: p, elapsed: elapsed)
                    }
                    ForEach(streamers) { s in
                        streamerPosition(particle: s, elapsed: elapsed)
                    }
                }
                .frame(width: width, height: height)
                .opacity(opacity)
                .allowsHitTesting(false)
            }
            .onAppear {
                guard startTime == nil else { return }
                startTime = Date()
                generateParticles()
            }
            .onChange(of: isActive) { _, newValue in
                if newValue && startTime == nil {
                    startTime = Date()
                    generateParticles()
                }
            }
        )
    }

    private func generateParticles() {
        var c: [ConfettiParticle] = []
        for _ in 0..<55 {
            let depth = CGFloat.random(in: 0.6...1.2)
            c.append(ConfettiParticle(
                initialX: CGFloat.random(in: 0...1),
                color: Self.colors.randomElement()!,
                size: CGSize(
                    width: CGFloat.random(in: 6...14) * depth,
                    height: CGFloat.random(in: 6...12) * depth
                ),
                fallSpeed: CGFloat.random(in: 180...320) * depth,
                drift: CGFloat.random(in: -40...40) * depth,
                delay: CGFloat.random(in: 0...0.8),
                rotationSpeed: Double.random(in: -3...3) * Double(depth),
                depth: depth
            ))
        }
        confetti = c

        var s: [StreamerParticle] = []
        for _ in 0..<12 {
            let depth = CGFloat.random(in: 0.6...1.1)
            s.append(StreamerParticle(
                initialX: CGFloat.random(in: 0...1),
                color: Self.colors.randomElement()!,
                width: CGFloat.random(in: 4...8) * depth,
                height: CGFloat.random(in: 50...90) * depth,
                fallSpeed: CGFloat.random(in: 120...220) * depth,
                drift: CGFloat.random(in: -50...50) * depth,
                delay: CGFloat.random(in: 0...0.5),
                rotationSpeed: Double.random(in: -2.5...2.5) * Double(depth),
                depth: depth
            ))
        }
        streamers = s
    }

    @ViewBuilder
    private func confettiPosition(particle: ConfettiParticle, elapsed: CGFloat) -> some View {
        let t = max(0, Double(elapsed) - Double(particle.delay))
        let y = CGFloat(t) * particle.fallSpeed
        let x = particle.drift * CGFloat(t) * 0.5
        let rotation = Angle(radians: particle.rotationSpeed * t)
        let posX = particle.initialX * width
        let posY = -50 + y

        RoundedRectangle(cornerRadius: 2)
            .fill(particle.color)
            .frame(width: particle.size.width, height: particle.size.height)
            .rotationEffect(rotation)
            .opacity(Double(min(1.0, max(0.5, particle.depth))))
            .position(x: posX + x, y: posY)
    }

    @ViewBuilder
    private func streamerPosition(particle: StreamerParticle, elapsed: CGFloat) -> some View {
        let t = max(0, Double(elapsed) - Double(particle.delay))
        let y = CGFloat(t) * particle.fallSpeed
        let x = particle.drift * CGFloat(t) * 0.4
        let rotation = Angle(radians: particle.rotationSpeed * t)
        let posX = particle.initialX * width
        let posY = -80 + y

        RoundedRectangle(cornerRadius: 2)
            .fill(
                LinearGradient(
                    colors: [particle.color, particle.color.opacity(0.7)],
                    startPoint: .top,
                    endPoint: .bottom
                )
            )
            .frame(width: particle.width, height: particle.height)
            .rotationEffect(rotation)
            .opacity(Double(min(1.0, max(0.45, particle.depth))))
            .position(x: posX + x, y: posY)
    }
}

/// Overlay de confetes que preenche a tela.
struct ConfettiStreamersOverlay: View {
    var isActive: Bool

    var body: some View {
        GeometryReader { geo in
            ConfettiStreamersView(
                isActive: isActive,
                width: geo.size.width,
                height: geo.size.height * 1.5
            )
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .ignoresSafeArea()
    }
}

#Preview("Confetti") {
    ZStack {
        Color.gray.opacity(0.2)
            .ignoresSafeArea()
        Text("Acerto!")
            .font(.largeTitle)
        ConfettiStreamersOverlay(isActive: true)
    }
}
