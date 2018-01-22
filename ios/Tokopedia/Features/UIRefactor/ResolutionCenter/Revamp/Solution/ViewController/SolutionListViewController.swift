//
//  SolutionListViewController.swift
//  Tokopedia
//
//  Created by Vishun Dayal on 15/11/17.
//  Copyright © 2017 TOKOPEDIA. All rights reserved.
//

import UIKit

class SolutionListViewController: UITableViewController {
    private weak var activityIndicator: UIActivityIndicatorView?
    var selectedSolution: RCCreateSolution?
    var solutionData: RCCreateSolutionData? {
        return RCManager.shared.rcCreateStep1Data?.solutionData
    }
    //    MARK:- Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupUI()
        AnalyticsManager.trackScreenName("Resolution Center Create Solution Page")
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.tableView.reloadData()
    }
    //    MARK:-
    private func setupUI() {
        self.title = "Pilih Solusi"
        self.getSolutionsList()
        self.tableView.rowHeight = UITableViewAutomaticDimension;
        self.tableView.estimatedRowHeight = 60.0
        let rightButton = UIBarButtonItem(title: "Selesai", style: .plain, target: self, action: #selector(SelectTroubleViewController.doneButtonTapped(sender:)))
        self.navigationItem.setRightBarButton(rightButton, animated: false)
    }
    func makeActivityIndicator(toShow: Bool) {
        if self.activityIndicator == nil {
            let activity = UIActivityIndicatorView(activityIndicatorStyle: .gray)
            activity.hidesWhenStopped = true
            activity.center = self.view.center
            self.view.addSubview(activity)
            activity.centerXAnchor.constraint(equalTo: self.view.centerXAnchor).isActive = true
            activity.centerYAnchor.constraint(equalTo: self.view.centerYAnchor).isActive = true
            self.activityIndicator = activity
        }
        if toShow {
            self.activityIndicator?.startAnimating()
        } else {
            self.activityIndicator?.stopAnimating()
        }
    }
    //    MARK:-
    private func getSolutionsList() {
        if self.solutionData != nil {
            self.selectedSolution = self.solutionData?.selectedSolution
            return
        }
        self.makeActivityIndicator(toShow: true)
        RCManager.shared.fetchSolutions {[weak self] (data: RCCreateSolutionData?, error: Error?) in
            self?.makeActivityIndicator(toShow: false)
            if let error = error {
                StickyAlertView.showErrorMessage([error.localizedDescription])
            } else {
                RCManager.shared.rcCreateStep1Data?.solutionData = data
                self?.tableView.reloadData()
            }
        }
    }
    //    MARK:- Actions
    func showReturnAmountScreen(solution: RCCreateSolution) {
        if let viewController = self.storyboard?.instantiateViewController(withIdentifier: "ReturnAmountViewController") as? ReturnAmountViewController {
            viewController.solution = solution
            self.navigationController?.pushViewController(viewController, animated: true)
        }
    }
    func doneButtonTapped(sender: UIBarButtonItem) {
        guard let solutionData = self.solutionData else {return}
        if self.selectedSolution != nil {
            solutionData.selectedSolution = self.selectedSolution
            self.navigationController?.popViewController(animated: true)
        }
    }
    // MARK: - Table view data source
    override func numberOfSections(in tableView: UITableView) -> Int {
        guard let solutionData = self.solutionData else {return 0}
        var count = solutionData.solution.count
        if let _ = solutionData.freeReturn {
            count += 1
        }
        return  count
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let solutionData = self.solutionData else {return UITableViewCell()}
        if indexPath.section == 0 && solutionData.freeReturn != nil {
            if let cell = tableView.dequeueReusableCell(withIdentifier: "SolutionFreeReturnCell", for: indexPath) as? SolutionFreeReturnCell {
                if let freeReturn = solutionData.freeReturn {
                    cell.updateWith(returnInfo: freeReturn)
                }
                return cell
            } else {
                return UITableViewCell()
            }
        } else {
            if let cell = tableView.dequeueReusableCell(withIdentifier: "SolutionTextCell", for: indexPath) as? SolutionTextCell {
                let index = indexPath.section - ((solutionData.freeReturn != nil) ? 1 : 0)
                let sol = solutionData.solution[index]
                cell.updateWith(solution: sol, selected: self.selectedSolution)
                return cell
            } else {
                return UITableViewCell()
            }
        }
    }
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let solutionData = self.solutionData else {return}
        let index = indexPath.section - ((solutionData.freeReturn != nil) ? 1 : 0)
        let sol = solutionData.solution[index]
        if sol.amount == nil {
            self.selectedSolution = sol
            self.tableView.reloadData()
        } else {
            self.showReturnAmountScreen(solution: sol)
        }
    }
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    override func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        return self.emptyView
    }
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return self.emptyView
    }
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == 0 {
            guard self.solutionData?.freeReturn != nil else {return 20}
        }
        return 0
    }
    private var emptyView: UIView {
        let footer = UIView()
        footer.backgroundColor = UIColor.clear
        return footer
    }
}
