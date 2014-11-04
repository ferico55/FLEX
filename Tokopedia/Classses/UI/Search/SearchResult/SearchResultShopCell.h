//
//  SearchResultShopCell.h
//  Tokopedia
//
//  Created by IT Tkpd on 9/15/14.
//  Copyright (c) 2014 TOKOPEDIA. All rights reserved.
//

#import <UIKit/UIKit.h>

#define kTKPDSEARCHRESULTSHOPCELL_IDENTIFIER @"SearchResultCellShopIdentifier"

@protocol SearchResultShopCellDelegate <NSObject>
@required
-(void)SearchResultShopCell:(UITableViewCell*)cell withindexpath:(NSIndexPath*)indexpath;

@end

@interface SearchResultShopCell : UITableViewCell

#if __IPHONE_OS_VERSION_MIN_REQUIRED >= TKPD_MINIMUMIOSVERSION
@property (nonatomic, weak) IBOutlet id<SearchResultShopCellDelegate> delegate;
#else
@property (nonatomic, assign) IBOutlet id<SearchResultShopCellDelegate> delegate;
#endif

@property (weak, nonatomic) IBOutlet UIImageView *thumb;
@property (weak, nonatomic) IBOutlet UILabel *shopname;
@property (weak, nonatomic) IBOutlet UIButton *favbutton;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *act;

@property (strong, nonatomic) NSIndexPath *indexpath;

+ (id)newcell;

@end
