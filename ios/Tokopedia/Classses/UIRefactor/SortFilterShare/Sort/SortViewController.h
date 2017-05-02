//
//  SortViewController.h
//  Tokopedia
//
//  Created by IT Tkpd on 9/17/14.
//  Copyright (c) 2014 TOKOPEDIA. All rights reserved.
//

#import <UIKit/UIKit.h>

@class SortViewController;

typedef NS_ENUM(NSInteger, SortType) {
    SortDefault,
    SortCondition,
    SortHotlistDetail,
    SortProductSearch,
    SortCatalogSearch,
    SortCatalogDetailSeach,
    SortShopSearch,
    SortProductShopSearch,
    SortManageProduct,
    SortImageSearch
};

@protocol SortViewControllerDelegate <NSObject>

- (void)didSelectSort:(NSString *)sort atIndexPath:(NSIndexPath *)indexPath;

@end

@interface SortViewController : UITableViewController

@property (nonatomic, weak) id<SortViewControllerDelegate> delegate;
@property SortType sortType;
@property (nonatomic, strong) NSIndexPath *selectedIndexPath;

@end
