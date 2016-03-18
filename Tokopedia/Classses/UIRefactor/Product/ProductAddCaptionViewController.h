//
//  ProductAddCaptionViewController.h
//  Tokopedia
//
//  Created by Kenneth Vincent on 1/19/16.
//  Copyright © 2016 TOKOPEDIA. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DetailReputationReview.h"

@class ProductAddCaptionViewController, GeneratedHost;

@protocol ProductAddCaptionDelegate <NSObject>
@optional
- (void)didDismissController:(ProductAddCaptionViewController*)controller
                withUserInfo:(NSDictionary*)userInfo;
@end

@interface ProductAddCaptionViewController : UIViewController

@property (weak, nonatomic) id<ProductAddCaptionDelegate> delegate;
@property NSInteger selectedImageTag;
@property NSInteger numberOfUploadedImages;

@property (nonatomic, strong) DetailReputationReview *review;
@property (nonatomic, strong) NSArray *selectedImages;
@property (nonatomic, strong) NSArray *selectedIndexPaths;
@property (nonatomic, strong) NSArray *imagesCaptions;

@end
