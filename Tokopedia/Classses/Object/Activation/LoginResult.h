//
//  LoginResult.h
//  Tokopedia
//
//  Created by IT Tkpd on 10/20/14.
//  Copyright (c) 2014 TOKOPEDIA. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface LoginResult : NSObject <NSCoding>

@property (nonatomic) BOOL is_login;
@property (nonatomic) NSInteger shop_id;
@property (nonatomic) NSInteger user_id;
@property (nonatomic, strong) NSString *full_name;

- (void)encodeWithCoder:(NSCoder *)encoder;
- (id)initWithCoder:(NSCoder *)decoder;

@end
