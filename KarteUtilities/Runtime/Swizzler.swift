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
import ObjectiveC

/// このクラスは Method swizzling したメソッドのセレクタおよび実装ブロックを管理するためのクラスです。
@available(*, deprecated, message: "Use SafeSwizzler instead.")
public class Swizzler {
    /// シングルトンなインスタンスを返します。
    public static let shared = Swizzler()

    private var originalImplementations = [String: IMP]()
    private var swizzledClasses = [String: AnyClass]()
    private var swizzledSelectors = [String: Set<String>]()

    /// メソッドの実装を置換します。
    /// - Parameters:
    ///   - label: 置換情報を管理するためのラベル
    ///   - cls: 対象メソッドが属するクラス
    ///   - name: 対象メソッドのセレクタ
    ///   - imp: 置換する実装
    ///   - proto: プロトコル（未使用）
    public func swizzle(label: String, cls: AnyClass?, name: Selector, imp: IMP, proto: Protocol) {
        if let originalMethod = class_getInstanceMethod(cls, name) {
            let originalImp = method_setImplementation(originalMethod, imp)
            if originalImp != imp {
                saveImplementation(originalImp, forName: name)
                saveClass(cls, forName: name)
                saveSelector(name, forLabel: label)
            }
        }
    }

    /// ラベルに関連する置換情報に基づき、置換を解除する。
    /// - Parameter label: ラベル
    public func unswizzle(label: String) {
        guard let selectors = swizzledSelectors[label] else {
            return
        }

        for selector in selectors.map({ NSSelectorFromString($0) }) {
            unswizzle(label: label, cls: swizzledClass(forName: selector), name: selector)
        }

        removeSelectors(forLabel: label)
    }

    /// ラベルに関連する置換情報とクラスおよびセレクタに基づき、置換を解除する。
    /// - Parameters:
    ///   - label: ラベル
    ///   - cls: 対象メソッドが属するクラス
    ///   - name: 対象メソッドのセレクタ
    public func unswizzle(label: String, cls: AnyClass?, name: Selector) {
        guard let swizzledMethod = class_getInstanceMethod(cls, name) else {
            return
        }

        guard let originalImp = originalImplementation(forName: name) else {
            return
        }

        method_setImplementation(swizzledMethod, originalImp)
        removeImplementation(forName: name)
        removeClass(forName: name)
        removeSelector(name, forLabel: label)
    }

    /// 指定されたセレクタに関連するオリジナル実装にアクセスします。
    /// - Parameter name: 対象メソッドのセレクタ
    /// - Returns: 指定されたセレクタに関連するオリジナル実装がある場合はそれを返し、ない場合は nil を返します。
    public func originalImplementation(forName name: Selector) -> IMP? {
        let key = NSStringFromSelector(name)
        return originalImplementations[key]
    }

    private func saveSelector(_ selector: Selector, forLabel label: String) {
        let name = NSStringFromSelector(selector)
        if var selectors = swizzledSelectors[label] {
            selectors.insert(name)
            swizzledSelectors[label] = selectors
        } else {
            swizzledSelectors[label] = Set([name])
        }
    }

    private func removeSelector(_ selector: Selector, forLabel label: String) {
        let name = NSStringFromSelector(selector)
        if var selectors = swizzledSelectors[label], selectors.contains(name) {
            selectors.remove(name)
            swizzledSelectors[label] = selectors
        }
    }

    private func removeSelectors(forLabel label: String) {
        swizzledSelectors[label] = nil
    }

    private func saveImplementation(_ imp: IMP, forName name: Selector) {
        let key = NSStringFromSelector(name)
        originalImplementations[key] = imp
    }

    private func removeImplementation(forName name: Selector) {
        let key = NSStringFromSelector(name)
        originalImplementations[key] = nil
    }

    private func saveClass(_ cls: AnyClass?, forName name: Selector) {
        let key = NSStringFromSelector(name)
        if let cls = cls {
            swizzledClasses[key] = cls
        }
    }

    private func removeClass(forName name: Selector) {
        let key = NSStringFromSelector(name)
        swizzledClasses[key] = nil
    }

    private func swizzledClass(forName name: Selector) -> AnyClass? {
        let key = NSStringFromSelector(name)
        return swizzledClasses[key]
    }

    deinit {
    }
}

