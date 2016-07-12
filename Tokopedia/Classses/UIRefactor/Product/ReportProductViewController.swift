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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let goToGeneralTabVCTapGestureRecognizer = UITapGestureRecognizer(target: self, action:#selector(didTapAlasanLabel))
        self.alasanLabel.addGestureRecognizer(goToGeneralTabVCTapGestureRecognizer)
        
        setupHiddenObject()
        generateKeyboardNotification()
        addDoneButtonOnKeyboard()
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
        
        self.navigationController?.pushViewController(generalTableViewController, animated: true)
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
            || alasanLabel.text == "Pornografi"{
            showDeskripsiForm()
            self.deskripsiTextView.becomeFirstResponder()
        } else {
            //pakai dispatch async supaya end editing di deskripsitextview nya jalan
            dispatch_async(dispatch_get_main_queue()) { [weak self] in
                if let weakSelf = self {
                    weakSelf.deskripsiTextView.endEditing(true)
                    weakSelf.hideDeskripsiForm()
                }
            }
        }
    }
    
    // MARK: Layout Setup
    
    func setupHiddenObject() {
        hideDeskripsiForm()
    }
    
    func showDeskripsiForm() {
        self.deskripsiLabel.hidden = false
        self.deskripsiTextView.hidden = false
    }
    
    func hideDeskripsiForm() {
        self.deskripsiTextView.hidden = true
        self.deskripsiLabel.hidden = true
    }
}
