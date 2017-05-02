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


@property (nonatomic, weak) IBOutlet id<MyShopEtalaseDetailViewControllerDelegate> delegate;

@property (nonatomic, strong)NSDictionary *data;

@end
