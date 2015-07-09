//
//  GiveReviewViewController.h
//  Tokopedia
//
//  Created by Tokopedia on 7/8/15.
//  Copyright (c) 2015 TOKOPEDIA. All rights reserved.
//

#import <UIKit/UIKit.h>
@class TKPDTextView, DetailReputationReview;

@interface GiveReviewViewController : UIViewController
{
    IBOutlet UIImageView *imgProduct;
    IBOutlet UILabel *lblProduct, *lblCountImage;
    IBOutlet TKPDTextView *txtDes;
    IBOutletCollection(UIImageView) NSArray *arrImgKualitas, *arrImgAkurasi;
    IBOutlet UIScrollView *scrollView;
    IBOutlet UIView *viewContent, *viewContentRating;
    IBOutlet NSLayoutConstraint *constraintHeightScrollView, *constHeightContentView;
}

@property (nonatomic, unsafe_unretained) DetailReputationReview *detailReputationView;
@end
