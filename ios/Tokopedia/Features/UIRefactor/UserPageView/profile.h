//
//  profile.h
//  Tokopedia
//
//  Created by IT Tkpd on 10/15/14.
//  Copyright (c) 2014 TOKOPEDIA. All rights reserved.
//

#ifndef Tokopedia_profile_h
#define Tokopedia_profile_h

typedef enum
{
    TYPE_ADD_EDIT_PROFILE_DEFAULT = 0,
    TYPE_ADD_EDIT_PROFILE_EDIT,
    TYPE_ADD_EDIT_PROFILE_ADD_NEW,
    TYPE_ADD_EDIT_PROFILE_ATC,
    TYPE_ADD_EDIT_PROFILE_EDIT_RESO,
    TYPE_ADD_EDIT_PROFILE_ADD_RESO
} TYPE_ADD_EDIT_PROFILE;

#define kTKPDPROFILEEDIT_TITLE @"Atur Profil"
#define ktkpdAddBankAccount @"Tambah Akun"
#define kTKPDPROFILEEDITPHONEConfirmed_TITLE @"Confirmed Phone Number"
#define kTKPDPROFILESAVE @"Simpan"
#define kTKPDPROFILEEDIT @"Ubah"

#define kTKPDPROFILESETTING_TITLE @"Settings"
#define kTKPDPROFILESETTINGNOTIFICATION_TITLE @"Setting Notification"
#define kTKPDPROFILESETTINGPRIVACY_TITLE @"Setting Privacy"
#define kTKPDPROFILESETTINGPASSWORD_TITLE @"Ubah Kata Sandi"
#define kTKPDPROFILESETTINGBANKACCOUNT_TITLE @"Setting Bank Account"
#define kTKPDPROFILESETTINGADDRESS_TITLE @"Setting Address"
#define TITLE_NEW_ADDRESS @"Tambah Alamat"
#define TITLE_ATC_ADDRESS @"Pilih Alamat"
#define TITLE_EDIT_ADDRESS @"Ubah Alamat"
#define TITLE_LIST_ADDRESS @"Daftar Alamat"
#define TITLE_DETAIL_ADDRESS_DEFAULT @"Alamat"
#define TITLE_LIST_BANK @"Daftar Rekening Bank"
#define TITLE_NEW_BANK @"Tambah Rekening Bank"
#define TITLE_EDIT_BANK @"Ubah Rekening Bank"
#define TITLE_DETAIL_BANK_DEFAULT @"Rekening Bank"
#define TITLE_SETTING_PROFILE_MENU @"Pengaturan Profil"
#define TITLE_SETTING_NOTIFICATION @"Notifikasi"
#define TITLE_SETTING_PRIVACY @"Pengaturan Privasi"

#define kTKPDPROFILE_DATAPROFILEKEY @"dataprofile"
#define kTKPDPROFILE_DATAADDRESSKEY @"dataaddress" //for address detail delegate
#define kTKPDPROFILE_DATABANKKEY @"databank" //for bank account detail delegate
#define kTKPDPROFILESETTING_DATAPRIVACYKEY @"dataprivacy"
#define kTKPDPROFILESETTING_DATAPRIVACYTYPEKEY @"dataprivacytype"
#define kTKPDPROFILESETTING_DATAPRIVACYTITILEKEY @"dataprivacytitle"
#define kTKPDPROFILEEDIT_DATAPHONENUMBERKEY @"phonenumber"
#define kTKPDPROFILE_DATAINDEXPATHKEY @"indexpath"
#define kTKPDPROFILE_DATAINDEXPATHDEFAULTKEY @"indexpathdefault" 
#define kTKPDPROFILE_DATAINDEXPATHDELETEKEY @"indexpathdelete"
#define kTKPDPROFILE_DATADELETEDOBJECTKEY @"datadeletedobject"
#define kTKPDPROFILE_DATAISDEFAULTKEY @"isdefault" //for manual set default data
#define kTKPDPROFILE_DATALOCATIONTYPEKEY @"locationtype"
#define kTKPDPROFILE_DATAEDITTYPEKEY @"edittype"
#define kTKPDPROFILE_DATABANKINDEXPATHKEY @"bankindexpath"
#define kTKPDPROFILE_DATALOCATIONNAMEKEY @"locationname"
#define kTKPDPROFILE_DATABANKACCOUNT @"bankaccount"
#define kTKPDPROFILE_UNSETORIGIN @"Pilih"

