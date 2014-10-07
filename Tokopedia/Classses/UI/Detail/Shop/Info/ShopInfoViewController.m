//
//  ShopInfoViewController.m
//  Tokopedia
//
//  Created by IT Tkpd on 10/6/14.
//  Copyright (c) 2014 TOKOPEDIA. All rights reserved.
//

#import "detail.h"

#import "Shop.h"

#import "StarsRateView.h"
#import "ShopInfoShipmentCell.h"
#import "ShopInfoPaymentCell.h"

#import "ShopInfoViewController.h"

@interface ShopInfoViewController()<UITableViewDataSource, UITableViewDelegate, UIScrollViewDelegate>
{
    Shop *_shop;
    BOOL _isnodata;
    NSInteger _requestcount;
    __weak RKObjectManager *_objectmanager;
    NSTimer *_timer;
}

@property (strong, nonatomic) IBOutlet UIScrollView *scrollview;
@property (weak, nonatomic) IBOutlet UIView *containerview;

@property (weak, nonatomic) IBOutlet UIImageView *thumb;
@property (weak, nonatomic) IBOutlet UILabel *labelshopname;
@property (weak, nonatomic) IBOutlet UILabel *labelshoptagline;
@property (weak, nonatomic) IBOutlet UILabel *labelshopdescription;
@property (weak, nonatomic) IBOutlet UIButton *buttonfav;
@property (weak, nonatomic) IBOutlet UIButton *buttonitemsold;
@property (weak, nonatomic) IBOutlet StarsRateView *speedrate;
@property (weak, nonatomic) IBOutlet StarsRateView *accuracyrate;
@property (weak, nonatomic) IBOutlet StarsRateView *servicerate;
@property (weak, nonatomic) IBOutlet UILabel *labellocation;
@property (weak, nonatomic) IBOutlet UILabel *labellastlogin;
@property (weak, nonatomic) IBOutlet UILabel *labelopensince;
@property (weak, nonatomic) IBOutlet UIButton *buttonofflocation;


@property (weak, nonatomic) IBOutlet UILabel *labelsuccessfulltransaction;
@property (weak, nonatomic) IBOutlet UILabel *labelsold;
@property (weak, nonatomic) IBOutlet UILabel *labeletalase;
@property (weak, nonatomic) IBOutlet UILabel *labeltotalproduct;

@property (weak, nonatomic) IBOutlet UITableView *tableshipment;

@property (weak, nonatomic) IBOutlet UITableView *tablepayment;

@property (weak, nonatomic) IBOutlet UIImageView *thumbowner;
@property (weak, nonatomic) IBOutlet UILabel *nameowner;

@property (weak, nonatomic) IBOutlet UIView *shipmentview;
@property (weak, nonatomic) IBOutlet UIView *paymentview;
@property (weak, nonatomic) IBOutlet UIView *ownerview;

@end

@implementation ShopInfoViewController

#pragma mark - Initialization
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        _requestcount = 0;
        _isnodata = YES;
    }
    return self;
}

#pragma mark - Life Cycle
- (void)viewDidLoad
{
    [super viewDidLoad];
    _scrollview.delegate = self;
    _scrollview.scrollEnabled = YES;
    CGSize viewsize = _containerview.frame.size;
    [_scrollview setContentSize:viewsize];
    [_scrollview addSubview:_containerview];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    //if (!_isrefreshview) {
        [self configureRestKit];
        if (_isnodata) {
            [self loadData];
        }
    //}
}

-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [self cancel];
}

