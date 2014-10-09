//
//  AlertListViewCell.h
//  Tokopedia
//
//  Created by IT Tkpd on 10/8/14.
//  Copyright (c) 2014 TOKOPEDIA. All rights reserved.
//

#import <UIKit/UIKit.h>
#define kTKPDALERTLISTVIEWCELL_IDENTIFIER @"AlertListViewCellIdentifier"

@protocol AlertListViewCellDelegate <NSObject>
@required
- (void)dismissAlertWithIndex:(NSInteger)index;

@end

@interface AlertListViewCell : UITableViewCell

#if __IPHONE_OS_VERSION_MIN_REQUIRED >= TKPD_MINIMUMIOSVERSION
@property (nonatomic, weak) IBOutlet id<AlertListViewCellDelegate> delegate;
#else
@property (nonatomic, assign) IBOutlet id<AlertListViewCellDelegate> delegate;
#endif

@property (weak, nonatomic) IBOutlet UILabel *label;

@property (strong , nonatomic) NSIndexPath *indexpath;

+(id)newcell;

@end
