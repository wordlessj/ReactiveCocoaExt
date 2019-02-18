//
//  CALayer.swift
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

import QuartzCore
import ReactiveSwift

extension Reactive where Base: CALayer {
    public var cornerRadius: BindingTarget<CGFloat> {
        return makeBindingTarget { $0.cornerRadius = $1 }
    }

    @available(iOS 11.0, *)
    public var maskedCorners: BindingTarget<CACornerMask> {
        return makeBindingTarget { $0.maskedCorners = $1 }
    }

    public var borderWidth: BindingTarget<CGFloat> {
        return makeBindingTarget { $0.borderWidth = $1 }
    }

    public var borderColor: BindingTarget<UIColor?> {
        return makeBindingTarget { $0.borderColor = $1?.cgColor }
    }

    public var shadowOpacity: BindingTarget<CGFloat> {
        return makeBindingTarget { $0.shadowOpacity = Float($1) }
    }

    public var shadowRadius: BindingTarget<CGFloat> {
        return makeBindingTarget { $0.shadowRadius = $1 }
    }

    public var shadowOffset: BindingTarget<CGSize> {
        return makeBindingTarget { $0.shadowOffset = $1 }
    }

    public var shadowColor: BindingTarget<UIColor?> {
        return makeBindingTarget { $0.shadowColor = $1?.cgColor }
    }
}
