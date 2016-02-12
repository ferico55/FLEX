//
//  NSArrayCategory.m
//  Tokopedia
//
//  Created by IT Tkpd on 9/24/14.
//  Copyright (c) 2014 TOKOPEDIA. All rights reserved.
//

#import "NSArrayCategory.h"

@implementation NSArray (tkpdcategory)

+ (NSArray*)sortViewsWithTagInArray:(NSArray*)views
{
	NSArray* array;
	
	array = [views sortedArrayUsingComparator:^NSComparisonResult(id o1, id o2) {
		UIView* v1 = o1;
		UIView* v2 = o2;
		if ([v1 isKindOfClass:[UIView class]] && [v2 isKindOfClass:[UIView class]]) {
			NSNumber *tag1 = @([v1 tag]);
			NSNumber *tag2 = @([v2 tag]);
			return [tag1 compare:tag2];
		}
		return NSOrderedSame;
	}];
	
	return array;
}

@end
