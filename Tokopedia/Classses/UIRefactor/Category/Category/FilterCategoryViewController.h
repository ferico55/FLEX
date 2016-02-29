//
//  FilterCategoryViewController.h
//  Tokopedia
//
//  Created by Tokopedia on 2/10/16.
//  Copyright © 2016 TOKOPEDIA. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CategoryDetail.h"

@protocol FilterCategoryViewDelegate <NSObject>

- (void)didSelectCategory:(CategoryDetail *)category;

@end

@interface FilterCategoryViewController : UITableViewController

@property (weak, nonatomic) id<FilterCategoryViewDelegate> delegate;
@property (weak, nonatomic) CategoryDetail *selectedCategory;

@end
