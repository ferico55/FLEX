//
//  CategoryResultViewController.h
//  Tokopedia
//
//  Created by IT Tkpd on 8/28/14.
//  Copyright (c) 2014 TOKOPEDIA. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TKPDTabNavigationController.h"

@protocol CategoryResultDelegate <NSObject>

- (void)pushViewController:(id)viewController animated:(BOOL)animated;
- (void)updateTabCategory:(CategoryDetail *)category;
- (void)updateCategories:(NSArray *)categories;

@end

#pragma mark - Search Result View Controller

@interface CategoryResultViewController : GAITrackedViewController

@property (strong,nonatomic) NSDictionary *data;
@property (strong,nonatomic) NSDictionary* imageQueryInfo;
@property (strong,nonatomic) NSString* image_url;
@property (nonatomic) BOOL isFromImageSearch;
@property (nonatomic) BOOL isFromAutoComplete;
@property (nonatomic) BOOL isFromDirectory;
@property (weak, nonatomic) id<CategoryResultDelegate> delegate;
@property (strong, nonatomic) IBOutlet UIView *fourButtonsToolbar;
@property (strong, nonatomic) IBOutlet UIView *threeButtonsToolbar;
@property (weak, nonatomic) TKPDTabNavigationController *tkpdTabNavigationController;

@end
