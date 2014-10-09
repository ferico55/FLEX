//
//  sort.h
//  Tokopedia
//
//  Created by IT Tkpd on 9/17/14.
//  Copyright (c) 2014 TOKOPEDIA. All rights reserved.
//

#ifndef Tokopedia_sort_h
#define Tokopedia_sort_h

typedef enum
{
    kTKPDFILTER_DATATYPEDEFAULTVIEWKEY = 0,
    kTKPDFILTER_DATATYPEHOTLISTVIEWKEY,
    kTKPDFILTER_DATATYPEPRODUCTVIEWKEY,
    kTKPDFILTER_DATATYPECATALOGVIEWKEY,
    kTKPDFILTER_DATATYPEDETAILCATALOGVIEWKEY,
    kTKPDFILTER_DATATYPESHOPVIEWKEY,
    kTKPDFILTER_DATATYPESHOPPRODUCTVIEWKEY
} kTKPDFILTERVIEWTYPE;

#define kTKPDFILTER_DATACONDITIONKEY @"condition"

#define kTKPDFILTER_APIDEPARTMENTIDKEY @"department_id"
#define kTKPDFILTER_APIORDERBYKEY @"order_by"
#define kTKPDFILTER_APILOCATIONKEY @"location"
#define kTKPDFILTER_APICONDITIONKEY @"condition"
#define kTKPDFILTER_APILOCATIONNAMEKEY @"locationname"
#define kTKPDFILTER_APISHOPTYPEKEY @"shop_type"
#define kTKPDFILTER_APIPRICEMINKEY @"price_min"
#define kTKPDFILTER_APIPRICEMAXKEY @"price_max"

#define kTKPDFILTER_DATACOLUMNKEY @"column"
#define kTKPDFILTER_DATAINDEXPATHKEY @"indexpath"

#define kTKPDFILTER_DATASORTNAMEKEY @"name"
#define kTKPDFILTER_DATASORTVALUEKEY @"value"

#define kTKPDSORT_DATASORTKEY @"sort"

#define kTKPDFILTER_TITLEFILTERKEY @"Filters"
#define kTKPDFILTER_TITLEFILTERLOCATIONKEY @"Select Location"
#define kTKPDFILTER_TITLEFILTERCONDITIONKEY @"Select Condition"
#define kTKPDFILTER_TITLESORTKEY @"Sort"

#define kTKPDFILTER_DATAFILTERTYPEVIEWKEY @"typeview"

#define kTKPDFILTERLOCATION_DATALOCATIONARRAYKEY @"locationarray"

#define kTKPDSORT_CONDITIONSARRAY @[@{kTKPDFILTER_DATASORTNAMEKEY:@"All Condition",kTKPDFILTER_DATASORTVALUEKEY:@"0"},@{kTKPDFILTER_DATASORTNAMEKEY:@"New",kTKPDFILTER_DATASORTVALUEKEY:@"1"},@{kTKPDFILTER_DATASORTNAMEKEY:@"Used",kTKPDFILTER_DATASORTVALUEKEY:@"2"}]

#define kTKPDSORT_HOTLISTSORTARRAY @[@{kTKPDFILTER_DATASORTNAMEKEY:@"Promosi",kTKPDFILTER_DATASORTVALUEKEY:@"1"}, @{kTKPDFILTER_DATASORTNAMEKEY:@"Penjualan",kTKPDFILTER_DATASORTVALUEKEY:@"8"}, @{kTKPDFILTER_DATASORTNAMEKEY:@"Ulasan",kTKPDFILTER_DATASORTVALUEKEY:@"6"}, @{kTKPDFILTER_DATASORTNAMEKEY:@"Diskusi",kTKPDFILTER_DATASORTVALUEKEY:@"7"}, @{kTKPDFILTER_DATASORTNAMEKEY:@"Terbaru",kTKPDFILTER_DATASORTVALUEKEY:@"9"}, @{kTKPDFILTER_DATASORTNAMEKEY:@"Harga Tertinggi",kTKPDFILTER_DATASORTVALUEKEY:@"4"}, @{kTKPDFILTER_DATASORTNAMEKEY:@"Harga Terendah",kTKPDFILTER_DATASORTVALUEKEY:@"3"}]

