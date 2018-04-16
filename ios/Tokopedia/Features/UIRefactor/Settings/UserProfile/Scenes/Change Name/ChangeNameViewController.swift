//
//  ChangeNameViewController.swift
//  Tokopedia
//
//  Created by Dhio Etanasti on 3/20/18.
//  Copyright © 2018 TOKOPEDIA. All rights reserved.
//

import RxCocoa
import RxSwift
import SwiftOverlays
import UIKit

@objc public class ChangeNameViewController: UIViewController {
    // outlet
    @IBOutlet weak private var nameTextField: UITextField!
    @IBOutlet weak private var underLineView: UIView!
    @IBOutlet weak private var submitButton: UIButton!
    @IBOutlet weak private var errorLabel: UILabel!
    
    // var
    private let doSubmitName = PublishSubject<Void>()
    
    // view model
    private var viewModel: ChangeNameViewModel
    
    public init() {
        viewModel = ChangeNameViewModel()
        super.init(nibName: nil, bundle: nil)
    }
    
    public required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override public func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Ubah Nama Lengkap"
        bindViewModel()
    }
    
    private func bindViewModel() {
        
        let input = ChangeNameViewModel.Input(userNameTrigger: nameTextField.rx.text.orEmpty.asDriver().distinctUntilChanged(),
                                              alertTrigger: submitButton.rx.tap.asDriver(),
                                              submitTrigger: doSubmitName.asDriverOnErrorJustComplete())
        let output = viewModel.transform(input: input)
        
        output.submitButtonIsEnabled.drive(submitButton.rx.isEnabled).disposed(by: rx_disposeBag)
        
        output.submitButtonBackgroundColor.drive(onNext: { [weak self] color in
            self?.submitButton.backgroundColor = color
        }).disposed(by: rx_disposeBag)
        
        output.descColor.drive(onNext: { [weak self] color in
            self?.errorLabel.textColor = color
        }).disposed(by: rx_disposeBag)
        
        output.underLineColor.drive(onNext: { [weak self] color in
            self?.underLineView.backgroundColor = color
        }).disposed(by: rx_disposeBag)
        
        output.cursorColor.drive(onNext: { [weak self] color in
            self?.nameTextField.tintColor = color
        }).disposed(by: rx_disposeBag)
        
        output.alert.drive(onNext: { [weak self] name in
            self?.askToChangeName(name)
        }).disposed(by: rx_disposeBag)
        
        output.activityIndicator.drive(onNext: { [weak self] isLoading in
            guard let strongSelf = self else { return }
            strongSelf.nameTextField.isUserInteractionEnabled = !isLoading
            strongSelf.submitButton.isUserInteractionEnabled = !isLoading
            if isLoading {
                strongSelf.view.endEditing(true)
                SwiftOverlays.showCenteredWaitOverlay(strongSelf.view)
            } else {
                SwiftOverlays.removeAllOverlaysFromView(strongSelf.view)
            }
        }).disposed(by: rx_disposeBag)
        
        output.isSuccess.drive(onNext: { [weak self] _ in
            StickyAlertView.showSuccessMessage(["Nama lengkap berhasil diubah"])
            self?.navigationController?.popViewController(animated: true)
        }).disposed(by: rx_disposeBag)
        
        output.messageErrors.drive(errorLabel.rx.text).disposed(by: rx_disposeBag)
        
        output.errorAlert.drive(onNext: { errorMessage in
            StickyAlertView.showErrorMessage(errorMessage)
        }).disposed(by: rx_disposeBag)
    }
    
    private func askToChangeName(_ name: String) {
        let alertController = UIAlertController(title: "\(name), Apakah nama Anda sudah benar?",
                                                message: "Nama lengkap hanya dapat diubah satu kali.", preferredStyle: .alert)
        let cancelAction = UIAlertAction(title: "Tidak", style: .default) { _ in }
        let registerAction = UIAlertAction(title: "Ya, Benar", style: .default) { _ in
            self.doSubmitName.onNext()
        }
        alertController.addAction(cancelAction)
        alertController.addAction(registerAction)
        
        present(alertController, animated: true)
    }
    
}
