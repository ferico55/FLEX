//
//  ResolutionDetailConversation.h
//  Tokopedia
//
//  Created by IT Tkpd on 3/3/15.
//  Copyright (c) 2015 TOKOPEDIA. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "ResolutionLast.h"
#import "ResolutionOrder.h"
#import "ResolutionBy.h"
#import "ResolutionShop.h"
#import "ResolutionCustomer.h"
#import "ResolutionDispute.h"
#import "ResolutionButton.h"
#import "ResolutionConversation.h"

@interface ResolutionDetailConversation : NSObject <TKPObjectMapping>

@property (nonatomic, strong) ResolutionLast *resolution_last;
@property (nonatomic, strong) NSNumber *resolution_conversation_count;
@property (nonatomic, strong) ResolutionButton *resolution_button;
@property (nonatomic, strong) ResolutionBy *resolution_by;
@property (nonatomic, strong) ResolutionShop *resolution_shop;
@property (nonatomic, strong) ResolutionCustomer *resolution_customer;
@property (nonatomic) NSInteger resolution_can_conversation;
@property (nonatomic, strong) NSArray *resolution_conversation;
@property (nonatomic, strong) ResolutionOrder *resolution_order;
@property (nonatomic, strong) ResolutionDispute *resolution_dispute;

@end
