//
//  ListFavorited.h
//  Tokopedia
//
//  Created by IT Tkpd on 10/15/14.
//  Copyright (c) 2014 TOKOPEDIA. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ListFavorited : NSObject <TKPObjectMapping>

@property (nonatomic) NSInteger user_id;
@property (nonatomic, strong) NSString *user_image;
@property (nonatomic, strong) NSString *user_name;

@end
