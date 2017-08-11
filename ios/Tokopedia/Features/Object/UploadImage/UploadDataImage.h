//
//  UploadDataImage.h
//  Tokopedia
//
//  Created by Tokopedia on 4/28/16.
//  Copyright © 2016 TOKOPEDIA. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface UploadDataImage : NSObject

@property (strong, nonatomic, nonnull) NSString *message_status;
@property (strong, nonatomic, nonnull) NSString *pic_code;
@property (strong, nonatomic, nonnull) NSString *pic_src;
@property (strong, nonatomic, nonnull) NSString *src;
@property (strong, nonatomic, nonnull) NSString *success;
@property (strong, nonatomic, nonnull) NSString *file_uploaded;
@property (strong, nonatomic, nonnull) NSString *is_success;

+ (RKObjectMapping *_Nonnull)mapping;

@end
