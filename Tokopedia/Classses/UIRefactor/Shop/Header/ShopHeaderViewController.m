//
//  ShopHeaderViewController.m
//  Tokopedia
//
//  Created by Tokopedia PT on 1/6/15.
//  Copyright (c) 2015 TOKOPEDIA. All rights reserved.
//

#import "ShopHeaderViewController.h"

#import "sortfiltershare.h"
#import "detail.h"
#import "string_product.h"

#import "ShopInfoViewController.h"

#import "URLCacheController.h"
#import "UIImage+ImageEffects.h"
#import "BackgroundLayer.h"

#import "ShopDescriptionView.h"
#import "ShopStatView.h"

#import "ShopDelegate.h"

#import "ProductAddEditViewController.h"
#import "ShopSettingViewController.h"
#import "SendMessageViewController.h"

#import "FavoriteShopAction.h"

@interface ShopHeaderViewController () <UIScrollViewDelegate> {
    BOOL _isNoData;
    BOOL _isRefreshView;
    
    NSInteger _requestCount;
    
    __weak RKObjectManager *_objectManager;
    __weak RKManagedObjectRequestOperation *_request;
    NSOperationQueue *_operationQueue;
    NSTimer *_timer;
    
    NSDictionary* _auth;
    
    NSString *_cachePath;
    URLCacheController *_cacheController;
    URLCacheConnection *_cacheConnection;
    NSTimeInterval _timeInterval;
    
    ShopDescriptionView *_descriptionView;
    ShopStatView *_statView;

}

@property (weak, nonatomic) IBOutlet UIImageView *coverImageView;
@property (weak, nonatomic) IBOutlet UIImageView *avatarImageView;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UIPageControl *pageControl;
@property (weak, nonatomic) IBOutlet UIButton *leftButton;
@property (weak, nonatomic) IBOutlet UIButton *rightButton;

@end

@implementation ShopHeaderViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _isNoData = YES;
    _isRefreshView = NO;
    _requestCount = 0;
    
    _operationQueue = [NSOperationQueue new];

    _cacheController = [URLCacheController new];
    _cacheController.URLCacheInterval = 86400.0;
    _cacheConnection = [URLCacheConnection new];
    
    _descriptionView = [ShopDescriptionView newView];
    [self.scrollView addSubview:_descriptionView];
    
    _statView = [ShopStatView newView];
    [self.scrollView addSubview:_statView];
    
    self.scrollView.hidden = YES;
    self.scrollView.delegate = self;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    self.avatarImageView.layer.cornerRadius = self.avatarImageView.frame.size.width/2;
    self.avatarImageView.layer.borderColor = [UIColor whiteColor].CGColor;
    self.avatarImageView.layer.borderWidth = 3.0f;
    
    self.leftButton.layer.cornerRadius = 3;
    self.leftButton.layer.borderWidth = 1;
    self.leftButton.layer.borderColor = [[UIColor blackColor] colorWithAlphaComponent:0.3].CGColor;

    self.rightButton.layer.cornerRadius = 3;
    self.rightButton.layer.borderWidth = 1;
    self.rightButton.layer.borderColor = [[UIColor blackColor] colorWithAlphaComponent:0.3].CGColor;
    
    if (!_auth) {
        TKPDSecureStorage* secureStorage = [TKPDSecureStorage standardKeyChains];
        NSDictionary* auth = [secureStorage keychainDictionary];
        _auth = auth;
    }
    
    //NSDictionary *auth = (NSDictionary *)[_data objectForKey:kTKPD_AUTHKEY]?:@{};
    if ([_auth allValues] > 0) {
        if ([[_data objectForKey:kTKPDDETAIL_APISHOPIDKEY]integerValue] == [[_auth objectForKey:kTKPD_SHOPIDKEY]integerValue]) {
            [self.leftButton setTitle:@"Settings" forState:UIControlStateNormal];
            [self.leftButton setImage:[UIImage imageNamed:@"icon_setting_grey"] forState:UIControlStateNormal];

            [self.rightButton setTitle:@"Add Product" forState:UIControlStateNormal];
            [self.rightButton setImage:[UIImage imageNamed:@"icon_plus_grey"] forState:UIControlStateNormal];
        } else {
            [self.leftButton setTitle:@"Message" forState:UIControlStateNormal];
            [self.leftButton setImage:[UIImage imageNamed:@"icon_message_grey"] forState:UIControlStateNormal];
            
            [self.rightButton setTitle:@"Favorite" forState:UIControlStateNormal];
            [self.rightButton setImage:[UIImage imageNamed:@"icon_love.png"] forState:UIControlStateNormal];
            self.rightButton.tintColor = [UIColor lightGrayColor];
        }
    } else {
        [self.leftButton setTitle:@"Message" forState:UIControlStateNormal];
        [self.leftButton setImage:[UIImage imageNamed:@"icon_message_grey"] forState:UIControlStateNormal];
        
        [self.rightButton setTitle:@"Favorite" forState:UIControlStateNormal];
        [self.rightButton setImage:[UIImage imageNamed:@"icon_love.png"] forState:UIControlStateNormal];
        self.rightButton.tintColor = [UIColor lightGrayColor];
    }
    
    self.leftButton.titleEdgeInsets = UIEdgeInsetsMake(0, 10, 0, 0);
    self.rightButton.titleEdgeInsets = UIEdgeInsetsMake(0, 10, 0, 0);
    
    self.scrollView.contentSize = CGSizeMake(2 * self.view.frame.size.width, self.scrollView.frame.size.height);
    
    if (_isNoData && !_shop) {
        [self configureRestKit];
        [self request];
    } else {
        [self setDetailData];
    }
    
    if ([[_data objectForKey:kTKPDDETAIL_APISHOPISGOLD] boolValue]) {

        //add gradient in cover image
        _coverImageView.layer.sublayers = nil;
        CAGradientLayer *gradientLayer = [BackgroundLayer blackGradientFromTop];
        gradientLayer.frame = _coverImageView.bounds;
        [_coverImageView.layer insertSublayer:gradientLayer atIndex:0];
    
    } else {
        _coverImageView.backgroundColor = [UIColor whiteColor];
        _avatarImageView.layer.borderWidth = 0;
        _avatarImageView.image = [UIImage imageNamed:@"icon_default_shop.jpg"];
    }

}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [self cancel];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark - Request and Mapping

