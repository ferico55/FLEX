//
//  TokoCashQRPaymentViewController.swift
//  Tokopedia
//
//  Created by Tiara Freddy Andika on 02/01/18.
//  Copyright © 2018 TOKOPEDIA. All rights reserved.
//

import Foundation
import RxCocoa
import RxSwift

public class TokoCashQRPaymentViewController: UIViewController {

    @IBOutlet weak private var nameLabel: UILabel!
    @IBOutlet weak private var phoneNumberLabel: UILabel!
    @IBOutlet weak private var phoneView: UIView!
    @IBOutlet weak private var amountTextField: UITextField!
    @IBOutlet weak private var amountLineView: UIView!
    @IBOutlet weak private var balanceLabel: UILabel!
    @IBOutlet weak private var balanceAcitivityIndicator: UIActivityIndicatorView!
    @IBOutlet weak private var notesTextField: UITextField!
    @IBOutlet weak private var paymentButton: UIButton!
    @IBOutlet weak private var paymentActivityIndicator: UIActivityIndicatorView!
    
    private var isAnimation = false
    
    // view model
    public var viewModel: TokoCashQRPaymentViewModel!
    
    override public func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Nominal Pembayaran"
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
