//
//  Copyright 2020 PLAID, Inc.
//
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//      https://www.apache.org/licenses/LICENSE-2.0
//
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.
//

import Foundation

internal class Queue<T> {
    class Atomic<T> {
        weak var queue: Queue<T>?

        var manipulator: DispatchQueue

        init(_ queue: DispatchQueue) {
            self.manipulator = queue
        }

        init(name: String, qos: DispatchQoS) {
            self.manipulator = DispatchQueue(
                label: "io.karte.queue.\(name)",
                qos: qos
            )
        }

        deinit {
        }

        func enqueue(_ element: T, completion: (() -> Void)? = nil) {
            manipulator.async { [weak self] in
                self?.queue?.enqueue(element)
                completion?()
            }
        }

        func enqueue(elementsOf elements: [T], completion: (() -> Void)? = nil) {
            manipulator.async { [weak self] in
                self?.queue?.enqueue(elementsOf: elements)
                completion?()
            }
        }

        func dequeue(_ completion: @escaping (T?) -> Void) {
            manipulator.async { [weak self] in
                completion(self?.queue?.dequeue())
            }
        }

        func dequeue(where predicate: @escaping (T) -> Bool, completion: @escaping (T?) -> Void) {
            manipulator.async { [weak self] in
                let element = self?.queue?.dequeue(where: predicate)
                completion(element)
            }
        }

        func dequeueLimit(_ max: Int, where predicate: @escaping (T) -> Bool, completion: @escaping ([T]) -> Void) {
            manipulator.async { [weak self] in
                let elements = self?.queue?.dequeueLimit(max, where: predicate) ?? []
                completion(elements)
            }
        }

        func removeAll(_ completion: (() -> Void)? = nil) {
            manipulator.async {
                self.queue?.removeAll()
                completion?()
            }
        }

        func count(_ completion: @escaping (Int) -> Void) {
            manipulator.async { [weak self] in
                completion(self?.queue?.count ?? 0)
            }
        }

        func isEmpty(_ completion: @escaping (Bool) -> Void) {
            manipulator.async { [weak self] in
                completion(self?.queue?.isEmpty ?? false)
            }
        }

        func manipurate(_ execute: @escaping () -> Void) {
            manipulator.async {
                execute()
            }
        }
    }

    var atomic: Atomic<T>

    private var elements: [T]

    var count: Int {
        elements.count
    }

    var isEmpty: Bool {
        elements.isEmpty
    }

    init(_ queue: DispatchQueue) {
        self.elements = []
        self.atomic = Atomic(queue)
        self.atomic.queue = self
    }

    init(name: String, qos: DispatchQoS) {
        self.elements = []
        self.atomic = Atomic(name: name, qos: qos)
        self.atomic.queue = self
    }

    func enqueue(_ element: T) {
        elements.append(element)
    }

    func enqueue(elementsOf elements: [T]) {
        self.elements.append(contentsOf: elements)
    }

    func dequeue() -> T? {
        if elements.isEmpty {
            return nil
        }
        return elements.removeFirst()
    }

    func dequeue(where predicate: (T) -> Bool) -> T? {
        guard let index = elements.firstIndex(where: predicate) else {
            return nil
        }
        return elements.remove(at: index)
    }

    func dequeueLimit(_ max: Int, where predicate: (T) -> Bool) -> [T] {
        let indexes = elements.enumerated().compactMap { offset, element -> Int? in
            let ret = predicate(element) ? offset : nil
            return ret
        }

        var dequeueElements = [T]()
        for index in indexes[0..<Swift.min(max, indexes.count)].reversed() {
            dequeueElements.append(elements.remove(at: index))
        }

        return dequeueElements.reversed()
    }

    func removeAll() {
        elements.removeAll()
    }

    func count(_ isIncluded: (T) -> Bool) -> Int {
        let elements = self.elements.filter(isIncluded)
        return elements.count
    }

    func isEmpty(_ isIncluded: (T) -> Bool) -> Bool {
        count(isIncluded) == 0
    }

    deinit {
    }
}
