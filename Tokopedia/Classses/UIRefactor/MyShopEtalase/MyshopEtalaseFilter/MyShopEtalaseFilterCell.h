//
//  MyShopEtalaseFilterCell.h
//  Tokopedia
//
//  Created by IT Tkpd on 10/13/14.
//  Copyright (c) 2014 TOKOPEDIA. All rights reserved.
//

#define kTKPDMYSHOPETALASEFILTER_IDENTIFIER @"MyShopEtalaseCellIdentifier"

#import <UIKit/UIKit.h>

@protocol MyShopEtalaseFilterCellDelegate <NSObject>
@required
-(void)MyShopEtalaseFilterCell:(UITableViewCell*)cell withindexpath:(NSIndexPath*)indexpath;

@end


@interface MyShopEtalaseFilterCell : UITableViewCell


@property (nonatomic, weak) IBOutlet id<MyShopEtalaseFilterCellDelegate> delegate;

@property (weak, nonatomic) IBOutlet UILabel *label;
@property (weak, nonatomic) IBOutlet UIImageView *imageview;
@property (strong, nonatomic) NSIndexPath *indexpath;

+(id)newcell;

@end
