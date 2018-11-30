//
//  LimitQueue.swift
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

public class LimitQueue<Value> {
    private struct PendingItem {
        var producer: NormalSignalProducer<Value>
        var observer: NormalSignal<Value>.Observer
        var lifetime: Lifetime
    }

    private let limit: Int

    private var runningCount = 0
    private var pendingItems = [PendingItem]()

    public init(_ limit: Int = 1) {
        self.limit = limit
    }

    public func add(_ producer: NormalSignalProducer<Value>) -> NormalSignalProducer<Value> {
        return SignalProducer { observer, lifetime in
            let item = PendingItem(producer: producer, observer: observer, lifetime: lifetime)

            if self.runningCount < self.limit {
                self.run(item)
            } else {
                self.pendingItems.append(item)
            }
        }
    }

    private func run(_ item: PendingItem) {
        runningCount += 1

        item.lifetime += item.producer.start { [observer = item.observer] event in
            if event.isTerminating {
                self.runningCount -= 1

                if !self.pendingItems.isEmpty {
                    let item = self.pendingItems.removeFirst()
                    self.run(item)
                }
            }

            observer.send(event)
        }
    }
}

public class KeyLimitQueue<Key: Hashable, Value> {
    private let limitQueue: LimitQueue<Value>
    private var queuedKeys = [Key: [NormalSignal<Value>.Observer]]()

    public init(_ limit: Int = 1) {
        limitQueue = LimitQueue(limit)
    }

    public func add(_ producer: NormalSignalProducer<Value>, key: Key) -> NormalSignalProducer<Value> {
        return SignalProducer { observer, lifetime in
            if self.queuedKeys[key] != nil {
                self.queuedKeys[key]!.append(observer)
            } else {
                self.queuedKeys[key] = []

                lifetime += self.limitQueue.add(producer).start { event in
                    observer.send(event)
                    self.queuedKeys[key]?.forEach { $0.send(event) }

                    if event.isTerminating {
                        self.queuedKeys[key] = nil
                    }
                }
            }
        }
    }
}
