//
//  detail.h
//  Tokopedia
//
//  Created by IT Tkpd on 9/8/14.
//  Copyright (c) 2014 TOKOPEDIA. All rights reserved.
//

#ifndef Tokopedia_detail_h
#define Tokopedia_detail_h

typedef enum
{
    kTKPDDETAIL_DATASTATUSSHOPDELETED = 0,
    kTKPDDETAIL_DATASTATUSSHOPOPEN,
    kTKPDDETAIL_DATASTATUSSHOPCLOSED,
    kTKPDDETAIL_DATASTATUSMODERATED,
    KTKPDDETAIL_DATASTATUSINACTIVE
} kTKPDDETAIL_DATASTATUSSHOPTYPE;

typedef enum
{
    kTKPDSETTINGEDIT_DATATYPEDEFAULTVIEWKEY = 0,
    kTKPDSETTINGEDIT_DATATYPEEDITVIEWKEY,               // edit notes without request detail
    kTKPDSETTINGEDIT_DATATYPENEWVIEWKEY,                // create new note
    kTKPDSETTINGEDIT_DATATYPEDETAILVIEWKEY,             // only see note detail
    kTKPDSETTINGEDIT_DATATYPEEDITWITHREQUESTVIEWKEY,    // can edit notes but need request
    kTKPDSETTINGEDIT_DATATYPENEWVIEWADDPRODUCTKEY,       // for etalase MyShopEtalaseEditViewController
    NOTES_RETURNABLE_PRODUCT                            // untuk notes pengembalian product
} kTKPDEDITSHOPTYPE;

typedef enum
{
    PRESENTED_ETALASE_DEFAULT = 0,
    PRESENTED_ETALASE_ADD_PRODUCT,
    PRESENTED_ETALASE_SHOP_PRODUCT,
    PRESENTED_ETALASE_MANAGE_PRODUCT,
}PRESENTED_ETALASE_TYPE;



#define kTKPDTITLE_TALK @"Diskusi"
#define kTKPDTITLE_REVIEW @"Ulasan"
#define kTKPDTITLE_SHOP_NOTES @"Catatan Toko"
#define kTKPDTITLE_SEND_MESSAGE @"Kirim Pesan"
#define kTKPDTITLE_NEW_TALK @"Diskusi Baru"
#define kTKPDTITLE_SHOP_INFO @"INFORMASI TOKO"
#define KTKPDTITLE_FAV_THIS_SHOP @"Yang Memfavoritkan"
#define KTKPDTITLE_PEOPLE @"Informasi Pengguna"
#define KTKPDTITLE_BIODATA @"BIODATA"

#define TITLE_SHOP_SETTING @"Pengaturan Toko"

#define TITLE_LIST_PRODUCT @"Produk"
#define TITLE_ADD_PRODUCT @"Tambah Produk"
#define TITLE_EDIT_PRODUCT @"Ubah Produk"
#define TITLE_SALIN_PRODUCT @"Salin Produk"

#define kTKPDTITLE_NOTE @"Catatan"
#define kTKPDTILTE_EDIT_NOTE @"Ubah Catatan"
#define kTKPDTITLE_NEW_NOTE @"Tambah Catatan"

#define kTKPDTITLE_LOCATION @"Lokasi Toko"
#define kTKPDTITLE_NEW_LOCATION @"Tambah Lokasi Toko"
#define kTKPDTITLE_EDIT_LOCATION @"Ubah Lokasi Toko"

#define kTKPDTITLE_ETALASE @"Etalase"
#define kTKPDTITLE_NEW_ETALASE @"Tambah Etalase"
#define kTKPDTITLE_EDIT_ETALASE @"Ubah Etalase"

#define kTKPDTITLE_EDIT_INFO @"Ubah Informasi Toko"

#define kTKPTITLE_PAYMENT @"Pembayaran"

#define KTKPDETAIL_DESCRIPTION_EMPTY @"Tidak ada deskripsi"

#define kTKPDDETAIL_DATASHOPSKEY @"shop"
#define kTKPDDETAIL_DATACLOSEDINFOKEY @"closedinfo"
#define kTKPDDETAIL_DATANOTEKEY @"note"
#define kTKPDDETAIL_DATASTATUSSHOPKEY @"statusshop"
#define kTKPDDETAIL_DATAINFOSHOPSKEY @"infoshop"
#define kTKPDDETAIL_DATAINFOLOGISTICKEY @"infologistic"
#define kTKPDDETAIL_DATATYPEKEY @"type"
#define DATA_PRESENTED_ETALASE_TYPE_KEY @"type"
#define kTKPDDETAIL_DATALOCATIONARRAYKEY @"locationarray"
#define kTKPDDETAIL_DATAQUERYKEY @"query"
#define DATA_ETALASE_KEY @"etalase"
#define kTKPDDETAIL_ACTIONKEY @"action"
#define kTKPD_SHOP_LOGO @"shop_logo"
#define kTKPD_OPEN_SHOP @"open_shop"
#define kTKPD_SHOP_SHORT_DESC @"shop_short_desc"
#define kTKPD_SHOP_TAG_LINE @"shop_tag_line"
#define kTKPD_SHOP_COURIER_ORIGIN @"shop_courier_origin"
#define kTKPD_SHOP_POSTAL @"shop_postal"
#define kTKPDDETAIL_DATAINDEXKEY @"index"
#define kTKPDDETAIL_DATAINDEXPATHKEY @"indexpath"
#define kTKPDDETAIL_DATAADDRESSKEY @"dataaddress" //for address detail delegate
#define kTKPDDETAIL_DATAISDEFAULTKEY @"isdefault" //for manual set default data
#define kTKPDDETAIL_DATAINDEXPATHDEFAULTKEY @"indexpathdefault"
#define kTKPDDETAIL_DATAINDEXPATHDELETEKEY @"indexpathdelete"
#define kTKPDDETAIL_DATADELETEDOBJECTKEY @"datadeletedobject"
#define DATA_INPUT_KEY @"datainput"
#define DATA_LAST_DELETED_IMAGE @"deletedimage"
#define DATA_LAST_DELETED_IMAGE_ID @"deletedimageid"
#define DATA_LAST_DELETED_IMAGE_PATH @"deletedimagepath"
#define DATA_LAST_DELETED_INDEX @"deletedimageindex"
#define DATA_WHOLESALE_LIST_KEY @"dataWholesale"
#define DATA_IS_DEFAULT_IMAGE @"isdefaultimage"
#define DATA_IS_GOLD_MERCHANT @"isgoldmerchant"
#define DATA_IMAGE_VIEW_IN_PROGRESS @"imageViewInProgress"

#define kTKPDDETAILETALASE_DATAINDEXPATHKEY @"etalaseindexpath"

#define kTKPDDETAIL_DATACOLUMNKEY @"column"

#define kTKPDDETAIL_APILISTKEYPATH @"result.list"
#define kTKPDDETAIL_APIPAGINGKEYPATH @"result.paging"
#define kTKPDDETAIL_APIRESULTKEY @"result"

#define kTKPDDETAIL_APIACTIONKEY @"action"
#define kTKPDDETAIL_APIPRODUCTIDKEY @"product_id"
#define kTKPDDETAIL_APICATALOGIDKEY @"catalog_id"
#define kTKPDDETAIL_APISHOPIDKEY @"shop_id"