-(void)cancel
{
    [_objectManager.operationQueue cancelAllOperations];
    _objectManager = nil;
}

- (void)configureRestKit
{
    // initialize RestKit
    _objectManager =  [RKObjectManager sharedClient];
    
    // setup object mappings
    RKObjectMapping *statusMapping = [RKObjectMapping mappingForClass:[Shop class]];
    [statusMapping addAttributeMappingsFromDictionary:@{kTKPD_APISTATUSKEY:kTKPD_APISTATUSKEY,
                                                        kTKPD_APISERVERPROCESSTIMEKEY:kTKPD_APISERVERPROCESSTIMEKEY}];
    
    RKObjectMapping *resultMapping = [RKObjectMapping mappingForClass:[DetailShopResult class]];
    [resultMapping addAttributeMappingsFromDictionary:@{kTKPDDETAILSHOP_APIISOPENKEY:kTKPDDETAILSHOP_APIISOPENKEY}];
    
    RKObjectMapping *closedinfoMapping = [RKObjectMapping mappingForClass:[ClosedInfo class]];
    [closedinfoMapping addAttributeMappingsFromDictionary:@{kTKPDDETAILSHOP_APIUNTILKEY:kTKPDDETAILSHOP_APIUNTILKEY,
                                                            kTKPDDETAILSHOP_APIRESONKEY:kTKPDDETAILSHOP_APIRESONKEY,
                                                            kTKPDDETAILSHOP_APINOTEKEY:kTKPDDETAILSHOP_APINOTEKEY
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
                                                          kTKPDDETAIL_APISHOPIDKEY:kTKPDDETAIL_APISHOPIDKEY,
                                                          kTKPDDETAILPRODUCT_APISHOPLASTLOGINKEY:kTKPDDETAILPRODUCT_APISHOPLASTLOGINKEY,
                                                          kTKPDDETAILPRODUCT_APISHOPTAGLINEKEY:kTKPDDETAILPRODUCT_APISHOPTAGLINEKEY,
                                                          kTKPDDETAILPRODUCT_APISHOPNAMEKEY:kTKPDDETAILPRODUCT_APISHOPNAMEKEY,
                                                          kTKPDDETAILPRODUCT_APISHOPISFAVKEY:kTKPDDETAILPRODUCT_APISHOPISFAVKEY,
                                                          kTKPDDETAILPRODUCT_APISHOPDESCRIPTIONKEY:kTKPDDETAILPRODUCT_APISHOPDESCRIPTIONKEY,
                                                          kTKPDDETAILPRODUCT_APISHOPAVATARKEY:kTKPDDETAILPRODUCT_APISHOPAVATARKEY,
                                                          kTKPDDETAILSHOP_APICOVERKEY:kTKPDDETAILSHOP_APICOVERKEY,
                                                          kTKPDDETAILSHOP_APITOTALFAVKEY:kTKPDDETAILSHOP_APITOTALFAVKEY,
                                                          kTKPDDETAILPRODUCT_APISHOPDOMAINKEY:kTKPDDETAILPRODUCT_APISHOPDOMAINKEY,
                                                          kTKPDDETAILSHOP_APISHOPISGOLD:kTKPDDETAILSHOP_APISHOPISGOLD,
                                                          kTKPDDETAILSHOP_APISHOPURLKEY:kTKPDDETAILSHOP_APISHOPURLKEY,
                                                          }];
    
    RKObjectMapping *shopstatsMapping = [RKObjectMapping mappingForClass:[ShopStats class]];
    [shopstatsMapping addAttributeMappingsFromDictionary:@{kTKPDDETAILPRODUCT_APISHOPSERVICERATEKEY:kTKPDDETAILPRODUCT_APISHOPSERVICERATEKEY,
                                                           kTKPDDETAILPRODUCT_APISHOPSERVICEDESCRIPTIONKEY:kTKPDDETAILPRODUCT_APISHOPSERVICEDESCRIPTIONKEY,
                                                           kTKPDDETAILPRODUCT_APISHOPSPEEDRATEKEY:kTKPDDETAILPRODUCT_APISHOPSPEEDRATEKEY,
                                                           kTKPDDETAILPRODUCT_APISHOPACURACYRATEKEY:kTKPDDETAILPRODUCT_APISHOPACURACYRATEKEY,
                                                           kTKPDDETAILPRODUCT_APISHOPACURACYDESCRIPTIONKEY:kTKPDDETAILPRODUCT_APISHOPACURACYDESCRIPTIONKEY,
                                                           kTKPDDETAILPRODUCT_APISHOPSPEEDDESCRIPTIONKEY:kTKPDDETAILPRODUCT_APISHOPSPEEDDESCRIPTIONKEY,
                                                           kTKPDSHOP_APISHOPTOTALTRANSACTIONKEY:kTKPDSHOP_APISHOPTOTALTRANSACTIONKEY,
                                                           kTKPDSHOP_APISHOPTOTALETALASEKEY:kTKPDSHOP_APISHOPTOTALETALASEKEY,
                                                           kTKPDSHOP_APISHOPTOTALPRODUCTKEY:kTKPDSHOP_APISHOPTOTALPRODUCTKEY,
                                                           kTKPDSHOP_APISHOPTOTALSOLDKEY:kTKPDSHOP_APISHOPTOTALSOLDKEY
                                                           }];
    
    RKObjectMapping *shipmentMapping = [RKObjectMapping mappingForClass:[Shipment class]];
    [shipmentMapping addAttributeMappingsFromDictionary:@{kTKPDDETAILSHOP_APISHIPMENTIDKEY:kTKPDDETAILSHOP_APISHIPMENTIDKEY,
                                                          kTKPDDETAILSHOP_APISHIPMENTIMAGEKEY:kTKPDDETAILSHOP_APISHIPMENTIMAGEKEY,
                                                          kTKPDDETAILSHOP_APISHIPMENTNAMEKEY:kTKPDDETAILSHOP_APISHIPMENTNAMEKEY
                                                          }];
    
    RKObjectMapping *shipmentpackageMapping = [RKObjectMapping mappingForClass:[ShipmentPackage class]];
    [shipmentpackageMapping addAttributeMappingsFromArray:@[kTKPDDETAILSHOP_APISHIPPINGIDKEY,
                                                            kTKPDDETAILSHOP_APIPRODUCTNAMEKEY
                                                            ]];
    
    RKObjectMapping *paymentMapping = [RKObjectMapping mappingForClass:[Payment class]];
    [paymentMapping addAttributeMappingsFromArray:@[kTKPDDETAILSHOP_APIPAYMENTIMAGEKEY,
                                                    kTKPDDETAILSHOP_APIPAYMENTNAMEKEY]];
    
    RKObjectMapping *addressMapping = [RKObjectMapping mappingForClass:[Address class]];
    [addressMapping addAttributeMappingsFromArray:@[//kTKPDDETAIL_APILOCATIONKEY,
                                                    kTKPDSHOP_APIADDRESSNAMEKEY,
                                                    kTKPDSHOP_APIADDRESSIDKEY,
                                                    kTKPDSHOP_APIPOSTALCODEKEY,
                                                    kTKPDSHOP_APIDISTRICTIDKEY,
                                                    kTKPDSHOP_APIFAXKEY,
                                                    kTKPDSHOP_APICITYIDKEY,
                                                    kTKPDSHOP_APIPHONEKEY,
                                                    kTKPDSHOP_APIEMAILKEY,
                                                    kTKPDSHOP_APIPROVINCEIDKEY
                                                    ]];
    // Relationship Mapping
    [statusMapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:kTKPD_APIRESULTKEY
                                                                                  toKeyPath:kTKPD_APIRESULTKEY withMapping:resultMapping]];
    [resultMapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:kTKPDDETAILSHOP_APICLOSEDINFOKEY
                                                                                  toKeyPath:kTKPDDETAILSHOP_APICLOSEDINFOKEY
                                                                                withMapping:closedinfoMapping]];
    [resultMapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:kTKPDDETAILSHOP_APIOWNERKEY
                                                                                  toKeyPath:kTKPDDETAILSHOP_APIOWNERKEY
                                                                                withMapping:ownerMapping]];
    [resultMapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:kTKPDDETAILSHOP_APIINFOKEY
                                                                                  toKeyPath:kTKPDDETAILSHOP_APIINFOKEY
                                                                                withMapping:shopinfoMapping]];
    [resultMapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:kTKPDDETAILSHOP_APISTATKEY
                                                                                  toKeyPath:kTKPDDETAILSHOP_APISTATKEY
                                                                                withMapping:shopstatsMapping]];
    
    RKRelationshipMapping *shipmentRel = [RKRelationshipMapping relationshipMappingFromKeyPath:kTKPDDETAILSHOP_APISHIPMENTKEY
                                                                                     toKeyPath:kTKPDDETAILSHOP_APISHIPMENTKEY
                                                                                   withMapping:shipmentMapping];
    [resultMapping addPropertyMapping:shipmentRel];
    
    RKRelationshipMapping *shipmentpackageRel = [RKRelationshipMapping relationshipMappingFromKeyPath:kTKPDDETAILSHOP_APISHIPMENTPACKAGEKEY
                                                                                            toKeyPath:kTKPDDETAILSHOP_APISHIPMENTPACKAGEKEY
                                                                                          withMapping:shipmentpackageMapping];
    [shipmentMapping addPropertyMapping:shipmentpackageRel];
    
    RKRelationshipMapping *paymentRel = [RKRelationshipMapping relationshipMappingFromKeyPath:kTKPDDETAILSHOP_APIPAYMENTKEY
                                                                                    toKeyPath:kTKPDDETAILSHOP_APIPAYMENTKEY
                                                                                  withMapping:paymentMapping];
    [resultMapping addPropertyMapping:paymentRel];
    
    RKRelationshipMapping *addressRel = [RKRelationshipMapping relationshipMappingFromKeyPath:kTKPDDETAIL_APIADDRESSKEY
                                                                                    toKeyPath:kTKPDDETAIL_APIADDRESSKEY
                                                                                  withMapping:addressMapping];
    [resultMapping addPropertyMapping:addressRel];
    
    RKResponseDescriptor *responseDescriptor = [RKResponseDescriptor responseDescriptorWithMapping:statusMapping
                                                                                            method:RKRequestMethodPOST
                                                                                       pathPattern:kTKPDDETAILSHOP_APIPATH
                                                                                           keyPath:@""
                                                                                       statusCodes:kTkpdIndexSetStatusCodeOK];
    
    [_objectManager addResponseDescriptor:responseDescriptor];
}