#define kTKPDSORT_SEARCHPRODUCTSORTARRAY @[@{kTKPDFILTER_DATASORTNAMEKEY:@"Promosi",kTKPDFILTER_DATASORTVALUEKEY:@"1"}, @{kTKPDFILTER_DATASORTNAMEKEY:@"Penjualan",kTKPDFILTER_DATASORTVALUEKEY:@"8"}, @{kTKPDFILTER_DATASORTNAMEKEY:@"Ulasan",kTKPDFILTER_DATASORTVALUEKEY:@"6"}, @{kTKPDFILTER_DATASORTNAMEKEY:@"Diskusi",kTKPDFILTER_DATASORTVALUEKEY:@"7"}, @{kTKPDFILTER_DATASORTNAMEKEY:@"Terbaru",kTKPDFILTER_DATASORTVALUEKEY:@"9"}, @{kTKPDFILTER_DATASORTNAMEKEY:@"Harga Tertinggi",kTKPDFILTER_DATASORTVALUEKEY:@"4"}, @{kTKPDFILTER_DATASORTNAMEKEY:@"Harga Terendah",kTKPDFILTER_DATASORTVALUEKEY:@"3"}]

#define kTKPDSORT_SEARCHCATALOGSORTARRAY @[@{kTKPDFILTER_DATASORTNAMEKEY:@"Tanggal Rilis",kTKPDFILTER_DATASORTVALUEKEY:@"1"}, @{kTKPDFILTER_DATASORTNAMEKEY:@"Product Terbanyak",kTKPDFILTER_DATASORTVALUEKEY:@"3"}, @{kTKPDFILTER_DATASORTNAMEKEY:@"Harga Tertinggi",kTKPDFILTER_DATASORTVALUEKEY:@"5"}, @{kTKPDFILTER_DATASORTNAMEKEY:@"Harga Terendah",kTKPDFILTER_DATASORTVALUEKEY:@"4"}]

#define kTKPDSORT_SEARCHDETAILCATALOGSORTARRAY @[@{kTKPDFILTER_DATASORTNAMEKEY:@"Product Terjual",kTKPDFILTER_DATASORTVALUEKEY:@"1"}, @{kTKPDFILTER_DATASORTNAMEKEY:@"Penilaian",kTKPDFILTER_DATASORTVALUEKEY:@"2"}, @{kTKPDFILTER_DATASORTNAMEKEY:@"Harga Terendah",kTKPDFILTER_DATASORTVALUEKEY:@"3"}, @{kTKPDFILTER_DATASORTNAMEKEY:@"Harga Tertinggi",kTKPDFILTER_DATASORTVALUEKEY:@"4"}]

#define kTKPDSORT_SEARCHPRODUCTSHOPSORTARRAY @[@{kTKPDFILTER_DATASORTNAMEKEY:@"Promo",kTKPDFILTER_DATASORTVALUEKEY:@"1"}, @{kTKPDFILTER_DATASORTNAMEKEY:@"Posisi",kTKPDFILTER_DATASORTVALUEKEY:@"2"}, @{kTKPDFILTER_DATASORTNAMEKEY:@"Pembaruan Terakhir",kTKPDFILTER_DATASORTVALUEKEY:@"3"}, @{kTKPDFILTER_DATASORTNAMEKEY:@"Produk Baru",kTKPDFILTER_DATASORTVALUEKEY:@"4"}, @{kTKPDFILTER_DATASORTNAMEKEY:@"Nama Produk",kTKPDFILTER_DATASORTVALUEKEY:@"5"}, @{kTKPDFILTER_DATASORTNAMEKEY:@"Dilihat Terbanyak",kTKPDFILTER_DATASORTVALUEKEY:@"6"}, @{kTKPDFILTER_DATASORTNAMEKEY:@"Diskusi Terbanyak",kTKPDFILTER_DATASORTVALUEKEY:@"7"},@{kTKPDFILTER_DATASORTNAMEKEY:@"Review Terbanyak",kTKPDFILTER_DATASORTVALUEKEY:@"8"},@{kTKPDFILTER_DATASORTNAMEKEY:@"Pembelian Terbanyak",kTKPDFILTER_DATASORTVALUEKEY:@"9"},@{kTKPDFILTER_DATASORTNAMEKEY:@"Harga Terendah",kTKPDFILTER_DATASORTVALUEKEY:@"10"}, @{kTKPDFILTER_DATASORTNAMEKEY:@"Harga Tertinggi",kTKPDFILTER_DATASORTVALUEKEY:@"11"}]

#define kTKPDHOME_GOTHAM_LIGHT [UIFont fontWithName:@"GothamLight" size:12.0]

#endif