#pragma mark - Get Action
#define kTKPDADD_WISHLIST_PRODUCT @"add_wishlist_product"
#define kTKPDREMOVE_WISHLIST_PRODUCT @"remove_wishlist_product"
#define kTKPDREMOVE_PRODUCT_PRICE_ALERT @"remove_product_price_alert"
#define kTKPDDETAIL_APIGETDETAILACTIONKEY @"get_detail"
#define kTKPDDETAIL_APIGETPRODUCTREVIEWKEY @"get_product_review"
#define kTKPDDETAIL_APIGETPRODUCTTALKKEY @"get_product_talk"
#define kTKPDDETAIL_APIGETCOMMENTBYTALKID @"get_comment_by_talk_id"
#define kTKPDDETAIL_APIGETINBOXDETAIL @"get_inbox_detail_talk"
#define kTKPDDETAIL_APIGETCATALOGDETAILKEY @"get_catalog_detail"
#define kTKPDDETAIL_APIGETSHOPDETAILKEY @"get_shop_info"
#define kTKPDDETAIL_APIGETSHOPPRODUCTKEY @"get_shop_product"
#define kTKPDDETAIL_APIGETSHOPTALKKEY @"get_shop_talk"
#define kTKPDDETAIL_APIGETSHOPREVIEWKEY @"get_shop_review"
#define kTKPDDETAIL_APIGETLIKEDISLIKE @"get_like_dislike_review_shop"

#define kTKPDDETAIL_APIGETSHOPNOTESKEY @"get_shop_notes"
#define kTKPDDETAIL_APIGETSHOPNOTEKEY @"get_shop_note"

#define kTKPDDETAIL_APIGETPAYMENTINFOKEY @"get_payment_info"
#define kTKPDDETAIL_APIUPDATEPAYMENTINFOKEY @"update_payment_info"

#define kTKPDDETAIL_APIGETSHOPFAVORITEDKEY @"get_people_who_favorite_myshop"
#define kTKPDDETAIL_APISETSHOPINFOKEY @"update_shop_info"
#define kTKPDDETAIL_APIUPLOADGENERATEHOSTKEY @"generate_host"
#define kTKPDDETAIL_APIUPLOADSHOPIMAGEKEY @"upload_shop_image"
//Shop Setting Shipping
#define kTKPDDETAIL_APIGETSHOPSHIPPINGINFOKEY @"get_shipping_info"
#define kTKPDDETAIL_APIEDITSHIPPINGINFOKEY @"update_shipping_info"
#define kTKPDDETAIL_APIGET_OPEN_SHOP_FORM @"get_open_shop_form"
//Shop Setting Etalase
#define kTKPDDETAIL_APIGETETALASEKEY @"get_shop_etalase"
#define kTKPDDETAIL_APIDELETEETALASEKEY @"event_shop_delete_etalase"
#define kTKPDDETAIL_APIADDETALASEKEY @"event_shop_add_etalase"
#define kTKPDDETAIL_APIEDITETALASEKEY @"event_shop_edit_etalase"
//Shop Setting Location
#define kTKPDDETAIL_APIGETSHOPLOCATIONKEY @"get_location"
#define kTKPDDETAIL_APIADDSHOPLOCATIONKEY @"add_location"
#define kTKPDDETAIL_APIEDITSHOPLOCATIONKEY @"edit_location"
#define kTKPDDETAIL_APIDELETESHOPLOCATIONKEY @"delete_location"
//Shop Setting Note
#define kTKPDDETAIL_APIGETNOTESDETAILKEY @"get_notes_detail"
#define kTKPDDETAIL_APIADDNOTESDETAILKEY @"add_shop_note"
#define kTKPDDETAIL_APIEDITNOTESDETAILKEY @"edit_shop_note"
#define kTKPDDETAIL_APIDELETENOTESDETAILKEY @"delete_shop_note"
//Shop Setting Product
#define ACTION_GET_PRODUCT_LIST @"manage_product"
#define ACTION_GET_PRODUCT_FORM @"get_edit_product_form"
#define ACTION_ADD_PRODUCT_KEY @"add_product"
#define ACTION_ADD_PRODUCT_VALIDATION @"add_product_validation"
#define ACTION_ADD_PRODUCT_PICTURE @"add_product_picture"
#define ACTION_ADD_PRODUCT_SUBMIT @"add_product_submit"
#define ACTION_EDIT_PRODUCT_KEY @"edit_product"
#define ACTION_MOVE_TO_WAREHOUSE @"move_to_warehouse"
#define ACTION_EDIT_ETALASE @"edit_etalase"
#define kTKPDDETAIL_APIDELETEPRODUCTKEY @"delete_product"
#define ACTION_UPLOAD_PRODUCT_IMAGE @"upload_product_image"
#define ACTION_DELETE_IMAGE @"delete_product_pic"
#define ACTION_GET_CATALOG @"get_catalog"

#define kTKPDDETAIL_APIPAGEKEY @"page"
#define kTKPDDETAIL_APITOTALPAGEKEY @"total_page"
#define kTKPDDETAIL_APILIMITKEY @"per_page"
#define kTKPDDETAIL_APILOCATIONKEY @"location"
#define kTKPDDETAIL_APIADDRESSKEY @"address"
#define kTKPDDETAIL_APICONDITIONKEY @"condition"
#define CStringPictureStatus @"picture_status"
#define kTKPDDETAIL_APIORERBYKEY @"order_by"
#define kTKPDDETAIL_APISORTKEY @"sort"
#define kTKPDDETAIL_APIKEYWORDKEY @"keyword"
#define kTKPDDETAIL_APIETALASEIDKEY @"etalase_id"

#define kTKPDDETAILDEFAULT_LIMITPAGE 5
#define kTKPDDETAILREVIEW_LIMITPAGE 5
#define kTKPDSHOPPRODUCT_LIMITPAGE 6
#define kTKPDSHOPETALASE_LIMITPAGE 5

#define kTKPDDETAIL_DATASHOPTITLEKEY @"Shop"

#define kTKPDDETAIL_APIQUERYKEY @"query"

#define SUCCESSMESSAGE_ADD_LOCATION @"Anda telah berhasil menambah lokasi."
#define SUCCESSMESSAGE_EDIT_LOCATION @"Anda telah berhasil merubah lokasi."


#define kTKPDDETAILPRODUCT_APIPRODUCTCOUNTREVIEWKEY @"product_count_review"
#define kTKPDDETAILPRODUCT_APIPRODUCTCOUNTTALKKEY @"product_count_talk"
#define kTKPDDETAILPRODUCT_APIPRODUCTRATINGPOINTKEY @"product_rating_point"
#define kTKPDDETAILPRODUCT_APIPRODUCTETALASEKEY @"product_etalase"
#define kTKPDDETAILPRODUCT_APIPRODUCTSHOPIDKEY @"product_shop_id"
#define kTKPDDETAILPRODUCT_APIPRODUCTSTATUSKEY @"product_status"
#define kTKPDDETAILPRODUCT_APIPRODUCTIDKEY @"product_id"
#define kTKPDDETAILPRODUCT_APICOUNTSOLDKEY @"product_count_sold"

#define kTKPDDETAILPRODUCT_APICURRENCYKEY @"product_currency"
#define kTKPDDETAILPRODUCT_APIPRODUCTIMAGEKEY @"product_image"
#define kTKPDDETAILPRODUCT_APINORMALPRICEKEY @"product_normal_price"
#define kTKPDDETAILPRODUCT_APIPRODUCTIMAGE300KEY @"product_image_300"
#define kTKPDDETAILPRODUCT_APIPRODUCTDEPARTMENTKEY @"product_department"
#define kTKPDDETAILPRODUCT_APIPRODUCTURKKEY @"product_url"


#define kTKPDDETAILPRODUCT_APIDEFAULTSORTKEY @"default_sort"
#define kTKPDDETAILPRODUCT_APITOTALDATAKEY @"total_data"
#define kTKPDDETAILPRODUCT_APIISPRODUCTMANAGERKEY @"is_product_manager"
#define kTKPDDETAILPRODUCT_APIISTXMANAGERKEY @"is_tx_manager"
#define kTKPDDETAILPRODUCT_APIISINBOXMANAGERKEY @"is_inbox_manager"
#define kTKPDDETAILPRODUCT_APIETALASENAMEKEY @"etalase_name"
#define kTKPDDETAILPRODUCT_APIMENUIDKEY @"menu_id"


#define kTKPDDETAILPRODUCT_APIINFOKEY @"info"
#define API_PRODUCT_INFO_KEY @"product"

