//
//  ProductAddEditDetailViewController.h
//  Tokopedia
//
//  Created by IT Tkpd on 12/8/14.
//  Copyright (c) 2014 TOKOPEDIA. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GenerateHost.h"

@class ProductAddEditDetailViewController;

#pragma mark - Product Edit Detail Delegate
@protocol ProductEditDetailViewControllerDelegate <NSObject>
@optional
-(void)ProductEditDetailViewController:(ProductAddEditDetailViewController*)cell withUserInfo:(NSDictionary*)userInfo;
-(void)MoveToWareHouseAtIndexPath:(NSIndexPath*)indexPath;
-(void)DidEditReturnableNote;

@end

@interface ProductAddEditDetailViewController : UIViewController

#if __IPHONE_OS_VERSION_MIN_REQUIRED >= TKPD_MINIMUMIOSVERSION
@property (nonatomic, weak) IBOutlet id<ProductEditDetailViewControllerDelegate> delegate;
#else
@property (nonatomic, assign) IBOutlet id<ProductEditDetailViewControllerDelegate> delegate;
#endif

@property (strong,nonatomic) NSDictionary *data;

@property GenerateHost *generateHost;
@property (strong,nonatomic) NSString *shopHasTerm;

@end
