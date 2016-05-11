//
//  UploadDataImage.h
//  Tokopedia
//
//  Created by Tokopedia on 4/28/16.
//  Copyright © 2016 TOKOPEDIA. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface UploadDataImage : NSObject

@property (strong, nonatomic) NSString *message_status;
@property (strong, nonatomic) NSString *pic_code;
@property (strong, nonatomic) NSString *pic_src;
@property (strong, nonatomic) NSString *success;

+ (RKObjectMapping *)mapping;

@end
