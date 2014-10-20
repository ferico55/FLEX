//
//  ShopFavoritedCell.h
//  Tokopedia
//
//  Created by IT Tkpd on 10/15/14.
//  Copyright (c) 2014 TOKOPEDIA. All rights reserved.
//

#import <UIKit/UIKit.h>

#define kTKPDSHOPFAVORITEDCELL_IDENTIFIER @"ShopFavoritedCellIdentifier"

@protocol ShopFavoritedCellDelegate <NSObject>
@required
-(void)ShopFavoritedCellDelegate:(UITableViewCell*)cell withindexpath:(NSIndexPath*)indexpath;

@end

@interface ShopFavoritedCell : UITableViewCell

#if __IPHONE_OS_VERSION_MIN_REQUIRED >= TKPD_MINIMUMIOSVERSION
@property (nonatomic, weak) IBOutlet id<ShopFavoritedCellDelegate> delegate;
#else
@property (nonatomic, assign) IBOutlet id<ShopFavoritedCellDelegate> delegate;
#endif

@property (weak, nonatomic) IBOutlet UIImageView *thumb;
@property (weak, nonatomic) IBOutlet UILabel *label;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *act;

@property (strong, nonatomic) NSIndexPath *indexpath;

+ (id)newcell;


@end