#define kTKPDLIMIT_TEXT_DESC 100
#define kTKPDMORE_TEXT @"..."
#define kTKPDDETAILPRODUCT_APIPRODUCTLASTUPDATEKEY @"product_last_update"
#define kTKPDDETAILPRODUCT_APIPRODUCTPRICEALERTKEY @"product_price_alert"
#define kTKPDPRODUCT_ALREADY_WISHLIST @"product_already_wishlist"
#define kTKPDDETAILPRODUCT_APIPRODUCTNAMEKEY @"product_name"
#define kTKPDDETAILPRODUCT_APIPRODUCTURLKEY @"product_url"
#define API_PRODUCT_PRICE_IDR_KEY @"product_price_idr"
#define API_PRODUCT_TOTAL_PRICE_IDR_KEY @"product_total_price_idr"
#define API_PRODUCT_TOTAL_PRICE_KEY @"product_total_price"
#define API_PRODUCT_PICTURE_KEY @"product_pic"
#define API_PRODUCT_MUST_INSURANCE_KEY @"product_must_insurance"

#define API_PRODUCT_WEIGHT_KEY @"product_weight"
#define API_PRODUCT_WEIGHT_UNIT_KEY @"product_weight_unit"

#define kTKPDDETAILPRODUCT_APISTATISTICKEY @"statistic"
#define kTKPDDETAILPRODUCT_APIPRODUCTSOLDKEY @"product_sold_count"
#define kTKPDDETAILPRODUCT_APIPRODUCTTRANSACTIONKEY @"product_transaction_count"
#define kTKPDDETAILPRODUCT_APIPRODUCTSUCCESSRATEKEY @"product_success_rate"
#define kTKPDDETAILPRODUCT_APIPRODUCTVIEWKEY @"product_view_count"
#define kTKPDDETAILPRODUCT_APIPRODUCTRATINGKEY @"product_rating_point"
#define kTKPDDETAILPRODUCT_APIPRODUCTCANCELRATEKEY @"product_cancel_rate"
#define kTKPDDETAILPRODUCT_APIPRODUCTTALKKEY @"product_talk_count"
#define kTKPDDETAILPRODUCT_APIPRODUCTREVIEWKEY @"product_review_count"
#define KTKPDDETAILPRODUCT_APIPRODUCTQUALITYRATEKEY @"product_quality_rate"
#define KTKPDDETAILPRODUCT_APIPRODUCTACCURACYRATEKEY @"product_accuracy_rate"
#define KTKPDDETAILPRODUCT_APIPRODUCTQUALITYPOINTKEY @"product_quality_point"
#define KTKPDDETAILPRODUCT_APIPRODUCTACCURACYPOINTKEY @"product_accuracy_point"


#define kTKPDDETAILPRODUCT_APISHOPINFOKEY @"shop_info"
#define kTKPDDETAILPRODUCT_APIRATINGKEY @"rating"
#define kTKPDDETAILPRODUCT_APISHOPOPENSINCEKEY @"shop_open_since"
#define kTKPDDETAILPRODUCT_APISHOPLOCATIONKEY @"shop_location"
#define kTKPDDETAILPRODUCT_APISHOPLASTLOGINKEY @"shop_owner_last_login"
#define kTKPDDETAILPRODUCT_APISHOPTAGLINEKEY @"shop_tagline"
#define kTKPDDETAILPRODUCT_APISHOPNAMEKEY @"shop_name"
#define kTKPDDETAILPRODUCT_APISHOPURLKEY @"shop_url"
#define kTKPDDETAILPRODUCT_APISHOPHASTERMKEY @"shop_has_terms"
#define kTKPDDETAILPRODUCT_APISHOPSTATUSKEY @"shop_status"
#define kTKPDDETAILPRODUCT_APISHOPCLOSEDUNTIL @"shop_is_closed_until"
#define kTKPDDETAILPRODUCT_APISHOPCLOSEDREASON @"shop_is_closed_reason"
#define kTKPDDETAILPRODUCT_APISHOPCLOSEDNOTE @"shop_is_closed_note"

#define kTKPDDETAILPRODUCT_APISHOPSTATSKEY @"shop_stats"
#define kTKPDDETAILPRODUCT_APISHOPISFAVKEY @"shop_already_favorited"
#define kTKPDDETAILPRODUCT_APISHOPDESCRIPTIONKEY @"shop_description"
#define kTKPDDETAILPRODUCT_APISHOPAVATARKEY @"shop_avatar"
#define kTKPDDETAILPRODUCT_APISHOPDOMAINKEY @"shop_domain"

#define kTKPDDETAILPRODUCT_APISHOPSTATKEY @"shop_stats"
#define kTKPDDETAILPRODUCT_APISHOPSERVICERATEKEY @"shop_service_rate"
#define kTKPDDETAILPRODUCT_APISHOPSERVICEDESCRIPTIONKEY @"shop_service_description"
#define kTKPDDETAILPRODUCT_APISHOPSPEEDRATEKEY @"shop_speed_rate"
#define kTKPDDETAILPRODUCT_APISHOPACURACYRATEKEY @"shop_accuracy_rate"
#define kTKPDDETAILPRODUCT_APISHOPACURACYDESCRIPTIONKEY @"shop_accuracy_description"
#define kTKPDDETAILPRODUCT_APISHOPSPEEDDESCRIPTIONKEY @"shop_speed_description"

#define kTKPDDETAILPRODUCT_APIQUALITYRATE @"product_rating_point"
#define kTKPDDETAILPRODUCT_APIQUALITYSTAR @"product_rating_star_point"
#define kTKPDDETAILPRODUCT_APIACCURACYRATE @"product_rate_accuracy_point"
#define kTKPDDETAILPRODUCT_APIACCURACYSTAR @"product_accuracy_star_rate"


#define kTKPDDETAILPRODUCT_APIBREADCRUMBKEY @"breadcrumb"
#define kTKPDDETAILPRODUCT_APIDEPARTMENTNAMEKEY @"department_name"


#define kTKPDDETAILPRODUCT_APIWHOLESALEMINKEY @"wholesale_min"
#define kTKPDDETAILPRODUCT_APIWHOLESALEPRICEKEY @"wholesale_price"
#define kTKPDDETAILPRODUCT_APIWHOLESALEMAXKEY @"wholesale_max"


#define kTKPDDETAILPRODUCT_APIPRODUCTIMAGESKEY @"product_images"
#define kTKPDDETAILPRODUCT_APIIMAGEIDKEY @"image_id"
#define kTKPDDETAILPRODUCT_APIIMAGESTATUSKEY @"image_status"
#define kTKPDDETAILPRODUCT_APIIMAGEDESCRIPTIONKEY @"image_description"
#define kTKPDDETAILPRODUCT_APIIMAGEPRIMARYKEY @"image_primary"
#define kTKPDDETAILPRODUCT_APIIMAGESRCKEY @"image_src"

#define kTKPDDETAIL_APIWHOLESALEPRICEPATHKEY @"wholesale_price"
#define kTKPDDETAIL_APIBREADCRUMBPATHKEY @"breadcrumb"
#define kTKPDDETAIL_APIOTHERPRODUCTPATHKEY @"other_product"
#define kTKPDDETAIL_APIPRODUCTIMAGEPATHKEY @"product_images"
#define kTKPDDETAIL_APICATALOGIMAGEPATHKEY @"catalog_images"
#define kTKPDDETAIL_APIPRODUCTLISTPATHKEY @"product_list"
#define kTKPDDETAIL_APICATALOGSPECSPATHKEY @"catalog_specs"
#define kTKPDDETAIL_APICATALOGSPECCHILDSPATHKEY @"spec_childs"

#pragma mark - Shop
#define kTKPDDETAILSHOP_APIISOPENKEY @"is_open"

#define kTKPDDETAILSHOP_APICLOSEDINFOKEY @"closed_info"
#define kTKPDDETAILSHOP_APIUNTILKEY @"until"
#define kTKPDDETAILSHOP_APIRESONKEY @"reason"
#define kTKPDDETAILSHOP_APINOTEKEY @"note"

