//
//  string_alert.h
//  Tokopedia
//
//  Created by IT Tkpd on 10/8/14.
//  Copyright (c) 2014 TOKOPEDIA. All rights reserved.
//

#ifndef Tokopedia_string_alert_h
#define Tokopedia_string_alert_h

typedef enum
{
    kTKPDALERT_DATAALERTTYPEDEFAULTKEY = 0,
    kTKPDALERT_DATAALERTTYPESHOPEDITKEY,
    kTKPDALERT_DATAALERTTYPEREGISTERKEY,
    kTKPDALERT_DATAALERTTYPECLOSESHOPKEY
}kTKPDALERT_DATAALERTTYPEKEY;

#define kTKPDALERTVIEW_DATALISTKEY @"list"
#define kTKPDALERTVIEW_BUTTON1KEY @"button1"
#define kTKPDALERTVIEW_BUTTON2KEY @"button2"
#define kTKPDALERTVIEW_DATATYPEKEY @"type"

#define kTKPDALERTVIEW_DATADATEPICKERKEY @"datepicker"
#define DATA_INDEX_KEY @"index"
#define DATA_INDEX_SECOND_KEY @"second_index"
#define DATA_LABEL_KEY @"label"

#define DATA_NAME_KEY @"name"
#define DATA_VALUE_KEY @"value"
#define CStringMatchChangePass @"Kata sandi baru tidak sesuai dengan konfirmasi"

#endif
