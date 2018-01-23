//
//  TokoCashQRPaymentViewController.swift
//  Tokopedia
//
//  Created by Tiara Freddy Andika on 02/01/18.
//  Copyright © 2018 TOKOPEDIA. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

class TokoCashQRPaymentViewController: UIViewController {

    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var phoneNumberLabel: UILabel!
    @IBOutlet weak var phoneView: UIView!
    @IBOutlet weak var amountTextField: UITextField!
    @IBOutlet weak var amountLineView: UIView!
    @IBOutlet weak var balanceLabel: UILabel!
    @IBOutlet weak var balanceAcitivityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var notesTextField: UITextField!
    @IBOutlet weak var paymentButton: UIButton!
    @IBOutlet weak var paymentActivityIndicator: UIActivityIndicatorView!
    
    private var isAnimation = false
    
    // view model
    var viewModel: TokoCashQRPaymentViewModel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        bindViewModel()
    }
    
    private func bindViewModel() {
        assert(viewModel != nil)
        let viewWillAppear = rx.sentMessage(#selector(UIViewController.viewWillAppear(_:)))
            .mapToVoid()
            .asDriverOnErrorJustComplete()
        let input = TokoCashQRPaymentViewModel.Input(trigger: viewWillAppear,
                                                     amount: amountTextField.rx.text.orEmpty.asDriver(),
                                                     notes: notesTextField.rx.text.orEmpty.asDriver(),
                                                     paymentTrigger: paymentButton.rx.tap.asDriver())
        let output = viewModel.transform(input: input)
        
        output.name
            .drive(nameLabel.rx.text)
            .disposed(by: rx_disposeBag)
        
        output.phoneNumber
            .drive(phoneNumberLabel.rx.text)
            .disposed(by: rx_disposeBag)
        
        output.isHiddenPhoneNumber
            .drive(phoneView.rx.isHidden)
            .disposed(by: rx_disposeBag)
        
        output.amount
            .drive(amountTextField.rx.text)
            .disposed(by: rx_disposeBag)
        
        output.enableAmount
            .drive(amountTextField.rx.isEnabled)
            .disposed(by: rx_disposeBag)
        
        output.fetching
            .drive(balanceAcitivityIndicator.rx.isAnimating)
            .disposed(by: rx_disposeBag)
        
        output.balance
            .drive(balanceLabel.rx.text)
            .disposed(by: rx_disposeBag)
        
        output.validationAmountColor
            .drive(onNext: { color in
                self.balanceLabel.textColor = color
            })
            .disposed(by: rx_disposeBag)
        
        output.validationLineColor
            .drive(onNext: { color in
                self.amountLineView.backgroundColor = color
            })
            .disposed(by: rx_disposeBag)
        
        output.disableButton
            .drive(paymentButton.rx.isEnabled)
            .addDisposableTo(rx_disposeBag)
        
        output.backgroundButtonColor
            .drive(onNext: { color in
                self.paymentButton.backgroundColor = color
            }).addDisposableTo(rx_disposeBag)
        
        output.paymentActivityIndicator
            .drive(paymentActivityIndicator.rx.isAnimating)
            .addDisposableTo(rx_disposeBag)
        
        output.paymentSuccess
            .drive()
            .disposed(by: rx_disposeBag)
        
        output.paymentFailed
            .drive()
            .disposed(by: rx_disposeBag)
    }
}
