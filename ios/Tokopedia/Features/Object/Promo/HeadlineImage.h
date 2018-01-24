//
//  HeadlineImage.h
//  Tokopedia
//
//  Created by Billion Goenawan on 29/12/17.
//  Copyright © 2017 TOKOPEDIA. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface HeadlineImage : NSObject

@property (nonatomic, strong) NSString* fullUrl;

+ (RKObjectMapping *)mapping;

@end