#define kTKPDDETAILSHOP_APIOWNERKEY @"owner"
#define kTKPDDETAILSHOP_APIOWNERIMAGEKEY @"owner_image"
#define kTKPDDETAILSHOP_APIOWNERPHONEKEY @"owner_phone"
#define kTKPDDETAILSHOP_APIOWNERIDKEY @"owner_id"
#define kTKPDDETAILSHOP_APIOWNEREMAILKEY @"owner_email"
#define kTKPDDETAILSHOP_APIOWNERNAMEKEY @"owner_name"
#define kTKPDDETAILSHOP_APIOWNERMESSAGERKEY @"owner_messager"

#define kTKPDDETAILSHOP_APIINFOKEY @"info"
#define kTKPDDETAILSHOP_APICOVERKEY @"shop_cover"
#define kTKPDDETAILSHOP_APITOTALFAVKEY @"shop_total_favorit"

#define kTKPDDETAILSHOP_APISHOPIMAGE @"shop_image"
#define kTKPDDETAILSHOP_APISHOPLOCATION @"shop_location"
#define kTKPDDETAILSHOP_APISHOPID @"shop_id"
#define kTKPDDETAILSHOP_APISHOPNAME @"shop_name"
#define kTKPDDETAILSHOP_APISHOPISGOLD @"shop_is_gold"
#define API_IS_GOLD_SHOP_KEY @"shop_is_gold"
#define API_IS_OWNER_SHOP_KEY @"shop_is_owner"

#define kTKPDDETAILSHOP_APISHOPURLKEY @"shop_url"

#define kTKPDDETAILSHOP_APISTATKEY @"stats"
#define kTKPDDETAILSHOP_APISHIPMENTKEY @"shipment"
#define kTKPDDETAILSHOP_APISHIPMENTIDKEY @"shipment_id"
#define kTKPDDETAILSHOP_APISHIPMENTPACKAGEKEY @"shipment_package"

#define kTKPDDETAILSHOP_APISHIPPINGIDKEY @"shipping_id"
#define kTKPDDETAILSHOP_APIPRODUCTNAMEKEY @"product_name"

#define kTKPDDETAILSHOP_APISHIPMENTIMAGEKEY @"shipment_image"
#define kTKPDDETAILSHOP_APISHIPMENTNAMEKEY @"shipment_name"

#define kTKPDDETAILSHOP_APIPAYMENTKEY @"payment"
#define kTKPDDETAILSHOP_APIPAYMENTOPTIONKEY @"payment_options"
#define kTKPDDETAILSHOP_APIPAYMENTIMAGEKEY @"payment_image"
#define kTKPDDETAILSHOP_APIPAYMENTIDKEY @"payment_id"
#define kTKPDDETAILSHOP_APIPAYMENTNAMEKEY @"payment_name"
#define kTKPDDETAILSHOP_APIPAYMENTINFOKEY @"payment_info"
#define kTKPDDETAILSHOP_APIPAYMENTDEFAULTSTATUSKEY @"payment_default_status"

#define kTKPDDETAILSHOP_APIPAYMENTLOCKEY @"loc"
#define kTKPDDETAILSHOP_APIPAYMENTNOTEKEY @"note"

#define kTKPDDETAILSHOP_APICLOSEDUNTILKEY @"closed_until"

#define kTKPDSHOP_APISHOPTOTALTRANSACTIONKEY @"shop_total_transaction"
#define kTKPDSHOP_APISHOPTOTALETALASEKEY @"shop_total_etalase"
#define kTKPDSHOP_APISHOPTOTALPRODUCTKEY @"shop_total_product"
#define kTKPDSHOP_APISHOPTOTALSOLDKEY @"shop_item_sold"

#define kTKPDSHOP_APIETALASENAMEKEY @"etalase_name"
#define kTKPDSHOP_APIETALASEIDKEY @"etalase_id"
#define kTKPDSHOP_APIETALASETOTALPRODUCTKEY @"etalase_total_product"

#pragma mark - -Shop Shipment

#define kTKPDSHOPSHIPMENT_APIPATH @"myshop-shipment.pl"

#define kTKPDSHOPSHIPMENT_APIDISTRICTKEY @"district"
#define kTKPDSHOPSHIPMENT_APIDISTRICTSKEY @"districts"
#define kTKPDSHOPSHIPMENT_APIPROVINCESKEY    @"provinces_cities_districts"
#define kTKPDSHOPSHIPMENT_APICITIESKEY    @"cities"
#define kTKPDSHOPSHIPMENT_APISHIPMENTSKEY @"shipments"

#define kTKPDSHOPSHIPMENT_APIISALLOWKEY @"is_allow"

#define kTKPDSHOPSHIPMENT_APISHOPNAMEKEY @"shop_name"

#define kTKPDSHOPSHIPMENT_APISHOPSHIPPINGKEY @"shop_shipping"

#define kTKPDSHOPSHIPMENT_APIDISTRICTIDKEY @"district_id"
#define kTKPDSHOPSHIPMENT_APIDISTRICTSHIPPINGSUPPORTEDKEY @"district_shipping_supported"
#define kTKPDSHOPSHIPMENT_APIDISTRICTNAMEKEY @"district_name"

#define kTKPDSHOPSHIPMENT_APISHIPMENTKEY @"shipment"
#define kTKPDSHOPSHIPMENT_APISHIPMENTNAMEKEY @"shipment_name"
#define kTKPDSHOPSHIPMENT_APISHIPPINGIDKEY @"shipping_id"
#define kTKPDSHOPSHIPMENT_APISHIPMENTIMAGEKEY @"shipment_image"
#define kTKPDSHOPSHIPMENT_APISHIPMENTAVAILABLEKEY @"shipment_available"
#define kTKPDSHOPSHIPMENT_APISHIPMENTPACKAGEKEY @"shipment_package"
#define API_SHIPMENT_PACKAGE_ID @"shipment_package_id"
#define API_SHIPMENT_PACKAGE_NAME @"shipment_package_name"

#define kTKPDSHOPSHIPMENT_APIDESCKEY @"desc"
#define kTKPDSHOPSHIPMENT_APIACTIVEKEY @"active"
#define kTKPDSHOPSHIPMENT_APINAMEKEY @"name"
#define kTKPDSHOPSHIPMENT_APISPIDKEY @"sp_id"
#define API_SHIPMENT_PRICE_TOTAL @"price_total"
#define API_SHIPMENT_PRICE @"price"

#define kTKPDSHOPSHIPMENT_APIDISTRICTIDKEY @"district_id"
#define kTKPDSHOPSHIPMENT_APIPOSTALCODEKEY @"postal_code"
#define kTKPDSHOPSHIPMENT_APIPOSTALKEY @"postal"
#define kTKPDSHOPSHIPMENT_APIORIGINKEY @"origin"
#define kTKPDSHOPSHIPMENT_APISHIPMENTIDKEY @"shipment_id"
#define kTKPDSHOPSHIPMENT_APIDISTRICTNAMEKEY @"district_name"
#define kTKPDSHOPSHIPMENT_APIDISCTRICTSUPPORTEDKEY @"district_shipping_supported"

#define kTKPDSHOPSHIPMENT_APIPROVINCEIDKEY  @"province_id"
#define kTKPDSHOPSHIPMENT_APIPROVINCENAMEKEY    @"province_name"
#define kTKPDSHOPSHIPMENT_APICITIESKEY  @"cities"

#define kTKPDSHOPSHIPMENT_APICITYIDKEY  @"city_id"
#define kTKPDSHOPSHIPMENT_APICITYNAMEKEY    @"city_name"
#define kTKPDSHIPSHIPMENT_APIDISCTRICTSKEY  @"districts"

#define kTKPDSHOPSHIPMENT_APICOURIRORIGINKEY @"courier_origin"

#define kTKPDSHOPSHIPMENT_APISHIPMENTIDS @"shipment_ids"
#define kTKPDSHOPSHIPMENT_APIPAYMENTIDS @"payment_ids"

