//
//  FavoriteShopRequest.m
//  Tokopedia
//
//  Created by Johanes Effendi on 1/21/16.
//  Copyright © 2016 TOKOPEDIA. All rights reserved.
//

#import "FavoriteShopRequest.h"
#import "TokopediaNetworkManager.h"

#define PER_PAGE 6

typedef NS_ENUM(NSInteger, FavoriteShopRequestType){
    FavoriteShopRequestAll,
    FavoriteShopRequestListing,
    FavoriteShopRequestDoFavorite,
    FavoriteShopRequestGetProductFeed
};

@interface FavoriteShopRequest()<TokopediaNetworkManagerDelegate>
@end

@implementation FavoriteShopRequest{
    TokopediaNetworkManager *networkManager;
    NSString* shopId;
    NSString* adKey;
    NSInteger page;
    FavoritedShopResult* favShops;
    __weak RKObjectManager *_objectmanager;
}

- (id)init{
    self = [super init];
    if(self){
        networkManager = [TokopediaNetworkManager new];
        networkManager.delegate = self;
    }
    return self;
}

#pragma mark Public Function
-(void)requestFavoriteShopListings{
    networkManager.tagRequest = FavoriteShopRequestAll;
    [networkManager doRequest];
}

-(void)requestFavoriteShopListingsWithPage:(NSInteger)p{
    page = p;
    networkManager.tagRequest = FavoriteShopRequestListing;
    [networkManager doRequest];
}

-(void)requestActionButtonFavoriteShop:(NSString*)shopIdd withAdKey:(NSString*)adKeyy{
    shopId = shopIdd;
    adKey = adKeyy;
    networkManager.tagRequest = FavoriteShopRequestDoFavorite;
    [networkManager doRequest];
}

-(void)requestProductFeedWithFavoriteShopList:(FavoritedShopResult*)favoriteShopResult withPage:(NSInteger)p{
    favShops = favoriteShopResult;
    page = p;
    networkManager.tagRequest = FavoriteShopRequestGetProductFeed;
    [networkManager doRequest];
}

-(void)cancelAllOperation{
    [_objectmanager.operationQueue cancelAllOperations];
}

#pragma mark Tokopedia Network Manager Delegate
- (NSDictionary*)getParameter:(int)tag{
    if(tag == FavoriteShopRequestListing){
        return @{kTKPDHOME_APIACTIONKEY:kTKPDHOMEFAVORITESHOPACT,
                 kTKPDHOME_APILIMITPAGEKEY : @(PER_PAGE),
                 kTKPDHOME_APIPAGEKEY:@(page)};
    }else if(tag == FavoriteShopRequestDoFavorite){
        return @{
                 @"shop_id":shopId,
                 @"ad_key":adKey
                 };
    }else if(tag == FavoriteShopRequestGetProductFeed){
        NSString* strShops = [self generateShopString];
        return @{
                 @"device":@"ios",
                 @"rows":@(PER_PAGE),
                 @"start":@((page*PER_PAGE)+1),
                 @"shop_id":strShops
                 };
    }else if(tag == FavoriteShopRequestAll){
        return @{kTKPDHOME_APIACTIONKEY:kTKPDHOMEFAVORITESHOPACT};
    }
    return nil;
}
- (NSString*)getPath:(int)tag{
    if(tag == FavoriteShopRequestListing || tag == FavoriteShopRequestAll){
        return @"/v4/home/get_favorite_shop.pl";
    }else if(tag == FavoriteShopRequestDoFavorite){
        return @"/v4/action/favorite-shop/fav_shop.pl";
    }else if(tag == FavoriteShopRequestGetProductFeed){
        return @"search/v1/product";
    }
    return nil;
}

- (int)getRequestMethod:(int)tag{
    if(tag == FavoriteShopRequestListing || tag == FavoriteShopRequestAll){
        networkManager.isUsingHmac = YES;
        return RKRequestMethodGET;
    }else if(tag == FavoriteShopRequestDoFavorite){
        networkManager.isUsingHmac = YES;
        return RKRequestMethodGET;
    }else if(tag == FavoriteShopRequestGetProductFeed){
        networkManager.isUsingHmac = NO;
        networkManager.isParameterNotEncrypted = YES;
        return RKRequestMethodGET;
    }
    return RKRequestMethodGET;
}

