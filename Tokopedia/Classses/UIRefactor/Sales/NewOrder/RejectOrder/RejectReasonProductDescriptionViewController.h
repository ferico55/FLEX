//
//  RejectReasonProductDescriptionViewController.h
//  Tokopedia
//
//  Created by Johanes Effendi on 6/16/16.
//  Copyright © 2016 TOKOPEDIA. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "OrderProduct.h"

@protocol RejectReasonProductDescriptionDelegate <NSObject>
- (void)didChangeProductDescription:(NSString *)description withEmptyStock:(BOOL)emptyStock ;
@end

@interface RejectReasonProductDescriptionViewController : UIViewController
@property (strong, nonatomic) OrderProduct *orderProduct;
@property (weak, nonatomic) id<RejectReasonProductDescriptionDelegate> delegate;
@end
