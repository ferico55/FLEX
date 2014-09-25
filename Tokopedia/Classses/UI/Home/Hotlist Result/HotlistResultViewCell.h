//
//  HotlistResultViewCell.h
//  Tokopedia
//
//  Created by IT Tkpd on 9/2/14.
//  Copyright (c) 2014 TOKOPEDIA. All rights reserved.
//

#import <UIKit/UIKit.h>

#define kTKPDHOTLISTRESULTVIEWCELL_IDENTIFIER @"HotlistResultCellIdentifier"

#pragma mark - Hotlist Result View Cell Delegate
@protocol HotlistResultViewCellDelegate <NSObject>
@required
-(void)HotlistResultViewCell:(UITableViewCell*)cell withindexpath:(NSIndexPath*)indexpath;

@end

#pragma mark - Hotlist Result Cell
@interface HotlistResultViewCell : UITableViewCell

#if __IPHONE_OS_VERSION_MIN_REQUIRED >= TKPD_MINIMUMIOSVERSION
@property (nonatomic, weak) IBOutlet id<HotlistResultViewCellDelegate> delegate;
#else
@property (nonatomic, assign) IBOutlet id<HotlistResultViewCellDelegate> delegate;
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
