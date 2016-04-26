//
//  FilterController.m
//  Tokopedia
//
//  Created by Renny Runiawati on 4/25/16.
//  Copyright © 2016 TOKOPEDIA. All rights reserved.
//

#import "FilterController.h"
#import "DBManager.h"

typedef void (^completion)(QueryObject *query);

@implementation FilterController{
    NSMutableArray *_listControllers;
    QueryObject *_query;
}

static completion onCompletion;

-(NSMutableArray *)listController{
    if (!_listControllers) {
        _listControllers = [NSMutableArray new];
    }
    
    return _listControllers;
}

-(QueryObject*)query{
    if (!_query) {
        _query = [QueryObject new];
    }
    
    return _query;
}

-(void)addCategoryWithType:(FilterCategoryType)type selectedCategory:(CategoryDetail*)selectedCategory categoryList:(NSArray*)categoryList{
    [self query].selectedCategory = selectedCategory;
    FilterCategoryViewController *controller = [FilterCategoryViewController new];
    controller.filterType = FilterCategoryTypeHotlist;
    controller.selectedCategory = selectedCategory;
    controller.categories = [categoryList mutableCopy];
    controller.delegate = self;
    controller.tabBarItem.title = @"Kategori";
    
    [[self listController] addObject:controller];
}

-(void)addEtalaseWithShopID:(NSString*)shopID selectedEtalase:(EtalaseList*)selectedEtalase{
    [self query].selectedEtalase = selectedEtalase;
    EtalaseViewController *controller = [EtalaseViewController new];
    controller.delegate = self;
    controller.shopId = shopID;
    controller.isEditable = NO;
    controller.showOtherEtalase = NO;
    controller.enableAddEtalase = NO;
    controller.tabBarItem.title = @"Etalase";
    [controller setInitialSelectedEtalase:selectedEtalase];
    
    [[self listController] addObject:controller];
}

-(void)addFilterShopWithSelectedShop:(FilterObject*)selectedShop{
    [self query].selectedShop = selectedShop;
    FilterTableViewController *controller = [FilterTableViewController new];
    
    NSMutableArray *items = [NSMutableArray new];
    FilterObject *object1 = [FilterObject new];
    object1.title = @"Semua Toko";
    object1.filterID = @"0";
    [items addObject:object1];
    FilterObject *object2 = [FilterObject new];
    object2.title = @"Gold Merchant";
    object2.filterID = @"2";
    [items addObject:object2];
    
    [controller createTableView:[items copy]
                 selectedObject:selectedShop
                   onCompletion:^(FilterObject * selectedObject) {
                       [self query].selectedShop = selectedObject;
    }];
    
    controller.tabBarItem.title = @"Toko";
    [[self listController] addObject:controller];
}

-(void)addFilterLocationWithSelectedLocation:(FilterObject*)selectedLocation{
    [self query].selectedLocation = selectedLocation;

    NSMutableArray *name = [NSMutableArray new];
    [name addObject:@"All Location"];
    [name addObjectsFromArray:@[@"Jabodetabek"]];
    [name addObjectsFromArray: [[DBManager getSharedInstance]LoadDataQueryLocationName:[NSString stringWithFormat:@"select d.district_name from ws_district d WHERE d.district_id IN (select distinct d.district_id from ws_shipping_city sc LEFT JOIN ws_district d ON sc.district_id = d.district_id order by d.district_name) order by d.district_name"]]];
    
    NSMutableArray *value = [NSMutableArray new];
    [value addObject:@"0"];
    [value addObjectsFromArray:@[@"2210,2228,5573,1940,1640,2197"]];
    [value addObjectsFromArray: [[DBManager getSharedInstance]LoadDataQueryLocationValue:[NSString stringWithFormat:@"select distinct sc.district_id from ws_shipping_city sc, ws_district d where sc.district_id = d.district_id order by d.district_name"]]];
    
    NSMutableArray<FilterObject*> *items = [NSMutableArray new];
    for (int i=0 ; i< name.count; i++) {
        FilterObject *object = [FilterObject new];
        object.title = name[i];
        object.filterID = value[i];
        [items addObject:object];
    }
    
    FilterTableViewController *controller = [FilterTableViewController new];
    [controller createTableView:[items copy]
                 selectedObject:selectedLocation?:items[0]
                   onCompletion:^(FilterObject * selectedObject) {
                       [self query].selectedLocation = selectedObject;
                   }];
    
    controller.tabBarItem.title = @"Lokasi";

    [[self listController]addObject:controller];
}

-(void)addFilterPrice:(FilterObject*)filter {
    FilterPriceViewController *controller = [FilterPriceViewController new];
    [controller createFilterPrice:filter onCompletion:^(FilterObject * filter) {
        [self query].selectedPrice = filter;
    }];
    controller.tabBarItem.title = @"Harga";
    
    [[self listController]addObject:controller];
}

-(void)addFilterConditionWithSelectedCondition:(FilterObject*)selectedCondition{
    [self query].selectedCondition = selectedCondition;
    FilterTableViewController *controller = [FilterTableViewController new];
    
    NSMutableArray *items = [NSMutableArray new];
    FilterObject *object1 = [FilterObject new];
    object1.title = @"Semua Kondisi";
    object1.filterID = @"0";
    [items addObject:object1];
    FilterObject *object2 = [FilterObject new];
    object2.title = @"Baru";
    object2.filterID = @"1";
    [items addObject:object2];
    FilterObject *object3 = [FilterObject new];
    object3.title = @"Bekas";
    object3.filterID = @"2";
    [items addObject:object3];
    
    [controller createTableView:[items copy]
                 selectedObject:selectedCondition
                   onCompletion:^(FilterObject * selectedObject) {
                       [self query].selectedCondition = selectedObject;
                   }];
    
    controller.tabBarItem.title = @"Kondisi";
    [[self listController] addObject:controller];
}

-(void)createFilterFromController:(UIViewController*)controller completion:(void (^)(QueryObject *))completion{
    onCompletion = completion;
    MHVerticalTabBarController *tabBarController = [[MHVerticalTabBarController alloc] init];
    tabBarController.delegate = self;
    tabBarController.title = @"Filter";
    tabBarController.viewControllers = [self listController];
    
    // turn off selection animation
    //    self.tabBarController.tabBar.animationDuration = 0.0;
    
    // set the width
    tabBarController.tabBarWidth = 120.0;
    tabBarController.tabBarItemHeight = 44.0;
    UINavigationController *nav = [[UINavigationController alloc]initWithRootViewController:tabBarController];
    nav.navigationBar.translucent = NO;
    controller.navigationController.navigationBar.alpha = 0;
    [controller.navigationController presentViewController:nav animated:YES completion:nil];
}

- (void)done{
    onCompletion([self query]);
}

- (void)didSelectCategoryFilter:(CategoryDetail *)category{
    [self query].selectedCategory = category;
}

-(void)didSelectEtalaseFilter:(EtalaseList *)selectedEtalase{
    [self query].selectedEtalase = selectedEtalase;
}

-(void)didSelectLocationFilter:(FilterObject *)selectedLocation{
    [self query].selectedLocation = selectedLocation;
}

@end
