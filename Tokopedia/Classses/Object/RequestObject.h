//
//  RequestObject.h
//  Tokopedia
//
//  Created by Renny Runiawati on 11/18/15.
//  Copyright © 2015 TOKOPEDIA. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface RequestObject : NSObject

@property (nonatomic, strong) NSString *action;
@property (nonatomic, strong) NSString *page;
@property (nonatomic, strong) NSString *per_page;
@property (nonatomic, strong) NSString *user_id;
@property (nonatomic, strong) NSString *query;


@end

@interface RequestObject1 : NSObject

@property (nonatomic, strong) NSString *action;
@property (nonatomic, strong) NSString *page;
@property (nonatomic, strong) NSString *per_page;
@property (nonatomic, strong) NSString *user_id;
@property (nonatomic, strong) NSString *query;


@end
