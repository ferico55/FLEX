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

@end
