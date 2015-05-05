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


@property (nonatomic, weak) IBOutlet id<FilterConditionCellDelegate> delegate;

@property (strong,nonatomic) NSDictionary *data;
@property (weak, nonatomic) IBOutlet UIImageView *imageview;
@property (weak, nonatomic) IBOutlet UILabel *label;

+(id)newcell;

@end
