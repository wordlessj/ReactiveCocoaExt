//
//  Object.swift
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

extension Reactive where Base: AnyObject {
    public subscript(_ action: @escaping (Base) -> () -> ()) -> BindingTarget<()> {
        return makeBindingTarget { base, _ in
            action(base)()
        }
    }

    public subscript<Value>(_ action: @escaping (Base) -> (Value) -> ()) -> BindingTarget<Value> {
        return makeBindingTarget { base, value in
            action(base)(value)
        }
    }

    public subscript<A, B>(_ action: @escaping (Base) -> (A, B) -> ()) -> BindingTarget<(A, B)> {
        return makeBindingTarget { base, value in
            let (a, b) = value
            action(base)(a, b)
        }
    }

    public subscript<A, B, C>(_ action: @escaping (Base) -> (A, B, C) -> ()) -> BindingTarget<(A, B, C)> {
        return makeBindingTarget { base, value in
            let (a, b, c) = value
            action(base)(a, b, c)
        }
    }
}

extension Reactive where Base: NSObject {
    public func producer<Value>(_ keyPath: KeyPath<Base, Value>) -> NormalSignalProducer<Value> {
        return SignalProducer { [base] observer, lifetime in
            let token = base.observe(keyPath) { base, _ in
                observer.send(value: base[keyPath: keyPath])
            }

            lifetime.observeEnded { token.invalidate() }
        }
    }
}
