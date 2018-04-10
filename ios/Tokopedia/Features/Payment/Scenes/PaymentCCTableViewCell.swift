//
//  PaymentCCTableViewCell.swift
//  Tokopedia
//
//  Created by Tiara Freddy Andika on 26/01/18.
//  Copyright © 2018 TOKOPEDIA. All rights reserved.
//

import RxCocoa
import RxSwift
import UIKit

public class PaymentCCTableViewCell: UITableViewCell {
    
    @IBOutlet private weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet private weak var ccImageView: UIImageView!
    @IBOutlet private weak var ccNumberLabel: UILabel!
    
    public func bind(_ viewModel: PaymentCCViewModel) {
        
        let input = PaymentCCViewModel.Input()
        let output = viewModel.transform(input: input)
        
        output.ccNumber
            .drive(ccNumberLabel.rx.text)
            .addDisposableTo(rx_disposeBag)
        
        output.ccImage
            .drive(onNext: { url in
                guard let urlReq = url else { return }
                self.activityIndicator.startAnimating()
                self.ccImageView.setImageWith(URLRequest(url: urlReq), placeholderImage: nil, success: { _, _, image in
                    UIView.transition(with: self.ccImageView, duration: 1, options: .transitionCrossDissolve, animations: {
                        self.activityIndicator.stopAnimating()
                        self.ccImageView.image = image
                    }, completion: nil)
                }, failure: nil)
            }).addDisposableTo(rx_disposeBag)
    }
}
