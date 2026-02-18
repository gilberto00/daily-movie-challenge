//
//  ConfettiStreamersView.swift
//  DailyMovieChallenge
//
//  Efeito de fogos (biblioteca de mercado):
//  https://github.com/GetStream/effects-library
//

import SwiftUI
import EffectsLibrary

/// Overlay de fogos (3-4s) acionado por `isActive`.
struct ConfettiStreamersView: View {
    var isActive: Bool
    var duration: TimeInterval = 4.0

    @State private var showEffect: Bool = false
    @State private var instanceID = UUID()
    @State private var hideTask: Task<Void, Never>?

    private var effectiveDuration: TimeInterval {
        // Mantem dentro do range desejado (mais “cinematic”).
        min(4.0, max(3.0, duration))
    }

    var body: some View {
        ZStack {
            if showEffect {
                FireworksView(
                    config: FireworksConfig(
                        intensity: .high,
                        lifetime: .long,
                        // “Flor” maior.
                        initialVelocity: .fast,
                        fadeOut: .slow,
                        spreadRadius: .high
                    )
                )
                // Forca reinicio do efeito a cada trigger.
                .id(instanceID)
                .transition(.opacity)
            }
        }
        .allowsHitTesting(false)
        .onAppear {
            if isActive { trigger() }
        }
        .onDisappear {
            hideTask?.cancel()
            hideTask = nil
        }
        .onChange(of: isActive) { _, newValue in
            if newValue { trigger() }
        }
    }

    private func trigger() {
        instanceID = UUID()
        showEffect = true

        hideTask?.cancel()
        hideTask = Task { @MainActor in
            let ns = UInt64(max(0.1, effectiveDuration) * 1_000_000_000)
            try? await Task.sleep(nanoseconds: ns)
            withAnimation(.easeOut(duration: 0.2)) {
                showEffect = false
            }
        }
    }
}

/// Overlay de confetes que preenche a tela.
struct ConfettiStreamersOverlay: View {
    var isActive: Bool

    var body: some View {
        ConfettiStreamersView(isActive: isActive)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
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
