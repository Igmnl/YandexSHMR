//
//  LaunchAnimationView.swift
//  Utilities
//
//  Created by Никита Арабчик on 24.07.2025.
//

import SwiftUI
import Lottie

public struct LaunchAnimationView: UIViewRepresentable {
    public var onFinished: () -> Void
    
    public init(onFinished: @escaping () -> Void) {
        self.onFinished = onFinished
    }

    public func makeUIView(context: Context) -> UIView {
        let view = UIView(frame: .zero)

        guard let animation = LottieAnimation.named("launch-animation", bundle: .module) else {
            onFinished()
            return view
        }

        let animationView = LottieAnimationView(animation: animation)
        animationView.contentMode = .scaleAspectFit
        animationView.translatesAutoresizingMaskIntoConstraints = false
        animationView.loopMode = .playOnce

        view.addSubview(animationView)

        NSLayoutConstraint.activate([
            animationView.topAnchor.constraint(equalTo: view.topAnchor),
            animationView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            animationView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            animationView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])

        animationView.play { finished in
            if finished {
                onFinished()
            }
        }

        return view
    }

    public func updateUIView(_ uiView: UIView, context: Context) {}
}
