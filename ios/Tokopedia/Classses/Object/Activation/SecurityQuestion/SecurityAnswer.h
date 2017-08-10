//
//  SecurityAnswer.h
//  Tokopedia
//
//  Created by Tonito Acen on 4/19/16.
//  Copyright © 2016 TOKOPEDIA. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SecurityAnswerResult.h"

@interface SecurityAnswer : NSObject <TKPObjectMapping>

@property(nonatomic, strong, nonnull) NSString* status;
@property(nonatomic, strong, nonnull) SecurityAnswerResult* data;
@property(nonatomic, strong, nonnull) NSArray* message_error;

@end
