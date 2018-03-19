//
//  NSMutableURLRequest+TKPDURLRequestUploadImage.m
//  Tokopedia
//
//  Created by IT Tkpd on 12/16/14.
//  Copyright (c) 2014 TOKOPEDIA. All rights reserved.
//

#import "camera.h"
#import "NSMutableURLRequest+TKPDURLRequestUploadImage.h"
#import "TkpdHMAC.h"
#import "NSURL+Dictionary.h"
#import "Tokopedia-Swift.h"
#import "NSString+MD5.h"

@implementation NSMutableURLRequest (TKPDURLRequestUploadImage)

+(NSMutableURLRequest*)requestUploadImageData:(NSData*)imageData withName:(NSString*)name andFileName:(NSString*)fileName withRequestParameters:(NSDictionary*)parameters uploadHost:(NSString*)uploadHost
{
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    
    //Set Params
    [request setHTTPShouldHandleCookies:NO];
    [request setTimeoutInterval:60];
    [request setHTTPMethod:@"POST"];
    
    //Create boundary, it can be anything
    NSString *boundary = @"------VohpleBoundary4QuqLuM1cE5lMwCy";
    
    //set Content-Type in HTTP header
    NSString *contentType = [NSString stringWithFormat:@"multipart/form-data; boundary=%@", boundary];
    [request setValue:contentType forHTTPHeaderField: @"Content-Type"];
    NSString *userAgent = @"Mozilla/5.0 (Macintosh; Intel Mac OS X 10_10_2) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/41.0.2272.118 Safari/537.36";
    [request setValue:userAgent forHTTPHeaderField:@"User-Agent"];
    
    //post body
    NSMutableData *body = [NSMutableData data];

    //add params (all params are strings)
    for (NSString *param in parameters) {
        [body appendData:[[NSString stringWithFormat:@"--%@\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
        [body appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"%@\"\r\n\r\n", param] dataUsingEncoding:NSUTF8StringEncoding]];
        [body appendData:[[NSString stringWithFormat:@"%@\r\n", [parameters objectForKey:param]] dataUsingEncoding:NSUTF8StringEncoding]];
//        [body appendData:[[NSString stringWithFormat:@"--%@--\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
    }
    
    //add image data
    if (imageData) {
        [body appendData:[[NSString stringWithFormat:@"--%@\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
        [body appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"%@\"; filename=\"%@\"; mimeType=\"image/png\"\r\n",name,fileName] dataUsingEncoding:NSUTF8StringEncoding]];
        [body appendData:[@"Content-Type: image/png\r\n\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
        [body appendData:[NSData dataWithData:imageData]];
        
        [body appendData:[@"\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
        //Close off the request with the boundary
        [body appendData:[[NSString stringWithFormat:@"--%@--\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
    }
    
    //setting the body of the post to the request
    [request setHTTPBody:body];
    
    NSString *urlString = [NSString stringWithFormat:@"http://%@/%@",uploadHost,@"web-service/v4/action/upload-image/upload_product_image.pl"];
    
    [request setURL:[NSURL URLWithString:urlString]];
    
    return request;
}

+ (NSMutableURLRequest*)requestWithAuthorizedHeader:(NSURL*)url {
    TkpdHMAC *hmac = [TkpdHMAC new];
    
    NSString* baseUrl = [NSString stringWithFormat:@"%@://%@", url.scheme, url.host];
    [hmac signatureWithWebviewUrl: url];
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    [request setURL:url];
    
    [request setValue:@"Mozilla/5.0 (iPod; U; CPU iPhone OS 4_3_3 like Mac OS X; ja-jp) AppleWebKit/533.17.9 (KHTML, like Gecko) Version/5.0.2 Mobile/8J2 Safari/6533.18.5" forHTTPHeaderField:@"User-Agent"];
    
    NSMutableDictionary* authorizedHeaders = [hmac authorizedHeaders];
    [authorizedHeaders setValue:[NSString stringWithFormat:@"ios-%@", [UIApplication getAppVersionString]] forKey:@"X-Device"];
    [authorizedHeaders bk_each:^(NSString* key, NSString* value) {
        [request setValue:value forHTTPHeaderField:key];
    }];
    
    return request;
}


@end
