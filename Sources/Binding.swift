//
//  Binding.swift
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

extension BindingTargetProvider {
    public static func <~ (provider: Self, source: Value) {
        provider.bindingTarget.action(source)
    }
}

extension BindingTargetProvider where Value == () {
    @discardableResult
    public static func <~ <Source: BindingSource>(provider: Self, source: Source) -> Disposable? {
        return source.producer
            .void()
            .take(during: provider.bindingTarget.lifetime)
            .startWithValues(provider.bindingTarget.action)
    }
}

extension BindingTarget {
    public func reversedMap<U>(_ transform: @escaping (U) -> Value) -> BindingTarget<U> {
        return BindingTarget<U>(lifetime: lifetime) { [action] value in
            action(transform(value))
        }
    }
}

extension BindingTarget where Value == Bool {
    public func negate() -> BindingTarget<Value> {
        return reversedMap { !$0 }
    }
}
