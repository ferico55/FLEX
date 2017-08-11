//
//  SecurityQuestionResult.h
//  Tokopedia
//
//  Created by Tonito Acen on 4/19/16.
//  Copyright © 2016 TOKOPEDIA. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SecurityQuestionResult : NSObject <TKPObjectMapping>

@property(nonatomic, strong, nonnull) NSString* question;
@property(nonatomic, strong, nonnull) NSString* title;
@property(nonatomic, strong, nonnull) NSString* example;

@end
