//
//  string.h
//  tokopedia
//
//  Created by IT Tkpd on 8/14/14.
//  Copyright (c) 2014 TOKOPEDIA. All rights reserved.
//

#ifndef tokopedia_string_h
#define tokopedia_string_h

#define kTKPD_AUTHKEY @"auth"

#define kTKPDREQUEST_OKSTATUS @"OK"
#define kTKPDREQUEST_NGSTATUS @"NG"

#define kTKPDREQUEST_ISLOGIN_FALSE  @"false"
#define kTKPDREQUEST_ISLOGIN_TRUE   @"true"

#define kTKPDREQUESTCOUNTMAX 3

#define kTKPDREQUEST_TIMEOUTINTERVAL 15.0
#define kTKPDREQUEST_STICKYFADEOUTINTERVAL 3.0
#define kTKPDREQUEST_DELAYINTERVAL 3.0

#define kTKPDREQUEST_REFRESHMESSAGE @""

#define kTKPDOBSERVER_WISHLIST @"wishlist_observer"
#define kTKPD_APIERRORMESSAGEKEY @"message_error"
#define kTKPD_APISTATUSKEY @"status"
#define kTKPD_APISERVERPROCESSTIMEKEY @"server_process_time"
#define kTKPD_APIISSUCCESSKEY @"is_success"
#define kTKPD_FILE_UPLOADED @"file_uploaded"
#define API_TOKEN_KEY @"token"

#define kTKPD_APIRESULTKEY @"result"
#define kTKPD_APIUPLOADKEY @"upload"
#define kTKPD_APIPAGINGKEY @"paging"
#define API_PAGE_KEY @"page"
#define kTKPD_APIURINEXTKEY @"uri_next"
#define kTKPD_APILISTKEY @"list"
#define kTKPD_APIERRORMESSAGEKEY @"message_error"
#define kTKPD_APISTATUSMESSAGEKEY @"message_status"
#define kTKPD_APIISSUCCESSKEY @"is_success"

#define kTKPDMESSAGE_SUCCESSMESSAGEDEFAULTKEY @"Permintaan Anda berhasil."
#define kTKPDMESSAGE_ERRORMESSAGEDEFAULTKEY @"Permintaan Anda gagal. Cobalah beberapa saat lagi."
#define kTKPDMESSAGE_ERRORMESSAGEDATEKEY @"Rentang waktu maksimal pemeriksaan mutasi adalah 31 hari."

#define kTKPDMESSAGE_SUCCESSEDITPROFILEMESSAGEKEY   @"Anda telah berhasil mengubah profil."
#define kTKPDMESSAGE_ERROREDITPROFILEMESSAGEKEY @"Gagal mengubah profil."

#define CStringBerhasilMemperbaharuiUlasan @"Anda telah berhasil memperbaharui ulasan"
#define CStringBerhasilMenambahUlasan @"Anda berhasil menambahkan ulasan"
#define CStringGagalMemperbaharuiUlasan @"Gagal memperbaharui ulasan"
#define CStringGagalMenambahUlasan @"Gagal menambahkan ulasan"

#define CStringBerhasilMenghapusKomentarDiskusi @"Anda telah berhasil menghapus komentar"

#define kTKPDNETWORK_ERRORTITLE @"Network Error"
#define kTKPDNETWORK_ERRORDESCS @"The Internet connection appears to be offline."
#define kTKPDBUTTON_OKTITLE @"OK"

#define kTKPD_PARAMETERSKEY @"parameters"

#define kTKPDMESSAGE_SUCCESSMESSAGEDEFAULT @"Sukses"
#define kTKPDMESSAGE_ERRORMESSAGEDEFAULT @"Error"
#define ERROR_TITLE @"ERROR"
#define ERROR_CANCEL_BUTTON_TITLE @"OK"
#define ERROR_REQUEST_TIMEOUT @"Request Timeout"
#define CStringFailedInServer @"Server error"
#define CStringNoConnection @"Tidak ada koneksi internet"


#define TKPD_SUCCESS_VALUE @"1"

#define TEXT_COLOUR_DEFAULT_CELL_TEXT [UIColor colorWithRed:66.0/255.0 green:66.0/255.0 blue:66.0/255.0 alpha:1.0]

#define TEXT_COLOUR_DISABLE [UIColor colorWithRed:158.0/255.0 green:158.0/255.0 blue:158.0/255.0 alpha:1.0]
#define TEXT_COLOUR_ENABLE [UIColor colorWithRed:0.0/255.0 green:122.0/255.0 blue:255.0/255.0 alpha:1.0]

#define USER_LAYOUT_PREFERENCES @"USER_LAYOUT_PREFERENCES"

#endif