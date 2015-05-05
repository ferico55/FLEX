//
//  ShopEditStatusViewController.h
//  Tokopedia
//
//  Created by IT Tkpd on 11/17/14.
//  Copyright (c) 2014 TOKOPEDIA. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol ShopEditStatusViewControllerDelegate <NSObject>
@required
-(void)ShopEditStatusViewController:(UIViewController*)vc withData:(NSDictionary*)data;

@end

@interface ShopEditStatusViewController : UIViewController


@property (nonatomic, weak) IBOutlet id<ShopEditStatusViewControllerDelegate> delegate;


@property (strong, nonatomic) NSDictionary *data;

@end
