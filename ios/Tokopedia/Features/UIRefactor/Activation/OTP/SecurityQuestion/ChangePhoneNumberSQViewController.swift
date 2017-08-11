//
//  ChangePhoneNumberSQViewController.swift
//  Tokopedia
//
//  Created by Kenneth Vincent on 3/9/17.
//  Copyright © 2017 TOKOPEDIA. All rights reserved.
//

import UIKit
import DKImagePickerController

@objc(ChangePhoneNumberSQViewController)
class ChangePhoneNumberSQViewController: UIViewController {
    
    @IBOutlet fileprivate var formView: UIView!
    @IBOutlet fileprivate var addKTPButton: UIButton!
    @IBOutlet fileprivate var editKTPImage: UIImageView!
    @IBOutlet fileprivate var addTabunganButton: UIButton!
    @IBOutlet fileprivate var editTabunganImage: UIImageView!
    
    @IBOutlet fileprivate var submitButton: UIButton!
    
    @IBOutlet fileprivate var successView: UIView!
    @IBOutlet fileprivate var backToHomeButton: UIButton!
    
    fileprivate var sendButtonActivityIndicator : UIActivityIndicatorView = {
        let activityIndicator = UIActivityIndicatorView(activityIndicatorStyle: .white)
        
        return activityIndicator
    }()
    
    fileprivate let userID: String!
    fileprivate let token: OAuthToken!
    fileprivate let status: Bool
    
    fileprivate var ktpAsset: [DKAsset] = []
    fileprivate var tabunganAsset: [DKAsset] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Ubah Nomor Ponsel"
        
        let backButton = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        self.navigationItem.backBarButtonItem = backButton
        
