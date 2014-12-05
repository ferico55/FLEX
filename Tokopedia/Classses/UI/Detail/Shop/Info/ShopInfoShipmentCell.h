//
//  ShopInfoShipmentCell.h
//  Tokopedia
//
//  Created by IT Tkpd on 10/6/14.
//  Copyright (c) 2014 TOKOPEDIA. All rights reserved.
//

#define kTKPDSHOPINFOSHIPMENTCELL_IDENTIFIER @"ShopInfoShipmentCellIdentifier"

#import <UIKit/UIKit.h>

@interface ShopInfoShipmentCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *labelshipment;
@property (weak, nonatomic) IBOutlet UILabel *packageLabel;

+(id)newcell;

@end
