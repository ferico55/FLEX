//
//  ReportProductViewController.swift
//  Tokopedia
//
//  Created by Billion Goenawan on 7/12/16.
//  Copyright © 2016 TOKOPEDIA. All rights reserved.
//

import UIKit
import BlocksKit
import RestKit
import DownPicker

@objc(ReportProductViewController)
class ReportProductViewController: UIViewController, UITextViewDelegate{
    
    var productId: String!

    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var jenisLaporanLabel: UILabel!
    @IBOutlet weak var deskripsiTextView: UITextView!
    @IBOutlet weak var linkInstructionLabel: UILabel!
    @IBOutlet var downPickerTextField: UITextField!
    @IBOutlet weak var tulisDeskripsiPlaceholderLabel: UILabel!
    @IBOutlet weak var laporkanButton: UIButton!
    
    var downPicker: DownPicker!
    var submitBarButtonItem: UIBarButtonItem!
    var networkManager = TokopediaNetworkManager()
    var reportDataArray : [[String: Any]] = [[:]]
    var reportLinkUrl: String?
    var userManager = UserAuthentificationManager()
    var selectedReportId: Int!
    var errorAlertView: UIAlertView?
    var successAlertView: UIAlertView?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        downPickerTextField.isEnabled = false
        deskripsiTextView.delegate = self
        generateKeyboardNotification()
        setupHiddenObject()
        generateSubmitBarButtonItem()
        if userManager.isLogin {
            getReportTypeFromAPI()
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationItem.title = "Laporkan Produk"
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    @IBAction func didTapReportButton(_ sender: UIButton) {
        let userManager = UserAuthentificationManager()
        let appVersion = UIApplication.getAppVersionStringWithoutDot()
        let webViewVC = WebViewController()
        
        let webViewURL = (self.reportLinkUrl! + "?flag_app=3&device=ios&app_version=\(appVersion)" as NSString).kv_encodeHTMLCharacterEntities()
        
        
        webViewVC.strURL = userManager.webViewUrl(fromUrl: webViewURL!)
        webViewVC.strTitle = "Laporkan Produk"
        webViewVC.shouldAuthorizeRequest = true
        webViewVC.onTapLinkWithUrl = { (url) in
            if (url?.absoluteString == "https://www.tokopedia.com/") {
                self.navigationController?.popViewController(animated: true)
            }
        }
        self.navigationController?.pushViewController(webViewVC, animated: true)
    }
    
    // MARK: KeyboardNotification
    
    func generateKeyboardNotification() {
        let notificationCenter = NotificationCenter.default
        notificationCenter.addObserver(self, selector: #selector(keyboardWillShow), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        notificationCenter.addObserver(self, selector: #selector(keyboardWillHide), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    }
    
    func keyboardWillShow(_ notification: Notification) {
        scrollView.contentInset = UIEdgeInsetsMake(0, 0, deskripsiTextView.frame.size.height, 0)
        scrollView.scrollIndicatorInsets = UIEdgeInsetsMake(0, 0, deskripsiTextView.frame.size.height, 0)
    }
    
    func keyboardWillHide(_ notification: Notification) {
        scrollView.contentInset = UIEdgeInsetsMake(0, 0, 0, 0)
    }
    
    // MARK: Layout Setup
    
    func generateSubmitBarButtonItem() {
        self.submitBarButtonItem = UIBarButtonItem(title: "Submit", style: .plain, target: self, action: #selector(ReportProductViewController.sendReportToServer))
        disableSubmitBarButtonItem()
        self.navigationItem.rightBarButtonItem = submitBarButtonItem
    }
    
    func disableSubmitBarButtonItem() {
        self.submitBarButtonItem.tintColor = UIColor(colorLiteralRed: 228/255, green: 228/255, blue: 228/255, alpha: 1.0)
        self.submitBarButtonItem.isEnabled = false
    }
    
    func enableSubmitBarButtonItem() {
        self.submitBarButtonItem.tintColor = UIColor(colorLiteralRed: 255/255, green: 255/255, blue: 255/255, alpha: 1.0)
        self.submitBarButtonItem.isEnabled = true
    }
    
    func setupHiddenObject() {
        hideDeskripsiForm()
        hideLinkInstruction()
    }
    
    func showDeskripsiForm() {
        self.deskripsiTextView.isHidden = false
        showOrHidePlaceholder()
    }
    
    func hideDeskripsiForm() {
        self.deskripsiTextView.isHidden = true
        showOrHidePlaceholder()
    }
    
    func hideLinkInstruction() {
        self.linkInstructionLabel.isHidden = true
        self.laporkanButton.isHidden = true
    }
    
    func showLinkInstruction() {
        self.linkInstructionLabel.isHidden = false
        self.laporkanButton.isHidden = false
    }
    
    func showOrHidePlaceholder() {
        if self.deskripsiTextView.text == "" && self.deskripsiTextView.isHidden == false {
            self.tulisDeskripsiPlaceholderLabel.isHidden = false
        } else {
            self.tulisDeskripsiPlaceholderLabel.isHidden = true
        }
    }
    
    func showErrorAlertViewWithIsNeedPopViewController(_ error: String) {
        let stickyAlertView = StickyAlertView(errorMessages: [error], delegate: self)
        stickyAlertView?.show()
        
    }
    
    func showSuccessAlertViewWithIsNeedPopViewController() {
        successAlertView = UIAlertView()
        successAlertView?.bk_init(withTitle: "Sukses Laporkan Produk", message: "")
        successAlertView?.bk_addButton(withTitle: "OK", handler: { 
            self.navigationController?.popViewController(animated: true)
        })
        successAlertView!.show()
    }
    
    // MARK: API
    
    func getReportTypeFromAPI() {
        networkManager.isUsingHmac = true
        networkManager.request(withBaseUrl: NSString.v4Url(), path: "/v4/product/get_product_report_type.pl", method: .GET, parameter: ["product_id":productId], mapping: ReportProductGetTypeResponse.mapping(), onSuccess: {(mappingResult, operation) in
                DispatchQueue.main.async(execute: { [weak self] in
                    if let weakSelf = self {
                        let result: NSDictionary = (mappingResult as RKMappingResult).dictionary() as NSDictionary
                        let reportProductResponse: ReportProductGetTypeResponse = result[""] as! ReportProductGetTypeResponse
                        
                        var reportTitleArray: [String] = []
                        weakSelf.reportDataArray = reportProductResponse.data.list
                        for reportArray in weakSelf.reportDataArray {
                            reportTitleArray.append(reportArray["report_title"]! as! String)
                        }
                        
                        weakSelf.initDownPickerData(reportTitleArray)
                        weakSelf.downPickerTextField.isEnabled = true
                    }
                })
            }) { (error) in
                DispatchQueue.main.async(execute: { [weak self] in
                    if let weakSelf = self {
                        weakSelf.showErrorAlertViewWithIsNeedPopViewController((error.localizedDescription))
                    }
                })
        }
    }
    
    func sendReportToServer() {
        let param : [String:String]! = ["product_id" : self.productId,
                    "report_type" : String(self.selectedReportId),
                    "text_message": self.deskripsiTextView.text,
                    "user_id"     : self.userManager.getUserId()]
        networkManager.isUsingHmac = true
        networkManager.request(withBaseUrl: NSString.v4Url(), path: "/v4/action/product/report_product.pl", method: .POST, parameter: param, mapping: ReportProductSubmitResponse.mapping(), onSuccess: { (mappingResult, operation) in
                DispatchQueue.main.async(execute: { 
                    [weak self] in
                    if let weakSelf = self {
                        let result: NSDictionary = (mappingResult as RKMappingResult).dictionary() as NSDictionary
                        let reportProductResponse: ReportProductSubmitResponse = result[""] as! ReportProductSubmitResponse
                        if reportProductResponse.data.is_success == "1" {
                            AnalyticsManager.trackEventName("reportSuccess", category: GA_EVENT_CATEGORY_PRODUCT_DETAIL_PAGE, action: "Report Success", label: "Report Success")
                            weakSelf.showSuccessAlertViewWithIsNeedPopViewController()
                        } else {
                            weakSelf.showErrorAlertViewWithIsNeedPopViewController(reportProductResponse.message_error[0])
                        }
                    }
                })
            }) { (error) in
                DispatchQueue.main.async(execute: { [weak self] in
                    if let weakSelf = self {
                        weakSelf.showErrorAlertViewWithIsNeedPopViewController(error.localizedDescription)
                    }
                })
        }
    }
    
    // MARK: DownPicker Functionality
    
    func initDownPickerData(_ reportTitleArray: [String]) {
        var reportTitleArrayWithHardcodedAtIndex0 :[String] = reportTitleArray
        reportTitleArrayWithHardcodedAtIndex0.insert("Pilih Jenis Laporan", at: 0)
        self.downPicker = DownPicker(textField: downPickerTextField, withData: reportTitleArrayWithHardcodedAtIndex0)
        var frame = self.downPicker.getTextField().rightView?.frame
        frame?.size.height = (frame?.size.height)! / 1.5
        frame?.size.width = (frame?.size.width)! / 2
        self.downPicker.getTextField().rightView?.contentMode = .left
        self.downPicker.getTextField().rightView?.frame = frame!
        self.downPicker.setArrowImage(UIImage(named: "icon_up_down_arrow_green"))
        self.downPicker.selectedIndex = 0
        self.downPicker.shouldDisplayCancelButton = false
        self.downPicker.addTarget(self, action: #selector(ReportProductViewController.didChangeDownPickerValue(_:)), for: .valueChanged)
    }
    
    func didChangeDownPickerValue(_ downPicker: DownPicker) {
        showOrHidePlaceholder()
        let downPickerSelectedIndex = downPicker.selectedIndex
        if downPickerSelectedIndex > 0 {
            var selectedReportData = reportDataArray[downPickerSelectedIndex-1]
            reportLinkUrl = selectedReportData["report_url"] as? String
            selectedReportId = selectedReportData["report_id"] as? Int!
            let reportReponse = selectedReportData["report_response"] as? Int
            if reportReponse == 1 {
                showDeskripsiForm()
                hideLinkInstruction()
                enableSubmitBarButtonItem()
            } else if reportReponse == 0 {
                hideDeskripsiForm()
                linkInstructionLabel.text = selectedReportData["report_description"] as! String?
                showLinkInstruction()
                disableSubmitBarButtonItem()
            }
        } else {
            hideDeskripsiForm()
            hideLinkInstruction()
            disableSubmitBarButtonItem()
        }
    }
    
    // MARK: Text view delegate
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        self.tulisDeskripsiPlaceholderLabel.isHidden = true
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        showOrHidePlaceholder()
    }
}
