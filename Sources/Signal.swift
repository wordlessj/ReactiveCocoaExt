//
//  Signal.swift
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

public typealias NormalSignal<Value> = Signal<Value, Never>
public typealias VoidSignal = NormalSignal<()>

func enumeratedTransform<Value>() -> (Value) -> (index: Int, value: Value) {
    var index = -1

    return { value in
        index += 1
        return (index, value)
    }
}

extension Signal {
    public func void() -> Signal<(), Error> {
        return map(value: ())
    }

    public func enumerated() -> Signal<(index: Int, value: Value), Error> {
        return map(enumeratedTransform())
    }

    public func map<Samplee: SignalProducerConvertible>(
        latest samplee: Samplee
    ) -> Signal<Samplee.Value, Error> where Samplee.Error == Never {
        return withLatest(from: samplee).map { $1 }
    }

    public func observeOnUI() -> Signal {
        return observe(on: UIScheduler())
    }

    public func flatMapError<F>(_ producer: SignalProducer<Value, F>) -> Signal<Value, F> {
        return flatMapError { _ in producer }
    }

    public func noError() -> NormalSignal<Value> {
        return flatMapError(.empty)
    }

    public func filter<Samplee: SignalProducerConvertible>(while samplee: Samplee) -> Signal
        where Samplee.Value == Bool, Samplee.Error == Never {
            return withLatest(from: samplee).filterMap { $1 ? $0 : nil }
    }

    public func onValue(_ action: @escaping (Value) -> ()) -> Signal {
        return on(value: action)
    }

    public func onCompleted(_ action: @escaping () -> ()) -> Signal {
        return on(completed: action)
    }

    public func onFailed(_ action: @escaping (Error) -> ()) -> Signal {
        return on(failed: action)
    }
}

extension Signal {
    public func with<A: AnyObject>(_ a: A) -> Signal<(Value, A), Error> {
        return take(duringLifetimeOf: a)
            .map { [unowned a] value in (value, a) }
    }

    public func with<A: AnyObject, B: AnyObject>(_ a: A, _ b: B) -> Signal<(Value, A, B), Error> {
        return take(duringLifetimeOf: a)
            .take(duringLifetimeOf: b)
            .map { [unowned a, unowned b] value in (value, a, b) }
    }

    public func with<A: AnyObject, B: AnyObject, C: AnyObject>(
        _ a: A, _ b: B, _ c: C
    ) -> Signal<(Value, A, B, C), Error> {
        return take(duringLifetimeOf: a)
            .take(duringLifetimeOf: b)
            .take(duringLifetimeOf: c)
            .map { [unowned a, unowned b, unowned c] value in (value, a, b, c) }
    }
}

extension Signal where Error == Never {
    @discardableResult
    public func bind(_ action: @escaping (Value) -> Void) -> Disposable? {
        return observeValues(action)
    }
}

extension Signal where Value: Sequence {
    public func filterElement(_ isIncluded: @escaping (Value.Element) -> Bool) -> Signal<[Value.Element], Error> {
        return map { $0.filter(isIncluded) }
    }

    public func mapElement<U>(_ transform: @escaping (Value.Element) -> U) -> Signal<[U], Error> {
        return map { $0.map(transform) }
    }

    public func compactMapElement<U>(_ transform: @escaping (Value.Element) -> U?) -> Signal<[U], Error> {
        return map { $0.compactMap(transform) }
    }

    public func flatMapElement<S: Sequence>(
        _ transform: @escaping (Value.Element) -> S
    ) -> Signal<[S.Element], Error> {
        return map { $0.flatMap(transform) }
    }
}

extension Signal where Value: OptionalProtocol {
    public func mapWrapped<U>(_ transform: @escaping (Value.Wrapped) -> U) -> Signal<U?, Error> {
        return map { $0.optional.map(transform) }
    }

    public func flatMapWrapped<U>(_ transform: @escaping (Value.Wrapped) -> U?) -> Signal<U?, Error> {
        return map { $0.optional.flatMap(transform) }
    }

    public func defaulted(_ value: Value.Wrapped) -> Signal<Value.Wrapped, Error> {
        return map { $0.optional ?? value }
    }
}

extension Signal where Value: OptionalProtocol, Value.Wrapped: Defaultable {
    public func defaulted() -> Signal<Value.Wrapped, Error> {
        return map { $0.optional.defaulted() }
    }
}

extension Signal.Observer: BindingTargetProvider, ReactiveExtensionsProvider {
    public var bindingTarget: BindingTarget<Value> {
        return rac.makeBindingTarget { $0.send(value: $1) }
    }
}

extension Signal.Observer where Value == () {
    public func send() {
        send(value: ())
    }
}
