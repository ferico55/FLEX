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
#import "ResolutionLast.h"

@protocol ResolutionInputReceiptViewControllerDelegate <NSObject>
@required
- (void)receiptNumber:(NSString*)receiptNumber withShipmentAgent:(ShipmentCourier*)shipmentAgent withAction:(NSString *)action conversation:(ResolutionConversation*)conversation;
- (void)addResolutionLast:(ResolutionLast*)resolutionLast conversationLast:(ResolutionConversation*)conversationLast replyEnable:(BOOL)isReplyEnable;
@end

@interface ResolutionInputReceiptViewController : UIViewController


@property (nonatomic, weak) IBOutlet id<ResolutionInputReceiptViewControllerDelegate> delegate;


@property (nonatomic) NSString *action;
@property (nonatomic) NSString *resolutionID;
@property (nonatomic) NSString *conversationID;
@property (nonatomic) BOOL isInputResi;

@property ShipmentCourier *selectedShipment;
@property ResolutionConversation *conversation;

@end
