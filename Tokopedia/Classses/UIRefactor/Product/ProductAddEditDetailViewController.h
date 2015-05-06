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


@property (nonatomic, weak) IBOutlet id<ProductEditDetailViewControllerDelegate> delegate;


@property (strong,nonatomic) NSDictionary *data;

@property GenerateHost *generateHost;
@property (strong,nonatomic) NSString *shopHasTerm;

@end
