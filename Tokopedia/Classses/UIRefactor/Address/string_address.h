//
//  string_address.h
//  Tokopedia
//
//  Created by IT Tkpd on 11/25/14.
//  Copyright (c) 2014 TOKOPEDIA. All rights reserved.
//

#ifndef Tokopedia_string_address_h
#define Tokopedia_string_address_h

typedef enum
{
    kTKPDLOCATION_DATATYPEDEFAULTVIEWKEY = 0,
    kTKPDLOCATION_DATATYPEPROVINCEKEY,
    kTKPDLOCATION_DATATYPEDISTICTKEY,
    kTKPDLOCATION_DATATYPEREGIONKEY
} kTKPDSHOPLOCATIONTYPE;

#define kTKPDLOCATION_DATALOCATIONTYPEKEY @"type"

#define kTKPDLOCATION_DATACITYIDKEY @"city_id"
#define kTKPDLOCATION_DATAPROVINCEIDKEY @"province_id"

#define DATA_SELECTED_LOCATION_KEY @"data_selected_location"
#define DATA_NAME_KEY @"Name"
#define DATA_ID_KEY @"ID"

#endif
