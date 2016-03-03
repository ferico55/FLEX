//
//  Paging.h
//  Tokopedia
//
//  Created by IT Tkpd on 9/1/14.
//  Copyright (c) 2014 TOKOPEDIA. All rights reserved.
//

#import <Foundation/Foundation.h>
#define CUriNext @"uri_next"
#define CUriPrevious @"uri_previous"

@interface Paging : NSObject <TKPObjectMapping>

@property (strong, nonatomic) NSString *uri_next;
@property (strong, nonatomic) NSString *uri_previous;
@property (strong, nonatomic) RKObjectMapping *mapping;

- (void) encodeWithCoder:(NSCoder *)encoder;
- (id)initWithCoder:(NSCoder *)decoder;

@end
