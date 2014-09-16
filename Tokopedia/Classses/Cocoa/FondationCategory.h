//
//  FondationCategory.h
//  tokopedia
//
//  Created by IT Tkpd on 8/14/14.
//  Copyright (c) 2014 TOKOPEDIA. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AssetsLibrary/AssetsLibrary.h>

#pragma mark - NSObject

//@interface NSObject (TkpdCategory)
//
//+ (id)allocinit;
//
//@end

#pragma mark - NSDictionary

@interface NSDictionary (TkpdCategory)

- (NSArray*)arrayForKey:(id)aKey;
- (NSMutableArray*)mutableArrayForKey:(id)aKey;
- (NSDictionary*)dictionaryForKey:(id)aKey;
- (NSMutableDictionary*)mutableDictionaryForKey:(id)aKey;
- (NSNumber*)numberForKey:(id)aKey;
- (double)doubleForKey:(id)aKey;
- (float)floatForKey:(id)aKey;
- (NSInteger)integerForKey:(id)aKey;
- (NSValue*)valueForKey:(id)aKey;
- (CGPoint)pointForKey:(id)aKey;
- (CGSize)sizeForKey:(id)aKey;
- (CGRect)rectForKey:(id)aKey;
- (NSIndexPath*)indexPathForKey:(id)aKey;
- (BOOL)boolForKey:(id)aKey;
- (NSString*)stringForKey:(id)aKey;
- (NSData*)dataForKey:(id)aKey;
- (UIImage*)imageForKey:(id)aKey;
- (UIImage*)imageFromDataForKey:(id)aKey;
- (ALAsset*)assetForKey:(id)aKey;
- (ALAssetsGroup*)assetGroupForKey:(id)aKey;
- (NSDate*)dateForKey:(id)aKey;

@end

#pragma mark - NSArray

@interface NSArray (TkpdCategory)

+ (NSArray*)sortViewsWithTagInArray:(NSArray*)array;

@end
