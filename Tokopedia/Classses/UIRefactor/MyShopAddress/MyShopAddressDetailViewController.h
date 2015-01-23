//
//  MyShopAddressDetailViewController.h
//  Tokopedia
//
//  Created by IT Tkpd on 11/21/14.
//  Copyright (c) 2014 TOKOPEDIA. All rights reserved.
//

#import <UIKit/UIKit.h>

#pragma mark - Setting Location Detail View Controller Delegate
@protocol MyShopAddressDetailViewControllerDelegate <NSObject>
@required
-(void)DidTapButton:(UIButton*)button withdata:(NSDictionary*)data;
@end

@interface MyShopAddressDetailViewController : UIViewController

#if __IPHONE_OS_VERSION_MIN_REQUIRED >= TKPD_MINIMUMIOSVERSION
@property (nonatomic, weak) IBOutlet id<MyShopAddressDetailViewControllerDelegate> delegate;
#else
@property (nonatomic, assign) IBOutlet id<MyShopAddressDetailViewControllerDelegate> delegate;
#endif

@property (nonatomic, strong) NSDictionary *data;

@end