- (void)request
{
    _requestCount ++;
    
    NSDictionary* param = @{kTKPDDETAIL_APIACTIONKEY : kTKPDDETAIL_APIGETSHOPDETAILKEY,
                            kTKPDDETAIL_APISHOPIDKEY : @([[_data objectForKey:kTKPDDETAIL_APISHOPIDKEY] integerValue])};
    
    [_cacheController getFileModificationDate];
    _timeInterval = fabs([_cacheController.fileDate timeIntervalSinceNow]);
    
    if (_timeInterval > _cacheController.URLCacheInterval || _isRefreshView) {
        
        UIApplication* app = [UIApplication sharedApplication];
        app.networkActivityIndicatorVisible = YES;
        
        _request = [_objectManager appropriateObjectRequestOperationWithObject:self
                                                                        method:RKRequestMethodPOST
                                                                          path:kTKPDDETAILSHOP_APIPATH
                                                                    parameters:[param encrypt]];
        
        [_request setCompletionBlockWithSuccess:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
            app.networkActivityIndicatorVisible = NO;
            [self requestSuccess:mappingResult withOperation:operation];
            [_timer invalidate];
            
        } failure:^(RKObjectRequestOperation *operation, NSError *error) {
            
            // Failure
            app.networkActivityIndicatorVisible = NO;
            [self requestFailure:error];
            [_timer invalidate];
            
        }];
        
        [_operationQueue addOperation:_request];
        
        _timer = [NSTimer scheduledTimerWithTimeInterval:kTKPDREQUEST_TIMEOUTINTERVAL
                                                  target:self
                                                selector:@selector(requestTimeout)
                                                userInfo:nil
                                                 repeats:NO];
        [[NSRunLoop currentRunLoop] addTimer:_timer forMode:NSRunLoopCommonModes];
    }
    else {
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setTimeStyle:NSDateFormatterShortStyle];
        [dateFormatter setDateStyle:NSDateFormatterMediumStyle];
        NSLog(@"Updated: %@",[dateFormatter stringFromDate:_cacheController.fileDate]);
        NSLog(@"cache and updated in last 24 hours.");
        [self requestFailure:nil];
    }
}

