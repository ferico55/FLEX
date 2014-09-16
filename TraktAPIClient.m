//
//  TraktAPIClient.m
//  Tokopedia
//
//  Created by IT Tkpd on 8/19/14.
//  Copyright (c) 2014 TOKOPEDIA. All rights reserved.
//

#import "Tkpd.h"
#import "TraktAPIClient.h"

// Set this to your Trakt API Key
NSString * const kTraktAPIKey = @"8b0c367dd3ef0860f5730ec64e3bbdc9";
NSString * const kTraktBaseURLString = kTkpdBaseURLString;

@implementation TraktAPIClient

+ (TraktAPIClient *)sharedClient {
    static TraktAPIClient *_sharedClient = nil;
    static dispatch_once_t oncePredicate;
    dispatch_once(&oncePredicate, ^{
        _sharedClient = [[self alloc] initWithBaseURL:[NSURL URLWithString:kTraktBaseURLString]];
    });
    return _sharedClient;
}

- (instancetype)initWithBaseURL:(NSURL *)url {
    
    self = [super initWithBaseURL:url];
    if (!self) {
        return nil;
    }
    
    return self;
}


/** for deployment target > 7.0 **/
//- (void)getShowsForDate:(NSDate *)date
//               username:(NSString *)username
//           numberOfDays:(int)numberOfDays
//                success:(void(^)(NSURLSessionDataTask *task, id responseObject))success
//                failure:(void(^)(NSURLSessionDataTask *task, NSError *error))failure
//{
//    NSDateFormatter* formatter = [[NSDateFormatter alloc] init];
//    formatter.dateFormat = @"yyyyMMdd";
//    NSString* dateString = [formatter stringFromDate:date];
//    
//    NSString* path = [NSString stringWithFormat:@"user/calendar/shows.json/%@/%@/%@/%d",
//                      kTraktAPIKey, username, dateString, numberOfDays];
//    
//    [self GET:path parameters:nil success:^(NSURLSessionDataTask *task, id responseObject) {
//        if (success) {
//            success(task, responseObject);
//        }
//    } failure:^(NSURLSessionDataTask *task, NSError *error) {
//        if (failure) {
//            failure(task, error);
//        }
//    }];
//}

@end
