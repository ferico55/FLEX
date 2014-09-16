//
//  CategoryViewCell.h
//  Tokopedia
//
//  Created by IT Tkpd on 8/27/14.
//  Copyright (c) 2014 TOKOPEDIA. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol CategoryViewCellDelegate <NSObject>
@required
-(void)CategoryViewCellDelegateCell:(UITableViewCell *)cell withindexpath:(NSIndexPath *)indexpath;

@end

@interface CategoryViewCell : UITableViewCell

#if __IPHONE_OS_VERSION_MIN_REQUIRED >= TKPD_MINIMUMIOSVERSION
@property (nonatomic, weak) IBOutlet id<CategoryViewCellDelegate> delegate;
#else
@property (nonatomic, assign) IBOutlet id<CategoryViewCellDelegate> delegate;
#endif


@property (strong,nonatomic) NSDictionary *data;

+(id)newcell;

@end
