//
//  AddressBookViewController.swift
//  Tokopedia
//
//  Created by Tonito Acen on 8/1/16.
//  Copyright © 2016 TOKOPEDIA. All rights reserved.
//

import UIKit

class AddressBookViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var tableView: UITableView!
    var contacts: [APContact]!
    var didTapContact: (APContact -> Void)?
    
    init() {
        super.init(nibName: "AddressBookViewController", bundle: nil)
    }
    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Nomor Kontak"
        self.tableView .registerNib(UINib(nibName: "AddressBookCell", bundle: nil), forCellReuseIdentifier: "AddressBookCellId")
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        self.didTapContact!(contacts[indexPath.row])
        self.navigationController?.popViewControllerAnimated(true)
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.contacts.count
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 70
    }

    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = self.tableView .dequeueReusableCellWithIdentifier("AddressBookCellId") as! AddressBookCell
        
        let contact = self.contacts[indexPath.row]
        cell.phoneNumber.text = contact.phones?.first?.number
        cell.contactName.text = contact.name?.firstName
        
        return cell
    }
}
