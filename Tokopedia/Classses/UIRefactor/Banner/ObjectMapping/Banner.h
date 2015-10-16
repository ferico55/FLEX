//
//  Banner.h
//  Tokopedia
//
//  Created by Tonito Acen on 10/16/15.
//  Copyright © 2015 TOKOPEDIA. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TKPObjectMapping.h"
#import "BannerResult.h"


@interface Banner : NSObject <TKPObjectMapping>

@property (nonatomic, strong) NSString *status;
@property (nonatomic, strong) NSString *server_process_time;
@property (nonatomic, strong) BannerResult *result;


@end
