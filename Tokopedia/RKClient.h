//
//  RKClient.h
//  Tokopedia
//
//  Created by IT Tkpd on 9/10/14.
//  Copyright (c) 2014 TOKOPEDIA. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface RKClient : RKHTTPRequestOperation

- (NSURLRequest *)connection:(NSURLConnection *)connection willSendRequest:(NSURLRequest *)request redirectResponse:(NSURLResponse *)redirectResponse;


@end
