//
//  UIKeyboard.swift
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
import ReactiveCocoa

extension KeyboardChangeContext {
    public var animationOptions: UIView.AnimationOptions {
        return .init(rawValue: UInt(animationCurve.rawValue))
    }

    public func animate(delay: TimeInterval = 0, animations: @escaping () -> ()) {
        animate(delay: delay, animations: animations, completion: nil)
    }

    public func animate(delay: TimeInterval = 0, animations: @escaping () -> (), completion: ((Bool) -> ())?) {
        UIView.animate(
            withDuration: animationDuration,
            delay: delay,
            options: animationOptions,
            animations: animations,
            completion: completion
        )
    }
}

extension KeyboardEvent: ReactiveExtensionsProvider {}

extension Reactive where Base == KeyboardEvent {
    public func signal() -> NormalSignal<KeyboardChangeContext> {
        return NotificationCenter.default.rac.keyboard(base)
    }
}
