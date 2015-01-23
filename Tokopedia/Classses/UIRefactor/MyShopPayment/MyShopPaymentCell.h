//
//  MyShopPaymentCell.h
//  Tokopedia
//
//  Created by IT Tkpd on 11/28/14.
//  Copyright (c) 2014 TOKOPEDIA. All rights reserved.
//

#import <UIKit/UIKit.h>

#define kTKPDMYSHOPPAYMENTCELL_IDENTIFIER @"MyShopPaymentCellIdentifier"

#pragma mark - Setting Payment Cell Delegate
@protocol MyShopPaymentCellDelegate <NSObject>
@required
-(void)MyShopPaymentCell:(UITableViewCell*)cell withindexpath:(NSIndexPath*)indexpath;

@end

@interface MyShopPaymentCell : UITableViewCell

#if __IPHONE_OS_VERSION_MIN_REQUIRED >= TKPD_MINIMUMIOSVERSION
@property (nonatomic, weak) IBOutlet id<MyShopPaymentCellDelegate> delegate;
#else
@property (nonatomic, assign) IBOutlet id<MyShopPaymentCellDelegate> delegate;
#endif

@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *act;
@property (weak, nonatomic) IBOutlet UIImageView *thumb;
@property (weak, nonatomic) IBOutlet UISwitch *switchpayment;
@property (weak, nonatomic) IBOutlet UILabel *labeldescription;
@property (weak, nonatomic) IBOutlet UIButton *buttonterms;
@property (strong, nonatomic) NSIndexPath *indexpath;
@property (weak, nonatomic) IBOutlet UITextView *textviewdesc;

+ (id)newcell;

@end
