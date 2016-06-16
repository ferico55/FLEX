//
//  string_product.h
//  Tokopedia
//
//  Created by IT Tkpd on 12/10/14.
//  Copyright (c) 2014 TOKOPEDIA. All rights reserved.
//

#ifndef Tokopedia_string_product_h
#define Tokopedia_string_product_h

typedef enum
{
    TYPE_ADD_EDIT_PRODUCT_DEFAULT = 0,
    TYPE_ADD_EDIT_PRODUCT_ADD,
    TYPE_ADD_EDIT_PRODUCT_EDIT,
    TYPE_ADD_EDIT_PRODUCT_COPY
}TYPE_ADD_EDIT_PRODUCT;

typedef enum
{
    BUTTON_PRODUCT_DEFAULT = 0,
    BUTTON_PRODUCT_PRODUCT_NAME = 0,
    BUTTON_PRODUCT_CATEGORY = 1,
    BUTTON_PRODUCT_CATALOG = 2,
    BUTTON_PRODUCT_MIN_ORDER = 3,
    
    BUTTON_PRODUCT_PRICE_CURRENCY = 0,
    BUTTON_PRODUCT_PRICE = 1,
    
    BUTTON_PRODUCT_WEIGHT_UNIT = 0,
    BUTTON_PRODUCT_WEIGHT = 1,
    
    BUTTON_PRODUCT_INSURANCE = 0,
    BUTTON_PRODUCT_RETURNABLE = 1,
    
    BUTTON_PRODUCT_ETALASE = 0,
    BUTTON_PRODUCT_ETALASE_DETAIL = 1,
    
    BUTTON_PRODUCT_CONDITION = 0,
    BUTTON_PRODUCT_RETURNABLE_NOTE = 14,
    
    BUTTON_PRODUCT_EDIT_WHOLESALE = 0,
    
    BUTTON_PRODUCT_ADD_WHOLESALE = 0,
    
    BUTTON_PRODUCT_DELETE_PRODUCT_IMAGE = 10,
    BUTTON_PRODUCT_UPDATE_PRODUCT_IMAGE = 11,
    
    BUTTON_PRODUCT_ADD_NEW_PRODUCT = 14
    
}BUTTON_PRODUCT;

typedef enum
{
    SWITCH_PRODUCT_DEFAULT = 0,
    SWITCH_PRODUCT_DEFAULT_IMAGE = 10
}SWITCH_PRODUCT;


typedef enum
{
    BARBUTTON_PRODUCT_DEFAULT = 0,
    BARBUTTON_PRODUCT_BACK = 10,
    BARBUTTON_PRODUCT_SAVE = 11,
    BARBUTTON_PRODUCT_NEXT = 12
}BARBUTTON_PRODUCT;

typedef enum
{
    GESTURE_PRODUCT_DEFAULT = 0,
    GESTURE_PRODUCT_EDIT_WHOLESALE = 11
}GESTURE_PRODUCT;

#define DATA_NAME_KEY @"name"
#define DATA_VALUE_KEY @"value"

#define DATA_INDEX_PRICE_CURRENCY_KEY @"index_price_currency"
#define DATA_INDEX_WEIGHT_UNIT_KEY @"index_weight_unit"
#define DATA_CATEGORY_KEY @"data_category"
#define DATA_BREADCRUMB_KEY @"data_breadcrumb"

#define WEIGHT_UNIT_ID_GRAM 1
#define MINIMUM_WEIGHT_GRAM 1
#define MAXIMUM_WEIGHT_GRAM 35000

#define WEIGHT_UNIT_ID_KILOGRAM 2
#define MINIMUM_WEIGHT_KILOGRAM 1
#define MAXIMUM_WEIGHT_KILOGRAM 35

#define PRICE_CURRENCY_ID_RUPIAH 1
#define MINIMUM_PRICE_RUPIAH 100
#define MAXIMUM_PRICE_RUPIAH 50000000

#define PRICE_CURRENCY_ID_USD 2
#define MINIMUM_PRICE_USD 1
#define MAXIMUM_PRICE_USD 4000

#define RETURNABLE_YES_ID 1
#define RETURNABLE_NO_ID 2
#define PRODUCT_WAREHOUSE_NOTSET_ID 0
#define PRODUCT_WAREHOUSE_YES_ID 2
#define PRODUCT_WAREHOUSE_NO_ID 1
#define PRODUCT_CONDITION_NOTSET_ID 0
#define PRODUCT_CONDITION_NEW_ID 1
#define PRODUCT_CONDITION_SECOND_ID 2

#define UPLOAD_TO_VALUE_IF_IS_WAREHOUSE 2
#define UPLOAD_TO_VALUE_IF_ISNOT_WAREHOUSE 1

