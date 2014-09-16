//
//  CategoryMenuViewCell.h
//  Tokopedia
//
//  Created by IT Tkpd on 9/2/14.
//  Copyright (c) 2014 TOKOPEDIA. All rights reserved.
//

#import <UIKit/UIKit.h>

#define kTKPDCATEGORYRESULTVIEWCELL_IDENTIFIER @"CategoryResultViewCellIdentifier"

@protocol CategoryMenuViewCellDelegate <NSObject>
@required
-(void)CategoryMenuViewCell:(UITableViewCell*)cell withindexpath:(NSIndexPath*)indexpath;

@end

@interface CategoryMenuViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *label;

@property (strong,nonatomic) NSDictionary *data;

#if __IPHONE_OS_VERSION_MIN_REQUIRED >= TKPD_MINIMUMIOSVERSION
@property (nonatomic, weak) IBOutlet id<CategoryMenuViewCellDelegate> delegate;
#else
@property (nonatomic, assign) IBOutlet id<CategoryMenuViewCellDelegate> delegate;
#endif

@property (weak, nonatomic) IBOutlet UIImageView *imagenext;

+(id)newcell;

@end
