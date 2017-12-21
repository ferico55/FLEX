//
//  CreateComplainTableViewController.swift
//  Tokopedia
//
//  Created by Vishun Dayal on 11/10/17.
//  Copyright © 2017 TOKOPEDIA. All rights reserved.
//

import UIKit

class CreateComplainTableViewController: UITableViewController {
//    MARK:- Outlets
    @IBOutlet private weak var itemsCell: CreateComplainCell!
    @IBOutlet private weak var solutionCell: CreateComplainCell!
    @IBOutlet private weak var proofCell: CreateComplainCell!
    weak var parentController: CreateComplainViewController?
//    MARK:- Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.rowHeight = UITableViewAutomaticDimension;
        self.tableView.estimatedRowHeight = 70.0
        self.refreshUI()
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.refreshUI()
    }
    override func didMove(toParentViewController parent: UIViewController?) {
        super.didMove(toParentViewController: parent)
        if let parent = parent as? CreateComplainViewController {
            self.parentController = parent
            self.refreshUI()
        }
    }
//MARK:- UI Update
    private func refreshUI() {
        self.tableView.backgroundView = nil
        self.itemsCell.setActive()
        self.solutionCell.setDisabled()
        self.proofCell.setDisabled()
        guard let data = RCManager.shared.rcCreateStep1Data else {
            return
        }
        if data.isItemsAdded {
            self.itemsCell.setCompleted()
            if data.isSolutionAdded {
                self.solutionCell.setCompleted()
                if data.isProofAdded {
                    self.proofCell.setCompleted()
                } else {
                    self.proofCell.setActive()
                }
            } else {
                self.solutionCell.setActive()
                self.proofCell.setDisabled()
            }
        }
        self.parentController?.updateCreateButton()
        self.itemsCell.subTitleLabel.text = data.titleForItemsAdded
        self.solutionCell.subTitleLabel.text = data.titleForSolution
        self.proofCell.subTitleLabel.text = data.titleForProofSubmission
        self.tableView.reloadData()
    }
// MARK: - Table view delegate
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let header = UIView()
        header.backgroundColor = UIColor.clear
        return header
    }
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 0 {
            self.parentController?.showSelectProblemScreen()
            return
        }
        guard let data = RCManager.shared.rcCreateStep1Data else { return }
        if indexPath.section == 1 && data.isItemsAdded {
            self.parentController?.showSolutionsListScreen()
        } else if data.isSolutionAdded {
            self.parentController?.showProofSubmissionScreen()
        }
    }
}