#define DATA_PRODUCT_IMAGE_NAME_KEY @"dataimagename"
#define DATA_PRODUCT_DETAIL_KEY @"productdetail"
#define DATA_SHOP_HAS_TERM_KEY @"data_shop_has_term"
#define DATA_TYPE_ADD_EDIT_PRODUCT_KEY @"type"
#define DATA_CATALOG_KEY @"data_catalog"

#define API_SERVER_ID_KEY @"server_id"
#define API_PRODUCT_WEIGHT_UNIT_KEY @"product_weight_unit"
#define API_PRODUCT_TOTAL_WEIGHT_KEY @"product_total_weight"
#define API_PRODUCT_NOTES_KEY @"product_notes"
#define API_PRODUCT_ERROR_MESSAGE_KEY @"product_error_msg"
#define API_PRODUCT_WEIGHT_KEY @"product_weight"
#define API_PRODUCT_DESCRIPTION_KEY @"product_description"
#define API_PRODUCT_PRICE_KEY @"product_price"
#define API_PRODUCT_IMAGE_NO_SQUARE @"product_image_no_square"
#define API_PRICE_KEY @"price"
#define API_PRODUCT_INSURANCE_KEY @"product_insurance"
#define API_PRODUCT_MUST_INSURANCE_KEY @"product_must_insurance"
#define API_PRODUCT_CONDITION_KEY @"product_condition"
#define API_PRODUCT_MINIMUM_ORDER_KEY @"product_min_order"
#define API_PRODUCT_IS_RETURNABLE_KEY @"product_returnable"
#define API_PRODUCT_FORM_RETURNABLE_KEY @"product_returnable"
#define API_PRODUCT_FORM_PRICE_CURRENCY_ID_KEY @"product_currency_id"
#define API_PRODUCT_PRICE_CURRENCY_ID_KEY @"product_price_currency"
#define API_PRODUCT_ETALASE_ID_KEY @"product_etalase_id"
#define API_PRODUCT_NAME_KEY @"product_name"
#define API_PRODUCT_ETALASE_NAME_KEY @"product_etalase_name"
#define API_PRODUCT_FORM_ETALASE_NAME_KEY @"product_etalase"
#define API_PRODUCT_MOVETO_WAREHOUSE_KEY @"product_upload_to"
#define API_PRODUCT_DEPARTMENT_ID_KEY @"product_department_id"
#define API_DEPARTMENT_ID_KEY @"department_id"
#define API_PRODUCT_IMAGE_TOUPLOAD_KEY @"product_photo"
#define API_PRODUCT_IMAGE_DEFAULT_KEY @"product_photo_default"
#define API_PRODUCT_IMAGE_DEFAULT_INDEX @"index_default"
#define API_PRODUCT_IMAGE_DESCRIPTION_KEY @"product_photo_desc"
#define API_PRODUCT_FORM_DESCRIPTION_KEY @"product_short_desc"
#define API_PRODUCT_FORM_DEPARTMENT_TREE_KEY @"product_department_tree"
#define API_PRODUCT_IS_CHANGE_WHOLESALE_KEY @"product_change_wholesale"
#define API_PRODUCT_RETURNABLE_KEY @"product_returnable"
#define API_SHOP_HAS_TERMS_KEY @"shop_has_terms"
#define API_IS_DUPLICATE_KEY @"duplicate"
#define API_PRODUCT_ID_KEY @"product_id"
#define API_PRODUCT_PICTURE_ID_KEY @"picture_id"
#define API_UPLOAD_PRODUCT_IMAGE_DATA_NAME @"fileToUpload"
#define API_UNIQUE_ID_KEY @"unique_id"
#define API_PRODUCT_PRIMARY_PHOTO_KEY @"product_primary_pic"
#define API_PRODUCT_DESC_KEY @"product_desc"
#define API_PRODUCT_ETALASE_KEY @"product_etalase"
#define API_PRODUCT_DESTINATION_KEY @"product_dest"
#define API_PRODUCT_URL_KEY @"product_url"
#define API_PRODUCT_NAME_KEY @"product_name"
#define API_PRODUCT_QUANTITY_KEY @"product_quantity"
#define API_PRODUCT_CART_ID_KEY @"product_cart_id"
#define API_PRODUCT_CURRENCY_SYMBOL @"product_currency_symbol"
#define API_PRICE_USD_VALUE @"product_no_idr_price"

