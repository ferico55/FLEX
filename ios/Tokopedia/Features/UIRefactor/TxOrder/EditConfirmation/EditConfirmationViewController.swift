//
//  EditConfirmationViewController.swift
//  Tokopedia
//
//  Created by Renny Runiawati on 10/31/16.
//  Copyright © 2016 TOKOPEDIA. All rights reserved.
//

import UIKit
import RSKPlaceholderTextView
import RxSwift
import NSObject_Rx

class EditConfirmationViewController: UIViewController {
    
    var paymentID = ""
    var didEditPayment: (()->Void)?
    fileprivate var refreshControl = UIRefreshControl()
    fileprivate var act = UIActivityIndicatorView()
    fileprivate var doneButton =  UIBarButtonItem()
    fileprivate var formData: PaymentConfirmationForm!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "Ubah Pembayaran"
        self.addDoneButton()
        self.addActivityIndicator()
        self.requestFormData()
        
        self.view.backgroundColor = .tpBackground()
        
        let tapGesture = UITapGestureRecognizer()
        self.view.addGestureRecognizer(tapGesture)
        
        tapGesture.rx.event.asDriver().drive(onNext: { _ in
            self.view.endEditing(true)
        }).disposed(by: rx_disposeBag)
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
    
    private func configForm(data:PaymentConfirmationForm) {
        formData = data
        formData.payment_id = paymentID

        let line1 = self.lineView()
        let selectedBank = self.getBankName(id: data.system_bank_id)
        let editBankView = self.selectionBankView(title: "Rekening Tujuan", detailText: selectedBank, listItems: data.system_bank_list)
        let line2 = self.lineView()
        let cardOwnerView = self.textFieldView(title: "Nama Pemilik Kartu", detailText: data.user_acc_name, didEndEditing: { accountName in
            data.user_acc_name = accountName
        })
        let line3 = self.lineView()
        let rekeningNumberView = self.textFieldView(title: "Nomor Rekening", detailText: data.user_acc_no, didEndEditing: { accountNumber in
            data.user_acc_no = accountNumber
        })
        let line4 = self.lineView()
        let noteView = self.textView(placeholder: "Catatan (Optional)", text: data.comment, didEndEditing: { note in
            data.comment = note
        })
        let line5 = self.lineView()
        
        let contentStackView = UIStackView(arrangedSubviews: [editBankView, line2, cardOwnerView, line3, rekeningNumberView, line4, noteView])
        contentStackView.axis = .vertical
        contentStackView.distribution = .fill
        contentStackView.translatesAutoresizingMaskIntoConstraints = false
        let contentView = UIView()
        contentView.backgroundColor = .white
        contentView.addSubview(contentStackView)
        
        let listView = UIStackView(arrangedSubviews: [line1, contentView, line5])
        listView.axis = .vertical
        listView.distribution = .fill
        listView.translatesAutoresizingMaskIntoConstraints = false
        
        self.view.addSubview(listView)
        
        NSLayoutConstraint.activate([
            contentStackView.topAnchor.constraint(equalTo: contentView.topAnchor),
            contentStackView.rightAnchor.constraint(equalTo: contentView.rightAnchor),
            contentStackView.leftAnchor.constraint(equalTo: contentView.leftAnchor, constant: 15),
            contentStackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            
            line1.heightAnchor.constraint(equalToConstant: 1),
            editBankView.heightAnchor.constraint(equalToConstant: 40),
            line2.heightAnchor.constraint(equalToConstant: 1),
            cardOwnerView.heightAnchor.constraint(equalToConstant: 40),
            line3.heightAnchor.constraint(equalToConstant: 1),
            rekeningNumberView.heightAnchor.constraint(equalToConstant: 40),
            line4.heightAnchor.constraint(equalToConstant: 1),
            noteView.heightAnchor.constraint(equalToConstant: 100),
            line5.heightAnchor.constraint(equalToConstant: 1),
            
            listView.topAnchor.constraint(equalTo: self.view.topAnchor, constant: 30),
            listView.rightAnchor.constraint(equalTo: self.view.rightAnchor),
            listView.leftAnchor.constraint(equalTo: self.view.leftAnchor),
            listView.heightAnchor.constraint(equalToConstant: 225)
        ])
    }
    
    fileprivate func selectionBankView(title: String, detailText: String, listItems: [SystemBank]) -> UIView {
        
        let view = UIView()
        view.backgroundColor = .white
        
        let titleLabel =  UILabel()
        titleLabel.text = title
        titleLabel.textColor = .tpPrimaryBlackText()
        titleLabel.backgroundColor = .white
        titleLabel.font = .largeTheme()
        
        let detailLabel = UILabel()
        detailLabel.text = detailText
        detailLabel.backgroundColor = .white
        detailLabel.textAlignment = .right
        detailLabel.textColor = .tpGreen()
        detailLabel.font = .largeTheme()
        
        let stackView = UIStackView(arrangedSubviews: [titleLabel, detailLabel])
        stackView.axis = .horizontal
        stackView.distribution = .fillProportionally
        stackView.layoutMargins = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 15)
        stackView.isLayoutMarginsRelativeArrangement = true
        