-(void)requestSuccess:(id)object withOperation:(RKObjectRequestOperation *)operation
{
    NSDictionary *result = ((RKMappingResult*)object).dictionary;
    id info = [result objectForKey:@""];
    _shop = info;
    NSString *statusstring = _shop.status;
    BOOL status = [statusstring isEqualToString:kTKPDREQUEST_OKSTATUS];
    
    if (status) {
        //only save cache for first page
        [_cacheConnection connection:operation.HTTPRequestOperation.request
                  didReceiveResponse:operation.HTTPRequestOperation.response];
        [_cacheController connectionDidFinish:_cacheConnection];
        //save response data
        [operation.HTTPRequestOperation.responseData writeToFile:_cachePath atomically:YES];
        
        [self requestProcess:object];
    }
}


-(void)requestFailure:(id)object
{
    if (_timeInterval > _cacheController.URLCacheInterval || _isRefreshView) {
        [self requestProcess:object];
    }
    else{
        NSError* error;
        NSData *data = [NSData dataWithContentsOfFile:_cachePath];
        id parsedData = [RKMIMETypeSerialization objectFromData:data MIMEType:RKMIMETypeJSON error:&error];
        if (parsedData == nil && error) {
            NSLog(@"parser error");
        }
        
        NSMutableDictionary *mappingsDictionary = [[NSMutableDictionary alloc] init];
        for (RKResponseDescriptor *descriptor in _objectManager.responseDescriptors) {
            [mappingsDictionary setObject:descriptor.mapping forKey:descriptor.keyPath];
        }
        
        RKMapperOperation *mapper = [[RKMapperOperation alloc] initWithRepresentation:parsedData
                                                                   mappingsDictionary:mappingsDictionary];
        NSError *mappingError = nil;
        BOOL isMapped = [mapper execute:&mappingError];
        if (isMapped && !mappingError) {
            RKMappingResult *mappingresult = [mapper mappingResult];
            NSDictionary *result = mappingresult.dictionary;
            id info = [result objectForKey:@""];
            _shop = info;
            NSString *statusstring = _shop.status;
            BOOL status = [statusstring isEqualToString:kTKPDREQUEST_OKSTATUS];
            
            if (status) {
                [self requestProcess:mappingresult];
            }
        }
    }
}

