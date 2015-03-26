//
//  ResolutionInputReceiptViewController.h
//  Tokopedia
//
//  Created by IT Tkpd on 3/9/15.
//  Copyright (c) 2015 TOKOPEDIA. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "ShipmentCourier.h"
#import "ResolutionConversation.h"

@protocol ResolutionInputReceiptViewControllerDelegate <NSObject>
@required
- (void)receiptNumber:(NSString*)receiptNumber withShipmentAgent:(ShipmentCourier*)shipmentAgent withAction:(NSString *)action conversation:(ResolutionConversation*)conversation;
@end

@interface ResolutionInputReceiptViewController : UIViewController

#if __IPHONE_OS_VERSION_MIN_REQUIRED >= TKPD_MINIMUMIOSVERSION
@property (nonatomic, weak) IBOutlet id<ResolutionInputReceiptViewControllerDelegate> delegate;
#else
@property (nonatomic, assign) IBOutlet id<ResolutionInputReceiptViewControllerDelegate> delegate;
#endif

@property (nonatomic) NSString *action;

@property ShipmentCourier *selectedShipment;
@property ResolutionConversation *conversation;

@end
