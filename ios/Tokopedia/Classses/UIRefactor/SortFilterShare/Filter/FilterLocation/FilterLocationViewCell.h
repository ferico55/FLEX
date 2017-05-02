//
//  FilterLocationViewCell.h
//  Tokopedia
//
//  Created by IT Tkpd on 9/5/14.
//  Copyright (c) 2014 TOKOPEDIA. All rights reserved.
//

#import <UIKit/UIKit.h>

#define kTKPDFILTERLOCATIONVIEWCELL_IDENTIFIER @"FilterLocationViewCellIdentifier"

#pragma mark - Filter Location View Cell Delegate
@protocol FilterLocationViewCellDelegate <NSObject>
@required
-(void)FilterLocationViewCell:(UITableViewCell*)cell withindexpath:(NSIndexPath*)indexpath;

@end

#pragma mark - Filter Location View Cell
@interface FilterLocationViewCell : UITableViewCell

@property (nonatomic, weak) IBOutlet id<FilterLocationViewCellDelegate> delegate;


@property (strong,nonatomic) NSDictionary *data;
@property (weak, nonatomic) IBOutlet UIImageView *imageview;

+(id)newcell;

@property (weak, nonatomic) IBOutlet UILabel *label;

@end
