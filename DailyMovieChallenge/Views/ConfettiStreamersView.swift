//
//  ConfettiStreamersView.swift
//  DailyMovieChallenge
//
//  Celebração pós-vitória com burst de partículas (sem emojis).
//

import SwiftUI
import UIKit

struct ConfettiStreamersView: View {
    var isActive: Bool
    var duration: TimeInterval = 1.0

    @State private var triggerID = UUID()
    @State private var hideTask: Task<Void, Never>?
    @State private var isVisible = false

    var body: some View {
        ZStack(alignment: .top) {
            Color.clear
            if isVisible {
                ConfettiBurstRepresentable(triggerID: triggerID)
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
        triggerID = UUID()
        isVisible = true
        hideTask?.cancel()
        hideTask = Task { @MainActor in
            let ns = UInt64(max(0.5, duration) * 1_000_000_000)
            try? await Task.sleep(nanoseconds: ns)
            withAnimation(.easeOut(duration: 0.3)) {
                isVisible = false
            }
        }
    }
}

private struct ConfettiBurstRepresentable: UIViewRepresentable {
    let triggerID: UUID

    func makeUIView(context: Context) -> BurstHostView {
        let view = BurstHostView()
        view.backgroundColor = .clear
        view.isUserInteractionEnabled = false
        return view
    }

    func updateUIView(_ uiView: BurstHostView, context: Context) {
        uiView.trigger(id: triggerID)
    }
}

private final class BurstHostView: UIView {
    private var lastTriggerID: UUID?
    private var pendingTriggerID: UUID?

    func trigger(id: UUID) {
        guard id != lastTriggerID else { return }
        pendingTriggerID = id
        emitIfReady()
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        emitIfReady()
    }

    private func emitIfReady() {
        guard bounds.width > 0, bounds.height > 0 else { return }
        guard let id = pendingTriggerID else { return }
        pendingTriggerID = nil
        lastTriggerID = id

        let emitter = CAEmitterLayer()
        emitter.emitterPosition = CGPoint(x: bounds.midX, y: bounds.height * 0.22)
        emitter.emitterShape = .point
        emitter.emitterSize = CGSize(width: 1, height: 1)
        emitter.renderMode = .unordered

        let colors: [UIColor] = [.systemBlue, .systemPurple, .systemPink, .systemTeal, .systemYellow]
        emitter.emitterCells = colors.enumerated().map { idx, color in
            let cell = CAEmitterCell()
            cell.name = "p\(idx)"
            cell.contents = (idx % 2 == 0 ? makeDot(color: color) : makeRect(color: color)).cgImage
            cell.birthRate = 46
            cell.lifetime = 0.75
            cell.lifetimeRange = 0.2
            cell.velocity = 145
            cell.velocityRange = 48
            cell.yAcceleration = 210
            cell.emissionRange = .pi * 2
            cell.scale = 0.28
            cell.scaleRange = 0.1
            cell.spin = 2.8
            cell.spinRange = 1.2
            cell.alphaSpeed = -1.5
            return cell
        }

        layer.addSublayer(emitter)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.07) { emitter.birthRate = 0 }
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) { emitter.removeFromSuperlayer() }
    }

    private func makeDot(color: UIColor) -> UIImage {
        let size = CGSize(width: 6, height: 6)
        return UIGraphicsImageRenderer(size: size).image { _ in
            color.setFill()
            UIBezierPath(ovalIn: CGRect(origin: .zero, size: size)).fill()
        }
    }

    private func makeRect(color: UIColor) -> UIImage {
        let size = CGSize(width: 8, height: 4)
        return UIGraphicsImageRenderer(size: size).image { _ in
            color.setFill()
            UIBezierPath(roundedRect: CGRect(origin: .zero, size: size), cornerRadius: 1.2).fill()
        }
    }
}

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
        Color.gray.opacity(0.2).ignoresSafeArea()
        Text("Acerto!").font(.largeTitle)
        ConfettiStreamersOverlay(isActive: true)
    }
}
