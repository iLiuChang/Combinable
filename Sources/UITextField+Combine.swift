//
//  UITextField+Combine.swift
//  Combinable
//
//  Created by LC on 2025/10/30.
//

import Combine
import UIKit

public extension CombinableWrapper where Base: UITextField {
    /// Text changes. Emits the current `text` for both user edits and programmatic updates.
    var textPublisher: AnyPublisher<String?, Never> {
        Publishers.Merge(
            UIControlPropertyPublisher(control: base, events: .allEditingEvents, keyPath: \.text),

            base.publisher(for: \.text)
        )
        .removeDuplicates()
        .eraseToAnyPublisher()
    }

    /// Attributed text changes. Emits the current `attributedText` for both user edits and programmatic updates.
    var attributedTextPublisher: AnyPublisher<NSAttributedString?, Never> {
        Publishers.Merge(
            UIControlPropertyPublisher(control: base, events: .allEditingEvents, keyPath: \.attributedText),

            base.publisher(for: \.attributedText)
        )
        .removeDuplicates { previous, current in
            switch (previous, current) {
            case (nil, nil):
                return true
            case let (previous?, current?):
                return previous.isEqual(to: current)
            default:
                return false
            }
        }
        .eraseToAnyPublisher()
    }

}
