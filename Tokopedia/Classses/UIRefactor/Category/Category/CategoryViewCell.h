//
//  CategoryViewCell.h
//  Tokopedia
//
//  Created by IT Tkpd on 8/27/14.
//  Copyright (c) 2014 TOKOPEDIA. All rights reserved.
//

#import <UIKit/UIKit.h>
#define kTKPDCATEGORYVIEWCELL_IDENTIFIER @"CategoryViewCellIdentifier"

@protocol CategoryViewCellDelegate <NSObject>
@required
-(void)CategoryViewCellDelegateCell:(UITableViewCell *)cell withindexpath:(NSIndexPath *)indexpath;

@end

@interface CategoryViewCell : UITableViewCell

@property (nonatomic, weak) IBOutlet id<CategoryViewCellDelegate> delegate;

@property (strong,nonatomic) NSDictionary *data;

+(id)newcell;
-(void)reset;

@end
