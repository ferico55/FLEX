//
//  ReportProductViewController.swift
//  Tokopedia
//
//  Created by Billion Goenawan on 7/12/16.
//  Copyright © 2016 TOKOPEDIA. All rights reserved.
//

import UIKit

class ReportProductViewController: UIViewController, UITextViewDelegate{
    
    let UNSELECTED_ALASAN: String! = "Pilih jenis laporan"
    var productId: String!

    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var jenisLaporanLabel: UILabel!
    @IBOutlet weak var deskripsiTextView: UITextView!
    @IBOutlet weak var linkInstructionLabel: UILabel!
    @IBOutlet var downPickerTextField: UITextField!
    @IBOutlet var tulisDeskripsiPlaceholderLabel: UILabel!
    @IBOutlet var laporkanButton: UIButton!
    
    var downPicker: DownPicker!
    var submitBarButtonItem: UIBarButtonItem!
    var networkManager = TokopediaNetworkManager()
    var reportDataArray : [[String: NSObject]] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let goToWebVCTapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(didTapUrlLink))
        self.linkInstructionLabel.addGestureRecognizer(goToWebVCTapGestureRecognizer)
        downPickerTextField.enabled = false
        deskripsiTextView.delegate = self
        generateKeyboardNotification()
        getReportTypeFromAPI()
        setupHiddenObject()
        generateSubmitBarButtonItem()
        setupDownPickerLayout()
    }
    
    override func viewWillAppear(animated: Bool) {
        self.navigationItem.title = "Laporkan Produk"
        //addDoneButtonOnKeyboard()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func didTapUrlLink() {
        let webViewVC = WebViewController()
        webViewVC.strURL = "http://www.tokopedia.com"
        webViewVC.strTitle = "Mengarahkan"
        webViewVC.onTapLinkWithUrl = { (url) in
            if (url.absoluteString == "https://www.tokopedia.com/") {
                self.navigationController?.popViewControllerAnimated(true)
            }
        }
        self.navigationController?.pushViewController(webViewVC, animated: true)
    }
    
    // MARK: KeyboardNotification 
    
    func generateKeyboardNotification() {
        let notificationCenter = NSNotificationCenter.defaultCenter()
        notificationCenter.addObserver(self, selector: #selector(keyboardWillShow), name: UIKeyboardWillShowNotification, object: nil)
        notificationCenter.addObserver(self, selector: #selector(keyboardWillHide), name: UIKeyboardWillHideNotification, object: nil)
    }
    
    func keyboardWillShow(notification: NSNotification) {
        scrollView.contentInset = UIEdgeInsetsMake(0, 0, deskripsiTextView.frame.size.height, 0)
        scrollView.scrollIndicatorInsets = UIEdgeInsetsMake(0, 0, deskripsiTextView.frame.size.height, 0)
    }
    
    func keyboardWillHide(notification: NSNotification) {
        scrollView.contentInset = UIEdgeInsetsMake(0, 0, 0, 0)
    }
    
    // MARK: Keyboard Functionality 
    
    func addDoneButtonOnKeyboard()
    {
        let doneToolbar: UIToolbar = UIToolbar(frame: CGRectMake(0, 0, 320, 50))
        doneToolbar.barStyle = UIBarStyle.BlackTranslucent
        
        let flexSpace = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.FlexibleSpace, target: nil, action: nil)
        let done: UIBarButtonItem = UIBarButtonItem(title: "Done", style: UIBarButtonItemStyle.Done, target: self, action: #selector(doneButtonAction))
        
        var items: [UIBarButtonItem] = []
        items.append(flexSpace)
        items.append(done)
        
        doneToolbar.items = items
        doneToolbar.sizeToFit()
        
        self.deskripsiTextView.inputAccessoryView = doneToolbar
    }
    
    func doneButtonAction() {
        self.deskripsiTextView.resignFirstResponder()
    }
    
    // MARK: Layout Setup
    
    func generateSubmitBarButtonItem() {
        self.submitBarButtonItem = UIBarButtonItem(title: "Submit", style: .Plain, target: self, action: #selector(ReportProductViewController.sendReportToServer))
        disableSubmitBarButtonItem()
        self.navigationItem.rightBarButtonItem = submitBarButtonItem
    }
    
    func disableSubmitBarButtonItem() {
        self.submitBarButtonItem.tintColor = UIColor(colorLiteralRed: 127/255, green: 127/255, blue: 127/255, alpha: 1.0)
        self.submitBarButtonItem.enabled = false
    }
    
    func enableSubmitBarButtonItem() {
        self.submitBarButtonItem.tintColor = UIColor(colorLiteralRed: 255/255, green: 255/255, blue: 255/255, alpha: 1.0)
        self.submitBarButtonItem.enabled = true
    }
    
    func setupHiddenObject() {
        self.tulisDeskripsiPlaceholderLabel.hidden = true
        self.laporkanButton.hidden = true
        self.laporkanButton.cornerRadius = 3
        self.laporkanButton.borderWidth = 1
        self.laporkanButton.borderColor = UIColor(red: 255/255, green: 87/255, blue: 34/255, alpha: 1.0)
        hideDeskripsiForm()
        hideLinkInstruction()
    }
    
    func showDeskripsiForm() {
        self.deskripsiTextView.hidden = false
        showOrHidePlaceholder()
    }
    
    func hideDeskripsiForm() {
        self.deskripsiTextView.hidden = true
        showOrHidePlaceholder()
    }
    
    func hideLinkInstruction() {
        self.linkInstructionLabel.hidden = true
        self.laporkanButton.hidden = true
    }
    
    func showLinkInstruction() {
        self.linkInstructionLabel.hidden = false
        self.laporkanButton.hidden = false
    }
    
    func setupDownPickerLayout() {
        downPickerTextField.layer.borderWidth = 1
        downPickerTextField.layer.cornerRadius = 3
        downPickerTextField.layer.borderColor = UIColor(red: 66/225, green: 181/225, blue: 73/225, alpha: 1.0).CGColor
        downPickerTextField.textColor = UIColor(red: 66/225, green: 181/225, blue: 73/225, alpha: 1.0)
    }
    
    func showOrHidePlaceholder() {
        if self.deskripsiTextView.text == "" && self.deskripsiTextView.hidden == false {
            self.tulisDeskripsiPlaceholderLabel.hidden = false
        } else {
            self.tulisDeskripsiPlaceholderLabel.hidden = true
        }
    }
    
    // MARK: API
    
    func getReportTypeFromAPI() {
        networkManager.requestWithBaseUrl("http://private-1a1cd-digitaloperator.apiary-mock.com", path: "/operators", method: .GET, parameter: ["":""], mapping: ReportProductResponse.mapping(), onSuccess: {(mappingResult, operation) in
                dispatch_async(dispatch_get_main_queue(), { [weak self] in
                    if let weakSelf = self {
                        let result: NSDictionary = (mappingResult as RKMappingResult).dictionary()
                        let reportProductResponse: ReportProductResponse = result[""] as! ReportProductResponse
                        
                        var reportTitleArray: [String] = []
                        weakSelf.reportDataArray = reportProductResponse.data.list
                        for reportArray in weakSelf.reportDataArray {
                            reportTitleArray.append(reportArray["report_title"]! as! String)
                        }
                        
                        weakSelf.initDownPickerData(reportTitleArray)
                        weakSelf.downPickerTextField.enabled = true
                    }
                })
            }) { (error) in
                
        }
    }
    
    func sendReportToServer() {
        print("sukses kirim")
    }
    
    // MARK: DownPicker Functionality
    
    func initDownPickerData(reportTitleArray: [String]) {
        var reportTitleArrayWithHardcodedAtIndex0 :[String] = reportTitleArray
        reportTitleArrayWithHardcodedAtIndex0.insert("Pilih Jenis Laporan", atIndex: 0)
        self.downPicker = DownPicker(textField: downPickerTextField, withData: reportTitleArrayWithHardcodedAtIndex0)
        self.downPicker.selectedIndex = 0
        self.downPicker.addTarget(self, action: #selector(ReportProductViewController.didChangeDownPickerValue(_:)), forControlEvents: .ValueChanged)
    }
    
    func didChangeDownPickerValue(downPicker: DownPicker) {
        showOrHidePlaceholder()
        let downPickerSelectedIndex = downPicker.selectedIndex
        if downPickerSelectedIndex > 0 {
            var selectedReportData = reportDataArray[downPickerSelectedIndex-1]
            if selectedReportData["report_response"] == 1 {
                showDeskripsiForm()
                hideLinkInstruction()
                enableSubmitBarButtonItem()
            } else if selectedReportData["report_response"] == 0 {
                hideDeskripsiForm()
                linkInstructionLabel.text = selectedReportData["report_description"] as? String
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
    
    func textViewDidBeginEditing(textView: UITextView) {
        self.tulisDeskripsiPlaceholderLabel.hidden = true
    }
    
    func textViewDidEndEditing(textView: UITextView) {
        showOrHidePlaceholder()
    }
}
