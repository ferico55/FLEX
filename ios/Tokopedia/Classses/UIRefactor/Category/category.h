//
//  category.h
//  Tokopedia
//
//  Created by IT Tkpd on 8/28/14.
//  Copyright (c) 2014 TOKOPEDIA. All rights reserved.
//

#ifndef Tokopedia_category_h
#define Tokopedia_category_h

typedef enum
{
    CATEGORY_MENU_PREVIOUS_VIEW_DEFAULT = 0,
    CATEGORY_MENU_PREVIOUS_VIEW_ADD_PRODUCT
} CATEGORY_MENU_PREVIOUS_VIEW;

#define kTKPDCATEGORY_TITLE @"Product List"

#define kTKPDCATEGORYRESULT_LIMITPAGE 5

#define kTKPDCATEGORY_DATAFILTERTYPEVIEWKEY @"typeview"
#define kTKPDCATEGORY_DATATYPEHOTLISTVIEWKEY @"hotlistview"

#define kTKPDCATEGORY_DATAINDEXPATHKEY @"indexpath"
#define kTKPDCATEGORY_DATACATEGORYINDEXPATHKEY @"categoryindexpath"

#define kTKPDCATEGORY_DATACOLUMNSKEY @"column"
#define kTKPDCATEGORY_DATACATEGORYKEY @"categories"
#define kTKPDCATEGORY_DATATITLEKEY @"title"
#define CStringKategory @"Kategory"
#define kTKPDCATEGORY_DATADIDALLCATEGORYKEY @"d_id_allcategory"
#define kTKPDCATEGORY_DATADIDKEY @"d_id"
#define kTKPDCATEGORY_DATADEPARTMENTIDKEY @"department_id"
#define kTKPDCATEGORY_DATAICONKEY @"icon"
#define kTKPDCATEGORY_DATAISNULLCHILD @"isnullchild"
#define kTKPDCATEGORY_DATATYPEKEY @"type"
#define kTKPDHASHTAG_HOTLIST @"hashtag_hotlist"
#define kTKPDCATEGORY_DATATYPECATEGORYKEY 1
#define DATA_CATEGORY_MENU_PREVIOUS_VIEW_TYPE @"previousviewtype"

#define kTKPDCATEGORY_DATAPUSHCOUNTKEY @"pushcount"
#define DATA_PUSH_COUNT_CONTROL @"pushcountcontrol"
#define kTKPDCATEGORY_DATAISAUTOMATICPUSHKEY @"isotomatis"
#define kTKPDCATEGORY_DATACHOSENINDEXPATHKEY @"chosenindexpaths"

#define kTKPDCATEGORY_APIDEPARTMENTTREEKEY @"department_tree"
#define kTKPDCATEGORY_APIDEPARTMENTCHILDKEY @"child"

#define kTKPDCATEGORY_STANDARDTABLEVIEWCELLIEDNTIFIER @"cell"
#define kTKPDCATEGORY_NODATACELLTITLE @"no data"
#define kTKPDCATEGORY_NODATACELLDESCS @"no data description"

#define kTKPDCATEGORY_TITLEARRAY @[@"Pakaian",@"Handphone & Tablet", @"Office & Stationery", @"Fashion & Aksesoris", @"Laptop & Aksesoris", @"Souvenir, Kado & Hadiah", @"Kecantikan", @"Komputer & Aksesoris", @"Mainan & Hobi", @"Kesehatan", @"Elektronik", @"Makanan & Minuman", @"Rumah Tangga", @"Kamera, Foto & Video", @"Buku", @"Dapur", @"Otomotif", @"Software", @"Perawatan Bayi", @"Olahraga", @"Film, Musik & Game", @"Produk Lainnya"]

#define kTKPDCATEGORY_IDARRAY @[@"78",@"65",@"642",  @"79",@"288",@"54",  @"61",@"297",@"55",  @"715",@"60",@"35",  @"984",@"578",@"8",  @"983",@"63",@"20",  @"56",@"62",@"57",  @"36"]

#endif