- (id)getObjectManager:(int)tag{
    if(tag == FavoriteShopRequestListing || tag == FavoriteShopRequestAll){
        _objectmanager =  [RKObjectManager sharedClientHttps];
        
        // setup object mappings
        RKObjectMapping *statusMapping = [RKObjectMapping mappingForClass:[FavoritedShop class]];
        [statusMapping addAttributeMappingsFromDictionary:@{kTKPD_APISTATUSKEY:kTKPD_APISTATUSKEY,
                                                            kTKPD_APISERVERPROCESSTIMEKEY:kTKPD_APISERVERPROCESSTIMEKEY}];
        
        RKObjectMapping *dataMapping = [RKObjectMapping mappingForClass:[FavoritedShopResult class]];
        
        RKObjectMapping *pagingMapping = [RKObjectMapping mappingForClass:[Paging class]];
        [pagingMapping addAttributeMappingsFromDictionary:@{kTKPDDETAIL_APIURINEXTKEY:kTKPDDETAIL_APIURINEXTKEY}];
        
        RKObjectMapping *listMapping = [RKObjectMapping mappingForClass:[FavoritedShopList class]];
        [listMapping addAttributeMappingsFromArray:@[
                                                     kTKPDDETAILSHOP_APISHOPIMAGE,
                                                     kTKPDDETAILSHOP_APISHOPLOCATION,
                                                     kTKPDDETAILSHOP_APISHOPID,
                                                     kTKPDDETAILSHOP_APISHOPNAME,
                                                     ]];
        
        RKObjectMapping *listGoldMapping = [RKObjectMapping mappingForClass:[FavoritedShopList class]];
        [listGoldMapping addAttributeMappingsFromArray:@[
                                                         kTKPDDETAILSHOP_APISHOPIMAGE,
                                                         kTKPDDETAILSHOP_APISHOPLOCATION,
                                                         kTKPDDETAILSHOP_APISHOPID,
                                                         kTKPDDETAILSHOP_APISHOPNAME,
                                                         ]];
        
        //relation
        RKRelationshipMapping *dataRel = [RKRelationshipMapping relationshipMappingFromKeyPath:@"data" toKeyPath:@"data" withMapping:dataMapping];
        [statusMapping addPropertyMapping:dataRel];
        
        RKRelationshipMapping *pageRel = [RKRelationshipMapping relationshipMappingFromKeyPath:kTKPDHOME_APIPAGINGKEY toKeyPath:kTKPDHOME_APIPAGINGKEY withMapping:pagingMapping];
        [dataMapping addPropertyMapping:pageRel];
        
        RKRelationshipMapping *listRel = [RKRelationshipMapping relationshipMappingFromKeyPath:kTKPDHOME_APILISTKEY toKeyPath:kTKPDHOME_APILISTKEY withMapping:listMapping];
        [dataMapping addPropertyMapping:listRel];
        
        RKRelationshipMapping *listGoldRel = [RKRelationshipMapping relationshipMappingFromKeyPath:kTKPDHOME_APILISTGOLDKEY toKeyPath:kTKPDHOME_APILISTGOLDKEY withMapping:listMapping];
        [dataMapping addPropertyMapping:listGoldRel];
        
        //register mappings with the provider using a response descriptor
        RKResponseDescriptor *responseDescriptorStatus = [RKResponseDescriptor responseDescriptorWithMapping:statusMapping
                                                                                                      method:[self getRequestMethod:FavoriteShopRequestListing]
                                                                                                 pathPattern:[self getPath:FavoriteShopRequestListing]
                                                                                                     keyPath:@""
                                                                                                 statusCodes:kTkpdIndexSetStatusCodeOK];
        
        [_objectmanager addResponseDescriptor:responseDescriptorStatus];
        return _objectmanager;

    }else if(tag == FavoriteShopRequestDoFavorite){
        _objectmanager =  [RKObjectManager sharedClientHttps];
        
        // setup object mappings
        RKObjectMapping *statusMapping = [RKObjectMapping mappingForClass:[FavoriteShopAction class]];
        [statusMapping addAttributeMappingsFromDictionary:@{kTKPD_APISTATUSKEY:kTKPD_APISTATUSKEY,
                                                            kTKPD_APISERVERPROCESSTIMEKEY:kTKPD_APISERVERPROCESSTIMEKEY}];
        
        RKObjectMapping *dataMapping = [RKObjectMapping mappingForClass:[FavoriteShopActionResult class]];
        [dataMapping addAttributeMappingsFromDictionary:@{@"content":@"content",
                                                          @"is_success":@"is_success"}];
        
        RKRelationshipMapping *dataRel = [RKRelationshipMapping relationshipMappingFromKeyPath:@"data" toKeyPath:@"data" withMapping:dataMapping];
        //[statusMapping addPropertyMapping:dataRel];
        
        //register mappings with the provider using a response descriptor
        RKResponseDescriptor *responseDescriptorStatus = [RKResponseDescriptor
                                                          responseDescriptorWithMapping:statusMapping
                                                          method:[self getRequestMethod:FavoriteShopRequestDoFavorite]
                                                          pathPattern:[self getPath:FavoriteShopRequestDoFavorite]
                                                          keyPath:@""
                                                          statusCodes:kTkpdIndexSetStatusCodeOK];
        
        [_objectmanager addResponseDescriptor:responseDescriptorStatus];
        
        return _objectmanager;
    }else if(tag == FavoriteShopRequestGetProductFeed){
        _objectmanager = [RKObjectManager sharedClient:@"http://ace.tokopedia.com/"];
        
        RKObjectMapping *statusMapping = [RKObjectMapping mappingForClass:[SearchAWS class]];
        [statusMapping addAttributeMappingsFromDictionary:@{kTKPD_APISTATUSKEY:kTKPD_APISTATUSKEY,
                                                            kTKPD_APISERVERPROCESSTIMEKEY:kTKPD_APISERVERPROCESSTIMEKEY
                                                            }];
        
        
        RKObjectMapping *resultMapping = [RKObjectMapping mappingForClass:[SearchAWSResult class]];
        
        [resultMapping addAttributeMappingsFromDictionary:@{kTKPDSEARCH_APIHASCATALOGKEY:kTKPDSEARCH_APIHASCATALOGKEY,
                                                            kTKPDSEARCH_APISEARCH_URLKEY:kTKPDSEARCH_APISEARCH_URLKEY,
                                                            @"st":@"st",@"redirect_url" : @"redirect_url", @"department_id" : @"department_id", @"share_url" : @"share_url"
                                                            }];
        
        RKObjectMapping *listMapping = [RKObjectMapping mappingForClass:[SearchAWSProduct class]];
        //product
        [listMapping addAttributeMappingsFromArray:@[@"product_image", @"product_image_full", @"product_price", @"product_name", @"product_shop", @"product_id", @"product_review_count", @"product_talk_count", @"shop_gold_status", @"shop_name", @"is_owner",@"shop_location", @"shop_lucky" ]];
        
        // paging mapping
        RKObjectMapping *pagingMapping = [RKObjectMapping mappingForClass:[Paging class]];
        [pagingMapping addAttributeMappingsFromDictionary:@{kTKPDSEARCH_APIURINEXTKEY:kTKPDSEARCH_APIURINEXTKEY}];
        
        //add list relationship
        [statusMapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:kTKPD_APIRESULTKEY toKeyPath:kTKPD_APIRESULTKEY withMapping:resultMapping]];
        
        RKRelationshipMapping *productsRel = [RKRelationshipMapping relationshipMappingFromKeyPath:@"products" toKeyPath:@"products" withMapping:listMapping];
        
        [resultMapping addPropertyMapping:productsRel];
        
        // add page relationship
        RKRelationshipMapping *pageRel = [RKRelationshipMapping relationshipMappingFromKeyPath:kTKPDSEARCH_APIPAGINGKEY toKeyPath:kTKPDSEARCH_APIPAGINGKEY withMapping:pagingMapping];
        [resultMapping addPropertyMapping:pageRel];
        
        // register mappings with the provider using a response descriptor
        RKResponseDescriptor *responseDescriptor = [RKResponseDescriptor responseDescriptorWithMapping:statusMapping
                                                                                                method:[self getRequestMethod:FavoriteShopRequestGetProductFeed]
                                                                                           pathPattern:[self getPath:FavoriteShopRequestGetProductFeed]
                                                                                               keyPath:@""
                                                                                           statusCodes:kTkpdIndexSetStatusCodeOK];
        
        //add response description to object manager
        [_objectmanager addResponseDescriptor:responseDescriptor];
        
        return _objectmanager;

    }
    return nil;
}

