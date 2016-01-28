//
//  ProductAddCaptionViewController.h
//  Tokopedia
//
//  Created by Kenneth Vincent on 1/19/16.
//  Copyright © 2016 TOKOPEDIA. All rights reserved.
//

#import <UIKit/UIKit.h>

@class ProductAddCaptionViewController, GeneratedHost;

@protocol ProductAddCaptionDelegate <NSObject>
@optional
- (void)didDismissController:(ProductAddCaptionViewController*)controller withUserInfo:(NSDictionary*)userInfo;
- (void)setGenerateHost:(GeneratedHost*)generateHost;
@end

@interface ProductAddCaptionViewController : UIViewController

@property (weak, nonatomic) id<ProductAddCaptionDelegate> delegate;
@property (nonatomic, strong) NSDictionary *userInfo;
@property BOOL isFromGiveReview;
@property NSInteger selectedImageTag;

@end
