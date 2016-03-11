//
//  UploadReviewImageResult.h
//  Tokopedia
//
//  Created by Kenneth Vincent on 3/10/16.
//  Copyright © 2016 TOKOPEDIA. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface UploadReviewImageResult : NSObject

@property (nonatomic, strong) NSString *success;
@property (nonatomic, strong) NSString *message_status;
@property (nonatomic, strong) NSString *server_id;
@property (nonatomic, strong) NSString *pic_src;
@property (nonatomic, strong) NSString *pic_obj;

+ (RKObjectMapping*)mapping;

@end
