//
//  SearchResultShopCell.h
//  Tokopedia
//
//  Created by IT Tkpd on 9/15/14.
//  Copyright (c) 2014 TOKOPEDIA. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Tokopedia-Swift.h"

#define kTKPDSEARCHRESULTSHOPCELL_IDENTIFIER @"SearchResultCellShopIdentifier"

@protocol SearchResultShopCellDelegate <NSObject>
@required
-(void)SearchResultShopCell:(UITableViewCell*)cell withindexpath:(NSIndexPath*)indexpath;

@end

@interface SearchResultShopCell : UITableViewCell


@property (nonatomic, weak) id<SearchResultShopCellDelegate> delegate;


@property (weak, nonatomic) IBOutlet UIImageView *shopImage;
@property (weak, nonatomic) IBOutlet UILabel *shopName;
@property (weak, nonatomic) IBOutlet UILabel *shopLocation;
@property (weak, nonatomic) IBOutlet UIImageView *goldBadgeView;

@property (weak, nonatomic) SearchShopModelView* modelView;

@property (strong, nonatomic) NSIndexPath *indexpath;


+ (id)newcell;

@end
