//
//  RKClient.m
//  Tokopedia
//
//  Created by IT Tkpd on 9/10/14.
//  Copyright (c) 2014 TOKOPEDIA. All rights reserved.
//

#import "RKClient.h"

@interface RKClient ()

@end

@implementation RKClient

- (NSURLRequest *)connection:(NSURLConnection *)connection willSendRequest:(NSURLRequest *)request redirectResponse:(NSURLResponse *)redirectResponse
{
    NSMutableURLRequest *requestWithTimeout = [request mutableCopy];
    [requestWithTimeout setTimeoutInterval:30];
    
    return [super connection:connection willSendRequest:requestWithTimeout redirectResponse:redirectResponse];
}

@end
