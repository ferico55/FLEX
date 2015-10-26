//
//  camera.h
//  Tokopedia
//
//  Created by IT Tkpd on 10/30/14.
//  Copyright (c) 2014 TOKOPEDIA. All rights reserved.
//

#ifndef Tokopedia_camera_h
#define Tokopedia_camera_h

#define kTKPDCAMERA_RAD(angle) ((angle) / 180.0 * M_PI)

#define kTKPDCAMERACROP_ZOOMANDCROPTITLE @"Crop Image"

#pragma mark - Data
#define kTKPDCAMERA_DATACAMERAKEY @"camera"
#define kTKPDCAMERA_DATAPHOTOTYPEKEY @"phototype"
#define kTKPDCAMERA_DATAMEDIATYPEKEY @"mediatype"
#define kTKPDCAMERA_DATAPHOTOACCESSKEY @"photoaccess"
#define kTKPDCAMERA_DATAPHOTOKEY @"photo"
#define DATA_CAMERA_PICKER_INFO @"camerainfo"
#define DATA_CAMERA_IMAGEDATA @"cameraimagedata"
#define DATA_CAMERA_SOURCE_TYPE @"source_type"
#define DATA_CAMERA_IMAGENAME @"cameraimagename"
#define kTKPDCAMERA_DATARAWPHOTOKEY @"rawphoto"
#define kTKPDCAMERA_DATAPHOTOIDKEY @"photo_id"
#define kTKPDCAMERA_DATAUSERINFOKEY @"userinfo"
#define kTKPDCAMERA_DATAPHOTOCAPTIONKEY @"photo_caption"
#define kTKPDCAMERA_DATASENDERKEY @"sender"
#define kTKPDCAMERA_DATAUSERINFOKEY @"userinfo"
#define kTKPDCAMERA_DATACOMMENTKEY @"comment"

#define kTKPDCAMERACROP_CROPDEFAULTRECT CGRectMake (0.0f, 0.0f, 320.0f, 320.0f)

#define kTKPDCAMERA_UPLOADEDIMAGERECT kTKPDCAMERACROP_CROPDEFAULTRECT
#define kTKPDCAMERA_UPLOADEDIMAGESIZE CGSizeMake(320, 568)
#define kTKPDCAMERA_MAXIMAGESIZE CGSizeMake(320, 568)

#endif
