//
//  ShipmentWebViewController.h
//  Tokopedia
//
//  Created by Tokopedia on 3/29/16.
//  Copyright © 2016 TOKOPEDIA. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ShipmentCourierData.h"

@protocol ShipmentWebViewDelegate <NSObject>

- (void)didUpdateCourierAdditionalURL:(NSURL *)additionalURL;

@end

@interface ShipmentWebViewController : UIViewController

@property (strong, nonatomic) ShipmentCourierData *courier;
@property (weak, nonatomic) id<ShipmentWebViewDelegate> delegate;

@end
