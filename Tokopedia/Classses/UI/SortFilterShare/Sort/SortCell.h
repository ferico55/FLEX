//
//  SortCell.h
//  Tokopedia
//
//  Created by IT Tkpd on 9/17/14.
//  Copyright (c) 2014 TOKOPEDIA. All rights reserved.
//

#define kTKPDSORTCELL_IDENTIFIER @"SortCellIdentifier"

#import <UIKit/UIKit.h>

@protocol SortCellDelegate <NSObject>
@required
-(void)SortCell:(UITableViewCell*)cell withindexpath:(NSIndexPath*)indexpath;

@end


@interface SortCell : UITableViewCell

#if __IPHONE_OS_VERSION_MIN_REQUIRED >= TKPD_MINIMUMIOSVERSION
@property (nonatomic, weak) IBOutlet id<SortCellDelegate> delegate;
#else
@property (nonatomic, assign) IBOutlet id<SortCellDelegate> delegate;
#endif

@property (strong,nonatomic) NSDictionary *data;

@property (weak, nonatomic) IBOutlet UILabel *label;
@property (weak, nonatomic) IBOutlet UIImageView *imageview;


+(id)newcell;

@end
