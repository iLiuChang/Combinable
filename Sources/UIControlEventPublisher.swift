//
//  UIControlEventPublisher.swift
//  Combinable
//
//  Created by LC on 2025/10/30.
//

import Combine
import Foundation
import UIKit

/// A publisher that emits when the specified control events occur.
public struct UIControlEventPublisher<Control: UIControl>: Publisher {
    public typealias Output = Void
    public typealias Failure = Never

    private let control: Control
    private let controlEvents: Control.Event

    /// Creates a publisher for control events.
    /// - Parameters:
    ///   - control: The control to observe.
    ///   - events: Control events that trigger an emission.
    public init(control: Control,
                events: Control.Event) {
        self.control = control
        self.controlEvents = events
    }

    public func receive<S: Subscriber>(subscriber: S) where S.Failure == Failure, S.Input == Output {
        let subscription = Subscription(subscriber: subscriber,
                                        control: control,
                                        event: controlEvents)

        subscriber.receive(subscription: subscription)
    }
}

extension UIControlEventPublisher {
    private final class Subscription<S: Subscriber, C: UIControl>: Combine.Subscription where S.Input == Void {
        private var subscriber: S?
        weak private var control: C?
        private let event: C.Event

        init(subscriber: S, control: C, event: C.Event) {
            self.subscriber = subscriber
            self.control = control
            self.event = event
            control.addTarget(self, action: #selector(processControlEvent), for: event)
        }

        deinit {
            cancel()
        }

        func request(_ demand: Subscribers.Demand) { }

        func cancel() {
            // UIControl does not retain its target, so the target must be removed before this object is released.
            control?.removeTarget(self, action: #selector(processControlEvent), for: event)
            control = nil
            subscriber = nil
        }

        @objc private func processControlEvent() {
            _ = subscriber?.receive()
        }
    }
}
