//
//  ResolutionActionResult.h
//  Tokopedia
//
//  Created by IT Tkpd on 3/6/15.
//  Copyright (c) 2015 TOKOPEDIA. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ResolutionLast.h"
#import "ResolutionConversation.h"
#import "ResolutionButton.h"

@interface ResolutionActionResult : NSObject <TKPObjectMapping>

@property (nonatomic) NSInteger is_success;
@property (nonatomic, strong) NSString *post_key;
@property (nonatomic, strong) NSString *file_uploaded;
@property (nonatomic, strong) NSString *hide_conversation_box;
@property (nonatomic, strong) NSString *resolution_id;

@property (nonatomic, strong) ResolutionLast *solution_last;
@property (nonatomic, strong) NSArray<ResolutionConversation*> *conversation_last;
@property (nonatomic, strong) ResolutionButton *button;

+(RKObjectMapping*)mappingNewWS;

@end
