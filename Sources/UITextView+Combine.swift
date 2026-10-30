//
//  UITextView+Combine.swift
//  Combinable
//
//  Created by LC on 2025/10/31.
//

import Combine
import UIKit

public extension CombinableWrapper where Base: UITextView {
    /// Text changes. Emits the current `text` for both user edits and programmatic updates.
    var textPublisher: AnyPublisher<String?, Never> {
        Publishers.Merge(
            NotificationCenter.default.publisher(for: UITextView.textDidChangeNotification, object: base)
                .map { ($0.object as? UITextView)?.text },

            base.publisher(for: \.text)
        )
        .removeDuplicates()
        .eraseToAnyPublisher()
    }
}
