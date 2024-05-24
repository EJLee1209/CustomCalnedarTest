//
//  Builder.swift
//  CustomCalnedarTest
//
//  Created by 굿소프트_이은재 on 5/22/24.
//

import Foundation

@dynamicMemberLookup
public struct Builder<Base: AnyObject> {

    private let _build: () -> Base

    public init(_ build: @escaping () -> Base) {
        self._build = build
    }

    public init(_ base: Base) {
        self._build = { base }
    }

    public subscript<Value>(dynamicMember keyPath: ReferenceWritableKeyPath<Base, Value>) -> (Value) -> Builder<Base> {
        { [build = _build] value in
            Builder {
                let object = build()
                object[keyPath: keyPath] = value
                return object
            }
        }
    }

    public func build() -> Base {
        _build()
    }
}

public protocol LayoutCompatible {
    associatedtype LayoutBase: AnyObject
    var with: Builder<LayoutBase> { get set }
}

extension LayoutCompatible where Self: AnyObject {
    public var with: Builder<Self> {
        get { Builder(self) }
        set {}
    }
}

extension NSObject: LayoutCompatible {}
