//
//  NSStringCategory.h
//  tokopedia
//
//  Created by IT Tkpd on 8/14/14.
//  Copyright (c) 2014 TOKOPEDIA. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (TkpdCategory)

-(NSString *)isEmail;
+(NSString *)convertHTML:(NSString *)html;
+(NSString *)getLinkFromHTMLString:(NSString*)html;
+(NSString*) timeLeftSinceDate:(NSDate *)dateT;
- (BOOL) isNotAllBaseCharacter;
-(BOOL)isAllNonNumber;
- (BOOL) isNumber;
+ (NSString *)stringReplaceAhrefWithUrl:(NSString *)string;
+ (NSString *)extracTKPMEUrl:(NSString *)string;


+ (NSString*) encodeString:(NSString*)string;

- (BOOL) isNotAllBaseCharacter;

-(NSString *)priceFromStringIDR;

+ (NSArray *)getStringsBetweenAhrefTagWithString:(NSString *)string;
+ (NSArray <NSString *> *)getLinksBetweenAhrefTagWithString:(NSString *)string;

+ (NSString *)joinStringsWithBullets:(NSArray *)strings;

+ (NSString *)jsonStringArrayFromArray:(NSArray *)array;

- (BOOL)empty;

@end
