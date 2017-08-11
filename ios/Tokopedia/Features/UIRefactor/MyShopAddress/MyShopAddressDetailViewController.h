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


@property (nonatomic, weak) IBOutlet id<MyShopAddressDetailViewControllerDelegate> delegate;

@property (nonatomic, strong) NSMutableDictionary *data;

@end