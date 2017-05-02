//
//  ProductListMyShopCell.h
//  Tokopedia
//
//  Created by IT Tkpd on 12/8/14.
//  Copyright (c) 2014 TOKOPEDIA. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MGSwipeTableCell.h"
#import "MarqueeLabel.h"

#define kTKPDSETTINGPRODUCTCELL_IDENTIFIER @"SettingProductCellIdentifier"

@interface ProductListMyShopCell : MGSwipeTableCell

@property (weak, nonatomic) IBOutlet UIImageView *thumb;
@property (weak, nonatomic) IBOutlet UILabel *labelname;
@property (weak, nonatomic) IBOutlet UILabel *labelprice;
@property (weak, nonatomic) IBOutlet UILabel *labeletalase;
@property (strong, nonatomic) NSIndexPath *indexpath;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *act;

+(id)newcell;

@end
