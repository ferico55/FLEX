//
//  OpenShopViewController.swift
//  Tokopedia
//
//  Created by Tokopedia on 4/25/16.
//  Copyright © 2016 TOKOPEDIA. All rights reserved.
//

import UIKit
import RSKPlaceholderTextView
import RestKit

@objc(OpenShopViewController) class OpenShopViewController: UITableViewController, UITextFieldDelegate, TKPDPhotoPickerDelegate {
    
    var imagePicker: TKPDPhotoPicker!
    
    var shopDomain: String!
    var shopDomainError: [String] = []
    var shopImage: UIImage!
    var shopName: NSString!
    var shopTagline: NSString!
    var shopDescription: NSString!
    
    var generatedHost: GeneratedHost!
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
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
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
        
        let saveButton: UIBarButtonItem = UIBarButtonItem(title: "Lanjut", style: .done, target: self, action:#selector(didTapContinueButton))
        navigationItem.rightBarButtonItem = saveButton
        
        shopDomain = ""
        domainIsValid = false
        shopImage = UIImage(named: "icon_default_shop")
        shopName =  ""
        shopTagline = ""
        shopDescription = ""
        enableChangePhotoButton = false
        pushToShipment = false
        
        GenerateHostObservable.getGeneratedHost()
            .subscribe(onNext: { (host) in
                
                self.generatedHost = host
                
                self.requestObject = RequestObjectUploadImage()
                self.requestObject.server_id = host.server_id
                self.requestObject.user_id = UserAuthentificationManager().getUserId();
                
                self.enableChangePhotoButton = true
                self.tableView.reloadData()
            })
        
        checkDomainButton.layer.cornerRadius = 2
        
        tableView.contentInset = UIEdgeInsetsMake(0, 0, 60, 0)
        
        tableView.register(UINib(nibName: "OpenShopDomainViewCell", bundle: nil), forCellReuseIdentifier: "OpenShopDomain")
        tableView.register(UINib(nibName: "OpenShopImageViewCell", bundle: nil), forCellReuseIdentifier: "OpenShopImage")
        tableView.register(UINib(nibName: "OpenShopNameViewCell", bundle: nil), forCellReuseIdentifier: "OpenShopName")
        tableView.register(UINib(nibName: "EditShopDescriptionViewCell", bundle: nil), forCellReuseIdentifier: "shopDescription")
        tableView.register(UINib(nibName: "ShopTagDescriptionViewCell", bundle: nil), forCellReuseIdentifier: "ShopTagDescriptionViewCell")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.navigationController?.setWhite()
        
        AnalyticsManager.trackScreenName("Create Shop Page")
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 3
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        var numberOfRows: Int = 0
        if section == 0 || section == 1 {
            numberOfRows = 1;
        }
        else if section == 2 {
            numberOfRows = 3
        }
        return numberOfRows
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell: UITableViewCell = tableView.dequeueReusableCell(withIdentifier: "OpenShopDomain") as! OpenShopDomainViewCell
        if indexPath.section == 0 {
            if let domainCell = tableView.dequeueReusableCell(withIdentifier: "OpenShopDomain") as? OpenShopDomainViewCell {
                domainCell.domainTextField.addTarget(self, action: #selector(OpenShopViewController.shopDomainDidChange(_:)), for: UIControlEvents.editingChanged)
                domainCell.domainTextField.delegate = self
                let domain = String(format: "https://tokopedia.com/%@", shopDomain)
                domainCell.domainTextField.text = domain
                if (domainIsValid == true) {
                    domainCell.accessoryType = .checkmark
                } else {
                    domainCell.accessoryType = .none
                }
                cell = domainCell
            }
        } else if indexPath.section == 1 {
            if let imageCell = tableView.dequeueReusableCell(withIdentifier: "OpenShopImage") as? OpenShopImageViewCell {
                imageCell.shopImageView?.image = shopImage
                imageCell.changeImageButton.addTarget(self, action: #selector(OpenShopViewController.didTapChangeImageButton(_:)), for: .touchUpInside)
                imageCell.changeImageButton.isEnabled = enableChangePhotoButton
                cell = imageCell
            }
        } else if indexPath.section == 2 {
            if indexPath.row == 0 {
                if let nameCell = tableView.dequeueReusableCell(withIdentifier: "OpenShopName") as? OpenShopNameViewCell {
                    nameCell.nameTextField.addTarget(self, action: #selector(OpenShopViewController.shopNameDidChange(_:)), for: UIControlEvents.editingChanged)
                    cell = nameCell
                }
            } else if indexPath.row == 1 {
                if let taglineCell = tableView.dequeueReusableCell(withIdentifier: "ShopTagDescriptionViewCell") as? ShopTagDescriptionViewCell {
                    taglineCell.textView.placeholder = "Tulis Slogan"
                    taglineCell.textView.tag = 1
                    taglineCell.updateCounterLabel()
                    NotificationCenter.default.addObserver(self, selector: #selector(shopTaglineDidChange), name: Notification.Name.UITextViewTextDidChange, object: taglineCell.textView)
                    cell = taglineCell
                }
            } else if indexPath.row == 2 {
                if let descriptionCell = tableView.dequeueReusableCell(withIdentifier: "ShopTagDescriptionViewCell") as? ShopTagDescriptionViewCell {
                    descriptionCell.textView.placeholder = "Tulis Deskripsi"
                    descriptionCell.textView.tag = 2
                    descriptionCell.updateCounterLabel()
                    NotificationCenter.default.addObserver(self, selector: #selector(shopDescriptionDidChange), name: Notification.Name.UITextViewTextDidChange, object: descriptionCell.textView)
                    cell = descriptionCell
                }
            }
        }
        return cell
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        var cell: UITableViewCell = tableView.dequeueReusableCell(withIdentifier: "OpenShopDomain") as! OpenShopDomainViewCell
        if indexPath.section == 1 {
            if let imageCell = tableView.dequeueReusableCell(withIdentifier: "OpenShopImage") as? OpenShopImageViewCell {
                imageCell.imageView?.image = UIImage(named: "icon_default_shop")
                cell = imageCell
            }
        } else if indexPath.section == 2 {
            if indexPath.row == 0 {
                if let nameCell = tableView.dequeueReusableCell(withIdentifier: "OpenShopName") as? OpenShopNameViewCell {
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
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
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
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
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
    
    override func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        if section == 0 {
            return self.checkDomainView
        } else if section == 1 {
            return self.shopImageFooterView
        } else {
            return nil
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
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
                errorMessages.append(contentsOf: shopDomainError)
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
            let alert: StickyAlertView = StickyAlertView(errorMessages: errorMessages, delegate: self)
            alert.show()
            AnalyticsManager.trackEventName("clickCreateShop", category: GA_EVENT_CATEGORY_CREATE_SHOP, action: GA_EVENT_ACTION_CLICK, label: "Continue Shop Biodata \(errorMessages)")
            return;
        }
        AnalyticsManager.trackEventName("clickCreateShop", category: GA_EVENT_CATEGORY_CREATE_SHOP, action: GA_EVENT_ACTION_CLICK, label: "Continue Shop Biodata")
        let shopImageURL = (uploadImageResponse != nil) ? uploadImageResponse.image.pic_src as String : ""
                
        let controller: ShipmentViewController = ShipmentViewController(shipmentType: .openShop)
        controller.shopName = shopName as String
        
        controller.shopDomain = shopDomain as String
        controller.shopLogo = shopImageURL
        controller.shopTagline = shopTagline as String
        controller.shopShortDescription = shopDescription as String
        controller.generatedHost = generatedHost
        self.navigationController?.pushViewController(controller, animated: true)
    }
    
    func shopDomainDidChange(_ textField: UITextField) -> Void {
        let text = textField.text! as NSString
        shopDomain = text.substring(with: NSRange(location: 22, length: text.length - 22))
        domainIsValid = false
        shopDomainError.removeAll()
    }

    func shopNameDidChange(_ textField: UITextField) -> Void {
        shopName = textField.text as NSString!
    }

    func shopTaglineDidChange(_ notification: Notification) -> Void {
        let textView = notification.object as! RSKPlaceholderTextView
        shopTagline = textView.text as NSString!
    }
    
    func shopDescriptionDidChange(_ notification: Notification) -> Void {
        let textView = notification.object as! RSKPlaceholderTextView
        shopDescription = textView.text as NSString!
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if range.location < 22 {
            return false
        } else {
            return true
        }
    }
    
    func didTapChangeImageButton(_ button: UIButton) -> Void {
        imagePicker = TKPDPhotoPicker(parentViewController: self, pickerTransistionStyle: .coverVertical)
        imagePicker.delegate = self
    }
    
    @IBAction func didTapCheckDomainButton(_ sender: UIButton) {
        let manager: TokopediaNetworkManager = TokopediaNetworkManager()
        manager.isUsingHmac = true
        manager.request(withBaseUrl: NSString.v4Url(),
                        path: "/v4/action/myshop/check_domain.pl",
                        method: .GET,
                        parameter: ["shop_domain": shopDomain as String],
                        mapping: AddShop.mapping(),
                        onSuccess: { (mappingResult: RKMappingResult!, operation: RKObjectRequestOperation!) in
                            let dictionary: NSDictionary = mappingResult.dictionary() as NSDictionary
                            let response = dictionary.object(forKey: "") as! AddShop
                            if (response.message_error != nil) {
                                self.shopDomainError = response.message_error as! [String]
                                let alert: StickyAlertView = StickyAlertView(errorMessages: self.shopDomainError, delegate: self)
                                alert.show()
                            } else if response.result.status_domain == "1" {
                                self.domainIsValid = true
                                self.tableView.reloadRows(at: [NSIndexPath(item: 0, section: 0) as IndexPath], with: .automatic)
                                
                                if (self.pushToShipment == true) {
                                    
                                }
                            }
                        },
                        onFailure: { error in
        
                        })

    }
    
    func photoPicker(_ picker: TKPDPhotoPicker!, didDismissCameraControllerWithUserInfo userInfo: [AnyHashable: Any]!) {
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
        
        let uploadHost = NSString(format: "https://%@", generatedHost.upload_host) as String
        
        let requestObject: RequestObjectUploadImage = RequestObjectUploadImage()
        requestObject.server_id = generatedHost.server_id
        requestObject.user_id = UserAuthentificationManager().getUserId();
        requestObject.add_new = "1"
        
        RequestUploadImage.requestUploadImage(
            shopImage,
            withUploadHost:uploadHost,
            path: "/web-service/v4/action/upload-image/upload_shop_image.pl",
            name: "logo",
            fileName: name,
            request: requestObject,
            onSuccess: { imageResult in
                self.uploadImageResponse = imageResult
                self.enableChangePhotoButton = true
                self.tableView.reloadData()
            },
            onFailure: { error in
                if let error = error {
                    let alert: StickyAlertView = StickyAlertView(errorMessages: [error.localizedDescription], delegate: self)
                    alert.show()
                }
                self.shopImage = UIImage(named: "icon_default_shop")
                self.enableChangePhotoButton = true
                self.tableView.reloadData()
            })
    }
}
