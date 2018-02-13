//
//  NSStringCategory.h
//  tokopedia
//
//  Created by IT Tkpd on 8/14/14.
//  Copyright (c) 2014 TOKOPEDIA. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (TkpdCategory)

- (null_unspecified NSString *)isEmail;
+ (nonnull NSString *)convertHTML:(nonnull NSString *)html;
+ (null_unspecified NSString *)getLinkFromHTMLString:(nonnull NSString*)html;
+ (null_unspecified NSString*) timeLeftSinceDate:(nonnull NSDate *)dateT;
- (BOOL)isNotAllBaseCharacter;
- (BOOL)isAllNonNumber;
- (BOOL)isNumber;
+ (nonnull NSString *)stringReplaceAhrefWithUrl:(nonnull NSString *)string;
+ (nonnull NSString *)extracTKPMEUrl:(nonnull NSString *)string;


+ (nonnull NSString*) encodeString:(nonnull NSString*)string;

- (null_unspecified NSString *)priceFromStringIDR;

+ (null_unspecified NSArray *)getStringsBetweenAhrefTagWithString:(nonnull NSString *)string;
+ (null_unspecified NSArray <NSString *> *)getLinksBetweenAhrefTagWithString:(nonnull NSString *)string;

+ (nonnull NSString *)joinStringsWithBullets:(nonnull NSArray *)strings;

+ (nonnull NSString *)jsonStringArrayFromArray:(nonnull NSArray *)array;

- (BOOL)empty;

+ (nonnull NSString *)authenticationType;

@end
