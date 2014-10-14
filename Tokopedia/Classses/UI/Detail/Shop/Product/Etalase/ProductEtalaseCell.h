//
//  ProductEtalaseCell.h
//  Tokopedia
//
//  Created by IT Tkpd on 10/13/14.
//  Copyright (c) 2014 TOKOPEDIA. All rights reserved.
//

#define kTKPDPRODUCTETALASECELL_IDENTIFIER @"SortCellIdentifier"

#import <UIKit/UIKit.h>

@protocol ProductEtalaseCellDelegate <NSObject>
@required
-(void)ProductEtalaseCell:(UITableViewCell*)cell withindexpath:(NSIndexPath*)indexpath;

@end


@interface ProductEtalaseCell : UITableViewCell

#if __IPHONE_OS_VERSION_MIN_REQUIRED >= TKPD_MINIMUMIOSVERSION
@property (nonatomic, weak) IBOutlet id<ProductEtalaseCellDelegate> delegate;
#else
@property (nonatomic, assign) IBOutlet id<ProductEtalaseCellDelegate> delegate;
#endif

@property (weak, nonatomic) IBOutlet UILabel *label;
@property (weak, nonatomic) IBOutlet UIImageView *imageview;
@property (strong, nonatomic) NSIndexPath *indexpath;

+(id)newcell;

@end
