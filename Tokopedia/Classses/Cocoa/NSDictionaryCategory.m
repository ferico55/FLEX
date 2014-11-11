//
//  NSDictionaryCategory.m
//  Tokopedia
//
//  Created by IT Tkpd on 10/29/14.
//  Copyright (c) 2014 TOKOPEDIA. All rights reserved.
//

#import "NSDictionaryCategory.h"

@implementation NSDictionary (tkpdcategory)

- (BOOL)isMutable
{
	@try {
		[(id)self setObject:@"" forKey:@""];	//TODO: unique key...
		[(id)self removeObjectForKey:@""];
		return YES;
	}
	@catch (NSException *exception) {
		return NO;
	}
	//@finally {
	//}
    return YES;
}


@end
