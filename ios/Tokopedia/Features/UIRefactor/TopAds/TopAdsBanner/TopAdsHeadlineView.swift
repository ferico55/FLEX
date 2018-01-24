//
//  TopAdsHeadlineView.swift
//  Tokopedia
//
//  Created by Billion Goenawan on 28/12/17.
//  Copyright © 2017 TOKOPEDIA. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class TopAdsHeadlineView: UIView {
    
    @IBOutlet private var logoImageView: UIImageView!
    @IBOutlet private var promotedLabel: UILabel!
    @IBOutlet private var nameLabel: UILabel!
    @IBOutlet private var descriptionLabel: UILabel!
    @IBOutlet private var badgesStackView: UIStackView!
    @IBOutlet private var separatorView: UIView!
    
    private var promoResult: PromoResult? {
        didSet {
            guard let headline = promoResult?.headline else { return }
            if let headlineDescription = headline.headlineDescription, let buttonText = headline.buttonText {
                let descriptionMutableString = setDescriptionLabel(descriptionText: headlineDescription.kv_decodeHTMLCharacterEntities(), buttonText: buttonText)
                descriptionLabel.attributedText = descriptionMutableString
            }
            nameLabel.text = headline.name.kv_decodeHTMLCharacterEntities()
            if headline.promotedText == "" {
                promotedLabel.isHidden = true
            } else {
                promotedLabel.isHidden = false
                promotedLabel.text = headline.promotedText
            }
            guard let headlineImage = headline.headlineImage, let url = URL(string: headlineImage.fullUrl) else { return }
            logoImageView.setImageWith(url)
            
            if headline.badges.isEmpty {
                badgesStackView.isHidden = true
            } else {
                badgesStackView.isHidden = false
                badgesStackView.removeAllSubviews()
                headline.badges.forEach { [weak self] (badge) in
                    guard let badgeURL = URL(string: badge.image_url) else { return }
                    let badgeImageView = UIImageView()
                    badgeImageView.setImageWithUrl(badgeURL)
                    self?.badgesStackView.addArrangedSubview(badgeImageView)
                }
            }
            
            let tapGesture = UITapGestureRecognizer()
            self.addGestureRecognizer(tapGesture)
            
            tapGesture.rx.event.bindNext { [weak self] recognizer in
                guard let `self` = self,
                    let applinks = self.promoResult?.applinks,
                    let url = URL(string: applinks),
                    let adClickURL = self.promoResult?.adClickURL else { return }
                TopAdsService.sendClickImpression(clickURLString: adClickURL)
                TPRoutes.routeURL(url)
            }.addDisposableTo(rx_disposeBag)
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        doLayoutTopAdsHeadlineView()
    }
    
    // need to override init frame, because there is a width bug in render
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 72)
        doLayoutTopAdsHeadlineView()
    }
    
    private func doLayoutTopAdsHeadlineView() {
        let topAdsHeadlineView = UINib(nibName: "TopAdsHeadlineView",
                                    bundle: nil).instantiate(withOwner: self, options: nil)[0] as! UIView
        self.addSubview(topAdsHeadlineView)
        
        NSLayoutConstraint.activate([
            topAdsHeadlineView.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: 0),
            topAdsHeadlineView.topAnchor.constraint(equalTo: self.topAnchor, constant: 0),
            topAdsHeadlineView.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 0),
            topAdsHeadlineView.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: 0)
            ])
    }
    
    func setInfo(_ promoResult: PromoResult) {
        self.promoResult = promoResult
    }
    
    func hideSeparatorView() {
        self.separatorView.backgroundColor = UIColor.tpBackground()
        self.separatorView.layer.borderWidth = 0
        
    }
    
    private func setDescriptionLabel(descriptionText: String, buttonText: String) -> NSMutableAttributedString {
        let fullDescription = descriptionText + " " + buttonText
        let fullDescriptionAttributedText = NSMutableAttributedString(string: fullDescription)
        let greenTextRange = NSString(string: fullDescription).range(of: buttonText, options: .backwards)
        fullDescriptionAttributedText.addAttributes([
            NSForegroundColorAttributeName: UIColor.tpGreen(),
            NSFontAttributeName: UIFont.microTheme()
        ], range: greenTextRange)
        
        return fullDescriptionAttributedText
    }

}
