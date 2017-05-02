//
//  InboxMessageReplyTime.h
//  Tokopedia
//
//  Created by Tonito Acen on 10/13/16.
//  Copyright © 2016 TOKOPEDIA. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface InboxMessageReplyTime : NSObject

@property(nonatomic, strong) NSString* unix;
@property(nonatomic, strong) NSString* formatted;

+ (RKObjectMapping*) mapping;

@end
