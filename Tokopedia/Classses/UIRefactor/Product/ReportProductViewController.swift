//
//  ReportProductViewController.swift
//  Tokopedia
//
//  Created by Billion Goenawan on 7/12/16.
//  Copyright © 2016 TOKOPEDIA. All rights reserved.
//

import UIKit

class ReportProductViewController: UIViewController, GeneralTableViewControllerDelegate{
    
    let UNSELECTED_ALASAN: String! = "Pilih jenis laporan"

    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var alasanLabel: UILabel!
    @IBOutlet weak var jenisLaporanLabel: UILabel!
    @IBOutlet weak var deskripsiTextView: UITextView!
    @IBOutlet weak var deskripsiLabel: UILabel!
    @IBOutlet weak var linkInstructionLabel: UILabel!
    @IBOutlet weak var kirimButton: UIButton!
    
    var networkManager = TokopediaNetworkManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let goToGeneralTabVCTapGestureRecognizer = UITapGestureRecognizer(target: self, action:#selector(didTapAlasanLabel))
        let goToWebVCTapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(didTapUrlLink))
        self.alasanLabel.addGestureRecognizer(goToGeneralTabVCTapGestureRecognizer)
        self.linkInstructionLabel.addGestureRecognizer(goToWebVCTapGestureRecognizer)
        
        setupHiddenObject()
        generateKeyboardNotification()
        addDoneButtonOnKeyboard()
        getReportTypeFromAPI()
    }
    
    override func viewWillAppear(animated: Bool) {
        self.navigationItem.title = "Lapor Produk"
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func didTapAlasanLabel() {
        let generalTableViewController: GeneralTableViewController = GeneralTableViewController()
        generalTableViewController.title = "Pilih Jenis Laporan"
        generalTableViewController.objects = ["Salah kategori", "Iklan situs luar", "Pornografi", "Transaksi", "Pelanggaran merk dagang & MLM", "Lain-lain"]
        if alasanLabel.text != UNSELECTED_ALASAN {
            generalTableViewController.selectedObject = alasanLabel.text
        }
        generalTableViewController.delegate = self
         self.deskripsiTextView.resignFirstResponder()
        
        self.navigationController?.pushViewController(generalTableViewController, animated: true)
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
        let keyboardFrame = (notification.userInfo![UIKeyboardFrameBeginUserInfoKey] as! NSValue).CGRectValue()
        let keyboardHeight = keyboardFrame.size.height
        scrollView.contentInset = UIEdgeInsetsMake(0, 0, keyboardHeight, 0)
        scrollView.scrollIndicatorInsets = UIEdgeInsetsMake(0, 0, keyboardHeight, 0)
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
    
    // MARK: GeneralTableViewControllerDelegate
    
    func didSelectObject(object: AnyObject!, senderIndexPath indexPath: NSIndexPath!, withObjectName strName: String!) {
        self.alasanLabel.hidden = false
        self.alasanLabel.text = String(object)
        if alasanLabel.text == "Salah kategori"
            || alasanLabel.text == "Iklan situs luar"
            || alasanLabel.text == "Pornografi"
            || alasanLabel.text == "Lain-lain" {
            showDeskripsiForm()
            hideLinkInstructionLabel()
            self.deskripsiTextView.becomeFirstResponder()
        } else if alasanLabel.text == "Transaksi"
            || alasanLabel.text == "Pelanggaran merk dagang & MLM" {
                self.hideDeskripsiForm()
                self.showLinkInstructionLabel()
        }
    }
    
    // MARK: Layout Setup
    
    func setupHiddenObject() {
        hideDeskripsiForm()
        hideLinkInstructionLabel()
    }
    
    func showDeskripsiForm() {
        self.deskripsiLabel.hidden = false
        self.deskripsiTextView.hidden = false
        self.kirimButton.hidden = false
    }
    
    func hideDeskripsiForm() {
        self.deskripsiTextView.hidden = true
        self.deskripsiLabel.hidden = true
        self.kirimButton.hidden = true
    }
    
    func hideLinkInstructionLabel() {
        self.linkInstructionLabel.hidden = true
    }
    
    func showLinkInstructionLabel() {
        self.linkInstructionLabel.hidden = false
    }
    
    // MARK: API
    
    func getReportTypeFromAPI() {
        networkManager.requestWithBaseUrl("", path: "", method: .GET, parameter: ["":""], mapping: RKObjectMapping!, onSuccess: { (result, operation) in
            
            }) { (error) in
                
        }
    }
}