#define kTKPDSHOPSHIPMENT_APIAUTORESIKEY @"auto_resi"

#define kTKPDSHOPSHIPMENT_APIALLOW_ACTIVATE_GOJEKKEY    @"allow_activate_gojek"

#define kTKPDSHOPSHIPMENT_APILONGITUDEKEY @"longitude"
#define kTKPDSHOPSHIPMENT_APILATITUDEKAY @"latitude"
#define kTKPDSHOPSHIPMENT_APIADDR_STREETKEY @"addr_street"

//JNE
#define kTKPDSHOPSHIPMENT_APIJNEKEY @"jne"
#define kTKPDSHOPSHIPMENT_APIJNEFEEKEY @"jne_fee"
#define kTKPDSHOPSHIPMENT_APIJNEFEEVALUEKEY @"jne_fee_value"
#define kTKPDSHOPSHIPMENT_APIJNETICKETKEY @"jne_tiket"
#define kTKPDSHOPSHIPMENT_APIMINWEIGHTKEY @"jne_min_weight"
#define kTKPDSHOPSHIPMENT_APIMINWEIGHTVALUEKEY @"jne_min_weight_value"
#define kTKPDSHOPSHIPMENT_APIDIFFDISTRICTKEY @"jne_diff_district"

//POS
#define kTKPDSHOPSHIPMENT_APIPOSKEY @"pos"
#define kTKPDSHOPSHIPMENT_APIPOSFEEKEY @"pos_fee"
#define kTKPDSHOPSHIPMENT_APIPOSFEEVALUEKEY @"pos_fee_value"
#define kTKPDSHOPSHIPMENT_APIPOSMINWEIGHTKEY @"pos_min_weight"
#define kTKPDSHOPSHIPMENT_APIPOSMINWEIGHTVALUEKEY @"pos_min_weight_value"

//TIKI
#define kTKPDSHOPSHIPMENT_APITIKIKEY @"tiki"
#define kTKPDSHOPSHIPMENT_APITIKIFEEKEY @"tiki_fee"
#define kTKPDSHOPSHIPMENT_APITIKIFEEVALUEKEY @"tiki_fee_value"

//RPX
#define kTKPDSHOPSHIPMENT_APIRPXKEY @"rpx"
#define kTKPDSHOPSHIPMENT_APIRPXPACKETKEY @"i_paket"
#define kTKPDSHOPSHIPMENT_APIRPXTICKETKEY @"rpx_tiket"
#define kTKPDSHOPSHIPMENT_APIRPXWHITELISTEDIDROPKEY @"whitelisted_idrop"
#define kTKPDSHOPSHIPMENT_APIRPXIDROPKEY @"i_drop"
#define kTKPDSHOPSHIPMENT_APIRPXINDOMARETLOGOKEY @"indomaret_logo"

//Gojek
#define kTKPDSHOPSHIPMENT_APIGOJEKKEY   @"gojek"
#define kTKPDSHOPSHIPMENT_APIGOJEKWHITELISTEDKEY    @"whitelisted"

#pragma mark -- Shop Edit Info

#define kTKPDSHOPEDIT_APISHOPNAMEKEY @"shop_name"
#define kTKPDSHOPEDIT_APISHORTDESCKEY @"short_desc"
#define kTKPDSHOPEDIT_APITAGLINEKEY @"tag_line"
#define kTKPDSHOPEDIT_APISTATUSKEY @"status"
#define kTKPDSHOPEDIT_APICLOSEUNTILKEY @"closed_until"
#define kTKPDSHOPEDIT_APICLOSEDNOTEKEY @"closed_note"
#define kTKPDSHOPEDIT_APIDEFAULTSORTKEY @"default_sort"
#define kTKPDSHOPEDIT_APIREASONKEY @"reason"

#define kTKPDSHOPEDIT_APIUSERIDKEY @"user_id"

#define kTKPDSHOPEDIT_APIUPLOADFILEPATHKEY @"file_path"
#define kTKPDSHOPEDIT_APIUPLOADFILETHUMBKEY @"file_th"
#define API_UPLOAD_PHOTO_ID_KEY @"pic_id"
#define kTKPD_SRC @"src"

#pragma mark -- Shop  Location
#define kTKPDSHOP_APICITYNAMEKEY @"location_city_name"
#define kTKPDSHOP_APIEMAILKEY @"location_email"
#define kTKPDSHOP_APIADDRESSKEY @"location_address"
#define kTKPDSHOP_APIPOSTALCODEKEY @"location_postal_code"
#define kTKPDSHOP_APICITYIDKEY @"location_city_id"
#define kTKPDSHOP_APILOCATIONAREAKEY @"location_area"
#define kTKPDSHOP_APIPHONEKEY @"location_phone"
#define kTKPDSHOP_APIDISTRICTIDKEY @"location_district_id"
#define kTKPDSHOP_APIPROVINCENAMEKEY @"location_province_name"
#define kTKPDSHOP_APIPROVINCEIDKEY @"location_province_id"
#define kTKPDSHOP_APIDISTRICTNAMEKEY @"location_district_name"
#define kTKPDSHOP_APIADDRESSIDKEY @"location_address_id"
#define kTKPDSHOP_APIFAXKEY @"location_fax"
#define kTKPDSHOP_APIADDRESSNAMEKEY @"location_address_name"

#pragma mark -- Shop Setting Location Action
#define kTKPDSHOPSETTINGACTION_APIPROVINCEIDKEY @"location_address_province"
#define kTKPDSHOPSETTINGACTION_APICITYIDKEY @"location_address_city"
#define kTKPDSHOPSETTINGACTION_APIDISTRICTIDKEY @"location_address_district"
#define kTKPDSHOPSETTINGACTION_APIPOSTALKEY @"location_address_postal"
#define kTKPDSHOPSETTINGACTION_APIEMAILKEY @"location_address_email"
#define kTKPDSHOPSETTINGACTION_APIPHONEKEY @"location_address_phone"
#define kTKPDSHOPSETTINGACTION_APIFAXKEY @"location_address_fax"

#pragma mark -- GENERATED HOST
#define kTKPDGENERATEDHOST_APIGENERATEDHOSTKEY @"generated_host"
#define kTKPDGENERATEDHOST_APISERVERIDKEY @"server_id"
#define API_SERVER_ID_KEY @"server_id"
#define kTKPDGENERATEDHOST_APIUPLOADHOSTKEY @"upload_host"
#define kTKPDGENERATEDHOST_APIUSERIDKEY @"user_id"

#define API_UPLOAD_SHOP_IMAGE_FORM_FIELD_NAME @"logo"

#pragma mark - Review

#define kTKPDREVIEW_APIADVREVIEWKEY @"advance_review"

#define kTKPDREVIEW_APIRATINGLISTKEY @"rating_list"
#define kTKPDREVIEW_APINETRALQUALITYKEY @"netral_quality_point"
#define kTKPDREVIEW_APINEGATIVEACCURACYKEY @"negative_accuracy_point"
#define kTKPDREVIEW_APIRATINGACCURACYKEY @"rating_accuracy_point"
#define kTKPDREVIEW_APINEGATIVEQUALITYKEY @"negative_quality_point"
#define kTKPDREVIEW_APIPOSITIVEQUALITYKEY @"positive_quality_point"
#define kTKPDREVIEW_APINETRALACCURACYKEY @"netral_accuracy_point"
#define kTKPDREVIEW_APIPOSITIVEACCURACYKEY @"positive_accuracy_point"
#define kTKPDREVIEW_APITOTALREVIEWKEY @"total_review"
#define kTKPDREVIEW_APIRATINGQUALITYKEY @"rating_quality_point"

#define kTKPDREVIEW_APIRATINGSTARPOINTKEY @"rating_star_point"
#define kTKPDREVIEW_APIRATINGACCURACYKEY @"rating_accuracy_point"
#define kTKPDREVIEW_APIRATINGQUALITYKEY @"rating_quality_point"

