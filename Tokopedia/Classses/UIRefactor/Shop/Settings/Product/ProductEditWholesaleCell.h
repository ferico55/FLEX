//
//  ProductEditWholesaleCell.h
//  Tokopedia
//
//  Created by IT Tkpd on 12/11/14.
//  Copyright (c) 2014 TOKOPEDIA. All rights reserved.
//

#import <UIKit/UIKit.h>
@class ProductEditWholesaleCell;

#pragma mark - Product Edit Wholesale Cell Delegate
@protocol ProductEditWholesaleCellDelegate <NSObject>
@optional
-(void)ProductEditWholesaleCell:(ProductEditWholesaleCell*)cell withindexpath:(NSIndexPath*)indexpath;
@required
-(void)removeCell:(ProductEditWholesaleCell*)cell atIndexPath:(NSIndexPath*)indexPath;
-(void)ProductEditWholesaleCell:(ProductEditWholesaleCell*)cell textFieldShouldReturn:(UITextField *)textField withIndexPath:(NSIndexPath*)indexPath;
-(void)ProductEditWholesaleCell:(ProductEditWholesaleCell*)cell textFieldShouldEndEditing:(UITextField *)textField withIndexPath:(NSIndexPath*)indexPath;
-(void)ProductEditWholesaleCell:(ProductEditWholesaleCell*)cell textFieldShouldBeginEditing:(UITextField *)textField withIndexPath:(NSIndexPath*)indexPath;

@end

#define PRODUCT_EDIT_WHOLESALE_CELL_IDENTIFIER @"ProductEditWholesaleCellIdentifier"

@interface ProductEditWholesaleCell : UITableViewCell <UITextFieldDelegate>

#if __IPHONE_OS_VERSION_MIN_REQUIRED >= TKPD_MINIMUMIOSVERSION
@property (nonatomic, weak) IBOutlet id<ProductEditWholesaleCellDelegate> delegate;
#else
@property (nonatomic, assign) IBOutlet id<ProductEditWholesaleCellDelegate> delegate;
#endif

@property (weak, nonatomic) IBOutlet UITextField *minimumProductTextField;
@property (weak, nonatomic) IBOutlet UITextField *maximumProductTextField;
@property (weak, nonatomic) IBOutlet UILabel *productCurrencyLabel;
@property (weak, nonatomic) IBOutlet UITextField *productPriceTextField;
@property (weak, nonatomic) IBOutlet UIButton *deleteWholesaleButton;

@property (weak, nonatomic) IBOutlet UITextField *activeTextField;
@property (strong, nonatomic) IBOutlet NSIndexPath *indexPath;

+(id)newcell;

@end
