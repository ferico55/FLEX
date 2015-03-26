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
@property (strong, nonatomic) NSIndexPath *indexPath;

+ (id)initCell;

@end
