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
    
    @IBOutlet private var mostHelpfulReviewIndicatorView: UIView!
    @IBOutlet private var reviewMessageLabel: TTTAttributedLabel!
    
    @IBOutlet private var reviewImagesView: UIView!
    
    @IBOutlet private var qualityStars: EDStarRating!
    @IBOutlet private var accuracyStars: EDStarRating!
    
    @IBOutlet private var reviewerImage: UIImageView!
    @IBOutlet private var reviewerName: UILabel!
    @IBOutlet private var reviewCreatedTime: UILabel!
    
    @IBOutlet private var productView: UIView!
    @IBOutlet private var productName: UIButton!
    
    @IBOutlet private var reviewImages: [UIImageView]!
    
    private var starActiveImage: UIImage! = UIImage(named: "icon_star_active_med")
    private var starInactiveImage: UIImage! = UIImage(named: "icon_star_med")
    private var reviewViewModel: DetailReviewReputationViewModel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    //MARK: Set view
    private func setupView() {
        reviewViewModel = viewModel
        resetImages()
        setupHelpfulReview(viewModel)
        setupMessage(viewModel)
        setupImages(viewModel)
        setupStars(viewModel.review_rate_quality, accuracy: viewModel.review_rate_accuracy)
        setupReviewer(viewModel)
        setupProduct(viewModel)
    }
    
    private func setupHelpfulReview(review: DetailReviewReputationViewModel) {
        mostHelpfulReviewIndicatorView.hidden = !review.review_is_helpful
    }
    
    private func setupMessage(review: DetailReviewReputationViewModel) {
        let seeMore = "Lihat Selengkapnya"
        var message = NSString.convertHTML(review.review_message)
        
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = 3.0

        if message.characters.count > 100 {
            let substring = message[message.startIndex...message.startIndex.advancedBy(100)]
            message = "\(substring)... \(seeMore)"
            
            reviewMessageLabel.enabledTextCheckingTypes = NSTextCheckingType.Link.rawValue
            reviewMessageLabel.activeLinkAttributes = [kCTForegroundColorAttributeName : UIColor.lightGrayColor(),
                                                       NSUnderlineStyleAttributeName : NSUnderlineStyle.StyleNone.rawValue]
            reviewMessageLabel.linkAttributes = [NSUnderlineStyleAttributeName : NSUnderlineStyle.StyleNone.rawValue]
        
            let mutableString = NSMutableAttributedString(string: message)
            mutableString.addAttribute(NSFontAttributeName,
                                       value: UIFont.smallTheme(), range: NSMakeRange(0, message.characters.count))
            mutableString.addAttribute(NSParagraphStyleAttributeName, value: paragraphStyle, range: NSMakeRange(0, message.characters.count))
            mutableString.addAttribute(NSForegroundColorAttributeName,
                                       value: UIColor(red: 78/255.0, green: 134/255.0, blue: 38/255.0, alpha: 1),
                                       range: NSMakeRange(message.characters.count - seeMore.characters.count, seeMore.characters.count))
            
            reviewMessageLabel.attributedText = mutableString
        } else {
            reviewMessageLabel.text = message
        }
    }
    
    private func setupImages(review: DetailReviewReputationViewModel) {
        if review.review_image_attachment == nil || review.review_image_attachment.count == 0 {
            reviewImagesView.mas_updateConstraints({ (make) in
                make.height.mas_equalTo()(0)
            })
            
            return
        }
        
        reviewImagesView.mas_updateConstraints({ (make) in
            make.height.mas_equalTo()(50)
        })
        
        for ii in 0...(review.review_image_attachment.count-1) {
            let image = review.review_image_attachment[ii]
            let imageView = reviewImages[ii]
            imageView.setImageWithURL(NSURL(string: image.uri_thumbnail), placeholderImage: UIImage(named: "icon_toped_loading_grey"))
        }
    }
    
    private func setupStars(quality: String, accuracy: String) {
        let accuracyRating = accuracyStars
        accuracyRating.backgroundImage = nil
        accuracyRating.starImage = starInactiveImage
        accuracyRating.starHighlightedImage = starActiveImage
        accuracyRating.maxRating = 5
        accuracyRating.horizontalMargin = 1.0
        accuracyRating.rating = Float(accuracy)!
        accuracyRating.displayMode = UInt(EDStarRatingDisplayAccurate)
        
        let qualityRating = qualityStars
        qualityRating.backgroundImage = nil
        qualityRating.starImage = starInactiveImage
        qualityRating.starHighlightedImage = starActiveImage
        qualityRating.maxRating = 5
        qualityRating.horizontalMargin = 1.0
        qualityRating.rating = Float(accuracy)!
        qualityRating.displayMode = UInt(EDStarRatingDisplayAccurate)
    }
    
    private func setupReviewer(review: DetailReviewReputationViewModel) {
        reviewerName.text = review.review_user_name
        reviewCreatedTime.text = review.review_create_time
        reviewerImage.setImageWithURL(NSURL(string: review.review_user_image), placeholderImage: UIImage(named: "default-boy"))
        reviewerImage.clipsToBounds = true
        reviewerImage.cornerRadius = reviewerImage.frame.size.height/2
    }
    
    private func setupProduct(review: DetailReviewReputationViewModel) {
        if review.product_name == nil {
            for image in productView.subviews {
                image.mas_makeConstraints({ (make) in
                    make.height.mas_equalTo()(0)
                })
            }
            
            productView.mas_makeConstraints({ (make) in
                make.height.mas_equalTo()(0)
            })
        }
        
        productName.setTitle(review.product_name, forState: .Normal)
    }
    
    private func resetImages() {
        for image in reviewImagesView.subviews {
            let imageView = image as! UIImageView
            imageView.image = nil
        }
    }
    
    //MARK: CTA Button
    
    @IBAction private func didTapProductName(sender: AnyObject) {
        onTapProductName?(reviewViewModel.product_name, reviewViewModel.product_id)
    }
}
