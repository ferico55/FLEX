//
//  FilterCategoryViewController.h
//  Tokopedia
//
//  Created by Tokopedia on 2/10/16.
//  Copyright © 2016 TOKOPEDIA. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Tokopedia-Swift.h"

typedef NS_ENUM(NSInteger, FilterCategoryType) {
    FilterCategoryTypeHotlist,
    FilterCategoryTypeCategory,
    FilterCategoryTypeSearchProduct,
    FilterCategoryTypeProductAddEdit,
};

@protocol FilterCategoryViewDelegate <NSObject>

@optional
- (void)didSelectCategory:(CategoryDetail *)category;
- (void)didSelectCategoryFilter:(CategoryDetail *)category;

@end

@interface FilterCategoryViewController : UITableViewController

@property (strong, nonatomic) NSMutableArray *categories;
@property (weak, nonatomic) CategoryDetail *selectedCategory;
@property (weak, nonatomic) id<FilterCategoryViewDelegate> delegate;
@property FilterCategoryType filterType;

-(void)resetSelectedFilter;

@end
