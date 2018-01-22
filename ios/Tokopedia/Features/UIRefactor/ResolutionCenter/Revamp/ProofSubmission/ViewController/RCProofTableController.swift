//
//  RCProofTableController.swift
//  Tokopedia
//
//  Created by Vishun Dayal on 27/11/17.
//  Copyright © 2017 TOKOPEDIA. All rights reserved.
//

import UIKit

class RCProofTableController: UITableViewController {
    @IBOutlet private weak var rcProblemTextCell: RCProblemTextCell!
    weak var parentController: RCProofViewController?
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupUI()
    }
    override func didMove(toParentViewController parent: UIViewController?) {
        super.didMove(toParentViewController: parent)
        if let parent = parent as? RCProofViewController {
            self.parentController = parent
        }
    }
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
//    MARK:- UI
    private func setupUI() {
        self.tableView.rowHeight = UITableViewAutomaticDimension;
        self.tableView.estimatedRowHeight = 100
        self.tableView.tableFooterView = UIView()
        NotificationCenter.default.addObserver(self, selector: #selector(RCProofTableController.textviewDidEndEditing(sender:)), name: NSNotification.Name.UITextViewTextDidEndEditing, object: self.rcProblemTextCell.textView)
        self.rcProblemTextCell.textView.text = RCManager.shared.rcCreateStep1Data?.attchmentMessage
    }

//    MARK:- Notification Handler
    func textviewDidEndEditing(sender: Notification) {
        self.tableView.reloadData()
        self.parentController?.attchmentMessage = self.rcProblemTextCell.textView.text
        self.parentController?.refreshUI()
    }
    
//    MARK:- Table View Delegate
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
}