#define API_MANAGE_PRODUCT_KEYWORD_KEY          @"keyword"
#define API_MANAGE_PRODUCT_ETALASE_ID_KEY       @"etalase_id"
#define API_MANAGE_PRODUCT_DEPARTMENT_ID_KEY    @"department_id"
#define API_MANAGE_PRODUCT_CATALOG_ID_KEY       @"catalog_id"
#define API_MANAGE_PRODUCT_PICTURE_STATUS_KEY   @"picture_status"
#define API_MANAGE_PRODUCT_CONDITION_KEY        @"condition"
#define DATA_DEPARTMENT_KEY                     @"data_department"

#define API_WHOLESALE_QUANTITY_MINIMUM_KEY @"qty_min_"
#define API_WHOLESALE_QUANTITY_MAXIMUM_KEY @"qty_max_"
#define API_WHOLESALE_PRICE @"prd_prc_"

#define BUTTON_DELETE_TITLE @"Hapus"
#define BUTTON_MOVE_TO_WAREHOUSE @"Gudangkan"
#define BUTTON_MOVE_TO_ETALASE @"Stok \nTersedia"
#define BUTTON_EDIT_PRODUCT @" Edit "
#define BUTTON_DUPLICATE_PRODUCT @"Salin"
#define BUTTON_MOVE_ETALASE @"Ubah\nEtalase"
#define BUTTON_MOVETO_WAREHOUSE_TITLE @"Pindah ke\nGudang"

#define CONFIRMATIONMESSAGE_DELETE_PRODUCT_IMAGE @"Apakah Anda ingin menghapus gambar ini?"

#define SUCCESSMESSAGE_ADD_PRODUCT @"Anda telah berhasil menambah produk"
#define SUCCESSMESSAGE_EDIT_PRODUCT @"Anda telah berhasil memperbaharui produk"
#define SUCCESSMESSAGE_COPY_PRODUCT @"Anda telah berhasil menyalin produk"

#define SUCCESSMESSAGE_DELETE_PRODUCT_IMAGE @"Anda telah berhasil menghapus gambar"
#define ERRORMESSAGE_DELETE_PRODUCT_IMAGE @"Anda gagal menghapus gambar"
#define ERRORMESSAGE_INVALID_DELETE_PRODUCT_IMAGE @"Anda tidak dapat menghapus gambar utama"

#define ERRRORMESSAGE_CANNOT_EDIT_PRODUCT_NAME @"Nama produk bersifat permanen dan tidak dapat diubah"

#define CStringDescTokoTutup @"Toko ini sedang tutup karena %@ sampai tanggal %@"
#define CStringDenganDanTanpaKatalog @"Dengan & Tanpa Katalog"
#define CStringDenganKatalog @"Dengan Katalog"
#define CStringTanpaKatalog @"Tanpa Katalog"
#define CStringSemuaKondisi @"Semua Kondisi"
#define CStringBaru @"Baru"
#define CStringBekas @"Bekas"
#define CStringDenganDanTanpaGambar @"Dengan & Tanpa Gambar"
#define CStringDenganGambar @"Dengan Gambar"
#define CStringTanpaGambar @"Tanpa Gambar"
#define CStringKatalog @"Katalog"
#define CStringGambar @"Gambar"
#define CStringKondisi @"Kondisi"
#define CStringPending @"Pending"
#define CStringUnderReview @"Pengawasan"
#define CStringWareHouse @"Warehouse"
#define CStringEtalase @"Etalase"
#define CStringAllEtalase @"All Etalase"
#define CStringAllProduct @"All Products"
#define CStringAllCategory @"Semua Kategori"

#define ERRORMESSAGE_NULL_PRODUCT_NAME @"Nama Produk harus diisi"
#define ERRORMESSAGE_NULL_PRICE @"Harga harus diisi"
#define ERRORMESSAGE_NULL_CATEGORY @"Kategori tidak benar"
#define ERRORMESSAGE_NULL_IMAGE @"Gambar harus tersedia"
#define ERRORMESSAGE_INVALID_PRICE_RUPIAH @"Rentang Harga 100 - 50000000"
#define ERRORMESSAGE_INVALID_PRICE_USD @"Rentang Harga 1 - 4000"
#define ERRORMESSAGE_INVALID_WEIGHT_GRAM @"Berat harus diisi antara 1 - 35000"
#define ERRORMESSAGE_INVALID_WEIGHT_KILOGRAM @"Berat harus diisi antara 1 - 35"
#define ERRORMESSAGE_INVALID_QUANTITY_WHOLESALE @"Total produk tidak valid"
#define ERRORMESSAGE_INVALID_QUANTITY_MINIMUM_WHOLESALE_COMPARE_MINIMUM_ORDER @"Jumlah barang grosir harus lebih besar dari minimum pemesanan"
#define ERRORMESSAGE_INVALID_PRICE_WHOLESALE @"Harga harus lebih murah dari harga grosir sebelumnya"
#define ERRORMESSAGE_INVALID_PRICE_WHOLESALE_COMPARE_NET @"Harga grosir harus lebih murah dari harga pas"
#define ERRORMESSAGE_MAXIMAL_WHOLESALE_LIST @"Hanya boleh menambahkan 5 harga grosir"
#define kTKPDSUCCESS_ADD_WISHLIST @"Anda berhasil menambah wishlist"
#define kTKPDSUCCESS_REMOVE_WISHLIST @"Anda berhasil menghapus wishlist"
#define kTKPDFAILED_ADD_WISHLIST @"Anda gagal menambah wishlist"
#define kTKPDFAILED_REMOVE_WISHLIST @"Anda gagal menghapus wishlist"
#define kTKPDTIDAK_ADA_WISHLIST @"Tidak ada wishlist"


