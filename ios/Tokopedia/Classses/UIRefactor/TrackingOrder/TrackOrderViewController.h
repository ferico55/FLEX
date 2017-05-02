//
//  TrackOrderViewController.h
//  Tokopedia
//
//  Created by Feizal Badri Asmoro on 2/4/15.
//  Copyright (c) 2015 TOKOPEDIA. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "OrderTransaction.h"

@protocol TrackOrderViewControllerDelegate <NSObject>

@optional
- (void)shouldRefreshRequest;
- (void)updateDeliveredOrder:(NSString *)receiverName;

@end

@interface TrackOrderViewController : UIViewController


@property (nonatomic, weak) IBOutlet id<TrackOrderViewControllerDelegate> delegate;

@property (strong, nonatomic) OrderTransaction *order;
@property (nonatomic) NSInteger orderID;

@property (strong, nonatomic) NSString *shippingRef;
@property (strong, nonatomic) NSString *shipmentID;

@property BOOL isShippingTracking;

@end