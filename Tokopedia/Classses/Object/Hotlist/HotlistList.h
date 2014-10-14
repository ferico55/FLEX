//
//  HotlistList.h
//  Tokopedia
//
//  Created by IT Tkpd on 8/29/14.
//  Copyright (c) 2014 TOKOPEDIA. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface HotlistList: NSObject

@property (nonatomic, strong) NSString *price_start;
@property (nonatomic, strong) NSString *url;
@property (nonatomic, strong) NSString *image_url;
@property (nonatomic, strong) NSString *title;

- (void) encodeWithCoder:(NSCoder *)encoder;
- (id)initWithCoder:(NSCoder *)decoder;

@end
