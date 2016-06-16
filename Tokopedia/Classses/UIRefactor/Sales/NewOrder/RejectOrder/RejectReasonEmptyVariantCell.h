//
//  RejectReasonEmptyVariantCell.h
//  Tokopedia
//
//  Created by Johanes Effendi on 6/16/16.
//  Copyright © 2016 TOKOPEDIA. All rights reserved.
//

#import <UIKit/UIKit.h>
@class ProductModelView;
@protocol RejectReasonEmptyVariantDelegate <NSObject>

@optional
- (void)tableViewCell:(UITableViewCell *)cell changeProductDescriptionAtIndexPath:(NSIndexPath *)indexPath;
@end

@interface RejectReasonEmptyVariantCell : UITableViewCell
@property (strong, nonatomic) IBOutlet UIImageView *productImage;
@property (strong, nonatomic) IBOutlet UILabel *productName;
@property (strong, nonatomic) IBOutlet UILabel *productPrice;
@property (strong, nonatomic) IBOutlet UILabel *emptyStockLabel;
@property (strong, nonatomic) IBOutlet UILabel *productDescription;
@property (strong, nonatomic) IBOutlet UIButton *changeDescriptionButton;

@property (strong, nonatomic) NSIndexPath *indexPath;
@property (weak, nonatomic) id<RejectReasonEmptyVariantDelegate> delegate;

- (void)setViewModel:(ProductModelView *)viewModel;
@end