#define DATA_LIST_BANK_ACOUNT_KEY @"list_bank_account"

#pragma mark - Action
#define kTKPDPROFILE_APIGETFAVORITESHOPKEY @"get_favorit_shop"
#define kTKPDPROFILE_APIGETPROFILEINFOKEY @"get_people_info"
#define kTKPDPROFILE_APIUPLOADPROFILEIMAGEKEY @"upload_profile_image"
#define kTKPDPROFILE_APIUPLOADGENERATEHOSTKEY @"generate_host"
#define kTKPDPROFILE_APIGETPROFILEFORMKEY @"get_profile_form"
#define kTKPDPROFILE_APISETUSERPROFILEKEY @"set_user_profile"
#define kTKPDPROFILE_APIEDITPROFILEKEY  @"edit_profile"
#define kTKPDPROFILE_APIUPLOADPROFILEPICTUREKEY    @"upload_profile_picture"
#define kTKPDPROFILE_APISETPASSWORDKEY @"set_password"
#define kTKPDPROFILE_APIEDITPASSWORDKEY @"edit_password"
#define kTKPDPROFILE_APISETEMAILNOTIFKEY @"set_email_notification"
#define kTKPDPROFILE_APIEDITNOTIFICATIONKEY @"edit_notification"
#define kTKPDPROFILE_APIGETEMAILNOTIFKEY @"get_notification"
#define kTKPDPROFILE_APIGETPRIVACYKEY @"get_privacy_form"
#define kTKPDPROFILE_APISETPRIVACYKEY @"get_privacy"
#define kTKPDPROFILE_APIGETUSERADDRESSKEY @"get_address"
#define kTKPDPROFILE_APISETDEFAULTADDRESSKEY @"edit_default_address"
#define kTKPDPROFILE_APIADDADDRESSKEY @"add_address"
#define kTKPDPROFILE_APIEDITADDRESSKEY @"edit_address"
#define kTKPDPROFILE_APIDELETEADDRESSKEY @"delete_address"
#define kTKPDPROFILE_APIGETUSERBANKACCOUNTKEY @"get_bank_account"
#define kTKPDPROFILE_APISETDEFAULTBANKACCOUNTKEY @"set_default_bank_account"
#define kTKPDPROFILE_APIEDITDEFAULTBANKACCOUNTKEY @"edit_default_bank_account"
#define ACTION_GET_DEFAULT_BANK_ACCOUNT_KEY @"get_default_bank_account"
#define ACTION_GET_DEFAULT_BANK @"get_default_bank_account"
#define kTKPDPROFILE_APIADDBANKKEY @"add_bank_account"
#define kTKPDPROFILE_APIEDITBANKKEY @"edit_bank_account"
#define kTKPDPROFILE_APIDELETEBANKKEY @"delete_bank_account"
#define ACTION_SEND_OTP @"send_otp"

#define kTKPDPROFILE_APIUSERIDKEY @"user_id"
#define kTKPDPROFILE_APIACTIONKEY @"action"
#define kTKPDPROFILE_APIPAGEKEY @"page"
#define kTKPDPROFILE_APILIMITKEY @"per_page"
#define API_QUERY_KEY @"query"

#define kTKPDPROFILE_APISHOPTOTALETALASEKEY @"shop_total_etalase"
#define kTKPDPROFILE_APISHOPIMAGEKEY @"shop_image"
#define kTKPDPROFILE_APISHOPLOCATIONKEY @"shop_location"
#define kTKPDPROFILE_APISHOPIDKEY @"shop_id"
#define kTKPDPROFILE_APISHOPTOTALSOLDKEY @"shop_total_sold"
#define kTKPDPROFILE_APISHOPTOTALPRODUCTKEY @"shop_total_product"
#define kTKPDPROFILE_APISHOPNAMEKEY @"shop_name"
#define kTKPDPROFILE_APIURINEXTKEY @"uri_next"

