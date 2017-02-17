//
//  EditConfirmationViewController.swift
//  Tokopedia
//
//  Created by Renny Runiawati on 10/31/16.
//  Copyright © 2016 TOKOPEDIA. All rights reserved.
//

import UIKit
import Eureka

enum EditConfirmationRowTag : String {
    case SystemBank, AccountNumber, AccountName, Comment
}

class EditConfirmationViewController: FormViewController {
    
    var paymentID = ""
    var didEditPayment : (()->Void)?
    fileprivate var refreshControl = UIRefreshControl()
    fileprivate var act = UIActivityIndicatorView()
    fileprivate var doneButton =  UIBarButtonItem()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "Ubah Pembayaran"
        self.addRefreshControl()
        self.addDoneButton()
        self.addActivityIndicator()
        self.requestFormData()
        
        tableView?.backgroundColor = UIColor(red: 231/255, green: 231/255, blue: 231/255, alpha: 1)
    }
    
    fileprivate func addActivityIndicator(){
        self.view.addSubview(act)
        act.hidesWhenStopped = true
        act.activityIndicatorViewStyle = .gray
        act.mas_makeConstraints { (make) in
            make?.center.equalTo()(self.view)
        }
        act.startAnimating()
    }
    
    fileprivate func addDoneButton(){
        doneButton = UIBarButtonItem(
            title: "Simpan",
            style: .plain,
            target: self,
            action: #selector(onTapSubmit)
        )
        self.navigationItem.rightBarButtonItem = doneButton
    }
    
    fileprivate func addRefreshControl(){
        refreshControl.addTarget(self, action: #selector(EditConfirmationViewController.requestFormData), for: UIControlEvents.valueChanged)
        tableView?.addSubview(refreshControl)
    }
    
    fileprivate func configFormWithData(_ data:PaymentConfirmationForm) {
        
        TextRow.defaultCellSetup = { cell, row in
            cell.tintColor = UIColor.black
        }

        form = Section()
            <<< PickerInlineRow<SystemBank>(EditConfirmationRowTag.SystemBank.rawValue) { (row : PickerInlineRow<SystemBank>) -> Void in
                row.title = "Rekening Tujuan"
                row.displayValueFor = {
                    guard let selectedBank = $0 else{
                        return "Pilih Bank"
                    }
                    return selectedBank.bankName
                }
                
                row.options = data.system_bank_list
                var selectedBank = row.options.first
                data.system_bank_list.forEach{
                    if $0.bankId == data.system_bank_id {
                        selectedBank = $0
                    }
                }
                row.value = selectedBank
                row.add(rule:RuleRequired())
                }.cellSetup() {cell, row in
                    cell.detailTextLabel!.textColor = UIColor(red: 66/255, green: 180/255, blue: 29/255, alpha: 1)
                    cell.tintColor = UIColor(red: 66/255, green: 180/255, blue: 29/255, alpha: 1)
            }
            
            <<< TextRow(EditConfirmationRowTag.AccountName.rawValue) {
                $0.title = "Nama Pemilik Kartu"
                $0.placeholder = "Nama Pemilik Kartu"
                $0.value = data.user_acc_name
                $0.add(rule:RuleRequired())
                $0.validationOptions = .validatesOnChange
            }
            
            <<< TextRow(EditConfirmationRowTag.AccountNumber.rawValue) {
                $0.title = "Nomor Rekening"
                $0.placeholder = "Nomor Rekening"
                $0.value = data.user_acc_no
                $0.add(rule:RuleRequired())
                $0.validationOptions = .validatesOnChange
            }
            
            <<< TextAreaRow(EditConfirmationRowTag.Comment.rawValue) {
                $0.placeholder = "Catatan (Optional)"
                $0.textAreaHeight = .dynamic(initialTextViewHeight: 80)
                $0.value = ""
            }
            
            +++ Section()
    }
    
    @objc fileprivate func onTapSubmit(_ sender: UIBarButtonItem){
        
        self.validateInput() { [weak self] dataInput in
            
            guard let `self` = self else { return }
            self.editPayment(dataInput)
            
        }
    }
    
    @objc fileprivate func editPayment(_ dataInput: PaymentConfirmationForm){
        
        self.doneButton.isEnabled = false
        
        ConfirmationRequest.fetchEdit(dataInput,
                                      onSuccess: { [weak self] (data) in
                                        
                guard let `self` = self else { return }
                self.doneButton.isEnabled = true
                self.navigationController?.popViewController(animated: true)
                
                self.didEditPayment?()
                                        
            }, onFailure: { [weak self] in
                
                guard let `self` = self else { return }
                self.doneButton.isEnabled = true
                
        })
    }
    
    @objc fileprivate func requestFormData(){
        
        doneButton.isEnabled = false
        
        ConfirmationRequest.fetchEditForm(paymentID,
                                          onSuccess: { [weak self] (data) in
            
                guard let `self` = self else { return }
                self.doneButton.isEnabled = true
                self.configFormWithData(data)
                self.endRefreshing()
            
            }, onFailure: { [weak self] in
                
                guard let `self` = self else { return }
                self.endRefreshing()
            
        })
    }
    
    fileprivate func endRefreshing(){
        self.refreshControl.endRefreshing()
        act.stopAnimating()
    }
    
    fileprivate func validateInput(then processForm:(PaymentConfirmationForm) -> Void){
        let valuesDictionary = form.values()
    
        let postObject : PaymentConfirmationForm = PaymentConfirmationForm()
        
        guard let selectedSystemBank = valuesDictionary[EditConfirmationRowTag.SystemBank.rawValue] as? SystemBank else {
            StickyAlertView.showErrorMessage(["Bank tujuan harus dipilih"])
            return
        }
        
        guard let userAccountName = valuesDictionary[EditConfirmationRowTag.AccountName.rawValue] as? String else {
            StickyAlertView.showErrorMessage(["Nama pemilik kartu harus diisi"])
            return
        }
        
        guard let userAccountNumber = valuesDictionary[EditConfirmationRowTag.AccountNumber.rawValue]  as? String else {
            StickyAlertView.showErrorMessage(["Nomor rekening harus diisi"])
            return
        }
        
        let comment = valuesDictionary[EditConfirmationRowTag.Comment.rawValue] as? String ?? ""
        
        postObject.system_bank_id   = "\(selectedSystemBank.bankId)"
        postObject.user_acc_name    = userAccountName
        postObject.user_acc_no      = userAccountNumber
        postObject.comment          = comment
        postObject.payment_id       = paymentID
        
        processForm(postObject)

    }
}