        if self.status {
            self.displaySuccessView()
        } else {
            self.displayFormView()
        }
    }
    
    init(userID: String, token: OAuthToken, status: Bool) {
        self.userID = userID
        self.token = token
        self.status = status
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        AnalyticsManager.trackScreenName("Security Question - Change Phone Number Page")
    }
    
    //MARK: Initial View
    fileprivate func displayFormView() {
        self.view.addSubview(self.formView)
        self.formView.mas_makeConstraints { (make) in
            _ = make?.edges.mas_equalTo()(self.view)
        }
        self.editKTPImage.isHidden = true
        self.editTabunganImage.isHidden = true
        
        self.setupActivityIndicator(onButton: self.submitButton, activityIndicator: self.sendButtonActivityIndicator)
    }
    
    fileprivate func displaySuccessView() {
        self.view.addSubview(self.successView)
        self.successView.mas_makeConstraints { (make) in
            _ = make?.edges.mas_equalTo()(self.view)
        }
    }
    
    fileprivate func setupActivityIndicator(onButton button: UIButton, activityIndicator: UIActivityIndicatorView) {
        let halfButtonHeight = button.bounds.size.height / 2
        let buttonWidth = button.bounds.size.width
        
        activityIndicator.center = CGPoint(x: buttonWidth - halfButtonHeight, y: halfButtonHeight)
        
        button.addSubview(activityIndicator)
        activityIndicator.mas_makeConstraints({ (make) in
            _ = make?.centerX.equalTo()(button.mas_centerX)
            _ = make?.centerY.equalTo()(button.mas_centerY)
        })
    }
    
    //MARK: KTP Form Functions
    @IBAction fileprivate func tapToAddKTP(_ sender: Any) {
        AnalyticsManager.trackEventName("clickChangeNumber",
                                        category: GA_EVENT_CATEGORY_CHANGE_PHONE_NUMBER,
                                        action: GA_EVENT_ACTION_CLICK,
                                        label: "Add KTP")
        TKPImagePickerController.showImagePicker(
            self,
            assetType: .allPhotos,
            allowMultipleSelect: false,
            showCancel: true,
            showCamera: true,
            maxSelected: 1,
            selectedAssets: self.ktpAsset as NSArray?,
            completion: { (assets) in
                self.ktpAsset = assets
                self.adjustKTPImage()
        })
    }
    
    fileprivate func adjustKTPImage() {
        for (_, asset) in self.ktpAsset.enumerated() {
            asset.fetchImageWithSize(
                self.addKTPButton.frame.size.toPixel(),
                completeBlock: { (image, info) in
                    self.addKTPButton.imageView?.contentMode = .scaleAspectFit
                    self.addKTPButton.setImage(image, for: .normal)
                    self.addKTPButton.layer.borderColor = UIColor.tpLine().cgColor
                    self.addKTPButton.layer.borderWidth = 2.0
                    self.editKTPImage.isHidden = false
            })
        }
    }
    
    //MARK: Tabungan Form Functions
    @IBAction fileprivate func tapToAddTabungan(_ sender: Any) {
        AnalyticsManager.trackEventName("clickChangeNumber",
                                        category: GA_EVENT_CATEGORY_CHANGE_PHONE_NUMBER,
                                        action: GA_EVENT_ACTION_CLICK,
                                        label: "Add Buku Tabungan")
        TKPImagePickerController.showImagePicker(
            self,
            assetType: .allPhotos,
            allowMultipleSelect: false,
            showCancel: true,
            showCamera: true,
            maxSelected: 1,
            selectedAssets: self.tabunganAsset as NSArray?,
            completion: { (assets) in
                self.tabunganAsset = assets
                self.adjustTabunganImage()
        })
    }
    
    fileprivate func adjustTabunganImage() {
        for (_, asset) in self.tabunganAsset.enumerated() {
            asset.fetchImageWithSize(
                self.addTabunganButton.frame.size.toPixel(),
                completeBlock: { (image, info) in
                    self.addTabunganButton.imageView?.contentMode = .scaleAspectFit
                    self.addTabunganButton.setImage(image, for: .normal)
                    self.addTabunganButton.layer.borderColor = UIColor.tpLine().cgColor
                    self.addTabunganButton.layer.borderWidth = 2.0
                    self.editTabunganImage.isHidden = false
            })
        }
    }
    
    //MARK: Submit Button
    @IBAction fileprivate func tapToSubmit(_ sender: Any) {
        AnalyticsManager.trackEventName("clickChangeNumber",
                                        category: GA_EVENT_CATEGORY_CHANGE_PHONE_NUMBER,
                                        action: GA_EVENT_ACTION_CLICK,
                                        label: "Send Request")
        
        if self.validateAttachedPictures() {
            let ktpImage = self.ktpObjectRequest()
            let tabunganImage = self.tabunganObjectRequest()
            
            self.setSubmitButtonLoadingState(true)
            
            OTPRequest.submitKTPAndTabungan(
                withKTPImage: ktpImage,
                tabungan: tabunganImage,
                userID: self.userID,
                oAuthToken: self.token,
                onSuccess: { (result) in
                    AnalyticsManager.trackEventName("clickChangeNumber",
                                                    category: GA_EVENT_CATEGORY_CHANGE_PHONE_NUMBER,
                                                    action: "Send Request Success",
                                                    label: "Send Request")
                    UIView.animate(withDuration: 1.0, delay: 0.0, options: .curveEaseIn, animations: {
                        self.formView.alpha = 0.0
                        self.successView.alpha = 1.0
                    }, completion: { (success) in
                        self.formView.removeFromSuperview()
                        self.view.addSubview(self.successView)
                        self.successView.snp.makeConstraints({ (make) in
                            make.edges.equalTo(self.view)
                        })
                    })
            }, onFailure: {
                self.setSubmitButtonLoadingState(false)
            })
        }
        
    }
    
    fileprivate func validateAttachedPictures() -> Bool {
        var messageError: [String] = []
        
        if self.ktpAsset.count == 0 {
            messageError.append("KTP belum dilampirkan.")
        }
        
        if self.tabunganAsset.count == 0 {
            messageError.append("Buku tabungan belum dilampirkan.")
        }
        
        if messageError.count > 0 {
            StickyAlertView.showErrorMessage(messageError)
            return false
        }
        
        return true
    }
    
    fileprivate func setSubmitButtonLoadingState(_ isLoading: Bool) {
        isLoading ? self.sendButtonActivityIndicator.startAnimating() : self.sendButtonActivityIndicator.stopAnimating()
        self.submitButton.isEnabled = !isLoading
        self.submitButton.setTitle(isLoading ? "" : "Kirim", for: .normal)
    }
    
    fileprivate func ktpObjectRequest() -> AttachedImageObject {
        let object = AttachedImageObject()
        object.asset = self.ktpAsset.first
        object.imageID = String(format: "%@ %@ %@", "KTP", Date().description, userID)
        
        return object
    }
    
    fileprivate func tabunganObjectRequest() -> AttachedImageObject {
        let object = AttachedImageObject()
        object.asset = self.tabunganAsset.first
        object.imageID = String(format: "%@ %@ %@", "Tabungan", Date().description, userID)
        
        return object
    }
    
    //MARK: Back to Home Button
    @IBAction fileprivate func tapToRedirectToHome(_ sender: Any) {
        self.navigationController?.popToRootViewController(animated: true)
        self.navigationController?.dismiss(animated: true, completion: nil)
        NotificationCenter.default.post(name: NSNotification.Name(kTKPD_REDIRECT_TO_HOME), object: nil)
    }
}
