//
//  ProblemDetailTableViewController.swift
//  Tokopedia
//
//  Created by Vishun Dayal on 13/10/17.
//  Copyright © 2017 TOKOPEDIA. All rights reserved.
//

import UIKit
class ProblemDetailTableViewController: UITableViewController {
    @IBOutlet private weak var productInfoCell: ProblemProductInfoCell!
    @IBOutlet private weak var rcOrderStatusCell: RCOrderStatusCell!
    @IBOutlet private weak var singleLineInputCell1: RCTextInputCell!
    @IBOutlet private weak var singleLineInputCell2: RCTextInputCell!
    @IBOutlet private weak var goodsCountCell: GoodCountCell!
    @IBOutlet private weak var addMoreItemsCell: RCButtonCell!
    @IBOutlet private weak var continueButtonCell: RCButtonCell!
    @IBOutlet private weak var cancelButtonCell: RCButtonCell!
    var problemItem: RCProblemItem?
    weak var parentController: ProblemDetailViewController?
//    MARK:- Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.rowHeight = UITableViewAutomaticDimension;
        self.tableView.estimatedRowHeight = 100.0
        NotificationCenter.default.addObserver(self, selector: #selector(ProblemDetailTableViewController.textview1DidEndEditing(sender:)), name: NSNotification.Name.UITextViewTextDidEndEditing, object: self.singleLineInputCell1.textView)
        NotificationCenter.default.addObserver(self, selector: #selector(ProblemDetailTableViewController.textview2DidEndEditing(sender:)), name: NSNotification.Name.UITextViewTextDidEndEditing, object: self.singleLineInputCell2.textView)
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: NSNotification.Name.UIKeyboardWillHide, object: self.singleLineInputCell2.textView)
        
        self.modalPresentationStyle = .overCurrentContext
        self.singleLineInputCell1.textView.returnKeyType = .continue
        self.singleLineInputCell2.textView.returnKeyType = .continue
        
    }
    override func didMove(toParentViewController parent: UIViewController?) {
        super.didMove(toParentViewController: parent)
        if let parent = parent as? ProblemDetailViewController {
            self.parentController = parent
            self.problemItem = parent.problemItem
            self.setupUI()
            self.updateUI()
        }
    }
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
//    MARK:- UI 
    private func setupUI() {
        guard let problem = self.problemItem else { return }
        self.rcOrderStatusCell.reachedButtonHandler = {
            if let problem = self.problemItem {
                problem.setSelectedStatus(isDeliveredType: true)
                if let status = problem.selectedStatus {
                    self.singleLineInputCell1.updateWith(status: status)
                }
            }
            self.updateUI()
        }
        self.rcOrderStatusCell.notReachedButtonHandler = {
            if let problem = self.problemItem {
                problem.setSelectedStatus(isDeliveredType: false)
                if let status = problem.selectedStatus {
                    self.singleLineInputCell1.updateWith(status: status)
                }
            }
            self.updateUI()
        }
        self.rcOrderStatusCell.infoButtonHandler = {
            if let viewController = self.storyboard?.instantiateViewController(withIdentifier: "RCReachingInfoViewController") as? RCReachingInfoViewController {
                viewController.problemItem = self.problemItem
                self.present(viewController, animated: false, completion: nil)
            }
        }
        if self.problemItem?.selectedStatus == nil {
            self.problemItem?.setSelectedStatus(isDeliveredType: true)
        }
        if let date = problem.getStatus(isDelivered: false)?.info?.date {
            self.rcOrderStatusCell.isDeliveryDatePassed = (date.timeIntervalSinceNow <= 0)
        }
        if problem.goodsCount == 0 {
            problem.goodsCount = problem.order.product.quantity
        }
        self.goodsCountCell.orderedQuantity = problem.order.product.quantity
        self.goodsCountCell.quantity = problem.goodsCount
        self.goodsCountCell.refresh()
        self.goodsCountCell.valueChangedHandler = {
            if let problem = self.problemItem {
                problem.goodsCount = self.goodsCountCell.quantity
            }
        }
        self.addMoreItemsCell.buttonHandler = {
            if self.validateFields() {
                problem.isSelected = true
                RCManager.shared.rcCreateStep1Data?.solutionData = nil
                self.navigationController?.popViewController(animated: true)
            }
        }
        self.continueButtonCell.buttonHandler = {
            if self.validateFields() {
                problem.isSelected = true
                RCManager.shared.rcCreateStep1Data?.solutionData = nil
                if var viewControllers = self.navigationController?.viewControllers {
                    viewControllers.removeLast()
                    viewControllers.removeLast()
                    self.navigationController?.setViewControllers(viewControllers, animated: true)
                }
            }
        }
        self.cancelButtonCell.buttonHandler = {
            self.navigationController?.popViewController(animated: true)
        }
        self.addMoreItemsCell.markButtonDisabled()
        self.continueButtonCell.markButtonDisabled()
        self.cancelButtonCell.markButtonEnabled()
    }
    private func updateUI() {
        guard let problem = self.problemItem else { return }
        self.productInfoCell.updateWithProblem(item: problem)
        self.rcOrderStatusCell.updateWith(problemItem: problem)
        if let status = problem.selectedStatus {
            self.singleLineInputCell1.updateWith(status: status)
        }
        if self.validateFields() {
            self.continueButtonCell.markButtonEnabled()
            self.addMoreItemsCell.markButtonHighlighted()
        } else {
            self.addMoreItemsCell.markButtonDisabled()
            self.continueButtonCell.markButtonDisabled()
        }
        self.singleLineInputCell2.textView.text = problem.remark
    }
    private func validateFields() -> Bool {
        guard let problem = self.problemItem else { return false}
        guard problem.selectedStatus != nil else {return false}
        guard problem.selectedStatus?.selectedTrouble != nil else {return false}
        if let text = problem.remark {
            if text.count < 30 {
                return false
            }
        } else {
            return false
        }
        return true
    }
//    MARK:-UITableViewDelegate
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row == 2 {
            guard let status = self.problemItem?.selectedStatus else {
                return
            }
            if let viewController = self.storyboard?.instantiateViewController(withIdentifier: "SelectTroubleViewController") as? SelectTroubleViewController {
                viewController.rcProblemStatus = status
                viewController.didSelectedHandler = {
                    self.updateUI()
                }
                self.navigationController?.pushViewController(viewController, animated: true)
            }
        }
    }
//    MARK:- Notification Handler
    func textview1DidEndEditing(sender: Notification) {
        self.tableView.reloadData()
        guard let problem = self.problemItem else { return }
        problem.selectedStatus?.userTypedTrouble = self.singleLineInputCell1.textView.text
        self.updateUI()
    }
    func textview2DidEndEditing(sender: Notification) {
        self.tableView.reloadData()
        guard let problem = self.problemItem else { return }
        problem.remark = self.singleLineInputCell2.textView.text
        self.updateUI()
    }
    
    func keyboardWillHide(sender: Notification) {
        self.tableView.reloadData()
        guard let problem = self.problemItem else { return }
        problem.selectedStatus?.userTypedTrouble = self.singleLineInputCell1.textView.text
        problem.remark = self.singleLineInputCell2.textView.text
        self.updateUI()
    }
}
