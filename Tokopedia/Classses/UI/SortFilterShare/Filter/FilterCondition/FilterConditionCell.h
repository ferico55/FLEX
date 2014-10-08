//
//  FilterConditionCell.h
//  Tokopedia
//
//  Created by IT Tkpd on 10/2/14.
//  Copyright (c) 2014 TOKOPEDIA. All rights reserved.
//

#import <UIKit/UIKit.h>

#define kTKPDFILTERCONDITIONCELL_IDENTIFIER @"FilterConditionCellIdentifier"

#pragma mark - Filter Location View Cell Delegate
@protocol FilterConditionCellDelegate <NSObject>
@required
-(void)FilterConditionCell:(UITableViewCell*)cell withindexpath:(NSIndexPath*)indexpath;

@end

#pragma mark - Filter Location View Cell
@interface FilterConditionCell : UITableViewCell

#if __IPHONE_OS_VERSION_MIN_REQUIRED >= TKPD_MINIMUMIOSVERSION
@property (nonatomic, weak) IBOutlet id<FilterConditionCellDelegate> delegate;
#else
@property (nonatomic, assign) IBOutlet id<FilterConditionCellDelegate> delegate;
#endif

@property (strong,nonatomic) NSDictionary *data;
@property (weak, nonatomic) IBOutlet UIImageView *imageview;
@property (weak, nonatomic) IBOutlet UILabel *label;

+(id)newcell;

@end
