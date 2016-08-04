//
//  ProductAddEditDetailViewController.h
//  Tokopedia
//
//  Created by IT Tkpd on 12/8/14.
//  Copyright (c) 2014 TOKOPEDIA. All rights reserved.
//

#import <UIKit/UIKit.h>

@class ProductEditResult;

@class ProductAddEditDetailViewController;

#pragma mark - Product Edit Detail Delegate
@protocol ProductEditDetailViewControllerDelegate <NSObject>
@optional
-(void)DidEditReturnableNote;

@end

@interface ProductAddEditDetailViewController : UIViewController

@property (nonatomic, weak) IBOutlet id<ProductEditDetailViewControllerDelegate> delegate;

@property ProductEditResult* form;
@property NSInteger type;

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
