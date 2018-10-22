//
//  UICollectionView.swift
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

class CollectionViewForwarder: WeakForwarder<UICollectionViewDelegate>, UICollectionViewDelegate {
    let (selected, selectedObserver) = NormalSignal<IndexPath>.pipe()

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        forwardee?.collectionView?(collectionView, didSelectItemAt: indexPath)
        selectedObserver.send(value: indexPath)
    }
}

private var forwarderKey: UInt8 = 0

extension UICollectionView {
    var forwarder: CollectionViewForwarder {
        return objc_getAssociatedObject(self, &forwarderKey) as? CollectionViewForwarder ?? {
            let forwarder = CollectionViewForwarder(forwardee: delegate)
            delegate = forwarder
            objc_setAssociatedObject(self, &forwarderKey, forwarder, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            return forwarder
        }()
    }
}

extension Reactive where Base: UICollectionView {
    public var selected: NormalSignal<IndexPath> {
        return base.forwarder.selected
    }
}
