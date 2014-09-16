//
//  ProdukFeedViewCell.h
//  Tokopedia
//
//  Created by IT Tkpd on 8/27/14.
//  Copyright (c) 2014 TOKOPEDIA. All rights reserved.
//

#import <UIKit/UIKit.h>

#define kTKPDPRODUKFEEDCELL_IDENTIFIER @"ProdukFeedCellIdentifier"

@protocol ProductFeedViewCellDelegate <NSObject>
@required
-(void)ProductFeedViewCell:(UITableViewCell*)cell withindexpath:(NSIndexPath*)indexpath withdata:(NSDictionary*)data;

@end


@interface ProductFeedViewCell : UITableViewCell

#if __IPHONE_OS_VERSION_MIN_REQUIRED >= TKPD_MINIMUMIOSVERSION
@property (nonatomic, weak) IBOutlet id<ProductFeedViewCellDelegate> delegate;
#else
@property (nonatomic, assign) IBOutlet id<ProductFeedViewCellDelegate> delegate;
#endif

@property (strong,nonatomic) NSDictionary *data;

+(id)newcell;

@end