//
//  SearchAWS.h
//  Tokopedia
//
//  Created by Tonito Acen on 8/26/15.
//  Copyright (c) 2015 TOKOPEDIA. All rights reserved.
//

#import <Foundation/Foundation.h>

@class SearchAWSResult;

@interface SearchAWS : NSObject

@property (strong, nonatomic) NSString *status;
@property (strong, nonatomic) NSString *server_process_time;
@property (nonatomic, strong) NSString *redirect_url;
@property (nonatomic, strong) NSString *department_id;
@property (strong, nonatomic) SearchAWSResult *result;

@end
