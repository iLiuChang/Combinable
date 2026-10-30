//
//  UIView+Combine.swift
//  Combinable
//
//  Created by LC on 2025/10/31.
//

import Combine
import UIKit

public extension CombinableWrapper where Base: UIView {
    /// Tap gesture. Emits the recognizer whenever its state changes.
    var tapPublisher: AnyPublisher<UITapGestureRecognizer, Never> {
        gesturePublisher(for: UITapGestureRecognizer.self)
    }

    /// Long-press gesture. Emits the recognizer whenever its state changes.
    var longPressPublisher: AnyPublisher<UILongPressGestureRecognizer, Never> {
        gesturePublisher(for: UILongPressGestureRecognizer.self)
    }

    /// Pan gesture. Emits the recognizer whenever its state changes.
    var panPublisher: AnyPublisher<UIPanGestureRecognizer, Never> {
        gesturePublisher(for: UIPanGestureRecognizer.self)
    }

    /// Swipe gesture. Emits the recognizer whenever its state changes.
    var swipePublisher: AnyPublisher<UISwipeGestureRecognizer, Never> {
        gesturePublisher(for: UISwipeGestureRecognizer.self)
    }

    /// Pinch gesture. Emits the recognizer whenever its state changes.
    var pinchPublisher: AnyPublisher<UIPinchGestureRecognizer, Never> {
        gesturePublisher(for: UIPinchGestureRecognizer.self)
    }

    /// Rotation gesture. Emits the recognizer whenever its state changes.
    var rotationPublisher: AnyPublisher<UIRotationGestureRecognizer, Never> {
        gesturePublisher(for: UIRotationGestureRecognizer.self)
    }

    /// Adds a gesture recognizer of the given type and emits it whenever its state changes.
    ///
    /// The recognizer is added on subscription and removed when the subscription is cancelled.
    /// - Parameters:
    ///   - gestureType: The gesture recognizer type to install.
    ///   - configure: Configures the recognizer before it is added, such as tap count or swipe direction.
    func gesturePublisher<T: UIGestureRecognizer>(
        for gestureType: T.Type,
        configure: @escaping (T) -> Void = { _ in }
    ) -> AnyPublisher<T, Never> {
        UIGesturePublisher<T>(view: base, configure: configure)
            .eraseToAnyPublisher()
    }
}