#define kTKPDREVIEW_APIREVIEWRESPONSEKEY @"review_response"
#define kTKPDREVIEW_APIRESPONSECREATETIMEKEY @"response_create_time"
#define kTKPDREVIEW_APIRESPONSEMESSAGEKEY @"response_message"

#define kTKPDREVIEW_APIREVIEWSHOPIDKEY @"review_shop_id"
#define kTKPDREVIEW_APIREVIEWUSERIMAGEKEY @"review_user_image"
#define kTKPDREVIEW_APIREVIEWCREATETIMEKEY @"review_create_time"
#define kTKPDREVIEW_APIREVIEWIDKEY @"review_id"

#define kTKPDREVIEW_APIPRODUCTNAMEKEY @"review_product_name"
#define kTKPDREVIEW_APIPRODUCTSTATUSKEY @"review_product_status"
#define kTKPDREVIEW_APIPRODUCTIDKEY @"review_product_id"
#define kTKPDREVIEW_APIPRODUCTIMAGEKEY @"review_product_image"

#define kTKPDREVIEW_APIREVIEWPRODUCTOWNERKEY @"review_product_owner"
#define kTKPDREVIEW_APIREVIEWISOWNERKEY @"review_is_owner"
#define kTKPDREVIEW_APIUSERIDKEY @"user_id"
#define kTKPDREVIEW_APIUSERIMAGEKEY @"user_image"
#define kTKPDREVIEW_APIUSERNAME @"user_name"

#define kTKPDREVIEW_APIREVIEWUSERNAMEKEY @"review_user_name"
#define kTKPDREVIEW_APIREVIEWRATEQUALITY @"review_rate_quality"
#define kTKPDREVIEW_APIREVIEWRATESPEEDKEY @"review_rate_speed"
#define kTKPDREVIEW_APIREVIEWRATESERVICEKEY @"review_rate_service"
#define kTKPDREVIEW_APIREVIEWRATEACCURACYKEY @"review_rate_accuracy"
#define kTKPDREVIEW_APIREVIEWPRODUCTRATEKEY @"review_rate_product"
#define kTKPDREVIEW_APIREVIEWMESSAGEKEY @"review_message"
#define kTKPDREVIEW_APIREVIEWUSERIDKEY @"review_user_id"
#define KTKPDREVIEW_APIREVIEWUSERLABELIDKEY @"review_user_label_id"
#define KTKPDREVIEW_APIREVIEWUSERLABELKEY @"review_user_label"

#define kTKPDREVIEW_APIMONTHRANGEKEY @"month_range"
#define kTKPDREVIEW_APIRATEACCURACYKEY @"shop_accuracy"
#define kTKPDTEVIEW_APIRATEQUALITYKEY @"shop_quality"

#pragma mark - Talk
//#define kTKPDTALK_APITALKTOTALCOMMENTKEY @"talk_total_comment"
//#define kTKPDTALK_APITALKUSERIMAGEKEY @"talk_user_image"
//#define kTKPDTALK_APITALKUSERNAMEKEY @"talk_user_name"
//#define kTKPDTALK_APITALKIDKEY @"talk_id"
//#define kTKPDTALK_APITALKCREATETIMEKEY @"talk_create_time"
//#define kTKPDTALK_APITALKMESSAGEKEY @"talk_message"
//#define kTKPDTALK_APITALKFOLLOWSTATUSKEY @"talk_follow_status"
//#define kTKPDTALK_APITALKREADSTATUSKEY @"talk_read_status"
#define kTKPDTALK_APITALKINBOXIDKEY @"talk_inbox_id"

//#define kTKPDTALK_APITALKSHOPID @"talk_shop_id"
#define kTKPDTALKCOMMENT_APITEXT @"text_comment"


//#define kTKPDTALK_APITALKPRODUCTNAMEKEY @"talk_product_name"
//#define kTKPDTALK_APITALKPRODUCTIMAGEKEY @"talk_product_image"
//#define kTKPDTALK_APITALKPRODUCTIDKEY @"talk_product_id"
#define kTKPDTALK_APITALKPRODUCTSTATUSKEY @"talk_product_status"
//#define kTKPDTALK_APITALKOWNKEY @"talk_own"
//#define kTKPDTALK_APITALKUSERIDKEY @"talk_user_id"

#pragma mark - Talk Comment
#define kTKPDTALKCOMMENT_TALKID @"talk_id"
#define kTKPDTALKCOMMENT_MESSAGE @"comment_message"
#define kTKPDTALKCOMMENT_ID @"comment_id"
#define kTKPDTALKCOMMENT_ISMOD @"is_moderator"
#define kTKPDTALKCOMMENT_ISSELLER @"is_seller"
#define kTKPDTALKCOMMENT_CREATETIME @"comment_create_time"
#define kTKPDTALKCOMMENT_USERIMAGE @"comment_user_image"
#define kTKPDTALKCOMMENT_USERNAME @"comment_user_name"
#define kTKPDDETAIL_APIADDCOMMENTTALK @"add_comment_talk"

#pragma mark - Notes
#define kTKPDNOTES_APINOTEIDKEY @"note_id"
#define kTKPDNOTES_APINOTESTATUSKEY @"note_status"
#define kTKPDNOTES_APINOTETITLEKEY @"note_title"
#define kTKPDNOTES_APINOTECONTENTKEY @"note_content"
#define NOTES_TERMS_FLAG_KEY @"terms"

#define kTKPDNOTE_APINOTESTITLEKEY @"notes_title"
#define kTKPDNOTE_APINOTESUPDATETIMEKEY @"notes_update_time"
#define kTKPDNOTE_APINOTESUPDATETIMEKEY @"notes_update_time"
#define kTKPDNOTE_APINOTESCONTENTKEY @"notes_content"
#define NOTE_CREATE_TIME @"notes_create_time"

#define kTKPDNOTE_EDIT_NOTE_SUCCESS @"Anda telah berhasil memperbaharui catatan"
#define kTKPDNOTE_DELETE_NOTE_SUCCESS @"Anda telah berhasil menghapus catatan"
#define kTKPDNOTE_ADD_NOTE_SUCCESS  @"Anda telah berhasil menambah catatan"

#pragma mark - Favorited
#define kTKPDFAVORITED_APIUSERIDKEY @"user_id"
#define kTKPDFAVORITED_APIUSERIMAGEKEY @"user_image"
#define kTKPDFAVORITED_APIUSERNAMEKEY @"user_name"

#pragma mark - Catalog
#define kTKPDDETAILCATALOG_APICATALOGINFOKEY @"catalog_info"
#define kTKPDDETAILCATALOG_APICATALOGSPECSKEY @"catalog_specs"
#define kTKPDDETAILCATALOG_APICATALOGREVIEWKEY @"catalog_review"
#define kTKPDDETAILCATALOG_APICATALOGMARKETPRICEKEY @"catalog_market_price"
#define kTKPDDETAILCATALOG_APICATALOGSHOPSKEY @"catalog_shops"
#define kTKPDDETAILCATALOG_APICATALOGIMAGEKEY @"catalog_image"

#define kTKPDDETAILCATALOG_APICATALOGDESCKEY @"catalog_description"
#define kTKPDDETAILCATALOG_APICATALOGKEYKEY @"catalog_key"
#define kTKPDDETAILCATALOG_APICATALOGDEPARTMENTIDKEY @"catalog_department_id"
#define kTKPDDETAILCATALOG_APICATALOGIDKEY @"catalog_id"
#define kTKPDDETAILCATALOG_APICATALOGNAMEKEY @"catalog_name"
#define kTKPDDETAILCATALOG_APICATALOGPRICEKEY @"catalog_price"
#define API_CATALOG_IMAGES_PATH @"catalog_image"
#define kTKPDDETAILCATALOG_APICATALOGIMAGESKEY @"catalog_image"
#define kTKPDDETAILCATALOG_APICATALOGURIKEY @"catalog_uri"

#define kTKPDDETAILCATALOG_APIIMAGEPRIMARYKEY @"image_primary"
#define kTKPDDETAILCATALOG_APIIMAGESRCKEY @"image_src"

