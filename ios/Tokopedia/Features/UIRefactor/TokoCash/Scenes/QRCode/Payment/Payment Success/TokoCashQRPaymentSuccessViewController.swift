//
//  TokoCashQRPaymentSuccessViewController.swift
//  Tokopedia
//
//  Created by Tiara Freddy Andika on 03/01/18.
//  Copyright © 2018 TOKOPEDIA. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import Lottie

class TokoCashQRPaymentSuccessViewController: UIViewController {
    
    @IBOutlet weak var animationView: UIView!
    @IBOutlet weak var checkmarkImageView: UIImageView!
    @IBOutlet weak var descView: UIView!
    @IBOutlet weak var merchantNameLabel: UILabel!
    @IBOutlet weak var amountLabel: UILabel!
    @IBOutlet weak var datetimeLabel: UILabel!
    @IBOutlet weak var transactionIdLabel: UILabel!
    @IBOutlet weak var balanceLabel: UILabel!
    @IBOutlet weak var backToHomeButton: UIButton!
    @IBOutlet weak var helpButton: UIButton!
    
    private var isAnimation = false
    
    // view model
    var viewModel: TokoCashQRPaymentSuccessViewModel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        bindViewModel()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        navigationItem.setHidesBackButton(true, animated: true)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        if !isAnimation {
            configureCheckmarkAnimation()
            configureDescAnimation()
        }
    }
    
    private func bindViewModel() {
        assert(viewModel != nil)
        let viewWillAppear = rx.sentMessage(#selector(UIViewController.viewWillAppear(_:)))
            .mapToVoid()
            .asDriverOnErrorJustComplete()
        let input = TokoCashQRPaymentSuccessViewModel.Input(trigger: viewWillAppear,
                                                            backToHomeTrigger: backToHomeButton.rx.tap.asDriver(),
                                                            helpTrigger: helpButton.rx.tap.asDriver())
        let output = viewModel.transform(input: input)
        
        output.merchantName
            .drive(merchantNameLabel.rx.text)
            .disposed(by: rx_disposeBag)
        
        output.amount
            .drive(amountLabel.rx.text)
            .disposed(by: rx_disposeBag)
        
        output.datetime
            .drive(datetimeLabel.rx.text)
            .disposed(by: rx_disposeBag)
        
        output.transactionId
            .drive(transactionIdLabel.rx.text)
            .disposed(by: rx_disposeBag)
        
        output.balance
            .drive(balanceLabel.rx.text)
            .disposed(by: rx_disposeBag)
        
        output.backToHome
            .drive()
            .disposed(by: rx_disposeBag)
        
        output.help
            .drive()
            .disposed(by: rx_disposeBag)
    }
    
    private func configureCheckmarkAnimation() {
        let animation = LOTAnimationView(name: "Success-animation")
        animation.frame = CGRect(x: 0.0, y: 0.0, width: animationView.frame.width, height: animationView.frame.height)
        animation.backgroundColor = .clear
        
        animationView.addSubview(animation)
        
        animation.translatesAutoresizingMaskIntoConstraints = true
        animation.autoresizingMask = [UIViewAutoresizing.flexibleLeftMargin, UIViewAutoresizing.flexibleRightMargin, UIViewAutoresizing.flexibleTopMargin, UIViewAutoresizing.flexibleBottomMargin]
        
        animation.play()
    }
    
    private func configureDescAnimation() {
        descView.frame = CGRect(x: view.frame.minX, y: view.frame.height, width: view.frame.width, height: self.descView.frame.height)
        descView.isHidden = true
        
        UIView.animate(withDuration: 1.0, delay: 0.1, options: .curveEaseIn, animations: {
            self.descView.isHidden = false
            self.descView.frame = CGRect(x: self.view.frame.minX, y: 264, width: self.view.frame.width, height: self.descView.frame.height)
            
        }, completion: { _ in
            self.isAnimation = true
        })
    }
}
