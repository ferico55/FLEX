//
//  GeneralPhotoProductCell.h
//  Tokopedia
//
//  Created by Feizal Badri Asmoro on 3/16/15.
//  Copyright (c) 2015 TOKOPEDIA. All rights reserved.
//

#import <UIKit/UIKit.h>

#define kTKPDGENERAL_PHOTO_PRODUCT_CELL_IDENTIFIER @"GeneralPhotoProductCell"

@protocol GeneralPhotoProductDelegate <NSObject>

-(void)didSelectCell:(UITableViewCell*)cell atIndexPath:(NSIndexPath*)indexPath;

@end

@interface GeneralPhotoProductCell : UITableViewCell

@property (weak, nonatomic) id<GeneralPhotoProductDelegate> delegate;
@property (strong, nonatomic) NSIndexPath *indexPath;
@property (strong, nonatomic) IBOutletCollection(UIView) NSArray *viewcell;
@property (strong, nonatomic) IBOutletCollection(UIImageView) NSArray *badges;
@property (strong, nonatomic) IBOutletCollection(UIImageView) NSArray *productImageViews;


+ (id)initCell;

@end