#define kTKPDPROFILE_APIUSERINFOKEY @"user_info"
#define kTKPDPROFILE_APIDATAUSERKEY @"data_user"
#define kTKPDPROFILE_APIUSEREMAILKEY @"user_email"
#define kTKPDPROFILE_APIUSERMESSENGERKEY @"user_messenger"
#define kTKPDPROFILE_APIUSERHOBBIESKEY @"user_hobbies"
#define kTKPDPROFILE_APIUSERPHONEKEY @"user_phone"
#define kTKPDPROFILE_APIPROFILEUSERIDKEY @"profile_user_id"
#define kTKPDPROFILE_APIUSERIMAGEKEY @"user_image"
#define kTKPDPROFILE_APIUSERNAMEKEY @"user_name"
#define kTKPDPROFILE_APIUSERBIRTHKEY @"user_birth"
#define kTKPDPROFILE_APIPASSKEY @"user_password"
#define kTKPDPROFILE_APIHOBBYKEY @"hobby"
#define kTKPDPROFILE_APIBIRTHDAYKEY @"birth_day"
#define kTKPDPROFILE_APIFULLNAMEKEY @"full_name"
#define kTKPDPROFILE_APIBIRTHMONTHKEY @"birth_month"
#define kTKPDPROFILE_APIBIRTHYEARKEY @"birth_year"
#define kTKPDPROFILE_APIGENDERKEY @"gender"
#define kTKPDPROFILE_APIEMAILKEY @"email"
#define kTKPDPROFILE_APIMESSENGERKEY @"messenger"
#define kTKPDPROFILE_APIMSISDNKEY  @"msisdn"
#define kTKPDPROFILE_APIFILEUPLOADEDKEY @"file_uploaded"

#define kTKPDPROFILESETTING_APIUSERIDKEY @"user_id"
#define kTKPDPROFILESETTING_APIPASSKEY @"password"
#define kTKPDPROFILESETTING_APINEWPASSKEY @"new_password"
#define kTKPDPROFILESETTING_APIPASSCONFIRMKEY @"confirm_password"

#define kTKPDPROFILESETTING_APINOTIFICATIONKEY @"notification"
#define kTKPDPROFILESETTING_APIFLAGNEWSLATTERKEY @"flag_newsletter"
#define kTKPDPROFILESETTING_APIFLAGREVIEWKEY @"flag_review"
#define kTKPDPROFILESETTING_APIFLAGTALKPRODUCTKEY @"flag_talk_product"
#define kTKPDPROFILESETTING_APIFLAGMESSAGEKEY @"flag_message"
#define kTKPDPROFILESETTING_APIFLAGADMINMESSAGEKEY @"flag_admin_message"

#define kTKPDPROFILESETTING_APIPRIVACYKEY @"privacy"
#define kTKPDPROFILESETTING_APIFLAGMESSEGERKEY @"flag_messenger"
#define kTKPDPROFILESETTING_APIFLAGHPKEY @"flag_hp"
#define kTKPDPROFILESETTING_APIFLAGEMAILKEY @"flag_email"
#define kTKPDPROFILESETTING_APIFLAGBIRTHDATEKEY @"flag_birthdate"
#define kTKPDPROFILESETTING_APIFLAGADDRESSKEY @"flag_address"

#define kTKPDPROFILESETTING_APICOUNTRYNAMEKEY @"country_name"
#define kTKPDPROFILESETTING_APIRECEIVERNAMEKEY @"receiver_name"
#define kTKPDPROFILESETTING_APIADDRESSNAMEKEY @"address_name"
#define kTKPDPROFILESETTING_APIADDRESSIDKEY @"address_id"
#define kTKPDPROFILESETTING_APIRECEIVERPHONEKEY @"receiver_phone"
#define kTKPDPROFILESETTING_APIPROVINCENAMEKEY @"province_name"
#define kTKPDPROFILESETTING_APIPOSTALCODEKEY @"postal_code"
#define API_POSTAL_CODE_CART_KEY @"address_postal"
#define kTKPDPROFILESETTING_APIADDRESSSTATUSKEY @"address_status"
#define kTKPDPROFILESETTING_APIADDRESSSTREETKEY @"address_street"
#define kTKPDPROFILESETTING_APIDISTRICNAMEKEY @"district_name"
#define kTKPDPROFILESETTING_APICITYNAMEKEY @"city_name"
#define kTKPDPROFILESETTING_APICITYIDKEY @"city_id"
#define kTKPDPROFILESETTING_APIPROVINCEIDKEY @"province_id"
#define kTKPDPROFILESETTING_APIDISTRICTIDKEY @"district_id"
#define kTKPDPROFILESETTING_APICITYKEY @"city"
#define kTKPDPROFILESETTING_APIPROVINCEKEY @"province"
#define kTKPDPROFILESETTING_APIDISTRICTKEY @"district"
#define kTKPDPROFILESETTING_APIUSERPASSWORDKEY @"user_password"
#define API_ADDRESS_COUNTRY @"address_country"
#define API_ADDRESS_POSTAL @"address_postal"
#define API_ADDRESS_DISTRICT @"address_district"
#define API_ADDRESS_CITY @"address_city"
#define API_ADDRESS_PROVINCE @"address_province"

