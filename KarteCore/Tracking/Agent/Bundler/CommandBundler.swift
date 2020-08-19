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

internal protocol CommandBundlerDelegate: AnyObject {
    func commandBundler(_ bundler: CommandBundler, didFinishBundle bundle: CommandBundle)
}

internal class CommandBundler {
    private var beforeBundleRules: [CommandBundleRule]
    private var afterBundleRules: [CommandBundleRule]
    private var asyncBundleRules: [AsyncCommandBundleRule]

    private var bundle = CommandBundle()

    weak var delegate: CommandBundlerDelegate?

    init(beforeBundleRules: [CommandBundleRule], afterBundleRules: [CommandBundleRule], asyncBundleRules: [AsyncCommandBundleRule]) {
        self.beforeBundleRules = beforeBundleRules
        self.afterBundleRules = afterBundleRules
        self.asyncBundleRules = asyncBundleRules
    }

    func addCommand(_ command: TrackingCommand) {
        if evaluateRules(beforeBundleRules, command: command) {
            return nextBundle(command)
        }

        bundle.addCommand(command)

        if evaluateRules(afterBundleRules, command: command) {
            return nextBundle()
        }

        evaluateAsyncRules(asyncBundleRules, command: command)
    }

    deinit {
    }
}

private extension CommandBundler {
    func evaluateRules(_ rules: [CommandBundleRule], command: TrackingCommand) -> Bool {
        rules.contains { rule -> Bool in
            rule.evaluate(bundle: self.bundle, command: command)
        }
    }

    func evaluateAsyncRules(_ rules: [AsyncCommandBundleRule], command: TrackingCommand) {
        for rule in rules {
            rule.schedule(bundle: bundle, command: command) { [weak self] isBoundary in
                if isBoundary {
                    self?.nextBundle()
                }
            }
        }
    }

    func nextBundle(_ command: TrackingCommand? = nil) {
        let bundle = swapBundle(newBundle(), command: command)
        bundle.freeze()

        delegate?.commandBundler(self, didFinishBundle: bundle)
    }

    func swapBundle(_ newBundle: CommandBundle, command: TrackingCommand? = nil) -> CommandBundle {
        let oldBundle = self.bundle
        self.bundle = newBundle

        if let command = command {
            addCommand(command)
        }

        return oldBundle
    }

    func newBundle() -> CommandBundle {
        CommandBundle()
    }
}
