//
//  AttachedPicture.m
//  Tokopedia
//
//  Created by Kenneth Vincent on 3/30/16.
//  Copyright © 2016 TOKOPEDIA. All rights reserved.
//

#import "AttachedPicture.h"

@implementation AttachedPicture

-(id)copyWithZone:(NSZone *)zone
{
    AttachedPicture *object = [[AttachedPicture alloc] init];
    object.image = _image;
    object.fileName = _fileName;
    object.thumbnailUrl = _thumbnailUrl;
    object.largeUrl = _largeUrl;
    object.imageDescription = _imageDescription;
    object.attachmentID = _attachmentID;
    object.isDeleted = _isDeleted;
    object.isPreviouslyUploaded = _isPreviouslyUploaded;
    object.asset = _asset;
    
    return object;
}

@end
