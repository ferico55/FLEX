//
//  PulsaOperatorViewController.swift
//  Tokopedia
//
//  Created by Tonito Acen on 11/30/16.
//  Copyright © 2016 TOKOPEDIA. All rights reserved.
//

import UIKit

class PulsaOperatorViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var tableView: UITableView!
    var operators = [PulsaOperator]()
    var didTapOperator: (PulsaOperator -> Void)?
    
    init() {
        super.init(nibName: "PulsaOperatorViewController", bundle: nil)
    }
    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        self.title = "Pilih Jenis"
        self.tableView .registerNib(UINib(nibName: "PulsaOperatorCell", bundle: nil), forCellReuseIdentifier: "PulsaOperatorCellIdentifier")
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //MARK: UITableViewDataSource
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = self.tableView .dequeueReusableCellWithIdentifier("PulsaOperatorCellIdentifier") as! PulsaOperatorCell
        
        let pulsaOperator = self.operators[indexPath.row]
        cell.operatorName.text = pulsaOperator.attributes.name
        
        return cell
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.operators.count
    }
    
    //MARK: UITableViewDelegate
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        self.didTapOperator?(operators[indexPath.row])
        self.navigationController?.popViewControllerAnimated(true)
    }
    

}
