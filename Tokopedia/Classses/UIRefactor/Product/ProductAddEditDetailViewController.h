//
//  ProductAddEditDetailViewController.h
//  Tokopedia
//
//  Created by IT Tkpd on 12/8/14.
//  Copyright (c) 2014 TOKOPEDIA. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ProductAddEditViewController.h"
@class ProductEditResult;
@class ProductEditDetail;
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
@property BOOL isShopHasTerm;
@property BOOL isNeedRequestAddProductPicture;

@property NSString* returnableStatus;
@property (strong,nonatomic) NSArray <SelectedImage*> *selectedImages;
@property (strong,nonatomic) ProductEditDetail *product;
@property NSInteger type;
@property NSDictionary *dataInput;

/** 
 my $var_state = {
 # Product Status
 PRD_STATE_DELETED                    => 0,
 PRD_STATE_ACTIVE                     => 1,
 PRD_STATE_BEST                       => 2,
 PRD_STATE_WAREHOUSE                  => 3,
 PRD_STATE_PENDING                    => -1,
 PRD_STATE_BANNED                     => -2,
 
 MAX_PRODUCT                         => 100,
 };
 **/

@end
