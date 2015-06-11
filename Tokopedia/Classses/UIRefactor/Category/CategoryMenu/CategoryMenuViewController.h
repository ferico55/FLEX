//
//  CategoryMenuViewController.h
//  Tokopedia
//
//  Created by IT Tkpd on 9/2/14.
//  Copyright (c) 2014 TOKOPEDIA. All rights reserved.
//

#import <UIKit/UIKit.h>
@class CategoryMenuViewController;

@protocol CategoryMenuViewDelegate <NSObject>
@optional
-(void)CategoryMenuViewController:(CategoryMenuViewController *)viewController userInfo:(NSDictionary*)userInfo;

@end

@interface CategoryMenuViewController : UIViewController


@property (nonatomic, weak) IBOutlet id<CategoryMenuViewDelegate> delegate;

@property (strong,nonatomic)NSDictionary *data;
@property (nonatomic) NSInteger selectedCategoryID;
@property (nonatomic, strong) NSString *selectedCategoryName;

@end
