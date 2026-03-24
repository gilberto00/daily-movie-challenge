//
//  NativeScrollView.swift
//  DailyMovieChallenge
//
//  UIViewControllerRepresentable garante que UIHostingController seja filho
//  real do view controller — único jeito confiável de dimensionar conteúdo
//  SwiftUI dentro de um UIScrollView.
//

import SwiftUI
import UIKit

struct NativeScrollView<Content: View>: UIViewControllerRepresentable {
    let content: Content

    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }

    func makeUIViewController(context: Context) -> NativeScrollVC<Content> {
        NativeScrollVC(content: content)
    }

    func updateUIViewController(_ vc: NativeScrollVC<Content>, context: Context) {
        vc.update(rootView: content)
    }
}

final class NativeScrollVC<Content: View>: UIViewController {
    private let scrollView = UIScrollView()
    private var hostingVC: UIHostingController<Content>

    init(content: Content) {
        hostingVC = UIHostingController(rootView: content)
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) { fatalError() }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .clear

        scrollView.backgroundColor = .clear
        scrollView.alwaysBounceVertical = true
        scrollView.showsVerticalScrollIndicator = true
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(scrollView)
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
        ])

        if #available(iOS 16.0, *) {
            hostingVC.sizingOptions = .intrinsicContentSize
        }
        addChild(hostingVC)
        hostingVC.view.backgroundColor = .clear
        hostingVC.view.translatesAutoresizingMaskIntoConstraints = false
        scrollView.addSubview(hostingVC.view)
        NSLayoutConstraint.activate([
            hostingVC.view.topAnchor.constraint(equalTo: scrollView.contentLayoutGuide.topAnchor),
            hostingVC.view.leadingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.leadingAnchor),
            hostingVC.view.trailingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.trailingAnchor),
            hostingVC.view.bottomAnchor.constraint(equalTo: scrollView.contentLayoutGuide.bottomAnchor),
            hostingVC.view.widthAnchor.constraint(equalTo: scrollView.frameLayoutGuide.widthAnchor),
        ])
        hostingVC.didMove(toParent: self)
    }

    func update(rootView: Content) {
        hostingVC.rootView = rootView
    }

    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        // Força recálculo do contentSize quando o container muda de tamanho.
        hostingVC.view.setNeedsLayout()
    }
}
