//
//  SecurityQuestion.h
//  Tokopedia
//
//  Created by Tonito Acen on 4/19/16.
//  Copyright © 2016 TOKOPEDIA. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SecurityQuestionResult.h"

@interface SecurityQuestion : NSObject <TKPObjectMapping>

@property(nonatomic, strong) NSString* status;
@property(nonatomic, strong) SecurityQuestionResult* data;

@end
