//
//  ResolutionCenterDetailResult.h
//  Tokopedia
//
//  Created by IT Tkpd on 3/3/15.
//  Copyright (c) 2015 TOKOPEDIA. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "ResolutionDetailConversation.h"
#import "ResolutionConversation.h"

@interface ResolutionCenterDetailResult : NSObject <TKPObjectMapping>

@property (nonatomic, strong) ResolutionDetailConversation *detail;
@property (nonatomic, strong) NSArray *resolution_conversation;

@end
