//
//  OpenShopViewController.swift
//  Tokopedia
//
//  Created by Tokopedia on 4/25/16.
//  Copyright © 2016 TOKOPEDIA. All rights reserved.
//

import UIKit

class OpenShopViewController: UITableViewController, UITextFieldDelegate, TKPDPhotoPickerDelegate, GenerateHostDelegate {
    
    var imagePicker: TKPDPhotoPicker!
    
    var shopDomain: NSString!
    var shopImage: UIImage!
    var shopName: NSString!
    var shopTagline: NSString!
    var shopDescription: NSString!
    
    var generatedHost: GenerateHost!
    var uploadImageRequest: RequestUploadImage!
    var imageObject: Dictionary<String, Dictionary<String, AnyObject?>>!
    var uploadImageResponse: ImageResult!
    
    var domainIsValid: Bool!
    var enableChangePhotoButton: Bool!
    
    @IBOutlet weak var checkDomainButton: UIButton!
    @IBOutlet var checkDomainView: UIView!
    @IBOutlet var domainHeaderView: UIView!
    @IBOutlet var shopImageHeaderView: UIView!
    @IBOutlet var shopImageFooterView: UIView!
    @IBOutlet var shopInformationHeaderView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        title = "Buka Toko"
        
        let saveButton: UIBarButtonItem = UIBarButtonItem(title: "Lanjut", style: .Done, target: self, action:#selector(didTapContinueButton))
        navigationItem.rightBarButtonItem = saveButton

        enableChangePhotoButton = false
        checkDomainButton.layer.cornerRadius = 2
        
        shopImage = UIImage(named: "icon_default_shop")
        
        tableView.contentInset = UIEdgeInsetsMake(0, 0, 60, 0)
        
        tableView.registerNib(UINib(nibName: "OpenShopDomainViewCell", bundle: nil), forCellReuseIdentifier: "OpenShopDomain")
        tableView.registerNib(UINib(nibName: "OpenShopImageViewCell", bundle: nil), forCellReuseIdentifier: "OpenShopImage")
        tableView.registerNib(UINib(nibName: "OpenShopNameViewCell", bundle: nil), forCellReuseIdentifier: "OpenShopName")
        tableView.registerNib(UINib(nibName: "EditShopDescriptionViewCell", bundle: nil), forCellReuseIdentifier: "shopDescription")
        tableView.registerNib(UINib(nibName: "ShopTagDescriptionViewCell", bundle: nil), forCellReuseIdentifier: "ShopTagDescriptionViewCell")
        
        let requestHost: RequestGenerateHost = RequestGenerateHost()
        requestHost.delegate = self
        requestHost.configureRestkitGenerateHost()
        requestHost.requestGenerateHost()
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
                imageCell.shopImageView?.image = shopImage
                imageCell.changeImageButton.addTarget(self, action: #selector(OpenShopViewController.didTapChangeImageButton(_:)), forControlEvents: .TouchUpInside)
                imageCell.changeImageButton.enabled = enableChangePhotoButton
                cell = imageCell
            }
        } else if indexPath.section == 2 {
            if indexPath.row == 0 {
                if let nameCell = tableView.dequeueReusableCellWithIdentifier("OpenShopName") as? OpenShopNameViewCell {
                    nameCell.nameTextField.addTarget(self, action: #selector(OpenShopViewController.shopNameDidChange(_:)), forControlEvents: UIControlEvents.EditingChanged)
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
                imageCell.imageView?.image = UIImage(named: "icon_default_shop")
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
    
    override func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if section == 0 {
            return self.domainHeaderView
        } else if section == 1 {
            return self.shopImageHeaderView
        } else if section == 2 {
            return self.shopInformationHeaderView
        } else {
            return nil
        }
    }
    
    override func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == 0 {
            return self.domainHeaderView.frame.size.height
        } else if section == 1 {
            return self.domainHeaderView.frame.size.height
        } else if section == 2 {
            return self.shopInformationHeaderView.frame.size.height
        } else {
            return 18
        }
    }
    
    override func tableView(tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        if section == 0 {
            return self.checkDomainView
        } else if section == 1 {
            return self.shopImageFooterView
        } else {
            return nil
        }
    }
    
    override func tableView(tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        if section == 0 {
            return self.checkDomainView.frame.size.height
        } else if section == 1 {
            return self.shopImageFooterView.frame.size.height
        } else {
            return 18
        }
    }
    
    func didTapContinueButton() -> Void {
        var errorMessages: [String] = []
        if domainIsValid == false {
            errorMessages.append("Domain harus diisi.")
        }
        if shopName.length > 0 {
            errorMessages.append("Nama Toko harus diisi")
        }
        if shopTagline.length > 0 {
            errorMessages.append("Slogan harus diisi.")
        }
        if shopDescription.length > 0 {
            errorMessages.append("Deskripsi harus diisi.")
        }
        if errorMessages.count > 0 {
            let alert: StickyAlertView = StickyAlertView.init(errorMessages: errorMessages, delegate: self)
            alert.show()
            return;
        }
        let controller: ShipmentViewController = ShipmentViewController()
        self.navigationController?.pushViewController(controller, animated: true)
    }

    
    func shopDomainDidChange(textField: UITextField) -> Void {
        let text = textField.text! as NSString
        shopDomain = text.substringWithRange(NSRange(location: 22, length: text.length))
    }

    func shopNameDidChange(textField: UITextField) -> Void {
        shopName = textField.text
    }

    func shopTaglineDidChange(notification: NSNotification) -> Void {
        let textField = notification.object as! UITextField
        shopTagline = textField.text
    }
    
    func shopDescriptionDidChange(notification: NSNotification) -> Void {
        let textField = notification.object as! UITextField
        shopDescription = textField.text
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
        imagePicker.delegate = self
    }
    
    @IBAction func didTapCheckDomainButton(sender: UIButton) {
        let manager: TokopediaNetworkManager = TokopediaNetworkManager()
        manager.isUsingHmac = true
        manager.requestWithBaseUrl(NSString.v4Url(),
                                   path: "/v4/action/myshop/check_domain.pl",
                                   method: .GET,
                                   parameter: ["shop_domain": shopDomain as String],
                                   mapping: AddShop.mapping(),
                                   onSuccess: { (mappingResult: RKMappingResult!, operation: RKObjectRequestOperation!) in
                                        let dictionary: NSDictionary = mappingResult.dictionary()
                                        let response = dictionary.objectForKey("") as! AddShop
                                        if response.message_error.count > 0 {
                                            let alert: StickyAlertView = StickyAlertView.init(errorMessages: response.message_error, delegate: self)
                                            alert.show()
                                        } else if response.result.is_success == "1" {
                                            self.domainIsValid = true
                                        }
                                    }) { (error: NSError!) in
        
                                    }
    }
    
    func photoPicker(picker: TKPDPhotoPicker!, didDismissCameraControllerWithUserInfo userInfo: [NSObject : AnyObject]!) {
        let photoDictionary = userInfo["photo"] as! [String: AnyObject];
        
        imageObject = [
            "photo": [
                "cameraimagedata": photoDictionary["cameraimagedata"],
                "cameraimagename": photoDictionary["cameraimagename"]
            ]
        ]

        shopImage = photoDictionary["photo"] as! UIImage
        enableChangePhotoButton = false
        
        tableView.reloadData()
        
        let name = photoDictionary["cameraimagename"] as! String
        
        let uploadHost = NSString(format: "https://%@", generatedHost.result.generated_host.upload_host) as String
        
        let requestObject: RequestObjectUploadImage = RequestObjectUploadImage()
        requestObject.add_new = "1"
        requestObject.server_id = generatedHost.result.generated_host.server_id
        requestObject.user_id = UserAuthentificationManager().getUserId();

        RequestUploadImage.requestUploadImage(shopImage,
                                              withUploadHost:uploadHost,
                                              path: "/web-service/v4/action/upload-image/upload_shop_image.pl",
                                              name: "logo",
                                              fileName: name,
                                              requestObject: requestObject,
                                              onSuccess: { (imageResult: ImageResult!) in
                                                self.uploadImageResponse = imageResult
                                                self.enableChangePhotoButton = true
                                                self.tableView.reloadData()
        }) { (error: NSError!) in
            if error != nil {
                let alert: StickyAlertView = StickyAlertView.init(errorMessages: [error.localizedDescription], delegate: self)
                alert.show()
            }
            self.shopImage = UIImage(named: "icon_default_shop")
            self.enableChangePhotoButton = true
            self.tableView.reloadData()
        }
    }

    func successGenerateHost(generateHostResponse: GenerateHost!) {
        generatedHost = generateHostResponse
        enableChangePhotoButton = true
        tableView.reloadData()
    }
    
    func failedGenerateHost(errorMessages: [AnyObject]!) {
        let alert: StickyAlertView = StickyAlertView.init(errorMessages: errorMessages, delegate: self)
        alert.show()
    }
    
}
