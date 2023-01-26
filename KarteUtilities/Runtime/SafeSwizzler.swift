//
//  Copyright 2023 PLAID, Inc.
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

/// このクラスは Method swizzling したメソッドの Class / Selector および IMP を管理するためのクラスです。
///
/// なおこのクラスではスコープの管理のみを行い、Class / Selector および IMP の管理は Scope クラスで行なっています。
public class SafeSwizzler {
    /// シングルトンなインスタンスを返します。
    public static let shared = SafeSwizzler()

    private var nameToScope = [String: Scope]()

    private init() {
    }

    /// 名前に紐付くスコープを返します。
    /// - Parameter initializer: スコープを初期化用のブロック
    /// - Returns: スコープ
    public static func scope(_ initializer: (ScopeBuilder) -> Void) -> Scope {
        let builder = ScopeBuilder(shared)
        initializer(builder)

        let name = builder.name
        if let scope = shared.nameToScope[name] {
            return scope
        }

        let scope = builder.build()
        shared.nameToScope[name] = scope
        return scope
    }

    deinit {
    }
}

public extension SafeSwizzler {
    /// このクラスは Method swizzling したメソッドの Class / Selector および IMP をスコープ毎に管理するためのクラスです。
    ///
    /// ここでのスコープとは同一 Class / Selector に対する実装を名前毎に管理するためのものとして利用しています。
    class Scope {
        private let swizzler: SafeSwizzler
        private let name: String

        private var signatureToPair = [Signature: Pair]()

        init(_ swizzler: SafeSwizzler, name: String) {
            self.swizzler = swizzler
            self.name = name
        }

        /// メソッドの実装を置換します。
        /// - Parameters:
        ///   - cls: 対象メソッドが属するクラス
        ///   - name: 対象メソッドのセレクタ
        ///   - imp: 置換する実装
        public func swizzle(cls: AnyClass, name: Selector, imp: IMP) {
            let signature = Signature(cls: cls, sel: name)
            swizzle(imp: imp, forSignature: signature)
        }

        /// 指定されたクラスとセレクタに基づき、実装の置換を解除します。
        /// - Parameters:
        ///   - cls: 対象メソッドが属するクラス
        ///   - name: 対象メソッドのセレクタ
        public func unswizzle(cls: AnyClass, name: Selector) {
            let signature = Signature(cls: cls, sel: name)
            unswizzle(forSignature: signature)
        }

        /// 全ての実装の置換を解除します。
        public func unswizzle() {
            for (signature, _) in signatureToPair {
                unswizzle(forSignature: signature)
            }
        }

        /// 指定されたクラスとセレクタに基づき、オリジナル実装を返します。
        /// - Parameters:
        ///   - cls: 対象メソッドが属するクラス
        ///   - name: 対象メソッドのセレクタ
        /// - Returns: オリジナル実装がある場合はそれを返し、ない場合は nil を返します。
        public func originalImplementation(cls: AnyClass, name: Selector) -> IMP? {
            let signature = Signature(cls: cls, sel: name)
            guard let pair = originalImplementationPair(forSignature: signature) else {
                return nil
            }

            return pair.original
        }

        private func swizzle(imp: IMP, forSignature signature: Signature) {
            guard let method = class_getInstanceMethod(signature.cls, signature.sel) else {
                return
            }

            let originalImp = method_setImplementation(method, imp)
            if originalImp != imp {
                putImplementationPair(Pair(original: originalImp, custom: imp), forSignature: signature)
            }
        }

        private func unswizzle(forSignature signature: Signature) {
            guard let pair = signatureToPair[signature] else {
                return
            }

            guard let method = class_getInstanceMethod(signature.cls, signature.sel) else {
                return
            }

            let imp = method_getImplementation(method)
            guard imp == pair.custom else {
                return
            }

            method_setImplementation(method, pair.original)
            removeImplementationPair(forSignature: signature)
        }

        private func putImplementationPair(_ pair: Pair, forSignature signature: Signature) {
            signatureToPair[signature] = pair
        }

        private func removeImplementationPair(forSignature signature: Signature) {
            signatureToPair[signature] = nil
        }

        private func originalImplementationPair(forSignature signature: Signature) -> Pair? {
            return signatureToPair[signature]
        }
    }

    /// スコープを構築するためのクラスです。
    class ScopeBuilder {
        private let swizzler: SafeSwizzler
        private var components = [String]()

        var name: String {
            components.joined(separator: "::")
        }

        init(_ swizzler: SafeSwizzler) {
            self.swizzler = swizzler
        }

        /// スコープ名を構成する要素を追加します。
        /// - Parameter type: 型
        /// - Returns: 自身のインスタンスを返します。
        @discardableResult
        public func add<T>(_ type: T.Type) -> ScopeBuilder {
            components.append(String(describing: type))
            return self
        }

        func build() -> Scope {
            Scope(swizzler, name: name)
        }
    }
}

internal extension SafeSwizzler {
    class Signature: Hashable {
        let cls: AnyClass
        let sel: Selector

        init(cls: AnyClass, sel: Selector) {
            self.cls = cls
            self.sel = sel
        }

        func hash(into hasher: inout Hasher) {
            hasher.combine(NSStringFromClass(cls))
            hasher.combine(NSStringFromSelector(sel))
        }

        static func == (lhs: SafeSwizzler.Signature, rhs: SafeSwizzler.Signature) -> Bool {
            return NSStringFromClass(lhs.cls) == NSStringFromClass(rhs.cls) && NSStringFromSelector(lhs.sel) == NSStringFromSelector(rhs.sel)
        }
    }

    class Pair {
        let original: IMP
        let custom: IMP

        init(original: IMP, custom: IMP) {
            self.original = original
            self.custom = custom
        }
    }
}
