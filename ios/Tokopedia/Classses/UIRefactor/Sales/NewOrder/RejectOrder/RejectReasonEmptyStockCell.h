//
//  RejectReasonEmptyStockCell.h
//  Tokopedia
//
//  Created by Johanes Effendi on 6/14/16.
//  Copyright © 2016 TOKOPEDIA. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "OrderProduct.h"

@class ProductModelView;

@interface RejectReasonEmptyStockCell : UITableViewCell
@property (strong, nonatomic) IBOutlet UIImageView *checkImage;
@property (strong, nonatomic) IBOutlet UIImageView *productImage;
@property (strong, nonatomic) IBOutlet UILabel *productName;
@property (strong, nonatomic) IBOutlet UILabel *productPrice;
@property (strong, nonatomic) IBOutlet UILabel *stokKosongLabel;

- (void)setViewModel:(ProductModelView*)viewModel;

@end
