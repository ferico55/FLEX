//
//  ReputationCell.h
//  Tokopedia
//
//  Created by Tokopedia on 3/2/15.
//  Copyright (c) 2015 TOKOPEDIA. All rights reserved.
//

#import <UIKit/UIKit.h>

#pragma mark - ReputationCell Delegate
@protocol ReputationCellDelegate <NSObject>

@required
-(void)ReputationCell:(UITableViewCell*)cell withindexpath:(NSIndexPath*)indexpath;

@end

@interface ReputationCell : UITableViewCell

#if __IPHONE_OS_VERSION_MIN_REQUIRED >= TKPD_MINIMUMIOSVERSION
@property (nonatomic, weak) IBOutlet id<ReputationCellDelegate> delegate;
#else
@property (nonatomic, assign) IBOutlet id<ReputationCellDelegate> delegate;
#endif

@property (strong, nonatomic) NSIndexPath *indexpath;
@property (strong, nonatomic) IBOutlet UILabel *productLabel;

+(id)newcell;

@end
