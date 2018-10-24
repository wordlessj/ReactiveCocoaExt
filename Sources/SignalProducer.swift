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
import Result

public typealias NormalSignalProducer<Value> = SignalProducer<Value, NoError>
public typealias VoidSignalProducer = NormalSignalProducer<()>

extension SignalProducer {
    public func void() -> SignalProducer<(), Error> {
        return map(value: ())
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

extension SignalProducer where Value: Sequence {
    public func mapElement<U>(_ transform: @escaping (Value.Element) -> U) -> SignalProducer<[U], Error> {
        return map { $0.map(transform) }
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
}

extension SignalProducer where Value: OptionalProtocol, Value.Wrapped: Defaultable {
    public func defaulted() -> SignalProducer<Value.Wrapped, Error> {
        return map { $0.optional.defaulted() }
    }
}

extension SignalProducer where Value == Date, Error == NoError {
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
