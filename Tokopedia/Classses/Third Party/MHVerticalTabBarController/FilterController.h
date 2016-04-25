//
//  FilterController.h
//  Tokopedia
//
//  Created by Renny Runiawati on 4/25/16.
//  Copyright © 2016 TOKOPEDIA. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "FilterCategoryViewController.h"
#import "EtalaseViewController.h"
#import "MHVerticalTabBarController.h"
#import "FilterLocationViewController.h"
#import "GeneralTableViewController.h"

@interface FilterController : NSObject

-(void)addCategoryWithType:(FilterCategoryType)type selectedCategory:(CategoryDetail*)selectedCategory categoryList:(NSArray*)categoryList;
-(void)addEtalaseWithShopID:(NSString*)shopID selectedEtalase:(EtalaseList*)selectedEtalase;
-(void)addFilterShopWithSelectedShop:(NSString*)selectedShop;
-(void)addFilterLocationWithSelectedLocation:(NSString*)selectedLocation;

-(void)CreateFilterFromController:(UIViewController*)controller;

@end
