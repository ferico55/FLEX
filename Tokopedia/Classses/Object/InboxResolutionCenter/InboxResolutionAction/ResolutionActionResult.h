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

@property (nonatomic, strong) ResolutionLast *solution_last;
@property (nonatomic, strong) NSArray *conversation_last;
@property (nonatomic, strong) ResolutionButton *button;

@end
