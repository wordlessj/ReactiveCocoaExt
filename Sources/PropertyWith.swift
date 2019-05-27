//
//  PropertyWith.swift
//  ReactiveCocoaExt
//
//  Copyright (c) 2019 Javier Zhang (https://wordlessj.github.io/)
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.
//

import ReactiveSwift

public struct PropertyWithOne<P: PropertyProtocol, A: AnyObject> {
    var property: P
    var a: A

    public func map<U>(_ transform: @escaping (P.Value, A) -> U) -> Property<U> {
        return Property(
            initial: transform(property.value, a),
            then: property.signal.with(a).map(transform)
        )
    }

    @discardableResult
    public func bind(_ action: @escaping (P.Value, A) -> Void) -> Disposable {
        return property.producer.with(a).bind(action)
    }
}

public struct PropertyWithTwo<P: PropertyProtocol, A: AnyObject, B: AnyObject> {
    var property: P
    var a: A
    var b: B

    public func map<U>(_ transform: @escaping (P.Value, A, B) -> U) -> Property<U> {
        return Property(
            initial: transform(property.value, a, b),
            then: property.signal.with(a, b).map(transform)
        )
    }

    @discardableResult
    public func bind(_ action: @escaping (P.Value, A, B) -> Void) -> Disposable {
        return property.producer.with(a, b).bind(action)
    }
}

public struct PropertyWithThree<P: PropertyProtocol, A: AnyObject, B: AnyObject, C: AnyObject> {
    var property: P
    var a: A
    var b: B
    var c: C

    public func map<U>(_ transform: @escaping (P.Value, A, B, C) -> U) -> Property<U> {
        return Property(
            initial: transform(property.value, a, b, c),
            then: property.signal.with(a, b, c).map(transform)
        )
    }

    @discardableResult
    public func bind(_ action: @escaping (P.Value, A, B, C) -> Void) -> Disposable {
        return property.producer.with(a, b, c).bind(action)
    }
}

extension PropertyProtocol {
    public func with<A: AnyObject>(_ a: A) -> PropertyWithOne<Self, A> {
        return PropertyWithOne(property: self, a: a)
    }

    public func with<A: AnyObject, B: AnyObject>(_ a: A, _ b: B) -> PropertyWithTwo<Self, A, B> {
        return PropertyWithTwo(property: self, a: a, b: b)
    }

    public func with<A: AnyObject, B: AnyObject, C: AnyObject>(
        _ a: A, _ b: B, _ c: C
    ) -> PropertyWithThree<Self, A, B, C> {
        return PropertyWithThree(property: self, a: a, b: b, c: c)
    }
}
