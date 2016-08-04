//
//  ProductEditWholesaleCell.h
//  Tokopedia
//
//  Created by IT Tkpd on 12/11/14.
//  Copyright (c) 2014 TOKOPEDIA. All rights reserved.
//

#import <UIKit/UIKit.h>

@class ProductEditResult;
@class WholesalePrice;

#define PRODUCT_EDIT_WHOLESALE_CELL_IDENTIFIER @"ProductEditWholesaleCellIdentifier"

@interface ProductEditWholesaleCell : UITableViewCell <UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UIButton *deleteWholesaleButton;

@property (strong, nonatomic) NSString *productPriceCurency;
@property WholesalePrice *wholesale;

+(id)newcell;

- (void)setRemoveWholesale:(void (^)(WholesalePrice *wholesale))removeWholesale;
- (void)setEditWholesale:(void (^)(WholesalePrice *wholesale))editWholesales;

@end
