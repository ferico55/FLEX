//
//  GeneralProductCell.h
//  Tokopedia
//
//  Created by IT Tkpd on 9/2/14.
//  Copyright (c) 2014 TOKOPEDIA. All rights reserved.
//

#import <UIKit/UIKit.h>

#define kTKPDGENERALPRODUCTCELL_IDENTIFIER @"GeneralProductCellIdentifier"

#pragma mark - Hotlist Result  Cell Delegate
@protocol GeneralProductCellDelegate <NSObject>

- (void)didSelectCell:(UITableViewCell*)cell atIndexPath:(NSIndexPath*)indexPath;

@end

#pragma mark - Hotlist Result Cell
@interface GeneralProductCell : UITableViewCell

#if __IPHONE_OS_VERSION_MIN_REQUIRED >= TKPD_MINIMUMIOSVERSION
@property (nonatomic, weak) IBOutlet id<GeneralProductCellDelegate> delegate;
#else
@property (nonatomic, assign) IBOutlet id<GeneralProductCellDelegate> delegate;
#endif

@property (strong, nonatomic) IBOutletCollection(UIView) NSArray *viewcell;
@property (strong, nonatomic) IBOutletCollection(UIImageView) NSArray *thumb;
@property (strong, nonatomic) IBOutletCollection(UILabel) NSArray *labelprice;
@property (strong, nonatomic) IBOutletCollection(UILabel) NSArray *labeldescription;
@property (strong, nonatomic) IBOutletCollection(UILabel) NSArray *labelalbum;
@property (strong, nonatomic) IBOutletCollection(UIImageView) NSArray *isGoldShop;

@property (strong,nonatomic) NSDictionary *data;
@property (strong, nonatomic) NSIndexPath *indexpath;

+(id)newcell;

@end
