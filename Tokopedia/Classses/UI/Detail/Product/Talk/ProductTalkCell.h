//
//  ProductTalkCell.h
//  Tokopedia
//
//  Created by IT Tkpd on 9/29/14.
//  Copyright (c) 2014 TOKOPEDIA. All rights reserved.
//

#import <UIKit/UIKit.h>

#define kTKPDPRODUCTTALKCELLIDENTIFIER @"ProductTalkCellIdentifier"

#pragma mark - Hotlist Result  Cell Delegate
@protocol ProductTalkCellDelegate <NSObject>
@required
-(void)ProductTalkCell:(UITableViewCell*)cell withindexpath:(NSIndexPath*)indexpath;

@end

@interface ProductTalkCell : UITableViewCell

#if __IPHONE_OS_VERSION_MIN_REQUIRED >= TKPD_MINIMUMIOSVERSION
@property (nonatomic, weak) IBOutlet id<ProductTalkCellDelegate> delegate;
#else
@property (nonatomic, assign) IBOutlet id<ProductTalkCellDeletgate> delegate;
#endif

@property (weak, nonatomic) IBOutlet UIImageView *thumb;
@property (weak, nonatomic) IBOutlet UILabel *namelabel;
@property (weak, nonatomic) IBOutlet UILabel *timelabel;
@property (weak, nonatomic) IBOutlet UILabel *commentlabel;
@property (weak, nonatomic) IBOutlet UIButton *commentbutton;

@property (strong,nonatomic) NSDictionary *data;
@property (strong, nonatomic) NSIndexPath *indexpath;

+(id)newcell;

@end
