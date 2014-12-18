//
//  UploadImageResult.h
//  Tokopedia
//
//  Created by IT Tkpd on 10/30/14.
//  Copyright (c) 2014 TOKOPEDIA. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface UploadImageResult : NSObject

@property (nonatomic) NSInteger pic_id;
@property (nonatomic, strong) NSString *file_path;
@property (nonatomic, strong) NSString *file_th;

@end
