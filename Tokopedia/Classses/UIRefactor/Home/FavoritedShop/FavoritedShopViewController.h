//
//  FavoriteShopViewController.h
//  Tokopedia
//
//  Created by Tokopedia on 10/28/14.
//  Copyright (c) 2014 TOKOPEDIA. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FavoritedShopCell.h"

@interface FavoritedShopViewController : GAITrackedViewController

@property (assign, nonatomic) NSInteger index;
@property (strong, nonatomic)NSDictionary *data;

@end