/// AnyObject に対応する操作をまとめたヘルパー関数
public enum AnyObjectHelper {
    /// 指定したプロパティにアクセスします。
    /// - Parameters:
    ///   - object: 対象オブジェクト
    ///   - propertyName: プロパティ名
    ///   - cls: 取得した値がクラスに適合するかチェックするために指定する値
    /// - Returns: 値がある場合はそれを返し、ない場合は nil を返します。
    public static func propertyValue(from object: AnyObject, propertyName: String, cls: AnyClass?) -> AnyObject? {
        let sel = NSSelectorFromString(propertyName)
        guard responds(to: sel, object: object) else {
            return nil
        }

        var clazz: AnyClass
        if let cls = cls {
            clazz = cls
        } else {
            clazz = NSObject.self
        }

        guard let value = object.perform(sel)?.takeUnretainedValue(), value.isKind(of: clazz) else {
            return nil
        }

        return value
    }

    /// 指定したプロパティにアクセスします。
    /// - Parameters:
    ///   - object: 対象オブジェクト
    ///   - propertyName: プロパティ名
    /// - Returns: 値がある場合はそれを返し、ない場合は nil を返します。
    public static func propertyValue<T>(from object: AnyObject, propertyName: String) -> T? {
        let sel = NSSelectorFromString(propertyName)
        guard responds(to: sel, object: object) else {
            return nil
        }
        return object.perform(sel)?.takeUnretainedValue() as? T
    }

    /// 指定したメソッド名を呼び出します。
    /// - Parameters:
    ///   - object: 対象オブジェクト
    ///   - methodName: メソッド名（セレクタ文字列）
    ///   - argument: メソッドに渡す値
    /// - Returns: メソッドの戻り値がある場合はそれを返し、ない場合は nil を返します。
    public static func invoke<T>(from object: AnyObject, methodName: String, with argument: Any) -> T? {
        let sel = NSSelectorFromString(methodName)
        guard responds(to: sel, object: object) else {
            return nil
        }
        return object.perform(sel, with: argument)?.takeUnretainedValue() as? T
    }

    /// 指定したオブジェクトに指定したセレクタが実装されているか確認します。
    /// - Parameters:
    ///   - name: セレクタ文字列
    ///   - object: 対象オブジェクト
    /// - Returns: 指定したオブジェクトに指定したセレクタが実装されている場合は `true` を返し、実装されていない場合は `false` を返します。
    public static func responds(to name: String, object: AnyObject) -> Bool {
        responds(to: NSSelectorFromString(name), object: object)
    }

    /// 指定したオブジェクトに指定したセレクタが実装されているか確認します。
    /// - Parameters:
    ///   - selector: セレクタ
    ///   - object: 対象オブジェクト
    /// - Returns: 指定したオブジェクトに指定したセレクタが実装されている場合は `true` を返し、実装されていない場合は `false` を返します。
    public static func responds(to selector: Selector, object: AnyObject) -> Bool {
        object.responds(to: selector)
    }

    /// 指定したオブジェクトが指定したクラスに適合するか確認します。
    /// - Parameters:
    ///   - name: クラス名文字列
    ///   - object: 対象オブジェクト
    /// - Returns: 指定したオブジェクトが指定したクラスに適合する場合は `true` を返し、適合しない場合は `false` を返します。
    public static func isKind(of name: String, object: AnyObject) -> Bool {
        guard let cls = NSClassFromString(name) else {
            return false
        }
        return object.isKind(of: cls)
    }

    /// 指定したオブジェクトが指定したプロトコルに適合するか確認します。
    /// - Parameters:
    ///   - name: プロトコル名文字列
    ///   - object: 対象オブジェクト
    /// - Returns: 指定したオブジェクトが指定したプロトコルに適合する場合は `true` を返し、適合しない場合は `false` を返します。
    public static func conforms(to name: String, object: AnyObject) -> Bool {
        guard let proto = NSProtocolFromString(name) else {
            return false
        }
        return object.conforms(to: proto)
    }

    /// 指定したオブジェクト同士が同一オブジェクトであるか確認します。
    /// - Parameters:
    ///   - lhs: オブジェクト1
    ///   - rhs: オブジェクト2
    /// - Returns: 指定したオブジェクト同士が同一のオブジェクトである場合は `true` を返し、同一のオブジェクトでない場合は `false` を返します。
    public static func equals(_ lhs: AnyObject?, _ rhs: AnyObject?) -> Bool {
        guard let lhs = lhs as? NSObject, let rhs = rhs as? NSObject else {
            return false
        }
        return lhs == rhs
    }
}
