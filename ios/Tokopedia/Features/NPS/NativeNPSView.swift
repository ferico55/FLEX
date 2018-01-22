//
//  NativeNPSView.swift
//  Tokopedia
//
//  Created by Digital Khrisna on 08/12/17.
//  Copyright © 2017 TOKOPEDIA. All rights reserved.
//

import UIKit
import CFAlertViewController
import RxSwift

@objc class NativeNPSView: UIView, Modal {
    internal typealias T = UIView
    
    @IBOutlet private weak var parentView: UIView!
    
    @IBOutlet private weak var bgView: UIView!
    
    @IBOutlet private weak var contentView: UIView!
    
    internal var backgroundView: T {
        return bgView
    }
    
    internal var dialogView: UIView {
        return contentView
    }
    
    @IBOutlet fileprivate weak var ratingEmoticonImageView: UIImageView!
    
    @IBOutlet fileprivate weak var ratingTextLabel: UILabel!
    
    @IBOutlet private weak var starRatingView: EDStarRating! {
        didSet {
            starRatingView.starImage = #imageLiteral(resourceName: "rating_star_inactive")
            starRatingView.starHighlightedImage = #imageLiteral(resourceName: "rating_star_active")
            starRatingView.maxRating = 5
            starRatingView.horizontalMargin = 1
            starRatingView.editable = true
            starRatingView.displayMode = UInt(EDStarRatingDisplayAccurate)
            starRatingView.rating = 0
            starRatingView.delegate = self
        }
    }
    
    @IBOutlet fileprivate weak var sendReviewButton: UIButton!
    
    @IBOutlet private weak var dialogViewLeadingConstraint: NSLayoutConstraint!
    
    @IBOutlet private weak var dialogViewTrailingConstraint: NSLayoutConstraint!
    
    @IBOutlet private weak var dialogViewHeightConstraint: NSLayoutConstraint!
    
    fileprivate static let dialogDefaultFrame: CGRect = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)

    fileprivate var currentRating: Variable<Float> = Variable(0)
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    convenience init() {
        self.init(frame: NativeNPSView.dialogDefaultFrame)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()

        self.layoutIfNeeded()

        if UI_USER_INTERFACE_IDIOM() == .pad {
            self.dialogViewLeadingConstraint.constant = 155
            self.dialogViewTrailingConstraint.constant = 155
            self.dialogViewHeightConstraint.constant = 0
        } else {
            self.dialogViewLeadingConstraint.constant = 25
            self.dialogViewTrailingConstraint.constant = 25
            self.dialogViewHeightConstraint.constant = 58
        }
    
        dialogView.subviews.forEach {
            self.dialogViewHeightConstraint.constant = (self.dialogViewHeightConstraint.constant + $0.frame.height) + 10
        }
    }
    
    public func showNPS() {
        self.show(animated: true, isWindow: true)
    }
    
    private func commonInit() {
        Bundle.main.loadNibNamed("NativeNPSView", owner: self, options: nil)
        addSubview(parentView)
        parentView.frame = self.bounds
        parentView.autoresizingMask = [.flexibleHeight, .flexibleWidth]
        
        let gesture = UITapGestureRecognizer(target: self, action: #selector(didTappedOnBackgroundView))
        backgroundView.addGestureRecognizer(gesture)
        
        setupObserver()
    }
    
    @objc
    internal func didTappedOnBackgroundView() {
        dismiss(animated: true)
    }
    
    @IBAction func sendReview(_ sender: Any) {
        UserDefaults.standard.lastVersionNPSRated = Bundle.main.releaseVersionNumber
        dismiss(animated: true)
        
        if currentRating.value > 3 {
            let closeButton = CFAlertAction.action(title: "Rating", style: .Destructive, alignment: .justified, backgroundColor: UIColor.tpGreen(), textColor: .white) {
                _ in
                if let url = URL(string: "itms-apps://itunes.apple.com/us/app/id1001394201?mt=8&action=write-review") {
                    UIApplication.shared.openURL(url)
                }
            }
            
            let actionSheet = TooltipAlert.createAlert(title: "Terima Kasih", subtitle: "Rate 5 bintang untuk aplikasi ini. Setiap rating yang kalian berikan adalah semangat bagi kami! Terima kasih Toppers.", image: #imageLiteral(resourceName: "rating_five_emoticon"), buttons: [closeButton])
         
            UIApplication.topViewController()?.present(actionSheet, animated: true, completion: nil)

        }
    }
}

extension NativeNPSView {
    fileprivate func setupObserver() {
        currentRating
            .asObservable()
            .subscribe(onNext: {
            [weak self] rating in
                guard let `self` = self else { return }
                self.setEmoticonAsset(rating)
                
                if rating > 0 {
                    self.sendReviewButton.isEnabled = true
                    self.sendReviewButton.backgroundColor = .tpGreen()
                    self.sendReviewButton.setTitleColor(.white, for: .normal)
                } else {
                    self.sendReviewButton.isEnabled = false
                    self.sendReviewButton.backgroundColor = .tpBorder()
                    self.sendReviewButton.setTitleColor(UIColor.black.withAlphaComponent(0.26), for: .normal)
                }
            })
            .disposed(by: rx_disposeBag)
    }
    
    fileprivate func setEmoticonAsset(_ rating: Float) {
        switch rating {
        case 1:
            ratingEmoticonImageView.image = #imageLiteral(resourceName: "rating_one_emoticon")
            ratingTextLabel.text = "Sangat Jelek"
            ratingTextLabel.textColor = UIColor(red: 234 / 255, green: 23 / 255, blue: 6 / 255, alpha: 1)
            break
        case 2:
            ratingEmoticonImageView.image = #imageLiteral(resourceName: "rating_two_emoticon")
            ratingTextLabel.text = "Jelek"
            ratingTextLabel.textColor = UIColor(red: 234 / 255, green: 23 / 255, blue: 6 / 255, alpha: 1)
            break
        case 3:
            ratingEmoticonImageView.image = #imageLiteral(resourceName: "rating_three_emoticon")
            ratingTextLabel.text = "Biasa"
            ratingTextLabel.textColor = UIColor(red: 255 / 255, green: 176 / 255, blue: 59 / 255, alpha: 1)
            break
        case 4:
            ratingEmoticonImageView.image = #imageLiteral(resourceName: "rating_four_emoticon")
            ratingTextLabel.text = "Baik"
            ratingTextLabel.textColor = UIColor(red: 66 / 255, green: 181 / 255, blue: 73 / 255, alpha: 1)
            break
        case 5:
            ratingEmoticonImageView.image = #imageLiteral(resourceName: "rating_five_emoticon")
            ratingTextLabel.text = "Super"
            ratingTextLabel.textColor = UIColor(red: 66 / 255, green: 181 / 255, blue: 73 / 255, alpha: 1)
            break
        default:
            ratingEmoticonImageView.image = #imageLiteral(resourceName: "rating_default_emoticon")
            ratingEmoticonImageView.tintColor = .gray
            ratingTextLabel.text = "Belum Memberi Rating"
            ratingTextLabel.textColor = UIColor(red: 134 / 255, green: 134 / 255, blue: 134 / 255, alpha: 1)
            break
        }
    }
}

extension NativeNPSView: EDStarRatingProtocol {
    func starsSelectionChanged(_ control: EDStarRating!, rating: Float) {
        currentRating.value = rating
    }
}
