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


@property (nonatomic, weak) IBOutlet id<AlertListViewCellDelegate> delegate;

@property (weak, nonatomic) IBOutlet UILabel *label;

@property (strong , nonatomic) NSIndexPath *indexpath;

+(id)newcell;

@end
