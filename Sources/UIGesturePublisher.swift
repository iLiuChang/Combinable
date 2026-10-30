//
//  UIGesturePublisher.swift
//  Combinable
//
//  Created by LC on 2025/10/31.
//

import UIKit
import Combine

/// A publisher that installs a gesture recognizer and emits it whenever its state changes.
///
/// The recognizer is added when a subscriber attaches and removed when the subscription is cancelled.
public struct UIGesturePublisher<Gesture: UIGestureRecognizer>: Publisher {
    public typealias Output = Gesture
    public typealias Failure = Never

    private let view: UIView
    private let configure: (Gesture) -> Void

    /// Creates a publisher that observes a gesture on the given view.
    /// - Parameters:
    ///   - view: The view that receives the gesture recognizer.
    ///   - configure: Configures the recognizer before it is added.
    public init(view: UIView, configure: @escaping (Gesture) -> Void) {
        self.view = view
        self.configure = configure
    }

    public func receive<S>(subscriber: S)
    where S: Subscriber, S.Input == Gesture, S.Failure == Never {
        let subscription = Subscription(
            subscriber: subscriber,
            view: view,
            gestureType: Gesture.self,
            configure: configure
        )
        subscriber.receive(subscription: subscription)
    }
}

extension UIGesturePublisher {
    private final class Subscription<S: Subscriber, T: UIGestureRecognizer>: Combine.Subscription
    where S.Input == T {
        private var subscriber: S?
        weak var view: UIView?
        private var gesture: T?

        init(subscriber: S,
             view: UIView,
             gestureType: T.Type,
             configure: @escaping (T) -> Void)
        {
            self.subscriber = subscriber
            self.view = view

            let gesture = gestureType.init(target: self, action: #selector(handleGesture(_:)))
            configure(gesture)
            view.addGestureRecognizer(gesture)
            self.gesture = gesture
        }

        deinit {
            cancel()
        }

        func request(_ demand: Subscribers.Demand) { }

        func cancel() {
            if let gesture = gesture {
                view?.removeGestureRecognizer(gesture)
                // The recognizer retains its target. Dropping this reference breaks that cycle.
                self.gesture = nil
            }
            subscriber = nil
        }

        @objc private func handleGesture(_ sender: UIGestureRecognizer) {
            guard let gesture = sender as? T else { return }
            _ = subscriber?.receive(gesture)
        }
    }

}