#pragma mark - Memory Management
-(void)dealloc{
    NSLog(@"%@ : %@",[self class], NSStringFromSelector(_cmd));
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - Table View Data Source
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if (tableView == _tableshipment) {
        // Table Shipment
#ifdef kTKPDSHOPINFO_NODATAENABLE
        return _isnodata ? 1 : _shop.result.shipment.count;
#else
        return _isnodata ? 0 : _shop.result.shipment.count;
#endif
    }
    else if (tableView == _tablepayment){
        // Table Payment
#ifdef kTKPDSHOPINFO_NODATAENABLE
        return _isnodata ? 1 : _shop.result.payment.count;
#else
        return _isnodata ? 0 : _shop.result.payment.count;
#endif
    }
    return 0;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell* cell = nil;
    
    if (!_isnodata) {
        if (tableView == _tableshipment) {
            // Table Shipment
        
            NSString *cellid = kTKPDSHOPINFOPAYMENTCELL_IDENTIFIER;
            
            cell = (ShopInfoShipmentCell*)[tableView dequeueReusableCellWithIdentifier:cellid];
            if (cell == nil) {
                cell = [ShopInfoShipmentCell newcell];
            }
            
            if (_shop.result.shipment.count > indexPath.row) {
                
                Shipment *shipment = _shop.result.shipment[indexPath.row];
                ((ShopInfoShipmentCell*)cell).labelshipment.text = shipment.shipment_name;
                NSArray *packages = shipment.shipment_package;
                for (int i = 0; i<packages.count; i++) {
                    ShipmentPackage *package = packages[i];
                    ((UILabel*)((ShopInfoShipmentCell*)cell).labelpackage[i]).text = package.product_name;
                    ((UIView*)((ShopInfoShipmentCell*)cell).viewpackage[i]).hidden = NO;
                }
            }
        }
        else if (tableView == _tablepayment){
            // Table Payment

            NSString *cellid = kTKPDSHOPINFOPAYMENTCELL_IDENTIFIER;
            
            cell = (ShopInfoPaymentCell*)[tableView dequeueReusableCellWithIdentifier:cellid];
            if (cell == nil) {
                cell = [ShopInfoPaymentCell newcell];
            }
            
            if (_shop.result.payment.count > indexPath.row) {
                
                Payment *payment = _shop.result.payment[indexPath.row];
                ((ShopInfoPaymentCell*)cell).labelpayment.text = payment.payment_name;
                
                NSURLRequest* request = [[NSURLRequest alloc] initWithURL:[NSURL URLWithString:payment.payment_image] cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:kTKPDREQUEST_TIMEOUTINTERVAL];
                //request.URL = url;
                
                UIImageView *thumb = ((ShopInfoPaymentCell*)cell).image;
                thumb.image = nil;
                //thumb.hidden = YES;	//@prepareforreuse then @reset
                
                //[((ShopInfoPaymentCell*)cell).act startAnimating];
                
                [thumb setImageWithURLRequest:request placeholderImage:nil success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-retain-cycles"
                    //NSLOG(@"thumb: %@", thumb);
                    [thumb setImage:image];
                    
                    //[((ShopInfoPaymentCell*)cell).act stopAnimating];
#pragma clang diagnostic pop
                    
                } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) {
                    //[((ShopInfoPaymentCell*)cell).act stopAnimating];
                }];
            }
        }
    }
    else {
        static NSString *CellIdentifier = kTKPDDETAIL_STANDARDTABLEVIEWCELLIDENTIFIER;
        
        cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        if (cell == nil) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
        }
        
        cell.textLabel.text = kTKPDDETAIL_NODATACELLTITLE;
        cell.detailTextLabel.text = kTKPDDETAIL_NODATACELLDESCS;
    }
    return cell;
}

#pragma mark - Table View Delegate
- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
	if (_isnodata) {
		cell.backgroundColor = [UIColor whiteColor];
	}
    
    NSInteger row = [self tableView:tableView numberOfRowsInSection:indexPath.section] -1;
	if (row == indexPath.row) {
		NSLog(@"%@", NSStringFromSelector(_cmd));
	}
}


#pragma mark - Request and Mapping
-(void)cancel
{
    [_objectmanager.operationQueue cancelAllOperations];
    _objectmanager = nil;
}

