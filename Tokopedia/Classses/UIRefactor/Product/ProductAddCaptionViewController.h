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
- (void)didDismissController:(ProductAddCaptionViewController*)controller
                withUserInfo:(NSDictionary*)userInfo;
@end

@interface ProductAddCaptionViewController : UIViewController

@property (weak, nonatomic) id<ProductAddCaptionDelegate> delegate;
@property (nonatomic, strong) NSDictionary *userInfo;
@property NSInteger selectedImageTag;
@property int numberOfUploadedImages;

@end
