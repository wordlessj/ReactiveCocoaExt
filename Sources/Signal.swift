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
import Result

public typealias NormalSignal<Value> = Signal<Value, NoError>
public typealias VoidSignal = NormalSignal<()>

extension Signal {
    public func void() -> Signal<(), Error> {
        return map(value: ())
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

extension Signal where Value: Sequence {
    public func mapElement<U>(_ transform: @escaping (Value.Element) -> U) -> Signal<[U], Error> {
        return map { $0.map(transform) }
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
