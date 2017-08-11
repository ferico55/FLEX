//
//  ProductReputationTableViewCell.swift
//  Tokopedia
//
//  Created by Kenneth Vincent on 12/9/16.
//  Copyright © 2016 TOKOPEDIA. All rights reserved.
//

import UIKit
import TTTAttributedLabel

@objc class ProductReputationTableViewCell: UITableViewCell, TTTAttributedLabelDelegate {
    
    var onTapProductName: ((String, String) -> Void)!
    var viewModel: DetailReviewReputationViewModel! {
        didSet {
            setupView()
        }
    }
    
    @IBOutlet fileprivate var mostHelpfulReviewIndicatorView: UIView!
    @IBOutlet fileprivate var reviewMessageLabel: TTTAttributedLabel!
    
    @IBOutlet fileprivate var reviewImagesView: UIView!
    
    @IBOutlet fileprivate var qualityStars: EDStarRating!
    @IBOutlet fileprivate var accuracyStars: EDStarRating!
    
    @IBOutlet fileprivate var reviewerImage: UIImageView!
    @IBOutlet fileprivate var reviewerName: UILabel!
    @IBOutlet fileprivate var reviewCreatedTime: UILabel!
    
    @IBOutlet fileprivate var productView: UIView!
    @IBOutlet fileprivate var productName: UIButton!
    
    @IBOutlet fileprivate var reviewImages: [UIImageView]!
    
    fileprivate var starActiveImage: UIImage! = UIImage(named: "icon_star_active_med")
    fileprivate var starInactiveImage: UIImage! = UIImage(named: "icon_star_med")
    fileprivate var reviewViewModel: DetailReviewReputationViewModel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    //MARK: Set view
    fileprivate func setupView() {
        reviewViewModel = viewModel
        resetImages()
        setupHelpfulReview(viewModel)
        setupMessage(viewModel)
        setupImages(viewModel)
        setupStars(viewModel.review_rate_quality as String, accuracy: viewModel.review_rate_accuracy as String)
        setupReviewer(viewModel)
        setupProduct(viewModel)
    }
    
    fileprivate func setupHelpfulReview(_ review: DetailReviewReputationViewModel) {
        mostHelpfulReviewIndicatorView.isHidden = !review.review_is_helpful
    }
    
    fileprivate func setupMessage(_ review: DetailReviewReputationViewModel) {
        let seeMore = "Lihat Selengkapnya"
        var message = NSString.convertHTML(review.review_message as String!)
        
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = 3.0

        if (message.characters.count) > 100 {
            let substring = message.substring(to: message.index(message.startIndex, offsetBy: 100))
            message = "\(substring)... \(seeMore)"
            
            reviewMessageLabel.enabledTextCheckingTypes = NSTextCheckingResult.CheckingType.link.rawValue
            reviewMessageLabel.activeLinkAttributes = [kCTForegroundColorAttributeName as AnyHashable : UIColor.lightGray,
                                                       NSUnderlineStyleAttributeName : NSUnderlineStyle.styleNone.rawValue]
            reviewMessageLabel.linkAttributes = [NSUnderlineStyleAttributeName : NSUnderlineStyle.styleNone.rawValue]
        
            let mutableString = NSMutableAttributedString(string: message)
            mutableString.addAttribute(NSFontAttributeName,
                                       value: UIFont.smallTheme(), range: NSMakeRange(0, (message.characters.count)))
            mutableString.addAttribute(NSParagraphStyleAttributeName, value: paragraphStyle, range: NSMakeRange(0, (message.characters.count)))
            mutableString.addAttribute(NSForegroundColorAttributeName,
                                       value: UIColor(red: 78/255.0, green: 134/255.0, blue: 38/255.0, alpha: 1),
                                       range: NSMakeRange((message.characters.count) - seeMore.characters.count, seeMore.characters.count))
            
            reviewMessageLabel.attributedText = mutableString
        } else {
            reviewMessageLabel.text = message
        }
    }
    
    fileprivate func setupImages(_ review: DetailReviewReputationViewModel) {
        if review.review_image_attachment == nil || review.review_image_attachment.count == 0 {
            reviewImagesView.mas_updateConstraints({ (make) in
                make?.height.mas_equalTo()(0)
            })
            
            return
        }
        
        reviewImagesView.mas_updateConstraints({ (make) in
            make?.height.mas_equalTo()(50)
        })
        
        for ii in 0...(review.review_image_attachment.count-1) {
            let image = review.review_image_attachment[ii]
            let imageView = reviewImages[ii]
            imageView.setImageWith(NSURL(string: (image as AnyObject).uri_thumbnail) as URL!, placeholderImage: UIImage(named: "icon_toped_loading_grey"))
        }
    }
    
    fileprivate func setupStars(_ quality: String, accuracy: String) {
        let accuracyRating = accuracyStars
        accuracyRating?.backgroundImage = nil
        accuracyRating?.starImage = starInactiveImage
        accuracyRating?.starHighlightedImage = starActiveImage
        accuracyRating?.maxRating = 5
        accuracyRating?.horizontalMargin = 1.0
        accuracyRating?.rating = Float(accuracy)!
        accuracyRating?.displayMode = UInt(EDStarRatingDisplayAccurate)
        
        let qualityRating = qualityStars
        qualityRating?.backgroundImage = nil
        qualityRating?.starImage = starInactiveImage
        qualityRating?.starHighlightedImage = starActiveImage
        qualityRating?.maxRating = 5
        qualityRating?.horizontalMargin = 1.0
        qualityRating?.rating = Float(quality)!
        qualityRating?.displayMode = UInt(EDStarRatingDisplayAccurate)
    }
    
    fileprivate func setupReviewer(_ review: DetailReviewReputationViewModel) {
        reviewerName.text = review.review_user_name as String?
        reviewCreatedTime.text = review.review_create_time as String?
        reviewerImage.setImageWith(URL(string: review.review_user_image as String), placeholderImage: UIImage(named: "default-boy"))
        reviewerImage.clipsToBounds = true
        reviewerImage.cornerRadius = reviewerImage.frame.size.height/2
    }
    
    fileprivate func setupProduct(_ review: DetailReviewReputationViewModel) {
        if review.product_name == nil {
            for image in productView.subviews {
                image.mas_makeConstraints({ (make) in
                    make?.height.mas_equalTo()(0)
                })
            }
            
            productView.mas_makeConstraints({ (make) in
                make?.height.mas_equalTo()(0)
            })
        }
        
        productName.setTitle(review.product_name as String?, for: .normal)
    }
    
    fileprivate func resetImages() {
        for image in reviewImagesView.subviews {
            let imageView = image as! UIImageView
            imageView.image = nil
        }
    }
    
    //MARK: CTA Button
    
    @IBAction fileprivate func didTapProductName(_ sender: AnyObject) {
        onTapProductName?(reviewViewModel.product_name as String, reviewViewModel.product_id as String)
    }
}
