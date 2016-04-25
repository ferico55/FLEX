//
//  FilterController.m
//  Tokopedia
//
//  Created by Renny Runiawati on 4/25/16.
//  Copyright © 2016 TOKOPEDIA. All rights reserved.
//

#import "FilterController.h"

@implementation FilterController{
    NSMutableArray *_listControllers;
}

-(NSMutableArray *)listController{
    if (!_listControllers) {
        _listControllers = [NSMutableArray new];
    }
    
    return _listControllers;
}

-(void)addCategoryWithType:(FilterCategoryType)type selectedCategory:(CategoryDetail*)selectedCategory categoryList:(NSArray*)categoryList{
    FilterCategoryViewController *controller = [FilterCategoryViewController new];
    controller.filterType = FilterCategoryTypeHotlist;
    controller.selectedCategory = selectedCategory;
    controller.categories = [categoryList mutableCopy];
    controller.delegate = self;
    controller.tabBarItem.title = @"Kategori";
    
    [[self listController] addObject:controller];
}

-(void)addEtalaseWithShopID:(NSString*)shopID selectedEtalase:(EtalaseList*)selectedEtalase{
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

-(void)addFilterShopWithSelectedShop:(NSString*)selectedShop{
    GeneralTableViewController *controller = [[GeneralTableViewController alloc]initWithStyle:UITableViewStylePlain];
    controller.objects = @[@"Semua Toko", @"Gold Merchant"];
    controller.selectedObject = selectedShop;
    controller.delegate = self;
    controller.tabBarItem.title = @"Toko";
    [[self listController] addObject:controller];
}

-(void)addFilterLocationWithSelectedLocation:(NSString*)selectedLocation{
    FilterLocationViewController *controller = [FilterLocationViewController new];
    controller.data = @{@"indexpath": [NSIndexPath indexPathForRow:0 inSection:0]};
    controller.tabBarItem.title = @"Lokasi";

    [[self listController]addObject:controller];
}

-(void)CreateFilterFromController:(UIViewController*)controller{
    
    MHVerticalTabBarController *tabBarController = [[MHVerticalTabBarController alloc] init];
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

@end
