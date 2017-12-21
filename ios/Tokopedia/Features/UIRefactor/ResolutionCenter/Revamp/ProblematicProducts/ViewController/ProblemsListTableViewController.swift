//
//  ProblemsListTableViewController.swift
//  Tokopedia
//
//  Created by Vishun Dayal on 30/10/17.
//  Copyright © 2017 TOKOPEDIA. All rights reserved.
//

import UIKit

class ProblemsListTableViewController: UITableViewController {
    weak var parentController: ProblemsListViewController?
    //MARK:- Temporary variables to be removed after modal classes
    var isPostageDifference = true
//    MARK:- Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.tableFooterView = UIView()
        self.tableView.register(ProblemsListHeaderView.self, forHeaderFooterViewReuseIdentifier: "ProblemsListHeaderView")
        self.title = "Pilih Barang & Masalah"
        self.tableView.rowHeight = UITableViewAutomaticDimension;
        self.tableView.estimatedRowHeight = 100.0
    }
    override func didMove(toParentViewController parent: UIViewController?) {
        super.didMove(toParentViewController: parent)
        if let parent = parent as? ProblemsListViewController {
            self.parentController = parent
            self.loadProblemItemsIfNeeded()
        }
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.tableView.reloadData()
    }
//    MARK:-
    private func loadProblemItemsIfNeeded() {
        guard RCManager.shared.rcCreateStep1Data == nil else {return}
        self.parentController?.makeActivityIndicator(toShow: true)
        RCManager.shared.fetchCreateStep1 { (error: Error?) in
            self.parentController?.makeActivityIndicator(toShow: false)
            if let error = error {
                StickyAlertView.showErrorMessage([error.localizedDescription])
            } else {
                self.tableView.reloadData()
            }
        }
    }
    private func showDetailScreenWith(problem: RCProblemItem) {
        if let viewController = self.storyboard?.instantiateViewController(withIdentifier: "ProblemDetailViewController") as? ProblemDetailViewController {
            viewController.problemItem = problem
            self.navigationController?.pushViewController(viewController, animated: true)
        }
    }
    // MARK: - Table view data source    
    override func numberOfSections(in tableView: UITableView) -> Int {
        guard let data = RCManager.shared.rcCreateStep1Data else {
            return 0
        }
        var count = (data.createInfo.count > 0) ? 1 : 0
        if let _ = data.postageIssueProblem {
            count += 1
        }
        return count
    }
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let data = RCManager.shared.rcCreateStep1Data else {
            return 0
        }
        if let _ = data.postageIssueProblem {
            if section == 0 {
                return 1
            } else {
                return data.createInfo.count - 1
            }
        } else {
            return data.createInfo.count
        }
    }
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let problematicProductCell = tableView.dequeueReusableCell(withIdentifier: "ProblematicProductCell", for: indexPath) as? ProblematicProductCell
        guard let cell = problematicProductCell else {
            return UITableViewCell()
        }
        guard let data = RCManager.shared.rcCreateStep1Data else {
            return cell
        }
        let problem = data.createInfo[indexPath.row + indexPath.section]
        cell.updateWithProblem(item: problem)
        cell.checkboxButtonHandler = {(problemCell) in
            RCManager.shared.rcCreateStep1Data?.solutionData = nil
            if problem.isSelected {
                problem.isSelected = false
            } else {
                if problem.problem.type == 1 {
                    problem.selectedStatus = problem.status.first
                    problem.selectedStatus?.selectedTrouble = problem.selectedStatus?.trouble.first
                    problem.isSelected = true
                } else {
                    self.showDetailScreenWith(problem: problem)
                }
            }
            problemCell.updateWithProblem(item: problem)
            self.parentController?.updateSaveButton()
        }
        return cell
    }
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if let headerView = tableView.dequeueReusableHeaderFooterView(withIdentifier: "ProblemsListHeaderView") as? ProblemsListHeaderView {
            if section == 0 {
                headerView.titleLabel?.text = "Kendala Ongkos Kirim"
            } else {
                headerView.titleLabel?.text = "Kendala Barang"
            }
            return headerView
        }
        return UIView()
    }
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let data = RCManager.shared.rcCreateStep1Data else {
            return
        }
        let problem = data.createInfo[indexPath.row + indexPath.section]
        if indexPath.section == 0 {
            problem.isSelected = !problem.isSelected
            problem.selectedStatus = problem.status.first
            problem.selectedStatus?.selectedTrouble = problem.selectedStatus?.trouble.first
            if let cell = tableView.cellForRow(at: indexPath) as? ProblematicProductCell {
                cell.updateWithProblem(item: problem)
                self.parentController?.updateSaveButton()
            }
        } else {
            self.showDetailScreenWith(problem: problem)
        }
    }
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }}
