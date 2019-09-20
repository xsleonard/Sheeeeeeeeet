//
//  ActionSheetTests.swift
//  SheeeeeeeeetTests
//
//  Created by Daniel Saidi on 2017-11-28.
//  Copyright © 2017 Daniel Saidi. All rights reserved.
//

import Quick
import Nimble
@testable import Sheeeeeeeeet
import UIKit

class ActionSheetTests: QuickSpec {
    
    override func spec() {
        
        var sheet: MockActionSheet!
        
        func createSheet(_ items: [ActionSheetItem] = []) -> MockActionSheet {
            MockActionSheet(items: items, action: { _, _ in })
        }
        
        
        // MARK: - Initialization
        
        describe("creating instance") {
            
            var counter: Int!
            
            beforeEach {
                counter = 0
            }
            
            context("with default configuration") {
                
                it("applies default values and no items") {
                    let sheet = ActionSheet() { _, _ in }
                    let isStandard = sheet.presenter is ActionSheetStandardPresenter
                    let isPopover = sheet.presenter is ActionSheetPopoverPresenter
                    expect(isStandard || isPopover).to(beTrue())
                    expect(sheet.items.count).to(equal(0))
                    expect(sheet.buttons.count).to(equal(0))
                }
            }
            
            context("with custom properties") {
                
                it("applies provided properties") {
                    let items = [ActionSheetItem(title: "foo"), ActionSheetOkButton(title: "foo")]
                    let presenter = ActionSheetPopoverPresenter()
                    let sheet = ActionSheet(items: items, presenter: presenter) { _, _ in counter += 1 }
                    expect(sheet.presenter).to(be(presenter))
                    expect(sheet.items.count).to(equal(1))
                    expect(sheet.buttons.count).to(equal(1))
                    sheet.selectAction(sheet, items[0])
                    expect(counter).to(equal(1))
                }
            }
            
            context("with menu") {
                
                it("applies provided properties and maps menu to items") {
                    let menuItems = [MenuItem(title: "item title"), OkButton(title: "button title")]
                    let menu = Menu(title: "title", items: menuItems)
                    let presenter = ActionSheetPopoverPresenter()
                    let sheet = ActionSheet(menu: menu, presenter: presenter) { _, _ in counter += 1 }
                    expect(sheet.presenter).to(be(presenter))
                    expect(sheet.presenter.isDismissable).to(beTrue())
                    expect(sheet.items.count).to(equal(2))
                    expect(sheet.items[0] is ActionSheetTitle).to(beTrue())
                    expect(sheet.items[0].title).to(equal("title"))
                    expect(sheet.items[1].title).to(equal("item title"))
                    expect(sheet.buttons.count).to(equal(1))
                    expect(sheet.buttons[0] as? ActionSheetOkButton).toNot(beNil())
                    sheet.selectAction(sheet, sheet.items[0])
                    expect(counter).to(equal(1))
                }
                
                it("can disable presenter dismissal with menu configuration") {
                    let menu = Menu(title: "title", items: [], configuration: .nonDismissable)
                    let sheet = ActionSheet(menu: menu) { _, _ in }
                    expect(sheet.presenter.isDismissable).to(beFalse())
                }
            }
        }
        
        
        describe("setup") {
            
            beforeEach {
                sheet = createSheet()
            }
            
            it("applies default preferred popover width") {
                sheet.setup()
                
                expect(sheet.preferredContentSize.width).to(equal(300))
            }
            
            it("applies custom preferred popover width") {
                sheet.preferredPopoverWidth = 200
                sheet.setup()
                
                expect(sheet.preferredContentSize.width).to(equal(200))
            }
        }
        
        
        describe("setup items") {
            
            beforeEach {
                sheet = createSheet()
            }
            
            it("applies empty collection") {
                sheet.setup(items: [])
                
                expect(sheet.items.count).to(equal(0))
                expect(sheet.buttons.count).to(equal(0))
            }
            
            it("separates items and buttons") {
                let item1 = ActionSheetItem(title: "foo")
                let item2 = ActionSheetItem(title: "bar")
                let button = ActionSheetOkButton(title: "baz")
                sheet.setup(items: [button, item1, item2])
                
                expect(sheet.items.count).to(equal(2))
                expect(sheet.items[0]).to(be(item1))
                expect(sheet.items[1]).to(be(item2))
                expect(sheet.buttons.count).to(equal(1))
                expect(sheet.buttons[0]).to(be(button))
            }
            
            it("reloads data") {
                sheet.reloadDataInvokeCount = 0
                sheet.setup(items: [])
                
                expect(sheet.reloadDataInvokeCount).to(equal(1))
            }
        }
        
        
        describe("loading view") {
            
            beforeEach {
                sheet = createSheet()
                sheet.viewDidLoad()
            }
            
            it("sets up action sheet") {
                expect(sheet.setupInvokeCount).to(beGreaterThanOrEqualTo(1))
            }
            
            it("sets up items table view") {
                let view = sheet.itemsTableView
                expect(view.delegate).to(be(sheet.itemHandler))
                expect(view.dataSource).to(be(sheet.itemHandler))
                expect(view.alwaysBounceVertical).to(beFalse())
                expect(view.estimatedRowHeight).to(equal(44))
                expect(view.rowHeight).to(equal(UITableView.automaticDimension))
                expect(view.cellLayoutMarginsFollowReadableWidth).to(beFalse())
            }
            
            it("sets up buttons table view") {
                let view = sheet.buttonsTableView
                expect(view.delegate).to(be(sheet.buttonHandler))
                expect(view.dataSource).to(be(sheet.buttonHandler))
                expect(view.alwaysBounceVertical).to(beFalse())
                expect(view.estimatedRowHeight).to(equal(44))
                expect(view.rowHeight).to(equal(UITableView.automaticDimension))
                expect(view.cellLayoutMarginsFollowReadableWidth).to(beFalse())
            }
        }
        
        
        describe("laying out subviews") {
            
            it("refreshes sheet") {
                sheet = createSheet()
                sheet.viewDidLayoutSubviews()
                
                expect(sheet.refreshInvokeCount).to(equal(1))
            }
        }
        
        
        describe("minimum content insets") {
            
            it("has correct default value") {
                sheet = createSheet()
                let expected = UIEdgeInsets(top: 15, left: 15, bottom: 15, right: 15)
                
                expect(sheet.minimumContentInsets).to(equal(expected))
            }
        }
        
        
        describe("preferred popover width") {
            
            it("has correct default value") {
                sheet = createSheet()
                let expected: CGFloat = 300
                
                expect(sheet.preferredPopoverWidth).to(equal(expected))
            }
        }
        
        
        describe("section margins") {
            
            it("has correct default value") {
                sheet = createSheet()
                let expected: CGFloat = 15
                
                expect(sheet.sectionMargins).to(equal(expected))
            }
        }
        
        
        describe("items height") {
            
            beforeEach {
                ActionSheetItem.height = 100
                ActionSheetSingleSelectItem.height = 110
                ActionSheetMultiSelectItem.height = 120
                ActionSheetOkButton.height = 120
            }
            
            it("is sum of all items") {
                let item1 = ActionSheetItem(title: "foo")
                let item2 = ActionSheetSingleSelectItem(title: "bar", isSelected: true)
                let item3 = ActionSheetMultiSelectItem(title: "baz", isSelected: false)
                let button = ActionSheetOkButton(title: "ok")
                sheet = createSheet([item1, item2, item3, button])
                
                expect(sheet.itemsHeight).to(equal(330))
            }
        }
        
        
        describe("item handler") {
            
            it("has correct item type") {
                sheet = createSheet()
                
                expect(sheet.itemHandler.itemType).to(equal(.items))
            }
            
            it("has correct items") {
                let item1 = ActionSheetItem(title: "foo")
                let item2 = ActionSheetItem(title: "bar")
                let button = ActionSheetOkButton(title: "ok")
                sheet = createSheet([item1, item2, button])
                
                expect(sheet.itemHandler.items.count).to(equal(2))
                expect(sheet.itemHandler.items[0]).to(be(item1))
                expect(sheet.itemHandler.items[1]).to(be(item2))
            }
        }
        
        
        describe("items height") {
            
            beforeEach {
                ActionSheetItem.height = 100
                ActionSheetOkButton.height = 110
                ActionSheetDangerButton.height = 120
                ActionSheetCancelButton.height = 130
            }
            
            it("is sum of all items") {
                let item = ActionSheetItem(title: "foo")
                let button1 = ActionSheetOkButton(title: "ok")
                let button2 = ActionSheetDangerButton(title: "ok")
                let button3 = ActionSheetCancelButton(title: "ok")
                sheet = createSheet([item, button1, button2, button3])
                
                expect(sheet.buttonsHeight).to(equal(360))
            }
        }
        
        
        describe("item handler") {
            
            it("has correct item type") {
                sheet = createSheet()
                
                expect(sheet.buttonHandler.itemType).to(equal(.buttons))
            }
            
            it("has correct items") {
                let item = ActionSheetItem(title: "foo")
                let button1 = ActionSheetOkButton(title: "ok")
                let button2 = ActionSheetOkButton(title: "ok")
                sheet = createSheet([item, button1, button2])
                
                expect(sheet.buttonHandler.items.count).to(equal(2))
                expect(sheet.buttonHandler.items[0]).to(be(button1))
                expect(sheet.buttonHandler.items[1]).to(be(button2))
            }
        }
        
        
        context("presentation") {
            
            var presenter: MockActionSheetPresenter!
            
            beforeEach {
                presenter = MockActionSheetPresenter()
                sheet = createSheet()
                sheet.presenter = presenter
            }
            
            describe("when dismissed") {
                
                it("it calls presenter") {
                    var counter = 0
                    let completion = { counter += 1 }
                    sheet.dismiss(completion: completion)
                    presenter.dismissInvokeCompletions[0]()
                    
                    expect(presenter.dismissInvokeCount).to(equal(1))
                    expect(counter).to(equal(1))
                }
            }
            
            describe("when presented from view") {
                
                it("refreshes itself") {
                    sheet.present(in: UIViewController(), from: UIView())
                    
                    expect(sheet.refreshInvokeCount).to(equal(1))
                }
                
                it("calls presenter") {
                    var counter = 0
                    let completion = { counter += 1 }
                    let vc = UIViewController()
                    let view = UIView()
                    sheet.present(in: vc, from: view, completion: completion)
                    presenter.presentInvokeCompletions[0]()
                    
                    expect(presenter.presentInvokeCount).to(equal(1))
                    expect(presenter.presentInvokeViewControllers[0]).to(be(vc))
                    expect(presenter.presentInvokeViews[0]).to(be(view))
                    expect(counter).to(equal(1))
                }
            }
            
            describe("when presented from bar button item") {
                
                it("refreshes itself") {
                    sheet.present(in: UIViewController(), from: UIBarButtonItem())
                    
                    expect(sheet.refreshInvokeCount).to(equal(1))
                }
                
                it("calls presenter") {
                    var counter = 0
                    let completion = { counter += 1 }
                    let vc = UIViewController()
                    let item = UIBarButtonItem()
                    sheet.present(in: vc, from: item, completion: completion)
                    presenter.presentInvokeCompletions[0]()
                    
                    expect(presenter.presentInvokeCount).to(equal(1))
                    expect(presenter.presentInvokeViewControllers[0]).to(be(vc))
                    expect(presenter.presentInvokeItems[0]).to(be(item))
                    expect(counter).to(equal(1))
                }
            }
        }
        
        
        describe("refreshing") {
            
            var presenter: MockActionSheetPresenter!
            
            beforeEach {
                presenter = MockActionSheetPresenter()
                sheet = createSheet()
                sheet.presenter = presenter
                sheet.refresh()
            }
            
            it("refreshes all components") {
                expect(sheet.refreshHeaderInvokeCount).to(equal(1))
                expect(sheet.refreshHeaderVisibilityInvokeCount).to(equal(1))
                expect(sheet.refreshItemsInvokeCount).to(equal(1))
                expect(sheet.refreshButtonsInvokeCount).to(equal(1))
                expect(sheet.stackView.spacing).to(equal(15))
                expect(presenter.refreshActionSheetInvokeCount).to(equal(1))
            }
        }
        
        
        describe("refreshing header") {
            
            var height: NSLayoutConstraint!
            
            beforeEach {
                height = NSLayoutConstraint()
                sheet = createSheet()
                sheet.headerViewContainerHeight = height
            }
            
            it("refreshes correctly if header view is nil") {
                sheet.refreshHeader()
                expect(sheet.headerViewContainer.subviews.count).to(equal(0))
                expect(height.constant).to(equal(0))
            }
            
            it("refreshes correctly if header view is set") {
                let view = UIView(frame: CGRect(x: 0, y: 0, width: 100, height: 200))
                sheet.headerView = view
                sheet.refreshHeader()
                
                let subviews = sheet.headerViewContainer.subviews
                expect(subviews.count).to(equal(1))
                expect(subviews[0]).to(be(view))
                expect(height.constant).to(equal(200))
            }
        }
        
        
        describe("refreshing header visibility") {
            
            beforeEach {
                sheet = createSheet()
                let view = UIView(frame: CGRect(x: 0, y: 0, width: 100, height: 200))
                sheet.headerView = view
            }
            
            func setLandscapeOrientation() {
                let view = sheet.view!
                view.frame.size.width = 2 * view.frame.size.height
            }
            
            func setPortraitOrientation() {
                let view = sheet.view!
                view.frame.size.height = 2 * view.frame.size.width
            }
            
            it("hides header container if header view is nil") {
                sheet.headerView = nil
                sheet.refreshHeaderVisibility()
                
                expect(sheet.headerViewContainer.isHidden).to(beTrue())
            }
            
            it("hides header container in landscape orientation if set to hide header in landscape") {
                setLandscapeOrientation()
                sheet.headerViewLandscapeMode = .hidden
                sheet.refreshHeaderVisibility()
                
                expect(sheet.headerViewContainer.isHidden).to(beTrue())
            }
            
            it("shows header container in landscape orientation if set to show header in landscape") {
                setLandscapeOrientation()
                sheet.headerViewLandscapeMode = .visible
                sheet.refreshHeaderVisibility()
                
                expect(sheet.headerViewContainer.isHidden).to(beFalse())
            }
            
            it("shows header container in portrait orientation if set to hide header in landscape") {
                setPortraitOrientation()
                sheet.headerViewLandscapeMode = .hidden
                sheet.refreshHeaderVisibility()
                
                expect(sheet.headerViewContainer.isHidden).to(beFalse())
            }
            
            it("shows header container in portrait orientation if set to show header in landscape") {
                setPortraitOrientation()
                sheet.headerViewLandscapeMode = .visible
                sheet.refreshHeaderVisibility()
                
                expect(sheet.headerViewContainer.isHidden).to(beFalse())
            }
        }
        
        
        describe("refreshing items") {
            
            var height: NSLayoutConstraint!
            
            beforeEach {
                height = NSLayoutConstraint()
                sheet = createSheet()
                sheet.itemsTableViewHeight = height
                ActionSheetItem.height = 12
                ActionSheetOkButton.height = 13
            }
            
            it("refreshes correctly if no items are set") {
                sheet.refreshItems()
                
                expect(height.constant).to(equal(0))
            }
            
            it("refreshes correctly if items are set") {
                let item1 = ActionSheetItem(title: "foo")
                let item2 = ActionSheetItem(title: "foo")
                let button = ActionSheetOkButton(title: "foo")
                sheet.setup(items: [item1, item2, button])
                sheet.refreshItems()
                
                expect(height.constant).to(equal(24))
            }
        }
        
        
        describe("refreshing buttons") {
            
            var height: NSLayoutConstraint!
            
            beforeEach {
                height = NSLayoutConstraint()
                sheet = createSheet()
                sheet.buttonsTableViewHeight = height
                ActionSheetItem.height = 12
                ActionSheetOkButton.height = 13
            }
            
            it("refreshes correctly if no items are set") {
                sheet.refreshButtons()
                
                expect(height.constant).to(equal(0))
            }
            
            it("refreshes correctly if items are set") {
                let item = ActionSheetItem(title: "foo")
                let button1 = ActionSheetOkButton(title: "foo")
                let button2 = ActionSheetOkButton(title: "foo")
                sheet.setup(items: [item, button1, button2])
                sheet.refreshButtons()
                
                expect(height.constant).to(equal(26))
            }
        }
        
        
        describe("handling tap on item") {
            
            beforeEach {
                sheet = createSheet()
                sheet.reloadDataInvokeCount = 0
            }
            
            it("reloads data") {
                sheet.handleTap(on: ActionSheetItem(title: ""))
                
                expect(sheet.reloadDataInvokeCount).to(equal(1))
            }
            
            it("calls select action without dismiss if item has none tap action") {
                var count = 0
                sheet = MockActionSheet { (_, _) in count += 1 }
                let item = ActionSheetItem(title: "", tapBehavior: .none)
                sheet.handleTap(on: item)
                
                expect(count).to(equal(1))
                expect(sheet.dismissInvokeCount).to(equal(0))
            }
            
            it("calls select action after dismiss if item has dismiss tap action") {
                var count = 0
                sheet = MockActionSheet { (_, _) in count += 1 }
                let item = ActionSheetItem(title: "", tapBehavior: .dismiss)
                sheet.handleTap(on: item)
                
                expect(count).to(equal(1))
                expect(sheet.dismissInvokeCount).to(equal(1))
            }
        }
        
        
        describe("margin at position") {
            
            beforeEach {
                sheet = createSheet()
            }
            
            it("ignores custom edge margins with smaller value than the default ones") {
                let sheet = createSheet()
                sheet.minimumContentInsets = UIEdgeInsets(top: -1, left: -1, bottom: -1, right: -1)
                guard #available(iOS 11.0, *) else { return }
                expect(sheet.margin(at: .top)).to(equal(sheet.view.safeAreaInsets.top))
                expect(sheet.margin(at: .left)).to(equal(sheet.view.safeAreaInsets.left))
                expect(sheet.margin(at: .right)).to(equal(sheet.view.safeAreaInsets.right))
                expect(sheet.margin(at: .bottom)).to(equal(sheet.view.safeAreaInsets.bottom))
            }

            it("uses custom edge margins with greated value than the default ones") {
                let sheet = createSheet()
                sheet.minimumContentInsets = UIEdgeInsets(top: 111, left: 222, bottom: 333, right: 444)
                
                expect(sheet.margin(at: .top)).to(equal(111))
                expect(sheet.margin(at: .left)).to(equal(222))
                expect(sheet.margin(at: .bottom)).to(equal(333))
                expect(sheet.margin(at: .right)).to(equal(444))
            }
        }
        
        describe("reloading data") {
            
            it("reloads both table views") {
                let view1 = MockItemTableView(frame: .zero)
                let view2 = MockButtonTableView(frame: .zero)
                sheet = createSheet()
                sheet.itemsTableView = view1
                sheet.buttonsTableView = view2
                sheet.reloadData()
                expect(view1.reloadDataInvokeCount).to(equal(1))
                expect(view2.reloadDataInvokeCount).to(equal(1))
            }
        }
    }
}