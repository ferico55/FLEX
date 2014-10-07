//
//  ShopInfoPaymentCell.h
//  Tokopedia
//
//  Created by IT Tkpd on 10/6/14.
//  Copyright (c) 2014 TOKOPEDIA. All rights reserved.
//

#import <UIKit/UIKit.h>

#define kTKPDSHOPINFOPAYMENTCELL_IDENTIFIER @"ShopInfoPaymentCellIdentifier"

@interface ShopInfoPaymentCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIImageView *image;
@property (weak, nonatomic) IBOutlet UILabel *labelpayment;

+(id)newcell;

@end
