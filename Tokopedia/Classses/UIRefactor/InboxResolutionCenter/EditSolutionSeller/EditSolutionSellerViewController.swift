//
//  EditSolutionSellerViewController.swift
//  Tokopedia
//
//  Created by Renny Runiawati on 8/26/16.
//  Copyright © 2016 TOKOPEDIA. All rights reserved.
//

import UIKit

@objc class EditSolutionSellerViewController: UIViewController {
    
    @IBOutlet var reasonCell: UITableViewCell!
    @IBOutlet var solutionCell: UITableViewCell!
    @IBOutlet var returnMoneyViewHeight: NSLayoutConstraint!
    @IBOutlet var tableView: UITableView!
    
//    private var resolutionData :
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tableView.rowHeight = UITableViewAutomaticDimension
        self.tableView.estimatedRowHeight = 44
        
    }
    
    @IBAction func onTapChooseSolution(sender: AnyObject) {
        let controller : GeneralTableViewController = GeneralTableViewController()
//        controller.objects= 
        self.navigationController?.pushViewController(controller, animated: true)
    }
}

extension EditSolutionSellerViewController : GeneralTableViewControllerDelegate {
    func didSelectObject(object: AnyObject!) {
        
    }
}

extension EditSolutionSellerViewController : UITableViewDelegate {
    //MARK: UITableViewDelegate
    
    
}

extension EditSolutionSellerViewController : UITableViewDataSource {
    //MARK: UITableViewDataSource
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 3
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            return 0
        case 1:
            return 1
        case 2:
            return 2
        default:
            return 0
        }
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        switch indexPath.section {
        case 0:
            let cell:EditSolutionSellerCell = tableView.dequeueReusableCellWithIdentifier("cell")! as! EditSolutionSellerCell
            //TODO:: SET VIEW MODEL
//            cell.setViewModel()
            return cell
        case 1:
            return self.solutionCell
        case 2:
            return self.reasonCell
        default:
            let cell:EditSolutionSellerCell = tableView.dequeueReusableCellWithIdentifier("cell")! as! EditSolutionSellerCell
            return cell
        }
    }
    
    func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section {
        case 0:
            return ""
        case 1:
            return "Solusi yang diinginkan"
        case 2:
            return "Alasan ubah solusi"
        default:
            return ""
        }
    }
}

