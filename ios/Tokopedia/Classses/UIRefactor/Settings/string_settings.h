//
//  string_settings.h
//  Tokopedia
//
//  Created by IT Tkpd on 12/29/14.
//  Copyright (c) 2014 TOKOPEDIA. All rights reserved.
//

#ifndef Tokopedia_string_settings_h
#define Tokopedia_string_settings_h

typedef enum
{
    TAG_SETTING_ADDRESS_BARBUTTONITEM_BACK = 10,
    TAG_SETTING_ADDRESS_BARBUTTONITEM_DONE = 11,
    TAG_SETTING_ADDRESS_BARBUTTONITEM_ADD = 12
}TAG_SETTING_ADDRESS_BARBUTTONITEM;

#define DATA_TYPE_KEY @"type"
#define DATA_INDEXPATH_KEY @"indexpath"
#define DATA_ADDRESS_DETAIL_KEY @"address"

#define TKPD_FORGETPASS_ACTION @"reset_password"
#define TKPD_FORGETPASS_PATH @"action/general-usage.pl"

#define TKPD_FORGETPASS_TITLE @"Lupa Kata Sandi"


#endif
