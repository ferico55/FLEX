//
//  MyShopEtalaseFilterViewController.h
//  Tokopedia
//
//  Created by IT Tkpd on 10/13/14.
//  Copyright (c) 2014 TOKOPEDIA. All rights reserved.
//

#import <UIKit/UIKit.h>
@class MyShopEtalaseFilterViewController;

@protocol MyShopEtalaseFilterViewControllerDelegate <NSObject>
@required
-(void)MyShopEtalaseFilterViewController:(MyShopEtalaseFilterViewController*)viewController withUserInfo:(NSDictionary*)userInfo;

@end

@interface MyShopEtalaseFilterViewController : UIViewController


@property (nonatomic, weak) IBOutlet id<MyShopEtalaseFilterViewControllerDelegate> delegate;


@property (strong, nonatomic) NSDictionary* data;

@property NSInteger tag;

@end
