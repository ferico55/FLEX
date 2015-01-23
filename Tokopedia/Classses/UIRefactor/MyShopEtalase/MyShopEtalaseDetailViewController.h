//
//  MyShopEtalaseDetailViewController.h
//  Tokopedia
//
//  Created by IT Tkpd on 11/18/14.
//  Copyright (c) 2014 TOKOPEDIA. All rights reserved.
//

#import <UIKit/UIKit.h>

#pragma mark - Setting Etalase Detail View Controller Delegate
@protocol MyShopEtalaseDetailViewControllerDelegate <NSObject>
@required
-(void)DidTapButton:(UIButton*)button withdata:(NSDictionary*)data;
@end

@interface MyShopEtalaseDetailViewController : UIViewController

#if __IPHONE_OS_VERSION_MIN_REQUIRED >= TKPD_MINIMUMIOSVERSION
@property (nonatomic, weak) IBOutlet id<MyShopEtalaseDetailViewControllerDelegate> delegate;
#else
@property (nonatomic, assign) IBOutlet id<MyShopEtalaseDetailViewControllerDelegate> delegate;
#endif

@property (nonatomic, strong)NSDictionary *data;

@end
