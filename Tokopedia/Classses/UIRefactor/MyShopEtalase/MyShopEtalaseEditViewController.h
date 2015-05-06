//
//  MyShopEtalaseEditViewController.h
//  Tokopedia
//
//  Created by IT Tkpd on 11/19/14.
//  Copyright (c) 2014 TOKOPEDIA. All rights reserved.
//

#import <UIKit/UIKit.h>
@class MyShopEtalaseEditViewController;

#pragma mark - Product Edit Wholesale Cell Delegate
@protocol MyShopEtalaseEditViewControllerDelegate <NSObject>

@optional
- (void)successEditEtalase:(NSString *)etalaseName;
- (void)MyShopEtalaseEditViewController:(MyShopEtalaseEditViewController*)viewController
                             withUserInfo:(NSDictionary*)userInfo;

@end

@interface MyShopEtalaseEditViewController : UIViewController


@property (nonatomic, weak) IBOutlet id<MyShopEtalaseEditViewControllerDelegate> delegate;


@property (nonatomic,strong)NSDictionary *data;

@end
