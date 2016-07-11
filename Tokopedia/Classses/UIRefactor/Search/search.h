//
//  search.h
//  Tokopedia
//
//  Created by IT Tkpd on 8/21/14.
//  Copyright (c) 2014 TOKOPEDIA. All rights reserved.
//

#ifndef Tokopedia_search_h
#define Tokopedia_search_h

#define kTKPDSEARCH_TITLE @"Search"

#define kTKPDSEARCH_DATAINDEXPATHKEY @"indexpath"
#define kTKPDSEARCH_DATACOLUMNSKEY @"column"
#define kTKPDSEARCH_DATASEARCHKEY @"search"
#define kTKPDSEARCH_DATATITLEKEY @"title"
#define kTKPDSEARCH_DATAICONKEY @"icon"
#define kTKPDSEARCH_DATATYPE @"type"
#define kTKPDSEARCH_DATAISSEARCHHOTLISTKEY @"issearchhotlist"
#define kTKPDSEARCH_DATAISREDIRECTKEY @"isredirect"

#define kTKPDSEARCH_TITLECATEGORYKEY @"Category"

#define kTKPDSEARCH_DATAURLREDIRECTHOTKEY @"hot"
#define kTKPDSEARCH_DATAURLREDIRECTCATEGORY @"p"

#define kTKPDSEARCH_DATASEARCHPRODUCTKEY @"search_product"
#define kTKPDSEARCH_DATASEARCHCATALOGKEY @"search_catalog"
#define kTKPDSEARCH_DATASEARCHSHOPKEY @"search_shop"

#define kTKPDSEARCH_LIMITPAGE 6

#define kTKPDSHOP_APIPATH @"shop.pl"
#define kTKPDSEARCH_APIPATH @"search.pl"
#define kTKPDSEARCHHOTLIST_APIPATH @"hotlist.pl"

#define kTKPDSEARCH_APIQUERYKEY @"query"
#define kTKPDSEARCH_APIACTIONTYPEKEY @"action"

#define kTKPDSEARCH_APIPAGEKEY @"page"
#define kTKPDSEARCH_APILIMITKEY @"per_page"

/** shop **/
#define kTKPDSEARCH_APISHOPIMAGEKEY @"shop_image"
#define kTKPDSEARCH_APISHOPLOCATIONKEY @"shop_location"
#define kTKPDSEARCH_APISHOPIDKEY @"shop_id"
#define kTKPDSEARCH_APISHOPTOTALTRANSACTIONKEY @"shop_total_transaction"
#define kTKPDSEARCH_APISHOPTOTALFAVKEY @"shop_total_favorite"
#define kTKPDSEARCH_APISHOPGOLDSHOP @"shop_gold_shop"
#define kTKPDSEARCH_APISHOPGOLDSTATUS @"shop_gold_status"
#define kTKPDSEARCH_APISHOPISFAV @"shop_is_fave_shop"
/** product **/
#define kTKPDSEARCH_APIPRODUCTIMAGEKEY      @"product_image"
#define kTKPDSEARCH_APIPRODUCTIMAGEFULLKEY  @"product_image_full"
#define kTKPDSEARCH_APIPRODUCTNAMEKEY       @"product_name"
#define kTKPDSEARCH_APIPRODUCTPRICEKEY      @"product_price"
#define kTKPDSEARCH_APIPRODUCTSHOPNAMEKEY   @"shop_name"
#define kTKPDSEARCH_APIPRODUCTIDKEY         @"product_id"

/** catalog **/
#define kTKPDSEARCH_APICATALOGIMAGEKEY      @"catalog_image"
#define kTKPDSEARCH_APICATALOGIMAGE300KEY   @"catalog_image_300"
#define kTKPDSEARCH_APICATALOGNAMEKEY       @"catalog_name"
#define kTKPDSEARCH_APICATALOGPRICEKEY      @"catalog_price"
#define kTKPDSEARCH_APICATALOGIDKEY         @"catalog_id"
#define kTKPDSEARCH_APICATALOGCOUNTSHOPKEY  @"catalog_count_shop"

/** redirect url **/
#define kTKPDSEARCH_APIREDIRECTURLKEY @"redirect_url"
#define kTKPDSEARCH_APIDEPARTMENTIDKEY @"department_id"
#define kTKPDSEARCH_APIDEPARTEMENTTITLEKEY @"department_title"
#define kTKPDSEARCH_APIDEPARTMENTNAMEKEY @"department_name"

#define kTKPDSEARCH_APIDEPARTMENT_1 @"department_1"
#define kTKPDSEARCH_APIDEPARTMENT_2 @"department_2"
#define kTKPDSEARCH_APIDEPARTMENT_3 @"department_3"

/** has catalog **/
#define kTKPDSEARCH_APIHASCATALOGKEY @"has_catalog"

/** search url **/
#define kTKPDSEARCH_APISEARCH_URLKEY @"search_url"

// department tree
#define kTKPDSEARCH_APIDEPARTMENTTREEKEY @"department_tree"
#define kTKPDSEARCH_APICHILDTREEKEY @"child"
#define kTKPDSEARCH_APIHREFKEY @"href"
#define kTKPDSEARCH_APITREEKEY @"tree"
#define kTKPDSEARCH_APIDIDKEY @"d_id"
#define kTKPDSEARCH_APITITLEKEY @"title"

#define kTKPDSEARCHHOTLIST_APIQUERYKEY @"key"

#define kTKPDSEARCH_APIURINEXTKEY @"uri_next"

#define kTKPDSEARCH_APILISTKEY @"list"
#define kTKPDSEARCH_APIPAGINGKEY @"paging"
#define kTKPDSEARCH_APIPATHMAPPINGREDIRECTKEY @"result"

#define kTKPDSEARCH_APIPRODUCTTYPEKEY @"vi"
#define kTKPDSEARCH_APILOCATIONIDKEY @"floc"
#define kTKPDSEARCH_APIGOLDMERCHANTKEY @"fshop"
#define kTKPDSEARCH_APIMINPRICEKEY @"pmin"
#define kTKPDSEARCH_APIMAXPRICEKEY @"pmax"
#define kTKPDSEARCH_APIIMAGESIZEKEY @"img_size"
#define kTKPDSEARCH_APIOBKEY @"ob"
#define kTKPDSEARCH_APIORDERBYKEY @"order_by"

#define kTKPDSEARCH_APIPRODUCTIDKEY @"product_id"
#define kTKPDSEARCH_APIPRODUCTREVIEWCOUNTKEY    @"product_review_count"
#define kTKPDSEARCH_APIPRODUCTTALKCOUNTKEY      @"product_talk_count"

#define kTKDPSEARCH_APICATALOGIDKEY @"catalog_id"

#define kTKPDSEARCH_STANDARDTABLEVIEWCELLIDENTIFIER @"cell"
#define kTKPDSEARCH_NODATACELLTITLE @"no data"
#define kTKPDSEARCH_NODATACELLDESCS @"no data description"

#define kTKPDSEARCH_CACHEFILEPATH @"search"
#define kTKPDSEARCHPRODUCT_APIRESPONSEFILEFORMAT @"searchproduct%@"
#define kTKPDSEARCHCATALOG_APIRESPONSEFILEFORMAT @"searchcatalog%@"
#define kTKPDSEARCHSHOP_APIRESPONSEFILEFORMAT @"searchshop%@"
#define kTKPDSEARCH_SEARCHHISTORYPATHKEY @"history_search.plist"

#endif