        view.addSubview(stackView)
        
        stackView.translatesAutoresizingMaskIntoConstraints = false
        view.translatesAutoresizingMaskIntoConstraints = false
        
        let tapGesture = UITapGestureRecognizer()
        view.addGestureRecognizer(tapGesture)
        
        tapGesture.rx.event.asDriver().drive(onNext: { _ in
            self.view.endEditing(true)
            let picker: AlertPickerView = AlertPickerView.newview() as! AlertPickerView
            let datas = listItems.map({ systemBank in
                return [
                    "name": systemBank.bankName,
                    "value": systemBank.bankId
                ]
            })
            picker.pickerData = datas
            picker.didTapDoneButton = { [weak self] data in
                guard let `self` = self else {
                    return
                }
                guard let selectedID = (data as? [NSString: NSString])?["value"] else {
                    return
                }
                self.formData.system_bank_id = selectedID as String
                
                let selectedBank = self.getBankName(id: self.formData.system_bank_id)
                detailLabel.text = selectedBank
            }
            picker.show()
        }).disposed(by: rx_disposeBag)
        
        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: view.topAnchor),
            stackView.rightAnchor.constraint(equalTo: view.rightAnchor),
            stackView.leftAnchor.constraint(equalTo: view.leftAnchor),
            stackView.heightAnchor.constraint(equalToConstant: 40)
            ])
        
        return view
    }
    
    private func textFieldView(title: String, detailText: String, didEndEditing:@escaping (String)->Void) -> UIView {
        
        let view = UIView()
        view.backgroundColor = .white
        
        let titleLabel =  UILabel()
        titleLabel.text = title
        titleLabel.backgroundColor = .white
        titleLabel.textColor = .tpPrimaryBlackText()
        titleLabel.font = .largeTheme()
        
        let textField = UITextField()
        textField.text = detailText
        textField.backgroundColor = .white
        textField.textAlignment = .right
        textField.textColor = .tpSecondaryBlackText()
        textField.font = .largeTheme()
        textField.rx.controlEvent([.editingDidEnd])
            .asDriver()
            .drive(onNext: { _ in
                didEndEditing(textField.text ?? "")
            }).disposed(by: rx_disposeBag)
        
        let stackView = UIStackView(arrangedSubviews: [titleLabel, textField])
        stackView.axis = .horizontal
        stackView.distribution = .fillEqually
        stackView.layoutMargins = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 15)
        stackView.isLayoutMarginsRelativeArrangement = true
        
        view.addSubview(stackView)
        
        stackView.translatesAutoresizingMaskIntoConstraints = false
        view.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: view.topAnchor),
            stackView.rightAnchor.constraint(equalTo: view.rightAnchor),
            stackView.leftAnchor.constraint(equalTo: view.leftAnchor),
            stackView.heightAnchor.constraint(equalToConstant: 40)
            ])
        
        return view
    }
    
    private func textView(placeholder: String, text: String, didEndEditing:@escaping (String)->Void) -> UIView {
        
        let view = UIView()
        view.backgroundColor = .white
        
        let textView = RSKPlaceholderTextView()
        textView.backgroundColor = .white
        textView.text = text
        textView.textColor = .tpSecondaryBlackText()
        textView.font = .largeTheme()
        textView.placeholder = placeholder as NSString
        textView.rx.didEndEditing
            .asDriver()
            .drive(onNext: { _ in
                didEndEditing(textView.text ?? "")
            }).disposed(by: rx_disposeBag)
        
        let stackView = UIStackView(arrangedSubviews: [textView])
        stackView.axis = .horizontal
        stackView.distribution = .fillProportionally
        stackView.layoutMargins = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 15)
        stackView.isLayoutMarginsRelativeArrangement = true
        
        view.addSubview(stackView)
        
        stackView.translatesAutoresizingMaskIntoConstraints = false
        view.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: view.topAnchor),
            stackView.rightAnchor.constraint(equalTo: view.rightAnchor),
            stackView.leftAnchor.constraint(equalTo: view.leftAnchor),
            stackView.heightAnchor.constraint(equalToConstant: 100)
            ])
        
        return view
    }
    
    private func lineView() -> UIView {
        let view = UIView()
        view.backgroundColor = .tpLine()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }
    
    @objc fileprivate func onTapSubmit(_ sender: UIBarButtonItem) {
        self.view.endEditing(true)
        self.editPayment(formData)
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
        
        ConfirmationRequest.fetchEditForm(
            paymentID,
            onSuccess: { [weak self] (data) in
                guard let `self` = self else { return }
                self.doneButton.isEnabled = true
                self.configForm(data: data)
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
    
    fileprivate func getBankName(id: String) -> String {
        return formData.system_bank_list.filter({ (systemBank) -> Bool in
            systemBank.bankId == formData.system_bank_id
        }).flatMap { (systemBank) -> String in
            systemBank.bankName
            }.first ?? ""
    }
}
