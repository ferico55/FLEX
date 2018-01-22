//
//  SelectTroubleViewController.swift
//  Tokopedia
//
//  Created by Vishun Dayal on 07/11/17.
//  Copyright © 2017 TOKOPEDIA. All rights reserved.
//

import UIKit

class SelectTroubleViewController: UITableViewController {
    var rcProblemStatus: RCStatus!
    var didSelectedHandler: (()->Void)?
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupUI()
    }
//    MARK:- UI
    private func setupUI() {
        self.title = "Pilih Masalah"
        self.tableView.rowHeight = UITableViewAutomaticDimension;
        self.tableView.estimatedRowHeight = 44
        self.tableView.tableFooterView = UIView()
        let rightButton = UIBarButtonItem(title: "Selesai", style: .plain, target: self, action: #selector(SelectTroubleViewController.doneButtonTapped(sender:)))
        self.navigationItem.setRightBarButton(rightButton, animated: false)
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.3) {
            if let trouble = self.rcProblemStatus.selectedTrouble {
                if let row = self.rcProblemStatus.trouble.index(of: trouble) {
                    let indexPath = IndexPath(row: row, section: 0)
                    self.tableView.selectRow(at: indexPath, animated: true, scrollPosition: .none)
                }
            }
        }
    }
    
//    MARK:- Actions
    func doneButtonTapped(sender: UIBarButtonItem) {
        if let indexPath = self.tableView.indexPathForSelectedRow {
            self.rcProblemStatus.selectedTrouble = self.rcProblemStatus.trouble[indexPath.row]
            if let handler = self.didSelectedHandler {
                handler()
            }
            self.navigationController?.popViewController(animated: true)
        } else {
            StickyAlertView.showErrorMessage(["Mohon pilih masalah yang diinginkan"])
        }
    }
    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.rcProblemStatus.trouble.count
    }
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "SelectTroubleCell", for: indexPath) as? SelectTroubleCell else {
            return UITableViewCell()
        }
        let trouble = self.rcProblemStatus.trouble[indexPath.row]
        cell.updateWith(trouble: trouble)
        return cell
    }
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
}
