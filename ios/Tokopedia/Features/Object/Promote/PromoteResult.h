//
//  GeneralActionResult.h
//  Tokopedia
//
//  Created by IT Tkpd on 9/29/14.
//  Copyright (c) 2014 TOKOPEDIA. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface PromoteResult : NSObject <TKPObjectMapping>

@property (nonatomic, strong) NSString *is_dink;
@property (nonatomic, strong) NSString *product_name;
@property (nonatomic, strong) NSString *uri;
@property (nonatomic, strong) NSString *time_expired;

@end
