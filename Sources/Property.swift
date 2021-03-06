//
//  Property.swift
//  ReactiveCocoaExt
//
//  Copyright (c) 2018 Javier Zhang (https://wordlessj.github.io/)
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

extension PropertyProtocol {
    public func void() -> Property<()> {
        return map(value: ())
    }

    public func enumerated() -> Property<(index: Int, value: Value)> {
        return map(enumeratedTransform())
    }

    @discardableResult
    public func bind(_ action: @escaping (Value) -> Void) -> Disposable {
        return producer.bind(action)
    }
}

extension PropertyProtocol where Value: Sequence {
    public func filterElement(_ isIncluded: @escaping (Value.Element) -> Bool) -> Property<[Value.Element]> {
        return map { $0.filter(isIncluded) }
    }

    public func mapElement<U>(_ transform: @escaping (Value.Element) -> U) -> Property<[U]> {
        return map { $0.map(transform) }
    }

    public func compactMapElement<U>(_ transform: @escaping (Value.Element) -> U?) -> Property<[U]> {
        return map { $0.compactMap(transform) }
    }

    public func flatMapElement<S: Sequence>(
        _ transform: @escaping (Value.Element) -> S
    ) -> Property<[S.Element]> {
        return map { $0.flatMap(transform) }
    }
}

extension PropertyProtocol where Value: OptionalProtocol {
    public func mapWrapped<U>(_ transform: @escaping (Value.Wrapped) -> U) -> Property<U?> {
        return map { $0.optional.map(transform) }
    }

    public func flatMapWrapped<U>(_ transform: @escaping (Value.Wrapped) -> U?) -> Property<U?> {
        return map { $0.optional.flatMap(transform) }
    }

    public func defaulted(_ value: Value.Wrapped) -> Property<Value.Wrapped> {
        return map { $0.optional ?? value }
    }
}

extension PropertyProtocol where Value: OptionalProtocol, Value.Wrapped: Defaultable {
    public func defaulted() -> Property<Value.Wrapped> {
        return map { $0.optional.defaulted() }
    }
}

extension Property where Value == Date {
    public static func timer(
        interval: Double,
        on scheduler: DateScheduler = QueueScheduler.main
    ) -> Property<Value> {
        return Property(initial: Date(), then: .timer(interval: interval, on: scheduler))
    }
}
