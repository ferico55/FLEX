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


@property (nonatomic, weak) IBOutlet id<ResolutionInputReceiptViewControllerDelegate> delegate;


@property (nonatomic) NSString *action;

@property ShipmentCourier *selectedShipment;
@property ResolutionConversation *conversation;

@end
