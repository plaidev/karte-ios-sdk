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

import Quick
import Nimble
@testable import KarteVisualTracking

class ActionAppropriateViewDetectorSpec: QuickSpec {
    
    override class func spec() {
        describe("a appropriate view detector") {
            describe("its detect") {
                context("when passing UIView") {
                    it("return is UIView") {
                        let view = UIView()
                        let action = UIKitAction.AppropriateViewDetector(view: view)
                        expect(action?.detect()).to(beAnInstanceOf(UIView.self))
                    }
                }
                
                context("when passing UITableViewCellContentView included in UITableViewCell") {
                    it("return is UITableViewCell") {
                        let cell = UITableViewCell()
                        let action = UIKitAction.AppropriateViewDetector(view: cell.contentView)
                        expect(action?.detect()).to(beAKindOf(UITableViewCell.self))
                    }
                }
                
                context("when passing a enabled UIButton contained in UITableViewCell") {
                    it("return is UIButton") {
                        let button = UIButton()
                        let cell = UITableViewCell()
                        cell.addSubview(button)
                        
                        let action = UIKitAction.AppropriateViewDetector(view: button)
                        expect(action?.detect()).to(beAKindOf(UIButton.self))
                    }
                }
                
                context("when passing a disabled UIButton contained in UITableViewCell") {
                    it("return is UITableViewCell") {
                        let button = UIButton()
                        button.isEnabled = false
                        let cell = UITableViewCell()
                        cell.addSubview(button)
                        
                        let action = UIKitAction.AppropriateViewDetector(view: button)
                        expect(action?.detect()).to(beAKindOf(UITableViewCell.self))
                    }
                }
            }
            
            describe("its isAppropriateView") {
                context("when passing UITableView") {
                    it("return true") {
                        let view = UITableView()
                        let detector = UIKitAction.AppropriateViewDetector(view: view)
                        expect(detector?.isAppropriateView).to(beTrue())
                    }
                }
                
                context("when passing UIScrollView") {
                    it("return true") {
                        let view = UIScrollView()
                        let detector = UIKitAction.AppropriateViewDetector(view: view)
                        expect(detector?.isAppropriateView).to(beTrue())
                    }
                }
                
                context("when passing UICollectionView") {
                    it("return true") {
                        let view = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout())
                        let detector = UIKitAction.AppropriateViewDetector(view: view)
                        expect(detector?.isAppropriateView).to(beTrue())
                    }
                }
                
                context("when passing UIButton is enable") {
                    it("return true") {
                        let view = UIButton()
                        let detector = UIKitAction.AppropriateViewDetector(view: view)
                        expect(detector?.isAppropriateView).to(beTrue())
                    }
                }
                
                context("when a UILabel containing one or more enable gestures is passed") {
                    it("return true") {
                        let view = UILabel()
                        view.addGestureRecognizer(UIGestureRecognizer())
                        
                        let detector = UIKitAction.AppropriateViewDetector(view: view)
                        expect(detector?.isAppropriateView).to(beTrue())
                    }
                }
                
                context("when a UIImageView containing one or more enable gestures is passed") {
                    it("return true") {
                        let view = UIImageView()
                        view.addGestureRecognizer(UIGestureRecognizer())
                        
                        let detector = UIKitAction.AppropriateViewDetector(view: view)
                        expect(detector?.isAppropriateView).to(beTrue())
                    }
                }
                
                context("when passing UITableViewCell") {
                    it("return true") {
                        let view = UITableViewCell()
                        let detector = UIKitAction.AppropriateViewDetector(view: view)
                        expect(detector?.isAppropriateView).to(beTrue())
                    }
                }
                
                context("when passing UIButton is disable") {
                    it("return false") {
                        let view = UIButton()
                        view.isEnabled = false
                        view.isUserInteractionEnabled = false
                        
                        let detector = UIKitAction.AppropriateViewDetector(view: view)
                        expect(detector?.isAppropriateView).to(beFalse())
                    }
                }
                
                context("when a UILabel containing disable gestures is passed") {
                    it("return false") {
                        let gesture = UIGestureRecognizer()
                        gesture.isEnabled = false
                        let view = UILabel()
                        view.addGestureRecognizer(gesture)
                        
                        let detector = UIKitAction.AppropriateViewDetector(view: view)
                        expect(detector?.isAppropriateView).to(beFalse())
                    }
                }
                
                context("when passing UITableViewCellContentView") {
                    it("return false") {
                        let view = UITableViewCell().contentView
                        let detector = UIKitAction.AppropriateViewDetector(view: view)
                        expect(detector?.isAppropriateView).to(beFalse())
                    }
                }
                
                context("when passing UIPickerView") {
                    it("return true") {
                        let view = UIPickerView()
                        let detector = UIKitAction.AppropriateViewDetector(view: view)
                        expect(detector?.isAppropriateView).to(beTrue())
                    }
                }
                
                context("when passing UIDatePicker") {
                    it("return true") {
                        let view = UIDatePicker()
                        let detector = UIKitAction.AppropriateViewDetector(view: view)
                        expect(detector?.isAppropriateView).to(beTrue())
                    }
                }
            }
        }
    }
}