#define API_BANK_ACCOUNT_KEY @"bank_account"
#define kTKPDPROFILESETTING_APIBANKIDKEY @"bank_id"
#define API_BANK_NAME_KEY @"bank_name"
#define API_BANK_ACCOUNT_NAME_KEY @"bank_account_name"
#define API_BANK_OWNER_ID_KEY @"bank_owner_id"
#define kTKPDPROFILESETTING_APIACCOUNTIDKEY @"account_id"
#define kTKPDPROFILESETTING_APIACCOUNTNAMEKEY @"account_name"
#define kTKPDPROFILESETTING_APIBANKACCOUNTNUMBERKEY @"bank_account_number"
#define kTKPDPROFILESETTING_APIACCOUNTNUMBERKEY @"account_no"
#define kTKPDPROFILESETTING_APIBANKBRANCHKEY @"bank_branch"
#define API_BANK_ACCOUNT_ID_KEY @"bank_account_id"
#define API_ACCOUNT_ID_KEY @"account_id"
#define kTKPDPROFILESETTING_APIISDEFAULTBANKKEY @"is_default_bank"
#define kTKPDPROFILESETTING_APIISVERIFIEDBANKKEY @"is_verified_account"
#define API_DEFAULT_BANK_KEY @"default_bank"
#define API_OWNER_ID_KEY @"owner_id"
#define kTKPDPROFILESETTING_APIOTPCODEKEY @"otp_code"

#define kTKPDPROFILE_APIISSUCCESSKEY @"is_success"

#define kTKPDPROFILE_APIUPLOADFILEPATHKEY @"file_path"
#define kTKPDPROFILE_APIUPLOADFILETHUMBKEY @"file_th"

#define kTKPDPROFILE_APIPROFILEPHOTOKEY @"profile_img"

#define kTKPDGENERATEDHOST_APIGENERATEDHOSTKEY @"generated_host"
#define kTKPDGENERATEDHOST_APISERVERIDKEY @"server_id"
#define kTKPDGENERATEDHOST_APIUPLOADHOSTKEY @"upload_host"
#define kTKPDGENERATEDHOST_APIUSERIDKEY @"user_id"

#define API_UPLOAD_PROFILE_IMAGE_DATA_NAME @"profile_img"

#define kTKPDPROFILESETTINGADDRESS_LIMITPAGE 5
#define kTKPDPROFILESETTINGBANKACCOUNT_LIMITPAGE 5

#define MINIMUM_PHONE_CHARACTER_COUNT 6
#define MAXIMUM_PHONE_CHARACTER_COUNT 20
#define ERRORMESSAGE_NULL_PASSWORD @"Kata sandi harus diisi."
#define ERRORMESSAGE_NULL_RECEIVER_NAME @"Nama penerima harus diisi."
#define ERRORMESSAGE_NULL_ADDRESS_NAME @"Nama alamat harus diisi."
#define ERRORMESSAGE_NULL_ADDRESS @"Alamat harus diisi."
#define ERRORMESSAGE_NULL_POSTAL_CODE @"Kode pos harus diisi."
#define ERRORMESSAGE_NULL_PROVINCE @"Provinsi harus diisi."
#define ERRORMESSAGE_NULL_REGECY @"Kotamadya/Kabupaten harus diisi."
#define ERRORMESSAGE_NULL_SUB_DISTRIC @"Kecamatan harus diisi."
#define ERRORMESSAGE_NULL_RECIEPIENT_PHONE @"Nomor telepon penerima harus diisi."
#define ERRORMESSAGE_NULL_ACCOUNT_NAME @"Nama akun harus diisi."
#define ERRORMESSAGE_NULL_BANK_NAME @"Nama bank harus diisi."
#define ERRORMESSAGE_NULL_BANK_BRANCH @"Cabang harus diisi."
#define ERRORMESSAGE_NULL_REKENING_NUMBER @"Nomor rekening harus diisi."

