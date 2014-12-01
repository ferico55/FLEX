//
//  NSStringCategory.m
//  tokopedia
//
//  Created by IT Tkpd on 8/14/14.
//  Copyright (c) 2014 TOKOPEDIA. All rights reserved.
//

#import "NSStringCategory.h"

@implementation NSString (TkpdCategory)

/** Checking string for email validation **/
-(NSString*)isEmail
{
    if ([self isKindOfClass:[NSString class]]) {
        BOOL stricterFilter = YES;
        NSString *stricterFilterString = @"[A-Z0-9a-z\\._%+-]+@([A-Za-z0-9-]+\\.)+[A-Za-z]{2,4}";
        NSString *laxString = @".+@([A-Za-z0-9]+\\.)+[A-Za-z]{2}[A-Za-z]*";
        NSString *emailRegex = stricterFilter ? stricterFilterString : laxString;
        NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegex];
        
        if ([emailTest evaluateWithObject:self]) {
            return self;
		}
	}
	return nil;
    
    //    NSLog(@"EMAIL =%@, TEXT = %@, +AST %d",emailRegex,emailTest,[emailTest evaluateWithObject:self]);
}

+(NSString *)convertHTML:(NSString *)html {
    
    NSScanner *myScanner;
    NSString *text = nil;
    myScanner = [NSScanner scannerWithString:html];
    
    while ([myScanner isAtEnd] == NO) {
        
        [myScanner scanUpToString:@"<" intoString:NULL] ;
        
        [myScanner scanUpToString:@">" intoString:&text] ;
        
        html = [html stringByReplacingOccurrencesOfString:[NSString stringWithFormat:@"%@>", text] withString:@""];
    }
    //
    html = [html stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    
    return html;
}

+(NSString *)getLinkFromHTMLString:(NSString*)html
{
    NSScanner *myScanner;
    NSString *text = nil;
    myScanner = [NSScanner scannerWithString:html];
    
    while ([myScanner isAtEnd] == NO) {
        
        [myScanner scanUpToString:@"<" intoString:NULL] ;
        
        [myScanner scanUpToString:@">" intoString:&text] ;
        
        if ([text rangeOfString:@"a href="].location == NSNotFound) {
        } else {
            text = [text stringByReplacingOccurrencesOfString:@"<a href="
                                                   withString:@""];
            text = [text stringByReplacingOccurrencesOfString:@" target=" withString:@""];
            text = [text stringByReplacingOccurrencesOfString:@"\"" withString:@""];
            text = [text stringByReplacingOccurrencesOfString:@"_blank" withString:@""];
            return text;
        }
    }
    return nil;
}

@end