#define kTKPDDETAILCATALOG_APIPRICEMINKEY @"price_min"
#define kTKPDDETAILCATALOG_APIPRICEMAXKEY @"price_max"

#define kTKPDDETAILCATALOG_APIREVIEWIMAGEKEY @"review_from_image"
#define kTKPDDETAILCATALOG_APIREVIEWRATINGKEY @"review_rating"
#define kTKPDDETAILCATALOG_APIREVIEWURLKEY @"review_url"
#define kTKPDDETAILCATALOG_APIREVIEWFROMURLKEY @"review_from_url"
#define kTKPDDETAILCATALOG_APIREVIEWFROMKEY @"review_from"
#define kTKPDDETAILCATALOG_APICATALOGIDKEY @"catalog_id"
#define kTKPDDETAILCATALOG_APIREVIEWDESCKEY @"review_description"

#define kTKPDDETAILCATALOG_APIMAXPRICEKEY @"max_price"
#define kTKPDDETAILCATALOG_APITIMEKEY @"time"
#define kTKPDDETAILCATALOG_APINAMEKEY @"name"
#define kTKPDDETAILCATALOG_APIMINPRICEKEY @"min_price"

#define kTKPDDETAIL_APIPAGINGKEY @"paging"
#define kTKPDDETAIL_APIDETAILKEY @"detail"

#define kTKPDDETAILCATALOG_APIPRODUCTLISTKEY @"product_list"
#define kTKPDDETAILCATALOG_APISHOPRATEACCURACYKEY @"shop_rate_accuracy"
#define kTKPDDETAILCATALOG_APISHOPIMAGEKEY @"shop_image"
#define kTKPDDETAIL_APISHOPIDKEY @"shop_id"
#define kTKPDDETAIL_REVIEWIDS @"review_ids"
#define kTKPDDETAIL_APISHOPNAMEKEY @"shop_name"
#define kTKPDDETAIL_APISHOPISGOLD @"shop_is_gold"
#define kTKPDDETAILCATALOG_APISHOPLOCATIONKEY @"shop_location"
#define kTKPDDETAILCATALOG_APISHOPRATESPEEDKEY @"shop_rate_speed"
#define kTKPDDETAILCATALOG_APIISGOLDSHOPKEY @"is_gold_shop"
#define kTKPDDETAILCATALOG_APISHOPNAMEKEY @"shop_name"
#define kTKPDDETAILCATALOG_APISHOPTOTALADDRESSKEY @"shop_total_address"
#define kTKPDDETAILCATALOG_APISHOPTOTALPRODUCTKEY @"shop_total_product"
#define kTKPDDETAILCATALOG_APISHOPRATESERVICEKEY @"shop_rate_service"
#define kTKPDDETAILCATALOG_APISHOPGOLDSTATUSKEY @"shop_gold_status"

#define API_KEYWORD_KEY @"keyword"

#define kTKPDDETAILCATALOG_APIPRODUCTPRICEKEY @"product_price"
#define kTKPDDETAILCATALOG_APIPRODUCTIDKEY @"product_id"
#define kTKPDDETAILCATALOG_APIPRODUCTCONDITIONKEY @"product_condition"
#define kTKPDDETAILCATALOG_APIPRODUCTNAMEKEY @"product_name"

#define kTKPDDETAILCATALOG_APISPECSKEY @"catalog_specs"
#define kTKPDDETAILCATALOG_APISPECCHILDSKEY @"spec_childs"
#define kTKPDDETAILCATALOG_APISPECVALKEY @"spec_val"
#define kTKPDDETAILCATALOG_APISPECKEYKEY @"spec_key"
#define kTKPDDETAILCATALOG_APISPECHEADERKEY @"spec_header"

#define kTKPDDETAILCATALOG_APILOCATIONKEY @"catalog_location"
#define kTKPDDETAILCATALOG_APILOCATIONNAMEKEY @"location_name"
#define kTKPDDETAILCATALOG_APILOCATIONIDKEY @"location_id"
#define kTKPDDETAILCATALOG_APITOTALSHOPKEY @"total_shop"

#define kTKPDDETAIL_APIURINEXTKEY @"uri_next"
#define kTKPDDETAIL_APIISSUCCESSKEY @"is_success"
#define API_POSTKEY_KEY @"post_key"
#define API_FILE_UPLOADED_KEY @"file_uploaded"

#define API_FILE_NAME_KEY @"file_name"
#define API_FILE_PATH_KEY @"file_path"

//wishList
#define KTKPDSHOP_GOLD_STATUS @"shop_gold_status"
#define KTKPDSHOP_ID @"shop_id"
#define KTKPDPRODUCT_RATING_POINT @"product_rating_point"
#define KTKPDPRODUCT_DEPARTMENT_ID @"product_department_id"
#define KTKPDPRODUCT_ETALASE @"product_etalase"
#define KTKPDSHOP_URL @"shop_url"
#define KTKPDSHOP_FEATURED_SHOP @"shop_featured_shop"
#define KTKPDPRODUCT_STATUS @"product_status"
#define KTKPDPRODUCT_ID @"product_id"
#define KTKPDPRODUCT_IMAGE_FULL @"product_image_full"
#define KTKPDPRODUCT_CURRENCY_ID @"product_currency_id"
#define KTKPDPRODUCT_RATING_DESC @"product_rating_desc"
#define KTKPDPRODUCT_CURRENCY @"product_currency"
#define KTKPDPRODUCT_TALK_COUNT @"product_talk_count"
#define KTKPDPRODUCT_PRICE_NO_IDR @"product_price_no_idr"
#define KTKPDPRODUCT_IMAGE @"product_image"
#define KTKPDPRODUCT_PRICE @"product_price"
#define KTKPDPRODUCT_SOLD_COUNT @"product_sold_count"
#define KTKPDPRODUCT_RETURNABLE @"product_returnable"
#define KTKPDSHOP_LOCATION @"shop_location"
#define KTKPDPRODUCT_NORMAL_PRICE @"product_normal_price"
#define KTKPDPRODUCT_IMAGE_300 @"product_image_300"
#define KTKPDSHOP_NAME @"shop_name"
#define KTKPDPRODUCT_REVIEW_COUNT @"product_review_count"
#define KTKPDSHOP_IS_OWNER @"shop_is_owner"
#define KTKPDPRODUCT_URL @"product_url"
#define KTKPDPRODUCT_NAME @"product_name"

//product
#define kTKPDDETAILPRODUCT_APIPATH @"product.pl"
#define kTKPDDETAILACTIONPRODUCT_APIPATH @"action/product.pl"

#define kTKDPDETAILCATALOG_APIPATH @"catalog.pl"
#define kTKPDDETAILSHOP_APIPATH @"shop.pl"
#define kTKPDDETAILNOTES_APIPATH @"notes.pl"
#define kTKPDDETAILTALK_APIPATH @"talk.pl"
#define kTKPDACTIONTALK_APIPATH @"action/talk.pl"
#define kTKPDDETAILSHOPEDITOR_APIPATH @"myshop-editor.pl"
#define kTKPDDETAILSHOPEDITORACTION_APIPATH @"action/myshop-editor.pl"
#define kTKPDDETAILSHOPEDITINFO_APIPATH @"action/myshop-info.pl"
#define kTKPDDETAILSHOPPAYMENT_APIPATH @"myshop-payment.pl"
#define kTKPDDETAILSHOPACTIONEDITOR_APIPATH @"action/myshop-shipment.pl"

#define kTKPDDETAILSHOPNOTE_APIPATH @"myshop-note.pl"
#define kTKPDDETAILSHOPNOTEACTION_APIPATH @"action/myshop-note.pl"
#define kTKPDINBOX_TALK_APIPATH @"inbox-talk.pl"

//address
#define kTKPDDETAILSHOPADDRESS_APIPATH @"myshop-address.pl"
#define kTKPDDETAILSHOPADDRESSACTION_APIPATH @"action/myshop-address.pl"

