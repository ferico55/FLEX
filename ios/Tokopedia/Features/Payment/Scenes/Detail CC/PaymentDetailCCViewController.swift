//
//  PaymentDetailCCViewController.swift
//  Tokopedia
//
//  Created by Tiara Freddy Andika on 25/01/18.
//  Copyright © 2018 TOKOPEDIA. All rights reserved.
//

import RxCocoa
import RxSwift
import SwiftOverlays
import UIKit

public class PaymentDetailCCViewController: UIViewController {
    
    @IBOutlet weak private var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak private var ccImageView: UIImageView!
    @IBOutlet weak private var ccNumberLabel: UILabel!
    @IBOutlet weak private var ccExpiryDateLabel: UILabel!
    @IBOutlet weak private var registerFingerPrintView: UIView!
    @IBOutlet weak private var registerFingerPrintButton: UIButton!
    @IBOutlet weak private var deleteButton: UIButton!
    
    // view model
    public var viewModel: PaymentDetailCCViewModel!
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Kartu Kredit"
        
        bindViewModel()
    }
    
    private func bindViewModel() {
        assert(viewModel != nil)
        let viewWillAppear = rx.sentMessage(#selector(UIViewController.viewWillAppear(_:)))
            .mapToVoid()
            .asDriverOnErrorJustComplete()
        let input = PaymentDetailCCViewModel.Input(trigger: viewWillAppear,
                                                   deleteCCTrigger: deleteButton.rx.tap.asDriver())
        let output = viewModel.transform(input: input)
        
        output.ccImageURL.drive(onNext: { url in
            guard let urlReq = url else { return }
            self.activityIndicator.startAnimating()
            self.ccImageView.setImageWith(URLRequest(url: urlReq), placeholderImage: nil, success: { _, _, image in
                self.activityIndicator.stopAnimating()
                UIView.transition(with: self.ccImageView, duration: 1, options: .transitionCrossDissolve,
                                  animations: { self.ccImageView.image = image },
                                  completion: nil)
            }, failure: nil)
        }).addDisposableTo(rx_disposeBag)
        
        output.ccNumber.drive(ccNumberLabel.rx.text).addDisposableTo(rx_disposeBag)
        output.ccExpiry.drive(ccExpiryDateLabel.rx.text).addDisposableTo(rx_disposeBag)
        
        output.isHiddenRegisterFingerprint
            .drive(registerFingerPrintView.rx.isHidden)
            .addDisposableTo(rx_disposeBag)
        
        output.isHiddenRegisterFingerprint
            .drive(registerFingerPrintButton.rx.isHidden)
            .addDisposableTo(rx_disposeBag)
        
        output.activityIndicator.drive(onNext: { isAnimating in
            if isAnimating {
                SwiftOverlays.showBlockingWaitOverlay()
            } else {
                SwiftOverlays.removeAllBlockingOverlays()
            }
        }).addDisposableTo(rx_disposeBag)
        
        output.successMessage.drive(onNext: { message in
            StickyAlertView.showSuccessMessage([message])
        }).addDisposableTo(rx_disposeBag)
        
        output.successTrigger
            .drive(onNext: { _ in
                self.navigationController?.popViewController(animated: true)
            }).addDisposableTo(rx_disposeBag)
        
        output.failedMessage.drive(onNext: { message in
            StickyAlertView.showErrorMessage([message])
        }).addDisposableTo(rx_disposeBag)
    }
}