- (void)configureRestKit
{
    // initialize RestKit
    _objectmanager =  [RKObjectManager sharedClient];
    
    // setup object mappings
    RKObjectMapping *statusMapping = [RKObjectMapping mappingForClass:[Shop class]];
    [statusMapping addAttributeMappingsFromDictionary:@{kTKPDDETAIL_APISTATUSKEY:kTKPDDETAIL_APISTATUSKEY,
                                                        kTKPDDETAIL_APISERVERPROCESSTIMEKEY:kTKPDDETAIL_APISERVERPROCESSTIMEKEY}];
    
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
    [shipmentpackageMapping addAttributeMappingsFromArray:@[kTKPDDETAILSHOP_APISHIPPINGIDKEY,
                                                            kTKPDDETAILSHOP_APIPRODUCTNAMEKEY
                                                            ]];
    
    RKObjectMapping *paymentMapping = [RKObjectMapping mappingForClass:[Payment class]];
    [paymentMapping addAttributeMappingsFromArray:@[kTKPDDETAILSHOP_APIPAYMENTIMAGEKEY,
                                                    kTKPDDETAILSHOP_APIPAYMENTNAMEKEY]];
    
    RKObjectMapping *addressMapping = [RKObjectMapping mappingForClass:[Address class]];
    [addressMapping addAttributeMappingsFromArray:@[kTKPDDETAILSHOP_APIADDRESSKEY,
                                                    kTKPDDETAILSHOP_APIADDRESSNAMEKEY,
                                                    kTKPDDETAILSHOP_APIADDRESSIDKEY,
                                                    kTKPDDETAILSHOP_APIADDRESSPOSTALKEY,
                                                    kTKPDDETAILSHOP_APIADDRESSDISTRICTKEY,
                                                    kTKPDDETAILSHOP_APIADDRESSFAXKEY,
                                                    kTKPDDETAILSHOP_APIADDRESSCITYKEY,
                                                    kTKPDDETAILSHOP_APIADDRESSPHONEKEY,
                                                    kTKPDDETAILSHOP_APIADDRESSEMAILKEY,
                                                    kTKPDDETAILSHOP_APIADDRESSPROVINCEKEY
                                                    ]];
    // Relationship Mapping
    [statusMapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:kTKPD_APIRESULTKEY toKeyPath:kTKPD_APIRESULTKEY withMapping:resultMapping]];
    [resultMapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:kTKPDDETAILSHOP_APICLOSEDINFOKEY toKeyPath:kTKPDDETAILSHOP_APICLOSEDINFOKEY withMapping:closedinfoMapping]];
    [resultMapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:kTKPDDETAILSHOP_APIOWNERKEY toKeyPath:kTKPDDETAILSHOP_APIOWNERKEY withMapping:ownerMapping]];
    [resultMapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:kTKPDDETAILSHOP_APIINFOKEY toKeyPath:kTKPDDETAILSHOP_APIINFOKEY withMapping:shopinfoMapping]];
    [resultMapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:kTKPDDETAILSHOP_APISTATKEY toKeyPath:kTKPDDETAILSHOP_APISTATKEY withMapping:shopstatsMapping]];
    
    RKRelationshipMapping *shipmentRel = [RKRelationshipMapping relationshipMappingFromKeyPath:kTKPDDETAILSHOP_APISHIPMENTKEY toKeyPath:kTKPDDETAILSHOP_APISHIPMENTKEY withMapping:shipmentMapping];
    [resultMapping addPropertyMapping:shipmentRel];
    
    RKRelationshipMapping *shipmentpackageRel = [RKRelationshipMapping relationshipMappingFromKeyPath:kTKPDDETAILSHOP_APISHIPMENTPACKAGEKEY toKeyPath:kTKPDDETAILSHOP_APISHIPMENTPACKAGEKEY withMapping:shipmentpackageMapping];
    [shipmentMapping addPropertyMapping:shipmentpackageRel];
    
    RKRelationshipMapping *paymentRel = [RKRelationshipMapping relationshipMappingFromKeyPath:kTKPDDETAILSHOP_APIPAYMENTKEY toKeyPath:kTKPDDETAILSHOP_APIPAYMENTKEY withMapping:paymentMapping];
    [resultMapping addPropertyMapping:paymentRel];
    
    RKRelationshipMapping *addressRel = [RKRelationshipMapping relationshipMappingFromKeyPath:kTKPDDETAILSHOP_APIADDRESSKEY toKeyPath:kTKPDDETAILSHOP_APIADDRESSKEY withMapping:addressMapping];
    [resultMapping addPropertyMapping:addressRel];
    
    RKResponseDescriptor *responseDescriptor = [RKResponseDescriptor responseDescriptorWithMapping:statusMapping method:RKRequestMethodGET pathPattern:kTKPDDETAILSHOP_APIPATH keyPath:@"" statusCodes:kTkpdIndexSetStatusCodeOK];
    
    [_objectmanager addResponseDescriptor:responseDescriptor];
}

- (void)loadData
{
    _requestcount ++;
    
	NSDictionary* param = @{
                            kTKPDDETAIL_APIACTIONKEY : kTKPDDETAIL_APIGETSHOPDETAILKEY,
                            kTKPDDETAIL_APISHOPIDKEY : @(681)
                            };
    
    [_objectmanager getObjectsAtPath:kTKPDDETAILSHOP_APIPATH parameters:param success:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
        
        [self requestsuccess:mappingResult];
        
    } failure:^(RKObjectRequestOperation *operation, NSError *error) {
        /** failure **/
        [self requestfailure:error];
    }];
    
    _timer = [NSTimer scheduledTimerWithTimeInterval:kTKPDREQUEST_TIMEOUTINTERVAL target:self selector:@selector(requesttimeout) userInfo:nil repeats:NO];
    [[NSRunLoop currentRunLoop] addTimer:_timer forMode:NSRunLoopCommonModes];
}

