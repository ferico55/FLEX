//
//  Tkpd.h
//  Tokopedia
//
//  Created by IT Tkpd on 8/19/14.
//  Copyright (c) 2014 TOKOPEDIA. All rights reserved.
//

#ifndef Tokopedia_Tkpd_h
#define Tokopedia_Tkpd_h

#define kTkpdBaseURLString @"http://www.tkpdevel-pg.tonito/ws"

#define kTkpdAPIkey @"8b0c367dd3ef0860f5730ec64e3bbdc9" //TODO:: Remove api key

#define is4inch  ([[UIScreen mainScreen] bounds].size.height == 568)?TRUE:FALSE

#define kTkpdIndexSetStatusCodeOK [NSIndexSet indexSetWithIndex:200] //statuscode 200 = OK

#define SYSTEM_VERSION_EQUAL_TO(v)                  ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedSame)
#define SYSTEM_VERSION_GREATER_THAN(v)              ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedDescending)
#define SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(v)  ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedAscending)
#define SYSTEM_VERSION_LESS_THAN(v)                 ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedAscending)
#define SYSTEM_VERSION_LESS_THAN_OR_EQUAL_TO(v)     ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedDescending)
#define iOS7_0 @"7.0"

#define TKPD_FADEANIMATIONDURATION 0.3

#define TKPD_ETALASEPOSTNOTIFICATIONNAME @"setetalase"
#define TKPD_FILTERPRODUCTPOSTNOTIFICATIONNAME @"setfilterProduct"
#define TKPD_FILTERCATALOGPOSTNOTIFICATIONNAME @"setfilterCatalog"
#define TKPD_FILTERDETAILCATALOGPOSTNOTIFICATIONNAME @"setfilterDetailCatalog"
#define TKPD_SETUSERINFODATANOTIFICATIONNAME @"setuserinfo"
#define TKPD_FILTERSHOPPOSTNOTIFICATIONNAME @"setfilterShop"
#define TKPD_SEARCHSEGMENTCONTROLPOSTNOTIFICATIONNAME @"setsegmentcontrol"
#define TKPD_DEPARTMENTIDPOSTNOTIFICATIONNAME @"setDepartmentID"

#endif
