//
//  WishListViewController.h
//  Tokopedia
//
//  Created by Tokopedia on 4/8/15.
//  Copyright (c) 2015 TOKOPEDIA. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GeneralProductCell.h"
#import "TKPDTabHomeViewController.h"

@interface WishListViewController : UIViewController<UITableViewDataSource, UITableViewDelegate, GeneralProductCellDelegate>
{
    IBOutlet UITableView *tblWishList;
    IBOutlet UIView *footer, *viewNoData;
    IBOutlet UIActivityIndicatorView *activityIndicator;
}
@property (weak, nonatomic) id<TKPDTabHomeDelegate> delegate;
@end
