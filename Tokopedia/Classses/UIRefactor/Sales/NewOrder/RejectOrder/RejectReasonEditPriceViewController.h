//
//  RejectReasonEditPriceViewController.h
//  Tokopedia
//
//  Created by Johanes Effendi on 6/21/16.
//  Copyright © 2016 TOKOPEDIA. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "OrderProduct.h"

@protocol RejectReasonEditPriceDelegate <NSObject>
- (void) didChangeProductPriceWeight:(OrderProduct*)orderProduct;
@end

@interface RejectReasonEditPriceViewController : UIViewController
@property (strong, nonatomic) OrderProduct* orderProduct;
@property (weak, nonatomic) id<RejectReasonEditPriceDelegate> delegate;
@end