-(void)requestsuccess:(id)object
{
    NSDictionary *result = ((RKMappingResult*)object).dictionary;
    
    id stats = [result objectForKey:@""];
    
    _shop = stats;
    BOOL status = [_shop.status isEqualToString:kTKPDREQUEST_OKSTATUS];
    
    if (status) {
        _isnodata = NO;
        [self setShopInfoData];
        [_tablepayment reloadData];
        [_tableshipment reloadData];
    }
}

-(void)requesttimeout
{
    [self cancel];
}

-(void)requestfailure:(id)object
{
    [self cancel];
    NSLog(@" REQUEST FAILURE ERROR %@", [(NSError*)object description]);
    if ([(NSError*)object code] == NSURLErrorCancelled) {
        if (_requestcount<kTKPDREQUESTCOUNTMAX) {
            NSLog(@" ==== REQUESTCOUNT %d =====",_requestcount);
            //_table.tableFooterView = _footer;
            //[_act startAnimating];
            [self performSelector:@selector(configureRestKit) withObject:nil afterDelay:kTKPDREQUEST_DELAYINTERVAL];
            [self performSelector:@selector(loadData) withObject:nil afterDelay:kTKPDREQUEST_DELAYINTERVAL];
        }
        else
        {
            //[_act stopAnimating];
            //_table.tableFooterView = nil;
        }
    }
    else
    {
        //[_act stopAnimating];
        //_table.tableFooterView = nil;
    }
}

#pragma mark - Methods
-(void)setShopInfoData
{
    _labelshopname.text = _shop.result.info.shop_name;
    _labelshoptagline.text = _shop.result.info.shop_tagline;
    _labelshopdescription.text = _shop.result.info.shop_description;
    [_buttonfav setTitle:_shop.result.info.shop_total_favorit forState:UIControlStateNormal];
    [_buttonitemsold setTitle:_shop.result.info.shop_total_favorit forState:UIControlStateNormal];
    _speedrate.starscount = _shop.result.stats.shop_service_rate;
    _accuracyrate.starscount = _shop.result.stats.shop_accuracy_rate;
    _servicerate.starscount = _shop.result.stats.shop_service_rate;
    _labellocation.text = _shop.result.info.shop_location;
    _labellastlogin.text = _shop.result.info.shop_owner_last_login;
    _labelopensince.text = _shop.result.info.shop_open_since;
    _nameowner.text = _shop.result.owner.owner_name;
    
    NSURLRequest* request = [[NSURLRequest alloc] initWithURL:[NSURL URLWithString:_shop.result.info.shop_avatar] cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:kTKPDREQUEST_TIMEOUTINTERVAL];
    //request.URL = url;
    
    UIImageView *thumb = _thumb;
    thumb.image = nil;
    //thumb.hidden = YES;	//@prepareforreuse then @reset
    
    //[((ShopInfoPaymentCell*)cell).act startAnimating];
    
    [thumb setImageWithURLRequest:request placeholderImage:nil success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-retain-cycles"
        //NSLOG(@"thumb: %@", thumb);
        [thumb setImage:image];
        
        //[((ShopInfoPaymentCell*)cell).act stopAnimating];
#pragma clang diagnostic pop
        
    } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) {
        //[((ShopInfoPaymentCell*)cell).act stopAnimating];
    }];
    
    request = [[NSURLRequest alloc] initWithURL:[NSURL URLWithString:_shop.result.owner.owner_image] cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:kTKPDREQUEST_TIMEOUTINTERVAL];
    //request.URL = url;
    
    thumb = _thumbowner;
    thumb.image = nil;
    //thumb.hidden = YES;	//@prepareforreuse then @reset
    
    //[((ShopInfoPaymentCell*)cell).act startAnimating];
    
    [thumb setImageWithURLRequest:request placeholderImage:nil success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-retain-cycles"
        //NSLOG(@"thumb: %@", thumb);
        [thumb setImage:image];
        
        //[((ShopInfoPaymentCell*)cell).act stopAnimating];
#pragma clang diagnostic pop
        
    } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) {
        //[((ShopInfoPaymentCell*)cell).act stopAnimating];
    }];

}

-(void)setFrame
{
    [_tableshipment layoutIfNeeded];
    CGSize size = _tableshipment.contentSize;
    CGRect frame = _shipmentview.frame;
    frame.size.height = size.height + _tableshipment.frame.origin.y;
    
    [_tablepayment layoutIfNeeded];
    size = _tablepayment.contentSize;
    frame = _paymentview.frame;
    frame.origin.y = _shipmentview.frame.size.height + _shipmentview.frame.origin.y;
    frame.size.height = size.height;
    _paymentview.frame = frame;
    
    frame = _ownerview.frame;
    frame.origin.y = _paymentview.frame.size.height + _paymentview.frame.origin.y;
    _ownerview.frame = frame;
}

@end
