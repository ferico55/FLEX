//
//  AddEmailViewController.swift
//  Tokopedia
//
//  Created by Dhio Etanasti on 3/20/18.
//  Copyright © 2018 TOKOPEDIA. All rights reserved.
//

import SwiftOverlays
import UIKit

public class AddEmailViewController: UIViewController {
    // outlet
    @IBOutlet private weak var emailTextField: UITextField!
    @IBOutlet private weak var continueButton: UIButton!
    @IBOutlet private weak var underlineView: UIView!
    @IBOutlet private weak var infoLabel: UILabel!
    
    // navigator
    private lazy var navigator: AddEmailNavigator = {
        let nv = AddEmailNavigator(navigationController: self.navigationController)
        return nv
    }()
    
    // view model
    private var viewModel: AddEmailViewModel
    
    public init() {
        self.viewModel = AddEmailViewModel()
        super.init(nibName: nil, bundle: nil)
    }
    
    public required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Tambah Email"
        self.bindViewModel()
    }
    
    private func bindViewModel() {
        
        let input = AddEmailViewModel.Input(emailTrigger: emailTextField.rx.text.orEmpty.asDriver().distinctUntilChanged(),
                                            continueTrigger: continueButton.rx.tap.asDriver())
        let output = viewModel.transform(input: input)
        
        output.isValid.drive(continueButton.rx.isEnabled).disposed(by: rx_disposeBag)
        
        output.activityIndicator.drive(onNext: { [weak self] isLoading in
            guard let strongSelf = self else { return }
            strongSelf.emailTextField.isUserInteractionEnabled = !isLoading
            strongSelf.continueButton.isUserInteractionEnabled = !isLoading
            if isLoading {
                strongSelf.view.endEditing(true)
                SwiftOverlays.showCenteredWaitOverlay(strongSelf.view)
            } else {
                SwiftOverlays.removeAllOverlaysFromView(strongSelf.view)
            }
        }).disposed(by: rx_disposeBag)
        
        output.isSendVerificationCodeSuccess.drive(onNext: navigator.goToEmailOTP).disposed(by: rx_disposeBag)
        
        output.messageErrors.drive(onNext: { messageErrors in
            StickyAlertView.showErrorMessage(messageErrors)
        }).disposed(by: rx_disposeBag)
        
        output.emailError.drive(infoLabel.rx.text).disposed(by: rx_disposeBag)
        
        output.cursorColor.drive(onNext: { [weak self] color in
            self?.emailTextField.tintColor = color
        }).disposed(by: rx_disposeBag)
        
        output.underLineColor.drive(onNext: { [weak self] color in
            self?.underlineView.backgroundColor = color
        }).disposed(by: rx_disposeBag)
        
        output.infoLabelColor.drive(onNext: { [weak self] color in
            self?.infoLabel.textColor = color
        }).disposed(by: rx_disposeBag)
        
        output.buttonBackgroundColor.drive(onNext: { [weak self] color in
            self?.continueButton.backgroundColor = color
        }).disposed(by: rx_disposeBag)
    }
}
