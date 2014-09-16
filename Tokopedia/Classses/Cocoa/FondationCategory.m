//
//  FondationCategory.m
//  tokopedia
//
//  Created by IT Tkpd on 8/14/14.
//  Copyright (c) 2014 TOKOPEDIA. All rights reserved.
//

#import "FondationCategory.h"

#pragma mark -
#pragma mark Foundation Category

#pragma mark - NSObject

@implementation NSObject (TkpdCategory)

//+ (id)allocinit
//{
//	id o = [[self class] alloc];
//	if (o) {
//		id t = o;
//		o = [o init];
//		if (o) {
//			return o;
//		}
//		[t release];
//	}
//	return nil;
//}

@end

#pragma mark - NSDictionary

@implementation NSDictionary (TkpdCategory)

- (NSArray*)arrayForKey:(id)aKey
{
	if ([aKey isKindOfClass:[NSString class]]) {
		id o = [self objectForKey:aKey];
		if ([o isKindOfClass:[NSArray class]]) {
			return o;
		}
	}
	return nil;
}

- (NSMutableArray*)mutableArrayForKey:(id)aKey
{
	if ([aKey isKindOfClass:[NSString class]]) {
		id o = [self objectForKey:aKey];
		if ([NSStringFromClass([o superclass]) isEqualToString:@"NSMutableArray"]) {
			return o;
		} else {
			if ([o isKindOfClass:[NSArray class]]) {
				return [o mutableCopy];
			}
		}
	}
	return nil;
}

- (NSDictionary*)dictionaryForKey:(id)aKey
{
	if ([aKey isKindOfClass:[NSString class]]) {
		id o = [self objectForKey:aKey];
		if ([o isKindOfClass:[NSDictionary class]]) {
			return o;
		}
	}
	return nil;
}

- (NSMutableDictionary*)mutableDictionaryForKey:(id)aKey
{
	if ([aKey isKindOfClass:[NSString class]]) {
		id o = [self objectForKey:aKey];
		if ([NSStringFromClass([o superclass]) isEqualToString:@"NSMutableDictionary"]) {
			return o;
		} else {
			if ([o isKindOfClass:[NSDictionary class]]) {
				return [o mutableCopy];
			}
		}
	}
	return nil;
}

- (NSNumber*)numberForKey:(id)aKey
{
	if ([aKey isKindOfClass:[NSString class]]) {
		id o = [self objectForKey:aKey];
		if ([o isKindOfClass:[NSNumber class]]) {
			return o;
		}
	}
	return nil;
}

- (double)doubleForKey:(id)aKey
{
	if ([aKey isKindOfClass:[NSString class]]) {
		id o = [self objectForKey:aKey];
		if ([o isKindOfClass:[NSNumber class]]) {
			return [o doubleValue];
		}
	}
	return 0.0;
}

- (float)floatForKey:(id)aKey
{
	if ([aKey isKindOfClass:[NSString class]]) {
		id o = [self objectForKey:aKey];
		if ([o isKindOfClass:[NSNumber class]]) {
			return [o floatValue];
		}
	}
	return 0.0f;
}

- (NSInteger)integerForKey:(id)aKey
{
	if ([aKey isKindOfClass:[NSString class]]) {
		id o = [self objectForKey:aKey];
		if ([o isKindOfClass:[NSNumber class]]) {
			return [o integerValue];
		}
	}
	return 0;
}

- (NSValue*)valueForKey:(id)aKey
{
	if ([aKey isKindOfClass:[NSString class]]) {
		id o = [self objectForKey:aKey];
		if ([o isKindOfClass:[NSValue class]]) {
			return o;
		}
	}
	return nil;
}

- (CGPoint)pointForKey:(id)aKey
{
	if ([aKey isKindOfClass:[NSString class]]) {
		id o = [self objectForKey:aKey];
		if ([o isKindOfClass:[NSValue class]]) {
			return [o CGPointValue];
		}
	}
	return CGPointZero;
}

- (CGSize)sizeForKey:(id)aKey
{
	if ([aKey isKindOfClass:[NSString class]]) {
		id o = [self objectForKey:aKey];
		if ([o isKindOfClass:[NSValue class]]) {
			return [o CGSizeValue];
		}
	}
	return CGSizeZero;
}

- (CGRect)rectForKey:(id)aKey
{
	if ([aKey isKindOfClass:[NSString class]]) {
		id o = [self objectForKey:aKey];
		if ([o isKindOfClass:[NSValue class]]) {
			return [o CGRectValue];
		}
	}
	return CGRectZero;
}

- (NSIndexPath*)indexPathForKey:(id)aKey
{
	if ([aKey isKindOfClass:[NSString class]]) {
		id o = [self objectForKey:aKey];
		if ([o isKindOfClass:[NSIndexPath class]]) {
			return o;
		}
	}
	return nil;
}

- (BOOL)boolForKey:(id)aKey
{
	if ([aKey isKindOfClass:[NSString class]]) {
		id o = [self objectForKey:aKey];
		if ([o isKindOfClass:[NSNumber class]]) {
			return [o boolValue];
		}
	}
	return NO;
}

- (NSString*)stringForKey:(id)aKey
{
	if ([aKey isKindOfClass:[NSString class]]) {
		id o = [self objectForKey:aKey];
		if ([o isKindOfClass:[NSString class]]) {
			return o;
		}
	}
	return nil;
}

- (NSData*)dataForKey:(id)aKey
{
	if ([aKey isKindOfClass:[NSString class]]) {
		id o = [self objectForKey:aKey];
		if ([o isKindOfClass:[NSData class]]) {
			return o;
		}
	}
	return nil;
}

- (UIImage*)imageForKey:(id)aKey
{
	if ([aKey isKindOfClass:[NSString class]]) {
		id o = [self objectForKey:aKey];
		if ([o isKindOfClass:[UIImage class]]) {
			return o;
		}
	}
	return nil;
}

- (UIImage*)imageFromDataForKey:(id)aKey
{
	if ([aKey isKindOfClass:[NSString class]]) {
		id o = [self objectForKey:aKey];
		if ([o isKindOfClass:[NSData class]]) {
			UIImage* m = [UIImage imageWithData:o];
			return m;
		}
	}
	return nil;
}

- (ALAsset*)assetForKey:(id)aKey
{
	if ([aKey isKindOfClass:[NSString class]]) {
		id o = [self objectForKey:aKey];
		if ([o isKindOfClass:[ALAsset class]]) {
			return o;
		}
	}
	return nil;
}

- (ALAssetsGroup*)assetGroupForKey:(id)aKey
{
	if ([aKey isKindOfClass:[NSString class]]) {
		id o = [self objectForKey:aKey];
		if ([o isKindOfClass:[ALAssetsGroup class]]) {
			return o;
		}
	}
	return nil;
}

- (NSDate*)dateForKey:(id)aKey
{
	if ([aKey isKindOfClass:[NSString class]]) {
		id o = [self objectForKey:aKey];
		if ([o isKindOfClass:[NSDate class]]) {
			return o;
		}
	}
	return nil;
}

@end

#pragma mark - NSArray

@implementation NSArray (TkpdCategory)

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
