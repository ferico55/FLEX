//
//  OpenShopViewController.swift
//  Tokopedia
//
//  Created by Tokopedia on 4/25/16.
//  Copyright © 2016 TOKOPEDIA. All rights reserved.
//

import UIKit

class OpenShopViewController: UITableViewController, UITextFieldDelegate {
    
    var imagePicker: TKPDPhotoPicker!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Buka Toko"
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Lanjut", style: .Done, target: self, action:#selector(pushToNextPage))
        tableView.registerNib(UINib(nibName: "OpenShopDomainViewCell", bundle: nil), forCellReuseIdentifier: "OpenShopDomain")
        tableView.registerNib(UINib(nibName: "OpenShopImageViewCell", bundle: nil), forCellReuseIdentifier: "OpenShopImage")
        tableView.registerNib(UINib(nibName: "OpenShopNameViewCell", bundle: nil), forCellReuseIdentifier: "OpenShopName")
        tableView.registerNib(UINib(nibName: "EditShopDescriptionViewCell", bundle: nil), forCellReuseIdentifier: "shopDescription")
        tableView.registerNib(UINib(nibName: "ShopTagDescriptionViewCell", bundle: nil), forCellReuseIdentifier: "ShopTagDescriptionViewCell")
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 3
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        var numberOfRows: Int = 0
        if section == 0 || section == 1 {
            numberOfRows = 1;
        }
        else if section == 2 {
            numberOfRows = 3
        }
        return numberOfRows
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell: UITableViewCell = tableView.dequeueReusableCellWithIdentifier("OpenShopDomain") as! OpenShopDomainViewCell
        if indexPath.section == 0 {
            if let domainCell = tableView.dequeueReusableCellWithIdentifier("OpenShopDomain") as? OpenShopDomainViewCell {
                domainCell.domainTextField.addTarget(self, action: #selector(OpenShopViewController.shopDomainDidChange(_:)), forControlEvents: UIControlEvents.EditingChanged)
                domainCell.domainTextField.delegate = self
                cell = domainCell
            }
        } else if indexPath.section == 1 {
            if let imageCell = tableView.dequeueReusableCellWithIdentifier("OpenShopImage") as? OpenShopImageViewCell {
                imageCell.changeImageButton.addTarget(self, action: #selector(OpenShopViewController.didTapChangeImageButton(_:)), forControlEvents: .TouchUpInside)
                cell = imageCell
            }
        } else if indexPath.section == 2 {
            if indexPath.row == 0 {
                if let nameCell = tableView.dequeueReusableCellWithIdentifier("OpenShopName") as? OpenShopNameViewCell {
                    cell = nameCell
                }
            } else if indexPath.row == 1 {
                if let taglineCell = tableView.dequeueReusableCellWithIdentifier("ShopTagDescriptionViewCell") as? ShopTagDescriptionViewCell {
                    taglineCell.textView.placeholder = "Tulis Slogan"
                    taglineCell.textView.tag = 1
                    taglineCell.updateCounterLabel()
                    NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(shopTaglineDidChange), name: UITextViewTextDidChangeNotification, object: taglineCell.textView)
                    cell = taglineCell
                }
            } else if indexPath.row == 2 {
                if let descriptionCell = tableView.dequeueReusableCellWithIdentifier("ShopTagDescriptionViewCell") as? ShopTagDescriptionViewCell {
                    descriptionCell.textView.placeholder = "Tulis Deskripsi"
                    descriptionCell.textView.tag = 2
                    descriptionCell.updateCounterLabel()
                    NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(shopDescriptionDidChange), name: UITextViewTextDidChangeNotification, object: descriptionCell.textView)
                    cell = descriptionCell
                }
            }
        }
        return cell
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        var cell: UITableViewCell = tableView.dequeueReusableCellWithIdentifier("OpenShopDomain") as! OpenShopDomainViewCell
        if indexPath.section == 1 {
            if let imageCell = tableView.dequeueReusableCellWithIdentifier("OpenShopImage") as? OpenShopImageViewCell {
                cell = imageCell
            }
        } else if indexPath.section == 2 {
            if indexPath.row == 0 {
                if let nameCell = tableView.dequeueReusableCellWithIdentifier("OpenShopName") as? OpenShopNameViewCell {
                    cell = nameCell
                }
            } else if indexPath.row == 1 {
                if let taglineCell = tableView.dequeueReusableCellWithIdentifier("shopDescription") as? EditShopDescriptionViewCell {
                    cell = taglineCell
                }
            } else if indexPath.row == 2 {
                if let descriptionCell = tableView.dequeueReusableCellWithIdentifier("shopDescription") as? EditShopDescriptionViewCell {
                    cell = descriptionCell
                }
            }
        }
        return cell.frame.size.height
    }
    
    func pushToNextPage() -> Void {
        let controller: ShipmentViewController = ShipmentViewController()
        self.navigationController?.pushViewController(controller, animated: true)
    }
    
    func shopTaglineDidChange(notification: NSNotification) -> Void {

    }
    
    func shopDescriptionDidChange(notification: NSNotification) -> Void {
        
    }
    
    func shopDomainDidChange(textField: UITextField) -> Void {
        
    }
    
    func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {
        if range.location < 22 {
            return false
        } else {
            return true
        }
    }
    
    func didTapChangeImageButton(button: UIButton) -> Void {
        imagePicker = TKPDPhotoPicker.init(parentViewController: self, pickerTransistionStyle: .CoverVertical)
    }
    
}
