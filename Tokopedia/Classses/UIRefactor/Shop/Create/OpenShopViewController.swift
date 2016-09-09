//
//  OpenShopViewController.swift
//  Tokopedia
//
//  Created by Tokopedia on 4/25/16.
//  Copyright © 2016 TOKOPEDIA. All rights reserved.
//

import UIKit

@objc(OpenShopViewController) class OpenShopViewController: UITableViewController, UITextFieldDelegate, TKPDPhotoPickerDelegate, GenerateHostDelegate {
    
    var imagePicker: TKPDPhotoPicker!
    
    var shopDomain: String!
    var shopDomainError: [String] = []
    var shopImage: UIImage!
    var shopName: NSString!
    var shopTagline: NSString!
    var shopDescription: NSString!
    
    var generatedHost: GenerateHost!
    var uploadImageRequest: RequestUploadImage!
    var imageObject: Dictionary<String, Dictionary<String, AnyObject?>>!
    var uploadImageResponse: ImageResult!
    
    var requestObject: RequestObjectUploadImage!
    
    var domainIsValid: Bool!
    var enableChangePhotoButton: Bool!
    
    var pushToShipment: Bool!
    
    @IBOutlet var checkDomainButton: UIButton!
    @IBOutlet var checkDomainView: UIView!
    @IBOutlet var domainHeaderView: UIView!
    @IBOutlet var shopImageHeaderView: UIView!
    @IBOutlet var shopImageFooterView: UIView!
    @IBOutlet var shopInformationHeaderView: UIView!
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: NSBundle?) {
        let nib = nibNameOrNil ?? "OpenShopViewController"
        super.init(nibName: nib, bundle: nibBundleOrNil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        title = "Buka Toko"
        
        hidesBottomBarWhenPushed = true
        
        let saveButton: UIBarButtonItem = UIBarButtonItem(title: "Lanjut", style: .Done, target: self, action:#selector(didTapContinueButton))
        navigationItem.rightBarButtonItem = saveButton
        
        shopDomain = ""
        domainIsValid = false
        shopImage = UIImage(named: "icon_default_shop")
        shopName =  ""
        shopTagline = ""
        shopDescription = ""
        enableChangePhotoButton = false
        pushToShipment = false
        
        let requestHost: RequestGenerateHost = RequestGenerateHost()
        requestHost.delegate = self
        requestHost.configureRestkitGenerateHost()
        requestHost.requestGenerateHost()
        
        checkDomainButton.layer.cornerRadius = 2
        
        tableView.contentInset = UIEdgeInsetsMake(0, 0, 60, 0)
        
        tableView.registerNib(UINib(nibName: "OpenShopDomainViewCell", bundle: nil), forCellReuseIdentifier: "OpenShopDomain")
        tableView.registerNib(UINib(nibName: "OpenShopImageViewCell", bundle: nil), forCellReuseIdentifier: "OpenShopImage")
        tableView.registerNib(UINib(nibName: "OpenShopNameViewCell", bundle: nil), forCellReuseIdentifier: "OpenShopName")
        tableView.registerNib(UINib(nibName: "EditShopDescriptionViewCell", bundle: nil), forCellReuseIdentifier: "shopDescription")
        tableView.registerNib(UINib(nibName: "ShopTagDescriptionViewCell", bundle: nil), forCellReuseIdentifier: "ShopTagDescriptionViewCell")
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
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
                let domain = String(format: "https://tokopedia.com/%@", shopDomain)
                domainCell.domainTextField.text = domain
                if (domainIsValid == true) {
                    domainCell.accessoryType = .Checkmark
                } else {
                    domainCell.accessoryType = .None
                }
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
                return 80
            } else if indexPath.row == 2 {
                return 90
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
            if shopDomainError.count > 0 {
                errorMessages.appendContentsOf(shopDomainError)
            } else if shopDomain.characters.count == 0 {
                errorMessages.append("Domain harus diisi.")
            } else {
                errorMessages.append("Mohon cek domain terlebih dahulu.")
            }
        }
        if shopName.length == 0 {
            errorMessages.append("Nama Toko harus diisi.")
        }
        if shopTagline.length == 0 {
            errorMessages.append("Slogan harus diisi.")
        }
        if shopDescription.length == 0 {
            errorMessages.append("Deskripsi harus diisi.")
        }
        if errorMessages.count > 0 {
            let alert: StickyAlertView = StickyAlertView.init(errorMessages: errorMessages, delegate: self)
            alert.show()
            return;
        }
        let shopImageURL = (uploadImageResponse != nil) ? uploadImageResponse.image.pic_src as String : ""
                
        let controller: ShipmentViewController = ShipmentViewController(shipmentType: .OpenShop)
        controller.shopName = shopName as String
        
        controller.shopDomain = shopDomain as String
        controller.shopLogo = shopImageURL
        controller.shopTagline = shopTagline as String
        controller.shopShortDescription = shopDescription as String
        controller.generatedHost = generatedHost.result.generated_host
        self.navigationController?.pushViewController(controller, animated: true)
    }

    
    func shopDomainDidChange(textField: UITextField) -> Void {
        let text = textField.text! as NSString
        shopDomain = text.substringWithRange(NSRange(location: 22, length: text.length - 22))
        domainIsValid = false
        shopDomainError.removeAll()
    }

    func shopNameDidChange(textField: UITextField) -> Void {
        shopName = textField.text
    }

    func shopTaglineDidChange(notification: NSNotification) -> Void {
        let textView = notification.object as! RSKPlaceholderTextView
        shopTagline = textView.text
    }
    
    func shopDescriptionDidChange(notification: NSNotification) -> Void {
        let textView = notification.object as! RSKPlaceholderTextView
        shopDescription = textView.text
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
                                        if (response.message_error != nil) {
                                            self.shopDomainError = response.message_error as! [String]
                                            let alert: StickyAlertView = StickyAlertView.init(errorMessages: self.shopDomainError, delegate: self)
                                            alert.show()
                                        } else if response.result.status_domain == "1" {
                                            self.domainIsValid = true
                                            self.tableView.reloadRowsAtIndexPaths([NSIndexPath (forRow: 0, inSection: 0)], withRowAnimation: .Automatic)

                                            if (self.pushToShipment == true) {
                                                
                                            }
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
        requestObject.server_id = generatedHost.result.generated_host.server_id
        requestObject.user_id = UserAuthentificationManager().getUserId();
        requestObject.add_new = "1"
        
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
        
        requestObject = RequestObjectUploadImage()
        requestObject.server_id = generatedHost.result.generated_host.server_id
        requestObject.user_id = UserAuthentificationManager().getUserId();

        enableChangePhotoButton = true
        tableView.reloadData()
    }
    
    func failedGenerateHost(errorMessages: [AnyObject]!) {
        let alert: StickyAlertView = StickyAlertView.init(errorMessages: errorMessages, delegate: self)
        alert.show()
    }
    
}
