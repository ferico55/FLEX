//
//  ShopProductViewCell.h
//  Tokopedia
//
//  Created by IT Tkpd on 9/2/14.
//  Copyright (c) 2014 TOKOPEDIA. All rights reserved.
//

#import <UIKit/UIKit.h>

#define kTKPDSHOPPRODUCTVIEWCELL_IDENTIFIER @"ShopProductCellIdentifier"

#pragma mark - Hotlist Result View Cell Delegate
@protocol ShopProductViewCellDelegate <NSObject>
@required
-(void)ShopProductViewCell:(UITableViewCell*)cell withindexpath:(NSIndexPath*)indexpath;

@end

#pragma mark - Hotlist Result Cell
@interface ShopProductViewCell : UITableViewCell

#if __IPHONE_OS_VERSION_MIN_REQUIRED >= TKPD_MINIMUMIOSVERSION
@property (nonatomic, weak) IBOutlet id<ShopProductViewCellDelegate> delegate;
#else
@property (nonatomic, assign) IBOutlet id<ShopProductViewCellDelegate> delegate;
#endif

@property (strong, nonatomic) IBOutletCollection(UIView) NSArray *viewcell;
@property (strong, nonatomic) IBOutletCollection(UIActivityIndicatorView) NSArray *act;
@property (strong, nonatomic) IBOutletCollection(UIImageView) NSArray *thumb;
@property (strong, nonatomic) IBOutletCollection(UILabel) NSArray *labelprice;
@property (strong, nonatomic) IBOutletCollection(UILabel) NSArray *labeldescription;
@property (strong, nonatomic) IBOutletCollection(UILabel) NSArray *labelalbum;

@property (strong,nonatomic) NSDictionary *data;
@property (strong, nonatomic) NSIndexPath *indexpath;

+(id)newcell;

@end