-(void)requestProcess:(id)object
{
    if (object) {
        if ([object isKindOfClass:[RKMappingResult class]]) {
            NSDictionary *result = ((RKMappingResult*)object).dictionary;
            id stats = [result objectForKey:@""];
            _shop = stats;
            BOOL status = [_shop.status isEqualToString:kTKPDREQUEST_OKSTATUS];
            if (status) {
                _isNoData = NO;
                [self setDetailData];
                [self.delegate didReceiveShop:_shop];
            }
        }
        else{
            [self cancel];
            NSLog(@" REQUEST FAILURE ERROR %@", [(NSError*)object description]);
            if ([(NSError*)object code] == NSURLErrorCancelled) {
                if (_requestCount<kTKPDREQUESTCOUNTMAX) {
                    [self performSelector:@selector(configureRestKit)
                               withObject:nil
                               afterDelay:kTKPDREQUEST_DELAYINTERVAL];
                    [self performSelector:@selector(request)
                               withObject:nil
                               afterDelay:kTKPDREQUEST_DELAYINTERVAL];
                }
            }
        }
    }
}

-(void)requestTimeout
{
    [self cancel];
}

-(void)setDetailData
{
    _leftButton.enabled = YES;
    _rightButton.enabled = YES;
    
    self.scrollView.hidden = NO;
    
    _descriptionView.nameLabel.text = _shop.result.info.shop_name;
    [_descriptionView.nameLabel sizeToFit];
    
    if (_shop.result.info.shop_is_gold == 1) {
//        _descriptionView.badgeImageView.hidden = NO;
    }
    
    UIFont *font = [UIFont fontWithName:@"GothamBook" size:13];
    
    NSMutableParagraphStyle *style = [[NSMutableParagraphStyle alloc] init];
    style.lineSpacing = 6.0;
    
    NSDictionary *attributes = @{NSForegroundColorAttributeName: [UIColor blackColor],
                                 NSFontAttributeName: font,
                                 NSParagraphStyleAttributeName: style,
                                 };
    
    NSAttributedString *productNameAttributedText = [[NSAttributedString alloc] initWithString:_shop.result.info.shop_description
                                                                                    attributes:attributes];
    
    _descriptionView.descriptionLabel.attributedText = productNameAttributedText;
    _descriptionView.descriptionLabel.textAlignment = NSTextAlignmentCenter;
    
    _statView.locationLabel.text = [NSString stringWithFormat:@"     %@", _shop.result.info.shop_location];
    UIImageView *iconLocation = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"icon_location.png"]];
    iconLocation.frame = CGRectMake(0, 0, 15, 15);
    [_statView.locationLabel addSubview:iconLocation];
    
    _statView.openStatusLabel.text = [NSString stringWithFormat:@"Terakhir Online : %@", _shop.result.info.shop_owner_last_login];
    
    NSString *stats = [NSString stringWithFormat:@"%@ Favorit %@ Barang Terjual",
                       _shop.result.info.shop_total_favorit,
                       _shop.result.stats.shop_item_sold];
