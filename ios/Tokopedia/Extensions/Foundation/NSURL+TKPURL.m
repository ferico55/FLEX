//
//  NSURL+TKPURL.m
//  Tokopedia
//
//  Created by Renny Runiawati on 2/3/17.
//  Copyright © 2017 TOKOPEDIA. All rights reserved.
//

#import "NSURL+TKPURL.h"

@implementation NSURL (TKPURL)


- (NSURL *)TKPMeUrl{
    
    NSString* theRealUrl = [NSString stringWithFormat:@"https://tkp.me/r?url=%@", [self.absoluteString stringByReplacingOccurrencesOfString:@"*" withString:@"."]];
    if ([[self.host stringByReplacingOccurrencesOfString:@"*" withString:@"."] containsString:@"tokopedia.com"]) {
        theRealUrl = [self.absoluteString stringByReplacingOccurrencesOfString:@"*" withString:@"."];
    }
    
    return [NSURL URLWithString:[theRealUrl stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
}


@end
