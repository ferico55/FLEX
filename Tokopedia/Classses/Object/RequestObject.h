//
//  RequestObject.h
//  Tokopedia
//
//  Created by Renny Runiawati on 11/18/15.
//  Copyright © 2015 TOKOPEDIA. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface RequestObjectGetAddress : NSObject <TKPObjectMapping>

@property (nonatomic, strong) NSString *action;
@property (nonatomic, strong) NSString *page;
@property (nonatomic, strong) NSString *per_page;
@property (nonatomic, strong) NSString *user_id;
@property (nonatomic, strong) NSString *query;


@end

