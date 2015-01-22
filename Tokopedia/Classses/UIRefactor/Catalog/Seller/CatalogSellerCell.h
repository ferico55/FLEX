//
//  CatalogSellerCell.h
//  Tokopedia
//
//  Created by IT Tkpd on 10/1/14.
//  Copyright (c) 2014 TOKOPEDIA. All rights reserved.
//

#import <UIKit/UIKit.h>

#define kTKPDCATALOGSELLERCELL_IDENTIFIER @"CatalogSellerCellIdentifier"

@protocol CatalogSellerCellDelegate <NSObject>
@required
-(void)CatalogSellerCell:(UITableViewCell*)cell;

@end

@interface CatalogSellerCell : UITableViewCell

#if __IPHONE_OS_VERSION_MIN_REQUIRED >= TKPD_MINIMUMIOSVERSION
@property (nonatomic, weak) IBOutlet id<CatalogSellerCellDelegate> delegate;
#else
@property (nonatomic, assign) IBOutlet id<CatalogSellerCellDelegate> delegate;
#endif

@property (weak, nonatomic) IBOutlet UIImageView *thumb;
@property (weak, nonatomic) IBOutlet UILabel *namelabel;
@property (weak, nonatomic) IBOutlet UILabel *conditionlabel;
@property (weak, nonatomic) IBOutlet UILabel *pricelabel;
@property (nonatomic) NSInteger product_id;

@property (weak, nonatomic) IBOutlet UIButton *buybutton;

+ (id)newcell;

@end
