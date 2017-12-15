//
//  HotlistResultPromoHeaderView.swift
//  Tokopedia
//
//  Created by Billion Goenawan on 11/28/17.
//  Copyright © 2017 TOKOPEDIA. All rights reserved.
//

import RxSwift
import RxCocoa

class HotlistResultPromoHeaderView: UIView {
    
    @IBOutlet private var titleLabel: UILabel!
    @IBOutlet private var couponButton: UIButton!
    @IBOutlet private var minimumTransactionLabel: UILabel!
    @IBOutlet private var promoPeriodLabel: UILabel!
    @IBOutlet private var couponButtonContainerView: UIView!
    @IBOutlet private var checkImageView: UIImageView! {
        didSet {
            self.checkImageView.tintColor = .tpOrange()
        }
    }
    @IBOutlet private var copyCodeButton: UIButton!
    @IBOutlet private var termConditionButton: UIButton!
    @IBOutlet private var separatorView: UIView!
    
    private var promoInfo: HotlistPromoInfo? {
        didSet {
            titleLabel.text = promoInfo?.text
            couponButton.setTitle(promoInfo?.voucherCode, for: .normal)
            minimumTransactionLabel.text = promoInfo?.minimalTransaction
            promoPeriodLabel.text = promoInfo?.promoPeriod
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        doLayoutPromoHeader()
        handleTapCopyPromoButton()
        handleTapTermConditionButton()
    }
    
    private func doLayoutPromoHeader() {
        let promoHeaderView = UINib(nibName: "HotlistResultPromoHeaderView",
                                    bundle: nil).instantiate(withOwner: self, options: nil)[0] as! UIView
        self.addSubview(promoHeaderView)
        
        NSLayoutConstraint.activate([
            promoHeaderView.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: 0),
            promoHeaderView.topAnchor.constraint(equalTo: self.topAnchor, constant: 0),
            promoHeaderView.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 0),
            promoHeaderView.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: 0)
            ])
    }
    
    private func handleTapCopyPromoButton() {
        copyCodeButton.rx.tap.asObservable()
            .do(onNext: { [weak self] in
                guard let `self` = self else { return }
                UIPasteboard.general.string = self.couponButton.title(for: .normal)
                self.couponButtonContainerView.layer.borderColor = UIColor.tpOrange().cgColor
                self.separatorView.backgroundColor = UIColor.tpOrange()
                self.couponButton.backgroundColor = UIColor.fromHexString("#fff2ee")
                self.couponButton.setTitle("Kode Tersalin!", for: .normal)
                self.checkImageView.isHidden = false
                self.copyCodeButton.isHidden = true
            })
            .subscribe()
            .disposed(by: rx_disposeBag)
    }
    
    private func handleTapTermConditionButton() {
        termConditionButton.rx.tap
            .subscribe(onNext: { [weak self] in
                guard let `self` = self,
                    let applinks = self.promoInfo?.applinks,
                    let applinksURL = URL(string: applinks) else { return }
                TPRoutes.routeURL(applinksURL)
            })
            .disposed(by: rx_disposeBag)
    }
    
    func setPromoInfo(_ promoInfo: HotlistPromoInfo) {
        self.promoInfo = promoInfo
    }
}

