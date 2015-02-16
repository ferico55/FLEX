//
//  FavoriteShopViewController.h
//  Tokopedia
//
//  Created by Tokopedia on 10/28/14.
//  Copyright (c) 2014 TOKOPEDIA. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FavoritedShopCell.h"
#import "TKPDTabHomeViewController.h"

@interface FavoritedShopViewController : UIViewController

@property (assign, nonatomic) NSInteger index;
@property (strong, nonatomic)NSDictionary *data;
@property (weak, nonatomic) id<TKPDTabHomeDelegate> delegate;

@end
