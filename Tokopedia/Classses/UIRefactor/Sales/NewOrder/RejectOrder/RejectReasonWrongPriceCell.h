//
//  RejectReasonWrongPriceCell.h
//  Tokopedia
//
//  Created by Johanes Effendi on 6/21/16.
//  Copyright © 2016 TOKOPEDIA. All rights reserved.
//

#import <UIKit/UIKit.h>
@class ProductModelView;
@protocol RejectReasonWrongPriceDelegate <NSObject>
- (void)tableViewCell:(UITableViewCell *)cell changeProductPriceAtIndexPath:(NSIndexPath *)indexPath;
@end

@interface RejectReasonWrongPriceCell : UITableViewCell
@property (strong, nonatomic) IBOutlet UIImageView *productImage;
@property (strong, nonatomic) IBOutlet UILabel *productName;
@property (strong, nonatomic) IBOutlet UILabel *productPrice;
@property (strong, nonatomic) IBOutlet UILabel *productWeight;
@property (strong, nonatomic) IBOutlet UIButton *changePriceButton;
@property (strong, nonatomic) IBOutlet UILabel *emptyStockLabel;
@property (weak, nonatomic) id<RejectReasonWrongPriceDelegate> delegate;
@property (strong, nonatomic) NSIndexPath *indexPath;

- (void)setViewModel:(ProductModelView *)viewModel;
@end
