//
//  SignalProducer.swift
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

public typealias NormalSignalProducer<Value> = SignalProducer<Value, Never>
public typealias VoidSignalProducer = NormalSignalProducer<()>

extension SignalProducer {
    public func void() -> SignalProducer<(), Error> {
        return map(value: ())
    }

    public func enumerated() -> SignalProducer<(index: Int, value: Value), Error> {
        return map(enumeratedTransform())
    }

    public func map<Samplee: SignalProducerConvertible>(
        latest samplee: Samplee
    ) -> SignalProducer<Samplee.Value, Error> where Samplee.Error == Never {
        return withLatest(from: samplee).map { $1 }
    }

    public func observeOnUI() -> SignalProducer {
        return observe(on: UIScheduler())
    }

    public func flatMapError<F>(_ producer: SignalProducer<Value, F>) -> SignalProducer<Value, F> {
        return flatMapError { _ in producer }
    }

    public func noError() -> NormalSignalProducer<Value> {
        return flatMapError(.empty)
    }

    public func filter<Samplee: SignalProducerConvertible>(while samplee: Samplee) -> SignalProducer
        where Samplee.Value == Bool, Samplee.Error == Never {
            return withLatest(from: samplee).filterMap { $1 ? $0 : nil }
    }

    public func onValue(_ action: @escaping (Value) -> ()) -> SignalProducer {
        return on(value: action)
    }

    public func onCompleted(_ action: @escaping () -> ()) -> SignalProducer {
        return on(completed: action)
    }

    public func onFailed(_ action: @escaping (Error) -> ()) -> SignalProducer {
        return on(failed: action)
    }
}

extension SignalProducer {
    public func with<A: AnyObject>(_ a: A) -> SignalProducer<(Value, A), Error> {
        return lift { $0.with(a) }
    }

    public func with<A: AnyObject, B: AnyObject>(_ a: A, _ b: B) -> SignalProducer<(Value, A, B), Error> {
        return lift { $0.with(a, b) }
    }

    public func with<A: AnyObject, B: AnyObject, C: AnyObject>(
        _ a: A, _ b: B, _ c: C
    ) -> SignalProducer<(Value, A, B, C), Error> {
        return lift { $0.with(a, b, c) }
    }
}

extension SignalProducer where Error == Never {
    @discardableResult
    public func bind(_ action: @escaping (Value) -> Void) -> Disposable {
        return startWithValues(action)
    }
}

extension SignalProducer where Value: Sequence {
    public func filterElement(
        _ isIncluded: @escaping (Value.Element) -> Bool
    ) -> SignalProducer<[Value.Element], Error> {
        return map { $0.filter(isIncluded) }
    }

    public func mapElement<U>(_ transform: @escaping (Value.Element) -> U) -> SignalProducer<[U], Error> {
        return map { $0.map(transform) }
    }

    public func compactMapElement<U>(_ transform: @escaping (Value.Element) -> U?) -> SignalProducer<[U], Error> {
        return map { $0.compactMap(transform) }
    }

    public func flatMapElement<S: Sequence>(
        _ transform: @escaping (Value.Element) -> S
    ) -> SignalProducer<[S.Element], Error> {
        return map { $0.flatMap(transform) }
    }
}

extension SignalProducer where Value: OptionalProtocol {
    public func mapWrapped<U>(_ transform: @escaping (Value.Wrapped) -> U) -> SignalProducer<U?, Error> {
        return map { $0.optional.map(transform) }
    }

    public func flatMapWrapped<U>(_ transform: @escaping (Value.Wrapped) -> U?) -> SignalProducer<U?, Error> {
        return map { $0.optional.flatMap(transform) }
    }

    public func defaulted(_ value: Value.Wrapped) -> SignalProducer<Value.Wrapped, Error> {
        return map { $0.optional ?? value }
    }
}

extension SignalProducer where Value: OptionalProtocol, Value.Wrapped: Defaultable {
    public func defaulted() -> SignalProducer<Value.Wrapped, Error> {
        return map { $0.optional.defaulted() }
    }
}

extension SignalProducer where Value == Date, Error == Never {
    public static func timer(
        interval: Double,
        on scheduler: DateScheduler = QueueScheduler.main
    ) -> SignalProducer<Value, Error> {
        return timer(interval: DispatchTimeInterval(interval), on: scheduler)
    }

    public static func timer(
        immediateInterval interval: Double,
        on scheduler: DateScheduler = QueueScheduler.main
    ) -> SignalProducer<Value, Error> {
        return timer(interval: interval, on: scheduler).prefix(value: Date())
    }
}
