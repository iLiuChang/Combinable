//
//  UIScrollView+Combine.swift
//  Combinable
//
//  Created by LC on 2025/10/30.
//

import UIKit
import Combine

public extension CombinableWrapper where Base: UIScrollView {
    /// Content offset changes.
    var contentOffsetPublisher: AnyPublisher<CGPoint, Never> {
        base.publisher(for: \.contentOffset)
            .eraseToAnyPublisher()
    }

    /// Emits when the scroll position comes within `offset` points of the bottom.
    ///
    /// Also emits when the content is shorter than the visible area. A `contentSize` height of zero does not emit.
    /// - Parameter offset: Distance from the bottom, in points, at which to emit. Defaults to `0`.
    func reachedBottomPublisher(offset: CGFloat = 0) -> AnyPublisher<Void, Never> {
        Publishers.CombineLatest(
            contentOffsetPublisher,
            base.publisher(for: \.contentSize)
        )
        .map { [weak base] contentOffset, contentSize -> Bool in
            guard let scrollView = base else { return false }
            let inset = scrollView.adjustedContentInset
            let visibleHeight = scrollView.bounds.height - inset.top - inset.bottom
            guard contentSize.height > 0, visibleHeight > 0 else { return false }
            let y = contentOffset.y + inset.top
            let threshold = contentSize.height - visibleHeight - offset
            return y >= threshold
        }
        .removeDuplicates()
        .filter { $0 }
        .map { _ in () }
        .eraseToAnyPublisher()
    }
}
