//
//  UIControl+Combine.swift
//  Combinable
//
//  Created by LC on 2025/10/30.
//

import Combine
import UIKit

public extension CombinableWrapper where Base: UIControl {
    /// Emits whenever any of the given control events occur.
    /// - Parameter events: The control events to observe.
    func controlEventPublisher(for events: UIControl.Event) -> AnyPublisher<Void, Never> {
        UIControlEventPublisher(control: base, events: events)
                  .eraseToAnyPublisher()
    }
}
