//
//  Optional.swift
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

import Foundation

public protocol Defaultable {
    static var defaultValue: Self { get }
}

extension Bool: Defaultable {
    public static let defaultValue = false
}

extension Int: Defaultable {
    public static let defaultValue = 0
}

extension Double: Defaultable {
    public static let defaultValue = 0.0
}

extension String: Defaultable {
    public static let defaultValue = ""
}

extension Array: Defaultable {
    public static var defaultValue: [Element] { return [] }
}

extension Dictionary: Defaultable {
    public static var defaultValue: [Key: Value] { return [:] }
}

extension CGFloat: Defaultable {
    public static var defaultValue: CGFloat = 0
}

extension Optional where Wrapped: Defaultable {
    public func defaulted() -> Wrapped {
        switch self {
        case .none: return Wrapped.defaultValue
        case let .some(wrapped): return wrapped
        }
    }
}
