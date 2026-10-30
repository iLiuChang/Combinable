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

    /// Emits when the scroll position passes the bottom of the content.
    ///
    /// The threshold is the greater of `offset` and the content offset at which the bottom becomes visible.
    /// - Parameter offset: Minimum vertical offset that must be exceeded. Defaults to `0`.
    func reachedBottomPublisher(offset: CGFloat = 0) -> AnyPublisher<Void, Never> {
        contentOffsetPublisher
            .map { [weak base] contentOffset -> Bool in
                guard let self = base else { return false }
                let visibleHeight = self.frame.height - self.contentInset.top - self.contentInset.bottom
                let yDelta = contentOffset.y + self.contentInset.top
                let threshold = max(offset, self.contentSize.height - visibleHeight)
                return yDelta > threshold
            }
            .removeDuplicates()
            .filter { $0 }
            .map { _ in () }
            .eraseToAnyPublisher()
    }
}
