//
//  FavoritedShopCell.h
//  Tokopedia
//
//  Created by IT Tkpd on 8/19/14.
//  Copyright (c) 2014 TOKOPEDIA. All rights reserved.
//

#define kTKPDFAVORITEDSHOPCELL_IDENTIFIER @"FavoritedShopCellIdentifier"

#import <UIKit/UIKit.h>

@protocol FavoritedShopCellDelegate <NSObject>
@required
-(void)FavoritedShopCell:(UITableViewCell*)cell withindexpath:(NSIndexPath*)indexpath withimageview:(UIImageView *)imageview;
-(void)removeFavoritedRow:(NSIndexPath*)indexpath;

@end


@interface FavoritedShopCell : UITableViewCell


@property (nonatomic, weak) IBOutlet id<FavoritedShopCellDelegate> delegate;
@property (strong,nonatomic) NSDictionary *data;

+(id)newcell;

@property (weak, nonatomic) IBOutlet UILabel *shopname;
@property (weak, nonatomic) IBOutlet UILabel *shoplocation;
@property (weak, nonatomic) IBOutlet UIImageView *shopimageview;
@property (weak, nonatomic) IBOutlet UIButton *isfavoritedshop;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *act;

@property (strong, nonatomic) NSIndexPath *indexpath;


@end