#define ERRORMESSAGE_FAILED_IMAGE_UPLOAD @"Anda telah gagal menambah gambar produk. Silahkan coba kembali."

#define ERRORMESSAGE_INVALID_PRICE_CURRENCY_USD @"Untuk mengaktifkan fitur ini anda harus menjadi Gold Merchant"

#define ERRORMESSAGE_PROCESSING_UPLOAD_IMAGE @"Anda belum selesai mengunggah gambar"

#define ARRAY_PRICE_CURRENCY @[@{DATA_NAME_KEY:@"Rp", DATA_VALUE_KEY:@(PRICE_CURRENCY_ID_RUPIAH)}, @{DATA_NAME_KEY:@"US$", DATA_VALUE_KEY:@(PRICE_CURRENCY_ID_USD)}]

#define ARRAY_WEIGHT_UNIT @[@{DATA_NAME_KEY:@"Gram (g)", DATA_VALUE_KEY:@(1)}, @{DATA_NAME_KEY:@"Kilogram (kg)", DATA_VALUE_KEY:@(2)}]
#define ARRAY_PRODUCT_INSURACE @[@{DATA_NAME_KEY:@"Opsional", DATA_VALUE_KEY:@(0)}, @{DATA_NAME_KEY:@"Ya", DATA_VALUE_KEY:@(1)}]
#define ARRAY_PRODUCT_CONDITION @[@{DATA_NAME_KEY:@"Baru", DATA_VALUE_KEY:@(PRODUCT_CONDITION_NEW_ID)}, @{DATA_NAME_KEY:@"Bekas", DATA_VALUE_KEY:@(PRODUCT_CONDITION_SECOND_ID)}]
#define ARRAY_PRODUCT_MOVETO_ETALASE @[@{DATA_NAME_KEY:@"Stok Kosong", DATA_VALUE_KEY:@(2)}, @{DATA_NAME_KEY:@"Stok Tersedia", DATA_VALUE_KEY:@(1)}]

#define ARRAY_PRODUCT_RETURNABLE @[@{DATA_NAME_KEY:@"-", DATA_VALUE_KEY:@(0)}, @{DATA_NAME_KEY:@"Ya", DATA_VALUE_KEY:@(RETURNABLE_YES_ID)}, @{DATA_NAME_KEY:@"Tidak", DATA_VALUE_KEY:@(RETURNABLE_NO_ID)}]

#define ARRAY_PRODUCT_WAREHOUSE @[@{DATA_NAME_KEY:@"Yes", DATA_VALUE_KEY:@(PRODUCT_WAREHOUSE_YES_ID)},@{DATA_NAME_KEY:@"No", DATA_VALUE_KEY:@(PRODUCT_WAREHOUSE_NO_ID)}]

#define PRODUCT_DESC @"Deskripsi Produk"
#define PRODUCT_WHOLESALE @"Harga Grosir"
#define PRODUCT_INFO @"Informasi Produk"
#define NO_DESCRIPTION @"Tidak ada deskripsi"

#define CStringCannotReture @"Produk yang sudah dibeli tidak dapat ditukar atau dikembalikan"
#define CStringCanReture @"Produk yang sudah dibeli dapat ditukar atau dikembalikan dengan Syarat dan Ketentuan masing-masing toko"
#define CStringCanRetureLinkDetection @"Syarat dan Ketentuan masing-masing toko"
#define CStringCanRetureReplace @" dengan Syarat dan Ketentuan masing-masing toko"
#define CStringSuccessFavoriteShop @"Anda berhasil memfavoritkan toko ini!"
#define CStringSuccessUnFavoriteShop @"Anda berhenti memfavoritkan toko ini!"
#define CStringSyaratDanKetentuan @"Syarat & Ketentuan"
#define CStringTitleBanned @"Produk ini berada dalam pengawasan."
#define CStringDescBanned @"Produk dapat dipesan kembali setelah pengawasan selesai."
#endif
