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
#import "Tokopedia-Swift.h"

@interface FilterController : NSObject <FilterCategoryViewDelegate, EtalaseViewControllerDelegate, MHVerticalTabBarControllerDelegate, FilterLocationViewControllerDelegate>

-(void)addCategoryWithType:(FilterCategoryType)type selectedCategory:(CategoryDetail*)selectedCategory categoryList:(NSArray*)categoryList;
-(void)addEtalaseWithShopID:(NSString*)shopID selectedEtalase:(EtalaseList*)selectedEtalase;
-(void)addFilterShopWithSelectedShop:(FilterObject*)selectedShop;
-(void)addFilterLocationWithSelectedLocation:(FilterObject*)selectedLocation;
-(void)addFilterPrice:(FilterObject*)filter;
-(void)addFilterConditionWithSelectedCondition:(FilterObject*)selectedCondition;

-(void)createFilterFromController:(UIViewController*)controller completion:(void (^)(QueryObject *))completion;

@end
