//
//  Copyright 2021 PLAID, Inc.
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
import KarteUtilities

@propertyWrapper
public struct CodableInjectedForObjcCompatibility<Service: Codable>: Codable {
    private var service: Service

    public var wrappedValue: Service {
        get { service }
        mutating set { service = newValue }
    }
    public var projectedValue: CodableInjectedForObjcCompatibility<Service> {
        get { self }
        mutating set { self = newValue }
    }

    public init() {
        self.service = Resolver.resolve(Service.self)
    }
    public init(name: String? = nil, container: Resolver? = nil) {
        self.service = container?.resolve(Service.self, name: name) ?? Resolver.resolve(Service.self, name: name)
    }
    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        self.service = try container.decode(Service.self)
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(service)
    }
}

@propertyWrapper
public struct OptionalCodableInjectedForObjcCompatibility<Service: Codable>: Codable {
    private var service: Service?

    public var wrappedValue: Service? {
        get { service }
        mutating set { service = newValue }
    }
    public var projectedValue: OptionalCodableInjectedForObjcCompatibility<Service> {
        get { self }
        mutating set { self = newValue }
    }

    public init() {
        self.service = Resolver.optional(Service.self)
    }
    public init(name: String? = nil, container: Resolver? = nil) {
        self.service = container?.optional(Service.self, name: name) ?? Resolver.optional(Service.self, name: name)
    }
    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        if container.decodeNil() {
            self.service = nil
        } else {
            self.service = try container.decode(Service.self)
        }
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(service)
    }
}
