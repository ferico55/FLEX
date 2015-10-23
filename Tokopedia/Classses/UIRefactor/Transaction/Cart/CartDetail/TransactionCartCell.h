//
//  TransactionCartCell.h
//  Tokopedia
//
//  Created by IT Tkpd on 1/9/15.
//  Copyright (c) 2015 TOKOPEDIA. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CartModelView.h"
#import "ProductModelView.h"

#define TRANSACTION_CART_CELL_IDENTIFIER @"TransactionCartCellIdentifier"

#pragma mark - Transaction Cart Cell Delegate
@protocol TransactionCartCellDelegate <NSObject>
@required
- (void)tapMoreButtonActionAtIndexPath:(NSIndexPath*)indexPath;
- (void)didTapProductAtIndexPath:(NSIndexPath*)indexPath;
@end

@interface TransactionCartCell : UITableViewCell


@property (nonatomic, weak) IBOutlet id<TransactionCartCellDelegate> delegate;


@property (weak, nonatomic) IBOutlet UIImageView *productThumbImageView;
@property (weak, nonatomic) IBOutlet UILabel *productNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *productPriceLabel;
@property (weak, nonatomic) IBOutlet UILabel *quantityLabel;
@property (weak, nonatomic) IBOutlet UILabel *remarkLabel;
@property (strong, nonatomic) NSIndexPath *indexPath;
@property (weak, nonatomic) IBOutlet UIButton *editButton;
@property (weak, nonatomic) IBOutlet UIView *productView;
@property (weak, nonatomic) IBOutlet UILabel *errorProductLabel;

@property (weak, nonatomic) IBOutlet UIView *border;

@property (nonatomic) NSInteger indexPage;

+(id)newcell;
- (void)setViewModel:(ProductModelView*)viewModel;

@end
