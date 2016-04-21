//
//  AttachedPicture.h
//  Tokopedia
//
//  Created by Kenneth Vincent on 3/30/16.
//  Copyright © 2016 TOKOPEDIA. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface AttachedPicture : NSObject

@property (strong, nonatomic) UIImage *image;
@property (strong, nonatomic) NSString *fileName;
@property (strong, nonatomic) NSString *largeUrl;
@property (strong, nonatomic) NSString *thumbnailUrl;
@property (strong, nonatomic) NSString *imageDescription;
@property (strong, nonatomic) NSString *attachmentID;
@property (strong, nonatomic) NSString *isDeleted;
@property (strong, nonatomic) NSString *isPreviouslyUploaded;

@end
