//
//  AddressBookViewController.swift
//  Tokopedia
//
//  Created by Tonito Acen on 8/1/16.
//  Copyright © 2016 TOKOPEDIA. All rights reserved.
//

import UIKit

class AddressBookViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var searchBar: UISearchBar!
    
    var didTapContact: (String -> Void)?
    
    private let addressBook = APAddressBook()
    private let noResultLabel = UILabel(frame: CGRectZero)
    private var contacts = [APContact]()
    
    init() {
        super.init(nibName: "AddressBookViewController", bundle: nil)
    }
    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Nomor Kontak"
        self.searchBar.delegate = self
        self.tableView .registerNib(UINib(nibName: "AddressBookCell", bundle: nil), forCellReuseIdentifier: "AddressBookCellId")
        
        self.addressBook.filterBlock = { contacts in
            return contacts.phones?.count > 0
        }

        self.addressBook.sortDescriptors = [NSSortDescriptor(key: "name.firstName", ascending: true), NSSortDescriptor(key: "name.lastName", ascending: true)]

        self.reloadContacts()
    }
    
    private func reloadContacts() {
        self.addressBook.loadContacts({ [unowned self] (contacts: [APContact]?, error: NSError?) in
            if(error == nil && contacts?.count > 0) {
                self.contacts = contacts!
                self.noResultLabel .removeFromSuperview()
            } else {
                self.contacts = []
                self.noResultLabel.text = "Tidak ada kontak"
                self.noResultLabel.font = UIFont.title1ThemeMedium()
                self.noResultLabel.textAlignment = .Center
                
                self.tableView.addSubview(self.noResultLabel)
                
                self.noResultLabel.mas_makeConstraints({ (make) in
                    make.left.right().equalTo()(self.tableView).offset()(10)
                    make.center.equalTo()(self.tableView)
                })
            }
            
            self.tableView.reloadData()
        })
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        self.didTapContact!(contacts[indexPath.section].phones![indexPath.row].number!)
        self.navigationController?.popViewControllerAnimated(true)
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if((self.contacts[section].phones) != nil) {
            return self.contacts[section].phones!.count
        }
        
        return 0
        
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return self.contacts.count
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 70
    }

    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = self.tableView .dequeueReusableCellWithIdentifier("AddressBookCellId") as! AddressBookCell
        
        let contact = self.contacts[indexPath.section]
        cell.phoneNumber.text = contact.phones![indexPath.row].number
        
        return cell
    }
    
    func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        let contact = self.contacts[section]
        
        return contact.name?.firstName
    }
    
    //MARK: Search delegate
    func searchBar(searchBar: UISearchBar, textDidChange searchText: String) {
        if(searchText != "") {
            self.addressBook.filterBlock = { contact in
                
                var isNameExists = false
                if ((contact.name?.firstName) != nil) {
                    isNameExists = (contact.name?.firstName?.containsString(searchText))!
                }
                
                let matchedPhoneNumber = contact.phones?.filter({ (phone) -> Bool in
                    return phone.number!.containsString(searchText)
                })
                
                
                return isNameExists || matchedPhoneNumber?.count > 0
            }
        } else {
            self.addressBook.filterBlock = { contacts in
                return contacts.phones?.count > 0
            }
        }
        
        
        self.reloadContacts()
    }
    
}
