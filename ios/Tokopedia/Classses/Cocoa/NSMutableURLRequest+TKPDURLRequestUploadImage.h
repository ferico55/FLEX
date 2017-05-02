//
//  NSMutableURLRequest+TKPDURLRequestUploadImage.h
//  Tokopedia
//
//  Created by IT Tkpd on 12/16/14.
//  Copyright (c) 2014 TOKOPEDIA. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSMutableURLRequest (TKPDURLRequestUploadImage)

+(NSMutableURLRequest*)requestUploadImageData:(NSData*)imageData withName:(NSString*)name andFileName:(NSString*)fileName withRequestParameters:(NSDictionary*)parameters uploadHost:(NSString*)uploadHost;


+ (NSMutableURLRequest*)requestWithAuthorizedHeader:(NSURL*)url;

@end
