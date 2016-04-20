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

@property(nonatomic, strong) NSString* status;
@property(nonatomic, strong) SecurityAnswerResult* data;
@property(nonatomic, strong) NSArray* message_error;

@end