#define ERRORMESSAGE_PASSWORD_TOO_SHORT @"Password yang anda masukkan terlalu pendek. Minimum 6 karakter."

#define ERRORMESSAGE_INVALID_PHONE_CHARACTER_TOO_SHORT @"Nomor telepon penerima terlalu pendek. Minimum 6 karakter."
#define ERRORMESSAGE_INVALID_PHONE_CHARACTER_TOO_LONG @"Nomor telepon penerima terlalu panjang. Maksimum 20 karakter."
#define ERRORMESSAGE_INVALID_HOBBY_CHARACTER_COUNT @"Hobi terlalu panjang. Maksimum 128 karakter."

#define kTKPDPROFILE_STANDARDTABLEVIEWCELLIDENTIFIER @"cell"
#define kTKPDPROFILE_NODATACELLTITLE @"no data"
#define kTKPDPROFILE_NODATACELLDESCS @"no data description"

#define kTKPDPROFILE_PEOPLEAPIPATH @"people.pl"
#define kTKPDPROFILE_SETTINGAPIPATH kTKPDPROFILE_PEOPLEAPIPATH
#define kTKPDPROFILE_UPLOADIMAGEAPIPATH @"action/upload-image.pl"
#define kTKPDPROFILE_PROFILESETTINGAPIPATH @"action/people.pl"
#define kTKPD_SETTING_API_PATH @"action/setting.pl"
#define API_OTP_PATH @"action/otp.pl"

#define kTKPD_DEPOSIT_API_PATH  @"action/deposit.pl"
#define kTKPD_DEPOSIT_VERIFY_BANK_ACCOUNT   @"send_otp_verify_bank_account"
#define kTKPD_DEPOSIT_EDIT_BANK_ACCOUNT   @"send_otp_edit_bank_account"

#define kTKPDPROFILE_VERIFICATIONNUMBERAPIPATH  @"action/verification-number.pl"
#define kTKPDPROFILE_SEND_EMAIL_CHANGE_PHONE_NUMBER @"send_email_change_phone_number"

#define kTKPDPROFILE_CACHEFILEPATH @"profile"
#define kTKPDPROFILE_APIRESPONSEFILEFORMAT @"profile%zd"
#define kTKPDPFAVORITESHOP_APIRESPONSEFILEFORMAT @"profilefavshop%zd"

#define ARRAY_GENDER @[@{DATA_NAME_KEY:@"Pria", DATA_VALUE_KEY:@(1)}, @{DATA_NAME_KEY:@"Wanita", DATA_VALUE_KEY:@(2)}]
#define ARRAY_LIST_MENU_SETTING_PROFILE @[@[@"Ubah Kata Sandi"],@[@"Biodata Diri" ,@"Daftar Alamat", @"Akun Bank", @"Notifikasi"], @[@"Touch ID"]]

#define kTKPDPROFILE_DATAGENDERARRAYKEY @[@"Pria",@"Wanita"]
#define kTKPDPROFILE_DATAGENDERVALUEARRAYKEY @[@"1",@"2"]

#define kTKPDPROFILE_DATAPRIVACYARRAYKEY @[@"Do not show", @"Show to public"]

#define ARRAY_LIST_NOTIFICATION @[@"Buletin",@"Review",@"Diskusi Produk",@"Pesan Pribadi",@"Pesan Pribadi dari Admin"]
#define ARRAY_LIST_NOTIFICATION_DESCRIPTION @[@"Setiap promosi, tips & tricks, informasi update seputar Tokopedia", @"Setiap Review dan  Komentar yang saya terima",@"Setiap Diskusi Produk dan Komentar yang saya terima", @"Setiap pesan pribadi yang saya terima", @"Setiap pesan pribadi dari admin yang saya terima"]
#define ARRAY_LIST_PRIVACY @[@"Tampilkan Tanggal Lahir", @"Tampilkan Email", @"Tampilkan YM", @"Tampilkan Nomor HP", @"Tampilkan Alamat"]

#define kTKPDPROFILEEDIT_DATEOFBIRTHFORMAT @"%@ / %@ / %@"

#define kTKPDLOGIN_API_MSISDN_IS_VERIFIED_KEY @"msisdn_is_verified"

#endif
