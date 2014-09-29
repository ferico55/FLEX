//
//  DetailShopViewController.m
//  Tokopedia
//
//  Created by IT Tkpd on 9/9/14.
//  Copyright (c) 2014 TOKOPEDIA. All rights reserved.
//

#import "Shop.h"

#import "detail.h"
#import "DetailShopViewController.h"

@interface DetailShopViewController ()
@property (weak, nonatomic) IBOutlet UILabel *namelabel;

@end

@implementation DetailShopViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self configureRestKit];
    [self loadData];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Mapping
- (void)configureRestKit
{
    // initialize RestKit
    RKObjectManager *objectManager =  [RKObjectManager sharedManager];
    
    // setup object mappings
    RKObjectMapping *shopMapping = [RKObjectMapping mappingForClass:[Shop class]];
    [shopMapping addAttributeMappingsFromDictionary:@{kTKPDDETAIL_APISTATUSKEY:kTKPDDETAIL_APISTATUSKEY,kTKPDDETAIL_APISERVERPROCESSTIMEKEY:kTKPDDETAIL_APISERVERPROCESSTIMEKEY}];

    RKObjectMapping *resultMapping = [RKObjectMapping mappingForClass:[DetailShopResult class]];
    RKObjectMapping *closedinfoMapping = [RKObjectMapping mappingForClass:[ClosedInfo class]];
    [closedinfoMapping addAttributeMappingsFromDictionary:@{kTKPDDETAILSHOP_APIUNTILKEY:kTKPDDETAILSHOP_APIUNTILKEY,
                                                      kTKPDDETAILSHOP_APIRESONKEY:kTKPDDETAILSHOP_APIRESONKEY
                                                      }];
    
    RKObjectMapping *ownerMapping = [RKObjectMapping mappingForClass:[Owner class]];
    [ownerMapping addAttributeMappingsFromDictionary:@{kTKPDDETAILSHOP_APIOWNERIMAGEKEY:kTKPDDETAILSHOP_APIOWNERIMAGEKEY,
                                                           kTKPDDETAILSHOP_APIOWNERPHONEKEY:kTKPDDETAILSHOP_APIOWNERPHONEKEY,
                                                           kTKPDDETAILSHOP_APIOWNERIDKEY:kTKPDDETAILSHOP_APIOWNERIDKEY,
                                                           kTKPDDETAILSHOP_APIOWNEREMAILKEY:kTKPDDETAILSHOP_APIOWNEREMAILKEY,
                                                           kTKPDDETAILSHOP_APIOWNERNAMEKEY:kTKPDDETAILSHOP_APIOWNERNAMEKEY,
                                                           kTKPDDETAILSHOP_APIOWNERMESSAGERKEY:kTKPDDETAILSHOP_APIOWNERMESSAGERKEY
                                                           }];

    RKObjectMapping *shopinfoMapping = [RKObjectMapping mappingForClass:[ShopInfo class]];
    [shopinfoMapping addAttributeMappingsFromDictionary:@{kTKPDDETAILPRODUCT_APISHOPINFOKEY:kTKPDDETAILPRODUCT_APISHOPINFOKEY,
                                                          kTKPDDETAILPRODUCT_APISHOPOPENSINCEKEY:kTKPDDETAILPRODUCT_APISHOPOPENSINCEKEY,
                                                          kTKPDDETAILPRODUCT_APISHOPLOCATIONKEY:kTKPDDETAILPRODUCT_APISHOPLOCATIONKEY,
                                                          kTKPDDETAILPRODUCT_APISHOPLOCATIONKEY:kTKPDDETAILPRODUCT_APISHOPLOCATIONKEY,
                                                          kTKPDDETAILPRODUCT_APISHOPIDKEY:kTKPDDETAILPRODUCT_APISHOPIDKEY,
                                                          kTKPDDETAILPRODUCT_APISHOPLASTLOGINKEY:kTKPDDETAILPRODUCT_APISHOPLASTLOGINKEY,
                                                          kTKPDDETAILPRODUCT_APISHOPTAGLINEKEY:kTKPDDETAILPRODUCT_APISHOPTAGLINEKEY,
                                                          kTKPDDETAILPRODUCT_APISHOPNAMEKEY:kTKPDDETAILPRODUCT_APISHOPNAMEKEY,
                                                          kTKPDDETAILPRODUCT_APISHOPISFAVKEY:kTKPDDETAILPRODUCT_APISHOPISFAVKEY,
                                                          kTKPDDETAILPRODUCT_APISHOPDESCRIPTIONKEY:kTKPDDETAILPRODUCT_APISHOPDESCRIPTIONKEY,
                                                          kTKPDDETAILPRODUCT_APISHOPAVATARKEY:kTKPDDETAILPRODUCT_APISHOPAVATARKEY,
                                                          kTKPDDETAILSHOP_APICOVERKEY:kTKPDDETAILSHOP_APICOVERKEY,
                                                          kTKPDDETAILSHOP_APITOTALFAVKEY:kTKPDDETAILSHOP_APITOTALFAVKEY,
                                                          kTKPDDETAILPRODUCT_APISHOPDOMAINKEY:kTKPDDETAILPRODUCT_APISHOPDOMAINKEY
                                                          }];
    
    RKObjectMapping *shopstatsMapping = [RKObjectMapping mappingForClass:[ShopStats class]];
    [shopstatsMapping addAttributeMappingsFromDictionary:@{kTKPDDETAILPRODUCT_APISHOPSERVICERATEKEY:kTKPDDETAILPRODUCT_APISHOPSERVICERATEKEY,
                                                           kTKPDDETAILPRODUCT_APISHOPSERVICEDESCRIPTIONKEY:kTKPDDETAILPRODUCT_APISHOPSERVICEDESCRIPTIONKEY,
                                                           kTKPDDETAILPRODUCT_APISHOPSPEEDRATEKEY:kTKPDDETAILPRODUCT_APISHOPSPEEDRATEKEY,
                                                           kTKPDDETAILPRODUCT_APISHOPACURACYRATEKEY:kTKPDDETAILPRODUCT_APISHOPACURACYRATEKEY,
                                                           kTKPDDETAILPRODUCT_APISHOPACURACYDESCRIPTIONKEY:kTKPDDETAILPRODUCT_APISHOPACURACYDESCRIPTIONKEY,
                                                           kTKPDDETAILPRODUCT_APISHOPSPEEDDESCRIPTIONKEY:kTKPDDETAILPRODUCT_APISHOPSPEEDDESCRIPTIONKEY
                                                           }];

    RKObjectMapping *shipmentMapping = [RKObjectMapping mappingForClass:[Shipment class]];
    [shipmentMapping addAttributeMappingsFromDictionary:@{kTKPDDETAILSHOP_APISHIPMENTIDKEY:kTKPDDETAILSHOP_APISHIPMENTIDKEY,
                                                           kTKPDDETAILSHOP_APISHIPMENTIMAGEKEY:kTKPDDETAILSHOP_APISHIPMENTIMAGEKEY,
                                                           kTKPDDETAILSHOP_APISHIPMENTNAMEKEY:kTKPDDETAILSHOP_APISHIPMENTNAMEKEY
                                                           }];
    
    RKObjectMapping *shipmentpackageMapping = [RKObjectMapping mappingForClass:[ShipmentPackage class]];
    [shipmentpackageMapping addAttributeMappingsFromDictionary:@{kTKPDDETAILSHOP_APISHIPPINGIDKEY:kTKPDDETAILSHOP_APISHIPPINGIDKEY,
                                                          kTKPDDETAILSHOP_APIPRODUCTNAMEKEY:kTKPDDETAILSHOP_APIPRODUCTNAMEKEY
                                                          }];
    
    RKObjectMapping *paymentMapping = [RKObjectMapping mappingForClass:[Payment class]];
    [paymentMapping addAttributeMappingsFromDictionary:@{kTKPDDETAILSHOP_APIPAYMENTIMAGEKEY:kTKPDDETAILSHOP_APIPAYMENTIMAGEKEY,
                                                         kTKPDDETAILSHOP_APIPAYMENTNAMEKEY:kTKPDDETAILSHOP_APIPAYMENTNAMEKEY}];

    RKObjectMapping *addressMapping = [RKObjectMapping mappingForClass:[Address class]];
    [addressMapping addAttributeMappingsFromDictionary:@{kTKPDDETAILSHOP_APIADDRESSKEY:kTKPDDETAILSHOP_APIADDRESSKEY,
                                                         kTKPDDETAILSHOP_APIADDRESSNAMEKEY:kTKPDDETAILSHOP_APIADDRESSNAMEKEY,
                                                         kTKPDDETAILSHOP_APIADDRESSIDKEY:kTKPDDETAILSHOP_APIADDRESSIDKEY,
                                                         kTKPDDETAILSHOP_APIADDRESSPOSTALKEY:kTKPDDETAILSHOP_APIADDRESSPOSTALKEY,
                                                         kTKPDDETAILSHOP_APIADDRESSDISTRICTKEY:kTKPDDETAILSHOP_APIADDRESSDISTRICTKEY,
                                                         kTKPDDETAILSHOP_APIADDRESSFAXKEY:kTKPDDETAILSHOP_APIADDRESSFAXKEY,
                                                         kTKPDDETAILSHOP_APIADDRESSCITYKEY:kTKPDDETAILSHOP_APIADDRESSCITYKEY,
                                                         kTKPDDETAILSHOP_APIADDRESSPHONEKEY :kTKPDDETAILSHOP_APIADDRESSPHONEKEY,
                                                         kTKPDDETAILSHOP_APIADDRESSEMAILKEY:kTKPDDETAILSHOP_APIADDRESSEMAILKEY,
                                                         kTKPDDETAILSHOP_APIADDRESSPROVINCEKEY:kTKPDDETAILSHOP_APIADDRESSPROVINCEKEY
                                                         }];
    
    [resultMapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:kTKPDDETAILSHOP_APICLOSEDINFOKEY toKeyPath:kTKPDDETAILSHOP_APICLOSEDINFOKEY withMapping:closedinfoMapping]];
    [resultMapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:kTKPDDETAILSHOP_APIOWNERKEY toKeyPath:kTKPDDETAILSHOP_APIOWNERKEY withMapping:ownerMapping]];
    [resultMapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:kTKPDDETAILSHOP_APIINFOKEY toKeyPath:kTKPDDETAILSHOP_APIINFOKEY withMapping:shopinfoMapping]];
    [resultMapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:kTKPDDETAILSHOP_APISTATKEY toKeyPath:kTKPDDETAILSHOP_APISTATKEY withMapping:shopstatsMapping]];
    
    [shipmentMapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:kTKPDDETAILSHOP_APISHIPMENTPACKAGEKEY toKeyPath:kTKPDDETAILSHOP_APISHIPMENTPACKAGEKEY withMapping:shipmentpackageMapping]];
    
    RKResponseDescriptor *responseDescriptor = [RKResponseDescriptor responseDescriptorWithMapping:shopMapping method:RKRequestMethodGET pathPattern:kTKPDDETAILSHOP_APIPATH keyPath:@"" statusCodes:kTkpdIndexSetStatusCodeOK];
    RKResponseDescriptor *responseshipmentDescriptor = [RKResponseDescriptor responseDescriptorWithMapping:shipmentMapping method:RKRequestMethodGET pathPattern:kTKPDDETAILSHOP_APIPATH keyPath:@"result.shipment" statusCodes:kTkpdIndexSetStatusCodeOK];
    RKResponseDescriptor *responsepaymentDescriptor = [RKResponseDescriptor responseDescriptorWithMapping:paymentMapping method:RKRequestMethodGET pathPattern:kTKPDDETAILSHOP_APIPATH keyPath:@"result.payment" statusCodes:kTkpdIndexSetStatusCodeOK];
    RKResponseDescriptor *responseaddressDescriptor = [RKResponseDescriptor responseDescriptorWithMapping:addressMapping method:RKRequestMethodGET pathPattern:kTKPDDETAILSHOP_APIPATH keyPath:@"result.address" statusCodes:kTkpdIndexSetStatusCodeOK];

    [objectManager addResponseDescriptor:responseDescriptor];
    [objectManager addResponseDescriptor:responseshipmentDescriptor];
    [objectManager addResponseDescriptor:responsepaymentDescriptor];
    [objectManager addResponseDescriptor:responseaddressDescriptor];
    
    NSMutableDictionary *dictionary = [NSMutableDictionary dictionary];
    [dictionary setObject:responseDescriptor.mapping forKey:(responseDescriptor.keyPath ?: [NSNull null])];
    [dictionary setObject:responseDescriptor.mapping forKey:(responseshipmentDescriptor.keyPath ?: [NSNull null])];
    [dictionary setObject:responseDescriptor.mapping forKey:(responsepaymentDescriptor.keyPath ?: [NSNull null])];
    [dictionary setObject:responseDescriptor.mapping forKey:(responseaddressDescriptor.keyPath ?: [NSNull null])];
}

- (void)loadData
{
    [NSTimer scheduledTimerWithTimeInterval:3.0
                                     target:self
                                   selector:@selector(requestfailure:)
                                   userInfo:nil
                                    repeats:NO];
	NSDictionary* param = @{
                            @"action" : @"get_shop_info",
                            @"shop_id" : @(681)
                            };
    
    [[RKObjectManager sharedManager] getObjectsAtPath:kTKPDDETAILSHOP_APIPATH parameters:param success:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
        
        [self requestsuccess:mappingResult];
        
    } failure:^(RKObjectRequestOperation *operation, NSError *error) {
        /** failure **/
        [self requestfailure:error];
    }];
}

-(void)requestsuccess:(id)object
{
    NSDictionary *result = ((RKMappingResult*)object).dictionary;
    
    id stats = [result objectForKey:@""];
    
    Shop *shop = stats;
    BOOL status = [shop.status isEqualToString:@"OK"];
    
    if (status) {
        
    }
}

-(void)requestfailure:(id)object
{
    [[RKObjectManager sharedManager].operationQueue cancelAllOperations];
}


@end
