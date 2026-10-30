//
//  Combinable.swift
//  Combinable
//
//  Created by LC on 2025/10/30.
//

import UIKit
import Combine

/// Namespace wrapper. Call Combine extensions through `cb` instead of adding methods directly to UIKit types.
public struct CombinableWrapper<Base> {
    /// The wrapped object.
    public let base: Base

    /// Creates a wrapper for the given object.
    public init(_ base: Base) {
        self.base = base
    }
}

/// Provides the `cb` namespace for reference types.
public protocol CombinableCompatible: AnyObject { }

/// Provides the `cb` namespace for value types.
public protocol CombinableCompatibleValue {}

extension CombinableCompatible {
    /// Entry point for Combinable extensions.
    public var cb: CombinableWrapper<Self> {
        get { return CombinableWrapper(self) }
        set { }
    }
}

extension CombinableCompatibleValue {
    /// Entry point for Combinable extensions.
    public var cb: CombinableWrapper<Self> {
        get { return CombinableWrapper(self) }
        set { }
    }
}

/// Every `NSObject` can use Combinable through `cb`.
extension NSObject: CombinableCompatible { }

/// `AnyCancellable` can bind a subscription to an object's lifetime through `cb`.
extension AnyCancellable: CombinableCompatibleValue { }
