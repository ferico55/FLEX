//
//  OrderRejectExplanationViewController.h
//  Tokopedia
//
//  Created by Tokopedia PT on 1/16/15.
//  Copyright (c) 2015 TOKOPEDIA. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol RejectExplanationDelegate <NSObject>

- (void)didFinishWritingExplanation:(NSString *)explanation;

@end

@interface OrderRejectExplanationViewController : UIViewController

@property (weak, nonatomic) id<RejectExplanationDelegate> delegate;
@property (strong, nonatomic) NSString* reasonCode;

@end
