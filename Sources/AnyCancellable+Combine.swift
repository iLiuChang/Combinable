//
//  AnyCancellable+Combine.swift
//  Combinable
//
//  Created by LC on 2025/10/31.
//

import Combine
import Foundation

private var cancellablesKey: UInt8 = 0

extension CombinableWrapper where Base: NSObject {
    /// Cancellables retained by this object. They are cancelled when the object is deallocated.
    public var cancellables: Set<AnyCancellable> {
        get {
            if let wrapper = objc_getAssociatedObject(base, &cancellablesKey) as? CancellableWrapper {
                return wrapper.cancellables
            }
            let cancellables = Set<AnyCancellable>()
            base.cb.cancellables = cancellables
            return cancellables
        }
        set {
            let wrapper = CancellableWrapper(cancellables: newValue)
            objc_setAssociatedObject(base, &cancellablesKey, wrapper, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
}

extension CombinableWrapper where Base: AnyCancellable {
    /// Stores this cancellable in the given object's `cancellables` set.
    /// - Parameter object: The object that should retain the subscription.
    public func store(in object: NSObject) {
        base.store(in: &object.cb.cancellables)
    }
}

/// Box that lets a cancellable set be stored as an associated object.
private class CancellableWrapper {
    let cancellables: Set<AnyCancellable>

    init(cancellables: Set<AnyCancellable>) {
        self.cancellables = cancellables
    }
}
