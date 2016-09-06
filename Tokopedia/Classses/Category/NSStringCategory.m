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
    html = html?:@"";
    
    html = [html stringByReplacingOccurrencesOfString:@"<br/>" withString:@"\n"];
    html = [html stringByReplacingOccurrencesOfString:@"<br>" withString:@"\n"];
    html = [html stringByReplacingOccurrencesOfString:@"[nl]" withString:@"\n"];
    html = [html stringByReplacingOccurrencesOfString:@"&amp;" withString:@"&"];
    html = [html stringByReplacingOccurrencesOfString:@"&gt;" withString:@">"];
    html = [html stringByReplacingOccurrencesOfString:@"&lt;" withString:@"<"];
    html = [html stringByReplacingOccurrencesOfString:@"&#39;" withString:@"'"];
    html = [html stringByReplacingOccurrencesOfString:@"&quot;" withString:@"\""];
    
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

+(NSString *)getLinkFromHTMLString:(NSString*)html {
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

+ (NSString*) timeLeftSinceDate:(NSDate *)dateT
{
    NSString *timeLeft;
    
    NSInteger seconds = [dateT timeIntervalSinceNow];
    
    NSInteger days = (int) (floor(seconds / (3600 * 24)));
    if(days) seconds -= days * 3600 * 24;
    
    NSInteger hours = (int) (floor(seconds / 3600));
    if(hours) seconds -= hours * 3600;
    
    NSInteger minutes = (int) (floor(seconds / 60));
    if(minutes) seconds -= minutes * 60;
    
    if(days) {
        if (days<0) {
            days = days;
        }
        timeLeft = [NSString stringWithFormat:@"%ld hari yang lalu", (long)labs(days)];
    }
    else if(hours) {
        if (hours<0) {
            timeLeft = [NSString stringWithFormat: @"Beberapa menit yang lalu"];
        }
        else timeLeft = [NSString stringWithFormat: @"%ld jam yang lalu", (long)hours];
    }
    else if(minutes) {
        if (minutes<0) {
            minutes = -minutes;
        }
        timeLeft = [NSString stringWithFormat: @"%ld menit yang lalu", (long)minutes];
    }
    else if(seconds)
    {
        timeLeft = [NSString stringWithFormat: @"%lds detik yang lalu", (long)seconds];
    }
    else
    {
        timeLeft = [NSString stringWithFormat: @"sekitar satu menit yang lalu"];
    }
    return timeLeft;
}

-(BOOL)isAllNonNumber
{
    
    NSCharacterSet* numbers = [NSCharacterSet decimalDigitCharacterSet];
    NSRange rnumbers = [self rangeOfCharacterFromSet: numbers];
    
    return rnumbers.location == NSNotFound;
}

-(BOOL)isNumber {
    return [self rangeOfCharacterFromSet:[NSCharacterSet decimalDigitCharacterSet].invertedSet].location == NSNotFound;
}

- (BOOL) isNotAllBaseCharacter
{
    //    NSCharacterSet* symbols = [NSCharacterSet symbolCharacterSet];
    //    NSRange r = [self rangeOfCharacterFromSet: symbols];
    //    NSCharacterSet* numbers = [NSCharacterSet decimalDigitCharacterSet];
    //    NSRange rnumbers = [self rangeOfCharacterFromSet: numbers];
    NSCharacterSet * set = [[NSCharacterSet characterSetWithCharactersInString:@"abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLKMNOPQRSTUVWXYZ "]invertedSet];
    return [self rangeOfCharacterFromSet:set].location != NSNotFound;
}

-(NSString *)priceFromStringIDR
{
    NSString *price = self;
    price = [price stringByReplacingOccurrencesOfString:@"." withString:@""];
    price = [price stringByReplacingOccurrencesOfString:@"Rp" withString:@""];
    price = [price stringByReplacingOccurrencesOfString:@"-" withString:@""];
    price = [price stringByReplacingOccurrencesOfString:@"," withString:@""];
    
    return price;
}

+ (NSString *)extracTKPMEUrl:(NSString *)string{
    NSString *leadingTrailingWhiteSpacesPattern = @"<a[^>]+href=\".*?\"[^>]*>(.*?)</a>";
    
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:leadingTrailingWhiteSpacesPattern options:NSRegularExpressionCaseInsensitive|NSRegularExpressionUseUnicodeWordBoundaries error:NULL];
    
    NSRange stringRange = NSMakeRange(0, string.length);
    NSString *trimmedString = [regex stringByReplacingMatchesInString:string options:NSMatchingReportProgress range:stringRange withTemplate:@"$1"];
    
    NSString* replacedString = [trimmedString stringByReplacingOccurrencesOfString:@"&bull;" withString:@"*"];
    
    return replacedString;
}

+ (NSArray *)getStringsBetweenAhrefTagWithString:(NSString *)string {
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"<a[^>]+href=\".*?\"[^>]*>(.*?)</a>" options:NSRegularExpressionCaseInsensitive|NSRegularExpressionUseUnicodeWordBoundaries error:nil];
    
    NSArray *array = [regex matchesInString:string options:0 range:NSMakeRange(0, [string length])];
    
    return array;
}
+ (NSString *)joinStringsWithBullets:(NSArray *)strings {
    if (strings.count == 1) {
        return strings[0];
    }
    
    return [NSString stringWithFormat:@"\u25CF %@", [[strings valueForKey:@"description"] componentsJoinedByString:@"\n\u25CF "]];
}

+ (NSArray<NSString *> *)getLinksBetweenAhrefTagWithString:(NSString *)string {
    NSScanner *myScanner;
    NSMutableArray<NSString *> *array = [NSMutableArray new];
    NSString *text = nil;
    myScanner = [NSScanner scannerWithString:string];
    
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
            
            [array addObject:text];
        }
    }
    
    return array;
}

+ (NSString *)stringReplaceAhrefWithUrl:(NSString *)string{
    NSString *leadingTrailingWhiteSpacesPattern = @"<a[^>]+href=\"(.*?)\"[^>]*>.*?</a>";
    
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:leadingTrailingWhiteSpacesPattern options:NSRegularExpressionCaseInsensitive|NSRegularExpressionUseUnicodeWordBoundaries error:NULL];
    
    NSRange stringRange = NSMakeRange(0, string.length);
    NSString *trimmedString = [regex stringByReplacingMatchesInString:string options:NSMatchingReportProgress range:stringRange withTemplate:@"$1"];
    
    
    return trimmedString;
}

+ (NSString*)encodeString:(NSString *)string {
    NSCharacterSet* customAllowedSet = [NSCharacterSet characterSetWithCharactersInString:@"=\"#%/<>?@\\^`{|}&"].invertedSet;
    
    NSString* encodedString = [string stringByAddingPercentEncodingWithAllowedCharacters:customAllowedSet];
    
    return encodedString;
}


@end
