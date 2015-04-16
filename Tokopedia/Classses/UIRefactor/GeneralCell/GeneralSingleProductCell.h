//
//  GeneralSingleProductCell.h
//  Tokopedia
//
//  Created by Feizal Badri Asmoro on 3/16/15.
//  Copyright (c) 2015 TOKOPEDIA. All rights reserved.
//

#import <UIKit/UIKit.h>

#define kTKPDGENERAL_SINGLE_PRODUCT_CELL_IDENTIFIER @"GeneralSingleProductCell"

@protocol GeneralSingleProductDelegate <NSObject>

-(void)didSelectCell:(UITableViewCell*)cell atIndexPath:(NSIndexPath*)indexPath;

@end

@interface GeneralSingleProductCell : UITableViewCell

@property (weak, nonatomic) id<GeneralSingleProductDelegate> delegate;
@property (weak, nonatomic) IBOutlet UIImageView *productImageView;
@property (weak, nonatomic) IBOutlet UILabel *productNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *productPriceLabel;
@property (weak, nonatomic) IBOutlet UILabel *productInfoLabel;
@property (weak, nonatomic) IBOutlet UILabel *productShopLabel;
@property (weak, nonatomic) IBOutlet UIImageView *badge;
@property (strong, nonatomic) NSIndexPath *indexPath;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *infoLabelConstraint;

+ (id)initCell;

@end
