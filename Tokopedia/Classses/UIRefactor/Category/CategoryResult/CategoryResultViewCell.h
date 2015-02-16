//
//  CategoryResultViewCell.h
//  Tokopedia
//
//  Created by IT Tkpd on 9/2/14.
//  Copyright (c) 2014 TOKOPEDIA. All rights reserved.
//

#import <UIKit/UIKit.h>

#define kTKPDCATEGORYRESULTVIEWCELL_IDENTIFIER @"CategoryResultViewCellIdentifier"

@protocol CategoryResultViewCellDelegate <NSObject>
@required
-(void)CategoryResultViewCell:(UITableViewCell*)cell withindexpath:(NSIndexPath*)indexpath withdata:(NSDictionary*)data;

@end

@interface CategoryResultViewCell : UITableViewCell

#if __IPHONE_OS_VERSION_MIN_REQUIRED >= TKPD_MINIMUMIOSVERSION
@property (nonatomic, weak) IBOutlet id<CategoryResultViewCellDelegate> delegate;
#else
@property (nonatomic, assign) IBOutlet id<CategoryResultViewCellDelegate> delegate;
#endif

@property (strong, nonatomic) IBOutletCollection(UIView) NSArray *viewcell;

@property (strong, nonatomic) IBOutletCollection(UIImageView) NSArray *thumb;
@property (strong, nonatomic) IBOutletCollection(UILabel) NSArray *labelprice;
@property (strong, nonatomic) IBOutletCollection(UILabel) NSArray *labeldescription;
@property (strong, nonatomic) IBOutletCollection(UILabel) NSArray *labelalbum;

@property (strong,nonatomic) NSDictionary *data;

+(id)newcell;

@end
