//
//  Tkpd.h
//  Tokopedia
//
//  Created by IT Tkpd on 8/19/14.
//  Copyright (c) 2014 TOKOPEDIA. All rights reserved.
//

#ifndef Tokopedia_Tkpd_h
#define Tokopedia_Tkpd_h

#define kTkpdBaseURLString @"http://www.tkpdevel-pg.api/ws"

#define kTkpdAPIkey @"8b0c367dd3ef0860f5730ec64e3bbdc9" //TODO:: Remove api key
#define kTKPD_AUTHKEY @"auth"

#define kTKPD_AUTHKEY @"auth"
#define kTKPD_ISLOGINKEY @"is_login"
#define kTKPD_USERIDKEY @"user_id"
#define kTKPD_SHOPIDKEY @"shop_id"
#define kTKPD_FULLNAMEKEY @"full_name"

#define is4inch  ([[UIScreen mainScreen] bounds].size.height == 568)?TRUE:FALSE

#define kTkpdIndexSetStatusCodeOK [NSIndexSet indexSetWithIndex:200] //statuscode 200 = OK

#define SYSTEM_VERSION_EQUAL_TO(v)                  ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedSame)
#define SYSTEM_VERSION_GREATER_THAN(v)              ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedDescending)
#define SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(v)  ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedAscending)
#define SYSTEM_VERSION_LESS_THAN(v)                 ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedAscending)
#define SYSTEM_VERSION_LESS_THAN_OR_EQUAL_TO(v)     ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedDescending)
#define iOS7_0 @"7.0"

#define TKPD_FADEANIMATIONDURATION 0.3

#define kTKPD_ETALASEPOSTNOTIFICATIONNAMEKEY @"setetalase"
#define kTKPD_FILTERPRODUCTPOSTNOTIFICATIONNAMEKEY @"setfilterProduct"
#define kTKPD_FILTERCATALOGPOSTNOTIFICATIONNAMEKEY @"setfilterCatalog"
#define kTKPD_FILTERDETAILCATALOGPOSTNOTIFICATIONNAMEKEY @"setfilterDetailCatalog"
#define kTKPD_SETUSERINFODATANOTIFICATIONNAMEKEY @"setuserinfo"
#define kTKPD_SETUSERSTICKYERRORMESSAGEKEY @"stickyerrormessage"
#define kTKPD_SETUSERSTICKYSUCCESSMESSAGEKEY @"stickysuccessmessage"

#define kTKPD_FILTERSHOPPOSTNOTIFICATIONNAMEKEY @"setfilterShop"
#define kTKPD_SEARCHSEGMENTCONTROLPOSTNOTIFICATIONNAMEKEY @"setsegmentcontrol"
#define kTKPD_DEPARTMENTIDPOSTNOTIFICATIONNAMEKEY @"setDepartmentID"

#define kTKPD_CROPIMAGEPOSTNOTIFICATIONNAMEKEY @"tokopedia.kTKPD_CROPIMAGEPOSTNOTIFICATIONNAMEKEY"

#define kTKPD_ADDETALASEPOSTNOTIFICATIONNAMEKEY @"tokopedia.kTKPD_ADDETALASEPOSTNOTIFICATIONNAMEKEY"
#define kTKPD_ADDADDRESSPOSTNOTIFICATIONNAMEKEY @"tokopedia.kTKPD_ADDADDRESSPOSTNOTIFICATIONNAMEKEY"
#define kTKPD_ADDLOCATIONPOSTNOTIFICATIONNAMEKEY @"tokopedia.kTKPD_ADDLOCATIONPOSTNOTIFICATIONNAMEKEY"
#define kTKPD_ADDNOTEPOSTNOTIFICATIONNAMEKEY @"tokopedia.kTKPD_ADDNOTEPOSTNOTIFICATIONNAMEKEY"


#define kTKPD_EDITPROFILEPOSTNOTIFICATIONNAMEKEY @"tokopedia.kTKPD_EDITPROFILEPOSTNOTIFICATIONNAMEKEY"
#define kTKPD_EDITPROFILEPICTUREPOSTNOTIFICATIONNAMEKEY @"tokopedia.kTKPD_EDITPROFILEPICTUREPOSTNOTIFICATIONNAMEKEY"
#define kTKPD_EDITSHOPPICTUREPOSTNOTIFICATIONNAMEKEY @"tokopedia.kTKPD_EDITSHOPPICTUREPOSTNOTIFICATIONNAMEKEY"

#define kTKPDACTIVATION_DIDAPPLICATIONLOGINNOTIFICATION @"tokopedia.kTKPDACTIVATION_DIDAPPLICATIONLOGINNOTIFICATION"
#define kTKPDACTIVATION_DIDAPPLICATIONLOGOUTNOTIFICATION @"tokopedia.kTKPDACTIVATION_DIDAPPLICATIONLOGOUTNOTIFICATION"
#define kTKPD_INTERRUPTNOTIFICATIONNAMEKEY @"tokopedia.kTKPD_INTERRUPTNOTIFICATIONNAMEKEY"

#define kTKPD_APPLICATIONKEY @"application"
#define kTKPD_INSTALLEDKEY @"installed"

#define TKPD_ISLOGINNOTIFICATIONNAME @"setlogin"

#endif