- (NSString*)getRequestStatus:(id)result withTag:(int)tag{
    NSDictionary *resultDict = ((RKMappingResult*)result).dictionary;
    id stat = [resultDict objectForKey:@""];
    
    if(tag == FavoriteShopRequestListing || tag == FavoriteShopRequestAll){
        return ((FavoritedShop*) stat).status;
    }else if(tag == FavoriteShopRequestDoFavorite){
        return ((FavoriteShopAction*) stat).status;
    }else if(tag == FavoriteShopRequestGetProductFeed){
        return ((SearchAWS*)stat).status;
    }
    return nil;
}

- (void)actionAfterRequest:(id)successResult withOperation:(RKObjectRequestOperation*)operation withTag:(int)tag{
    NSDictionary *result = ((RKMappingResult*)successResult).dictionary;
    id temp = [result objectForKey:@""];
    
    if(tag == FavoriteShopRequestListing || tag == FavoriteShopRequestAll){
        [_delegate didReceiveFavoriteShopListing:((FavoritedShop*)temp).data];
    }else if(tag == FavoriteShopRequestDoFavorite){
        FavoriteShopAction* favShopAction = (FavoriteShopAction*)temp;
        [_delegate didReceiveActionButtonFavoriteShopConfirmation:favShopAction];
    }else if(tag == FavoriteShopRequestGetProductFeed){
        [_delegate didReceiveProductFeed:(SearchAWS*)temp];
    }
}

- (void)actionFailAfterRequest:(id)errorResult withTag:(int)tag{
    if(tag == FavoriteShopRequestListing || tag == FavoriteShopRequestAll){
        [_delegate failToRequestFavoriteShopListing];
    }else if(tag == FavoriteShopRequestDoFavorite){
        [_delegate failToRequestActionButtonFavoriteShopConfirmation];
    }else if(tag == FavoriteShopRequestGetProductFeed){
        [_delegate failToRequestProductFeed];
    }
}

#pragma mark Utils Method

//return string with format: shop_id_0, shop_id_1, shop_id_2, dst
-(NSMutableString*) generateShopString{
    NSMutableString* result = [NSMutableString string];
    for (FavoritedShopList* shop in favShops.list) {
        [result appendFormat:@"%@,",shop.shop_id];
    }
    [result deleteCharactersInRange:NSMakeRange([result length]-1, 1)];
    return result;
}

@end