//    
//    NSMutableAttributedString *attributedText = [[NSMutableAttributedString alloc] initWithString:stats];
//    [attributedText addAttribute:NSFontAttributeName value:boldFont range:NSMakeRange(0, [_shop.result.info.shop_total_favorit length])];
//    [attributedText addAttribute:NSFontAttributeName value:boldFont range:NSMakeRange([_shop.result.info.shop_total_favorit length] + 11, [_shop.result.stats.shop_item_sold length])];
    
    [_statView.statLabel setText:stats];
    
    self.scrollView.hidden = NO;
    self.pageControl.hidden = NO;
    
    // Set cover image
    NSURLRequest* request = [[NSURLRequest alloc] initWithURL:[NSURL URLWithString:_shop.result.info.shop_cover]
                                                  cachePolicy:NSURLRequestUseProtocolCachePolicy
                                              timeoutInterval:kTKPDREQUEST_TIMEOUTINTERVAL];
    
    [self.coverImageView setImageWithURLRequest:request placeholderImage:nil success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-retain-cycles"

        self.coverImageView.image = image;
        self.coverImageView.hidden = NO;
        
        self.coverImage = image;

        [self.delegate didLoadImage:image];

#pragma clang diagnostic pop
    } failure:nil];
    
    request = [[NSURLRequest alloc] initWithURL:[NSURL URLWithString:_shop.result.info.shop_avatar]
                                    cachePolicy:NSURLRequestUseProtocolCachePolicy
                                timeoutInterval:kTKPDREQUEST_TIMEOUTINTERVAL];
    
    [_avatarImageView setImageWithURLRequest:request placeholderImage:nil success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-retain-cycles"
        [_avatarImageView setImage:image];
#pragma clang diagnostic pop
        
    } failure:nil];
    

    //NSDictionary *auth = (NSDictionary *)[_data objectForKey:kTKPD_AUTHKEY];
    if ([[_data objectForKey:kTKPDDETAIL_APISHOPIDKEY] integerValue] != [[_auth objectForKey:kTKPD_SHOPIDKEY] integerValue]) {

        if (_shop.result.info.shop_already_favorited == 1) {
            _rightButton.tag = 3;
            [_rightButton setTitle:@"Unfavorite" forState:UIControlStateNormal];
            [_rightButton setImage:[UIImage imageNamed:@"icon_love_white.png"] forState:UIControlStateNormal];
            [_rightButton.layer setBorderWidth:0];
            _rightButton.tintColor = [UIColor whiteColor];
            [UIView animateWithDuration:0.3 animations:^(void) {
                [_rightButton setBackgroundColor:[UIColor colorWithRed:240.0/255.0 green:60.0/255.0 blue:100.0/255.0 alpha:1]];
                [_rightButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
            }];
            
        } else {
            _rightButton.tag = 2;
            [_rightButton setTitle:@"Favorite" forState:UIControlStateNormal];
            [_rightButton setImage:[UIImage imageNamed:@"icon_love.png"] forState:UIControlStateNormal];
            _rightButton.tintColor = [UIColor lightGrayColor];
            [_rightButton.layer setBorderWidth:1];
            [UIView animateWithDuration:0.3 animations:^(void) {
                [_rightButton setBackgroundColor:[UIColor whiteColor]];
                [_rightButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
            }];
        }
    }
}

#pragma mark - Request and mapping favorite action

-(void)configureFavoriteRestkit {

    // initialize RestKit
    _objectManager =  [RKObjectManager sharedClient];
    
    // setup object mappings
    RKObjectMapping *statusMapping = [RKObjectMapping mappingForClass:[FavoriteShopAction class]];
    [statusMapping addAttributeMappingsFromDictionary:@{kTKPD_APISTATUSKEY:kTKPD_APISTATUSKEY,
                                                        kTKPD_APISERVERPROCESSTIMEKEY:kTKPD_APISERVERPROCESSTIMEKEY}];
    
    RKObjectMapping *resultMapping = [RKObjectMapping mappingForClass:[FavoriteShopActionResult class]];
    [resultMapping addAttributeMappingsFromDictionary:@{@"content":@"content",
                                                        @"is_success":@"is_success"}];
    
    //relation
    RKRelationshipMapping *resulRel = [RKRelationshipMapping relationshipMappingFromKeyPath:kTKPD_APIRESULTKEY
                                                                                  toKeyPath:kTKPD_APIRESULTKEY
                                                                                withMapping:resultMapping];
    [statusMapping addPropertyMapping:resulRel];
    
    //register mappings with the provider using a response descriptor
    RKResponseDescriptor *responseDescriptorStatus = [RKResponseDescriptor responseDescriptorWithMapping:statusMapping
                                                                                                  method:RKRequestMethodPOST
                                                                                             pathPattern:@"action/favorite-shop.pl"
                                                                                                 keyPath:@""
                                                                                             statusCodes:kTkpdIndexSetStatusCodeOK];
    
    [_objectManager addResponseDescriptor:responseDescriptorStatus];
}


-(void)favoriteShop:(NSString *)shop_id sender:(UIButton*)btn
{
    if (_request.isExecuting) return;

    _requestCount ++;

    NSDictionary *param = @{kTKPDDETAIL_ACTIONKEY   :   @"fav_shop",
                            @"shop_id"              :   shop_id};
    
    _request = [_objectManager appropriateObjectRequestOperationWithObject:self
                                                                    method:RKRequestMethodPOST
                                                                      path:@"action/favorite-shop.pl"
                                                                parameters:[param encrypt]];
    
    [_request setCompletionBlockWithSuccess:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
        [self requestFavoriteResult:mappingResult withOperation:operation];
        [_timer invalidate];
        _timer = nil;
        
    } failure:^(RKObjectRequestOperation *operation, NSError *error) {
        /** failure **/
        [self requestFavoriteError:error];
        [_timer invalidate];
        _timer = nil;
    }];
    
    [_operationQueue addOperation:_request];
    
    _timer = [NSTimer scheduledTimerWithTimeInterval:kTKPDREQUEST_TIMEOUTINTERVAL
                                              target:self
                                            selector:@selector(requestTimeout)
                                            userInfo:nil
                                             repeats:NO];
    [[NSRunLoop currentRunLoop] addTimer:_timer forMode:NSRunLoopCommonModes];
}