#define kTKPDDETAIL_UPLOADIMAGEAPIPATH @"action/upload-image.pl"

#define kTKPDDETAILSHOPETALASE_APIPATH @"myshop-etalase.pl"
#define kTKPDDETAILSHOPETALASEACTION_APIPATH @"action/myshop-etalase.pl"

#define kTKPDDETAIL_STANDARDTABLEVIEWCELLIDENTIFIER @"cell"
#define kTKPDDETAIL_NODATACELLTITLE @"no data"
#define kTKPDDETAIL_NODATACELLDESCS @"no data description"

#define kTKPDREVIEW_ALERTRATINGLISTARRAY @[@"Average Quality Rating", @"Average Accuracy Rating"]

#define kTKPDREVIEW_ALERTPERIODSARRAY @[@"All The Times", @"6 Months"]
#define kTKPDREVIEW_ALERTPERIODSVALUEARRAY @[@(0), @(6)]

#define kTKPDSHOP_APIETALASENAMEKEY @"etalase_name"
#define kTKPDSHOP_APIETALASEIDKEY @"etalase_id"
#define kTKPDSHOP_APIETALASENUMPRODUCTKEY @"etalase_num_product"
#define kTKPDSHOP_APIETALASETOTALPRODUCTKEY @"etalase_total_product"

#define kTKPDMESSAGE_KEYSUBJECT @"message_subject"
#define kTKPDMESSAGE_KEYCONTENT @"message"
#define kTKPDMESSAGE_PRODUCTIDKEY @"product_id"
#define kTKPDMESSAGE_KEYTOSHOPID @"to_shop_id"
#define kTKPDMESSAGE_KEYTOUSERID @"to_user_id"
#define KTKPDMESSAGE_DELIVERED @"Pesan Anda telah terkirim!"
#define KTKPDTALK_DELIVERED @"Diskusi Anda telah terkirim!"
#define KTKPDMESSAGE_UNDELIVERED @"Pesan Anda gagal terkirim."
#define KTKPDTALK_UNDELIVERED @"Anda baru saja menulis komentar. Silakan coba beberapa saat lagi."
#define KTKPDMESSAGE_EMPTYFORM @"Panjang pesan harus lebih dari 3 karakter."
#define KTKPDSHOP_SUCCESSEDIT @"Anda berhasil memperbaharui informasi Toko."

#define KTKPDMESSAGE_EMPTYFORM2 @"Panjang pesan harus lebih dari 5 karakter."
#define kTKPDMESSAGE_EMPTY @"Pesan harus diisi"
#define kTKPDSUBJECT_EMPTY @"Subject harus diisi"
#define KTKPDMESSAGE_EMPTYFORM5 @"Panjang pesan harus lebih dari 5 karakter."


#define kTKPD_STATUSSUCCESS @"1"
#define kTKPDMESSAGE_KEYTOUSERID @"to_user_id"
#define kTKPDMESSAGE_KEYTO @"message_to"
#define kTKPDMESSAGE_PLACEHOLDER @"Message"

#define kTKPDTALK_ADDTALK @"add_product_talk"
#define kTKPDTALK_TALKMESSAGE @"text_comment"

#define kTKPDSHOP_ETALASEARRAY @[@{kTKPDSHOP_APIETALASENAMEKEY:@"Produk Terjual",kTKPDSHOP_APIETALASEIDKEY:@(7)}, @{kTKPDSHOP_APIETALASENAMEKEY:@"Semua Etalase",kTKPDSHOP_APIETALASEIDKEY:@(0)}]

#define kTKPDMANAGEPRODUCT_ETALASEARRAY @[@{kTKPDSHOP_APIETALASENAMEKEY:@"Semua Produk",kTKPDSHOP_APIETALASEIDKEY:@""}, @{kTKPDSHOP_APIETALASENAMEKEY:@"Semua Etalase",kTKPDSHOP_APIETALASEIDKEY:@"etalase"}, @{kTKPDSHOP_APIETALASENAMEKEY:@"Stok Kosong",kTKPDSHOP_APIETALASEIDKEY:@"warehouse"}, @{kTKPDSHOP_APIETALASENAMEKEY:@"Pengawasan", kTKPDSHOP_APIETALASEIDKEY:@"pending"}]

#define DATA_ADD_NEW_ETALASE_ID -1
#define API_ADD_PRODUCT_NEW_ETALASE_TAG @"new"
#define DATA_ADD_NEW_ETALASE_DICTIONARY @{kTKPDSHOP_APIETALASENAMEKEY:@"Tambah Etalase",kTKPDSHOP_APIETALASEIDKEY:@(-1)}

#define kTKPDDETAILCATALOG_CACHEFILEPATH @"catalog"
#define kTKPDDETAILSHOP_CACHEFILEPATH @"shop"
#define kTKPDDETAILSHOPEDIT_CACHEFILEPATH @"shopedit"
#define kTKPDDETAILPRODUCT_CACHEFILEPATH @"product"
#define kTKPDDETAILETALASE_CACHEFILEPATH @"etalase"

#define TKPD_INBOXTALK_CACHE @"inbox-talk"
#define TKPD_INBOXREVIEW_CACHE @"inbox-review"

#define ARRAY_SHOP_SETTING_MENU @[@"Etalase", @"Produk", @"Lokasi", @"Pengiriman", @"Pembayaran", @"Catatan", @"Admin"]

#define kTKPDDETAILSHOPETALASE_APIRESPONSEFILE @"etalase"

#define kTKPDDETAILPRODUCT_APIRESPONSEFILEFORMAT @"productdetail%zd"
#define kTKPDDETAILPRODUCTFORM_APIRESPONSEFILEFORMAT @"productdetailform%d"
#define TKPD_INBOXTALK_RESPONSEFILEFORMAT @"inbox-talk%zd"

#define kTKPDDETAILPRODUCTTALK_APIRESPONSEFILEFORMAT @"producttalk%zd"
#define kTKPDDETAILPRODUCTTALKDETAIL_APIRESPONSEFILEFORMAT @"producttalkdetail%zd"
#define kTKPDDETAILPRODUCTREVIEW_APIRESPONSEFILEFORMAT @"productreview%zd"

#define kTKPDDETAILSHOP_APIRESPONSEFILEFORMAT @"shopdetail%zd"
#define kTKPDDETAILSHOPEDIT_APIRESPONSEFILEFORMAT @"shopedit%zd"
#define kTKPDDETAILSHOPPRODUCT_APIRESPONSEFILEFORMAT @"shopproduct%zd"
#define kTKPDDETAILSHOPTALK_APIRESPONSEFILEFORMAT @"shoptalk%zd"
#define kTKPDDETAILSHOPREVIEW_APIRESPONSEFILEFORMAT @"shopreview%zd"
#define kTKPDDETAILSHOPNOTES_APIRESPONSEFILEFORMAT @"shopnotes%zd"
#define kTKPDDETAILSHOPFAVORITED_APIRESPONSEFILEFORMAT @"shopfavorited%zd"
#define kTKPDDETAILSHOPNOTEDETAIL_APIRESPONSEFILEFORMAT @"shopnotedetail%zd"
#define kTKPDDETAILSHOPETALASE_APIRESPONSEFILEFORMAT @"shopetalase%zd"
#define kTKPDDETAILSHOPLOCATION_APIRESPONSEFILEFORMAT @"shoplocation%zd"
#define kTKPDDETAILSHOPPAYMENT_APIRESPONSEFILEFORMAT @"shoppayment%zd"
#define kTKPDDETAILSHOPSHIPPING_APIRESPONSEFILEFORMAT @"shopshipping%zd"
#define kTKPDDETAILMANAGEPRODUCT_APIRESPONSEFILEFORMAT @"manageproduct%zd"

#define kTKPDDETAILCATALOG_APIRESPONSEFILEFORMAT @"catalogdetail%zd.plist"

#define kTKPD_URINEXTKEY @"uri_next"
#define kTKPD_APIPAGINGKEY @"paging"
#define kTKPD_APIPAGEKEY @"page"

#endif
