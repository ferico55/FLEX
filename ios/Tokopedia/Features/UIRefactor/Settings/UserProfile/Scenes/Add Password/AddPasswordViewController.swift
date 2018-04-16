//
//  AddPasswordViewController.swift
//  Tokopedia
//
//  Created by Dhio Etanasti on 3/20/18.
//  Copyright © 2018 TOKOPEDIA. All rights reserved.
//

import RxCocoa
import RxSwift
import SwiftOverlays
import UIKit

@objc public class AddPasswordViewController: UIViewController {
    // outlet
    @IBOutlet private weak var passwordTextView: UITextField!
    @IBOutlet private weak var underlineView: UIView!
    @IBOutlet private weak var errorLabel: UILabel!
    @IBOutlet private weak var submitButton: UIButton!
    @IBOutlet private weak var toggleRevealButton: UIButton!
    
    // navigator
    private lazy var navigator: AddPasswordNavigator = {
        let nv = AddPasswordNavigator(navigationController: self.navigationController)
        return nv
    }()
    
    // view model
    private var viewModel: AddPasswordViewModel
    
    public init() {
        self.viewModel = AddPasswordViewModel()
        super.init(nibName: nil, bundle: nil)
    }
    
    public required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Buat Kata Sandi"
        self.bindViewModel()
    }
    
    private func bindViewModel() {
        
        let input = AddPasswordViewModel.Input(passwordTrigger: passwordTextView.rx.text.orEmpty.asDriver(),
                                               revealTrigger: toggleRevealButton.rx.tap.asDriver(),
                                               submitTrigger: submitButton.rx.tap.asDriver())
        
        let output = viewModel.transform(input: input)
        
        output.isValid.drive(submitButton.rx.isEnabled).disposed(by: rx_disposeBag)
        
        output.revealPassword.drive(onNext: { [weak self] _ in
            guard let strongSelf = self else { return }
            strongSelf.passwordTextView.isSecureTextEntry = !strongSelf.passwordTextView.isSecureTextEntry
            if strongSelf.passwordTextView.isSecureTextEntry {
                strongSelf.toggleRevealButton.setImage(#imageLiteral(resourceName: "password_eyeClose"), for: .normal)
            } else {
                strongSelf.toggleRevealButton.setImage(#imageLiteral(resourceName: "password_eyeOpen"), for: .normal)
            }
        }).disposed(by: rx_disposeBag)
        
        output.activityIndicator.drive(onNext: { [weak self] isLoading in
            guard let strongSelf = self else { return }
            strongSelf.passwordTextView.isUserInteractionEnabled = !isLoading
            strongSelf.submitButton.isUserInteractionEnabled = !isLoading
            if isLoading {
                strongSelf.view.endEditing(true)
                SwiftOverlays.showCenteredWaitOverlay(strongSelf.view)
            } else {
                SwiftOverlays.removeAllOverlaysFromView(strongSelf.view)
            }
        }).disposed(by: rx_disposeBag)
        
        output.isSuccess.drive(onNext: { [weak self] _ in
            StickyAlertView.showSuccessMessage(["Password berhasil ditambahkan"])
            
            guard let reactEventManager = UIApplication.shared.reactBridge.module(for: ReactEventManager.self) as? ReactEventManager else {
                return
            }
            reactEventManager.sendProfileEditedEvent()
            self?.navigator.backToProfileSettingsAfterSuccessAddPassword()
        }).disposed(by: rx_disposeBag)
        
        output.messageErrors.drive(onNext: { messageErrors in
            StickyAlertView.showErrorMessage(messageErrors)
        }).disposed(by: rx_disposeBag)
        
        output.cursorColor.drive(onNext: { [weak self] color in
            self?.passwordTextView.tintColor = color
        }).disposed(by: rx_disposeBag)
        
        output.underLineColor.drive(onNext: { [weak self] color in
            self?.underlineView.backgroundColor = color
        }).disposed(by: rx_disposeBag)
        
        output.buttonBackgroundColor.drive(onNext: { [weak self] color in
            self?.submitButton.backgroundColor = color
        }).disposed(by: rx_disposeBag)
    }
}