-(void)requestFavoriteResult:(id)mappingResult withOperation:(NSOperation *)operation {
    [[NSNotificationCenter defaultCenter] postNotificationName:@"notifyFav" object:nil];
}

-(void)requestFavoriteError:(id)object {
    
}


#pragma mark - Scroll view delegate

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    self.pageControl.currentPage = scrollView.contentOffset.x / self.view.frame.size.width;
}

- (void)didScroll:(UIScrollView *)scrollView
{
    if (scrollView.contentOffset.y < 0) {
        CGRect frame = _coverImageView.frame;
        CGPoint translation = [scrollView.panGestureRecognizer translationInView:scrollView.superview];
        if(translation.y > 0)
        {
            frame.origin.y = scrollView.contentOffset.y;
            frame.size.height =  200 + fabsf(scrollView.contentOffset.y);
        } else {
            frame.origin.y = 0;
            frame.size.height = 200;
        }        
        _coverImageView.frame = frame;
    }
}

#pragma mark - Actions

- (IBAction)tap:(id)sender
{
    
    //NSDictionary *auth = (NSDictionary *)[_data objectForKey:kTKPD_AUTHKEY];
    
    UIButton *button = (UIButton *)sender;
    switch (button.tag) {
        case 1: {
            if ([[_data objectForKey:kTKPDDETAIL_APISHOPIDKEY] integerValue] == [[_auth objectForKey:kTKPD_SHOPIDKEY] integerValue]) {
                ShopSettingViewController *settingController = [ShopSettingViewController new];
                settingController.data = @{kTKPD_AUTHKEY : [_data objectForKey:kTKPD_AUTHKEY]?:@{},
                                           kTKPDDETAIL_DATAINFOSHOPSKEY:_shop.result
                                           };
                [self.navigationController pushViewController:settingController animated:YES];
                break;
            }
 
            SendMessageViewController *messageController = [SendMessageViewController new];
            messageController.data = @{
                        kTKPDDETAIL_APISHOPIDKEY:@([[_data objectForKey:kTKPDDETAIL_APISHOPIDKEY]integerValue]?:0),
                        kTKPDDETAIL_APISHOPNAMEKEY:_shop.result.info.shop_name
                        };
            [self.navigationController pushViewController:messageController animated:YES];
            break;
        }

        case 2: {
            
            if ([[_data objectForKey:kTKPDDETAIL_APISHOPIDKEY] integerValue] == [[_auth objectForKey:kTKPD_SHOPIDKEY] integerValue]) {
                ProductAddEditViewController *productViewController = [ProductAddEditViewController new];
                productViewController.type = TYPE_ADD_EDIT_PRODUCT_ADD;
                UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:productViewController];
                nav.navigationBar.translucent = NO;
                
                [self.navigationController presentViewController:nav animated:YES completion:nil];
                break;
            }
            
            // Favorite shop action
            [self configureFavoriteRestkit];
            [self favoriteShop:_shop.result.info.shop_id sender:_rightButton];
            
            _rightButton.tag = 3;
            [_rightButton setTitle:@"Unfavorite" forState:UIControlStateNormal];
            [_rightButton setImage:[UIImage imageNamed:@"icon_love_white.png"] forState:UIControlStateNormal];
            [_rightButton.layer setBorderWidth:0];
            _rightButton.tintColor = [UIColor whiteColor];
            [UIView animateWithDuration:0.3 animations:^(void) {
                [_rightButton setBackgroundColor:[UIColor colorWithRed:240.0/255.0 green:60.0/255.0 blue:100.0/255.0 alpha:1]];
                [_rightButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
            }];
            break;            
        }

        case 3: {
            [self configureFavoriteRestkit];
            
            [self favoriteShop:_shop.result.info.shop_id sender:_rightButton];
            
            _rightButton.tag = 2;
            [_rightButton setTitle:@"Favorite" forState:UIControlStateNormal];
            [_rightButton setImage:[UIImage imageNamed:@"icon_love.png"] forState:UIControlStateNormal];
            [_rightButton.layer setBorderWidth:1];
            self.rightButton.tintColor = [UIColor lightGrayColor];
            [UIView animateWithDuration:0.3 animations:^(void) {
                [_rightButton setBackgroundColor:[UIColor whiteColor]];
                [_rightButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
            }];
        }
            
        default:
            break;
    }
}

@end
