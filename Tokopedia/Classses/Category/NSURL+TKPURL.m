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
    
    NSString *urlString = self.absoluteString;
    urlString = [urlString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    
    if([urlString containsString:@"tokopedia.com"]) {
        UserAuthentificationManager *auth = [UserAuthentificationManager new];
        urlString = [auth webViewUrlFromUrl:urlString];
    } else {
        urlString = [NSString stringWithFormat:@"https://tkp.me/r?url=%@", [urlString stringByReplacingOccurrencesOfString:@"*" withString:@"."]];
    }
    
    return [NSURL URLWithString:urlString];
}


@end
