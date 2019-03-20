//
//  UIScrollView.swift
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

import ReactiveSwift

class ScrollViewForwarder: WeakForwarder<UIScrollViewDelegate>, UIScrollViewDelegate {
    let (scrolled, scrolledObserver) = NormalSignal<UIScrollView>.pipe()
    let (draggingBegan, draggingBeganObserver) = VoidSignal.pipe()
    let (draggingEnded, draggingEndedObserver) = NormalSignal<Bool>.pipe()
    let (deceleratingEnded, deceleratingEndedObserver) = VoidSignal.pipe()
    let (scrollingAnimationEnded, scrollingAnimationEndedObserver) = VoidSignal.pipe()

    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        forwardee?.scrollViewDidScroll?(scrollView)
        scrolledObserver.send(value: scrollView)
    }

    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        forwardee?.scrollViewWillBeginDragging?(scrollView)
        draggingBeganObserver.send()
    }

    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        forwardee?.scrollViewDidEndDragging?(scrollView, willDecelerate: decelerate)
        draggingEndedObserver.send(value: decelerate)
    }

    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        forwardee?.scrollViewDidEndDecelerating?(scrollView)
        deceleratingEndedObserver.send()
    }

    func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView) {
        forwardee?.scrollViewDidEndScrollingAnimation?(scrollView)
        scrollingAnimationEndedObserver.send()
    }
}

private var forwarderKey: UInt8 = 0

extension UIScrollView {
    var scrollForwarder: ScrollViewForwarder {
        return objc_getAssociatedObject(self, &forwarderKey) as? ScrollViewForwarder ?? {
            let forwarder = ScrollViewForwarder(forwardee: delegate)
            delegate = forwarder
            objc_setAssociatedObject(self, &forwarderKey, forwarder, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            return forwarder
        }()
    }
}

extension Reactive where Base: UIScrollView {
    public var scrolled: NormalSignal<UIScrollView> {
        return base.scrollForwarder.scrolled
    }

    public var draggingBegan: VoidSignal {
        return base.scrollForwarder.draggingBegan
    }

    public var draggingEnded: NormalSignal<Bool> {
        return base.scrollForwarder.draggingEnded
    }

    public var deceleratingEnded: VoidSignal {
        return base.scrollForwarder.deceleratingEnded
    }

    public var draggingDeceleratingEnded: VoidSignal {
        return .merge(
            draggingEnded.filter { !$0 }.void(),
            deceleratingEnded
        )
    }

    public var scrollingAnimationEnded: VoidSignal {
        return base.scrollForwarder.scrollingAnimationEnded
    }
}
