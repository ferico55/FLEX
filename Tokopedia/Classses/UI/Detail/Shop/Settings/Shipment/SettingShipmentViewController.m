//
//  SettingShipmentViewController.m
//  Tokopedia
//
//  Created by IT Tkpd on 11/18/14.
//  Copyright (c) 2014 TOKOPEDIA. All rights reserved.
//

#import "detail.h"
#import "ShippingInfo.h"
#import "ShopSettings.h"

#import "../../../../../CacheController/URLCacheController.h"
#import "../../../../../CacheController/URLCacheConnection.h"

#import "SettingShipmentViewController.h"
#import "SettingShipmentSectionHeaderView.h"
#import "SettingShipmentInfoViewController.h"
#import "SettingShipmentCell.h"
#import "SettingShipmentSectionFooterView.h"
#import "SettingShipmentSectionFooter2View.h"
#import "SettingShipmentSectionFooter3View.h"

#import "../../../../SortFilterShare/sortfiltershare.h"
#import "../../../../SortFilterShare/Filter/FilterLocation/FilterLocationViewController.h"

@interface SettingShipmentViewController ()<UITableViewDataSource,UITableViewDelegate, SettingShipmentCellDelegate, SettingShipmentSectionFooterViewDelegate,SettingShipmentSectionFooter2ViewDelegate,SettingShipmentSectionFooter3ViewDelegate,FilterLocationViewControllerDelegate>
{
    NSMutableDictionary *_datainput;
    NSMutableArray *_shipmentids;
    
    UITextField *_activetextfield;
    
    ShippingInfo *_shippinginfo;
    NSMutableArray *_expandedSections;
    BOOL _isnodata;
    NSInteger _requestcount;
    
    __weak RKObjectManager *_objectmanager;
    __weak RKManagedObjectRequestOperation *_request;
    
    __weak RKObjectManager *_objectmanagerActionShipment;
    __weak RKManagedObjectRequestOperation *_requestActionShipment;
    
    RKResponseDescriptor *_responseDescriptor;
    NSOperationQueue *_operationQueue;
    
    NSString *_cachepath;
    URLCacheController *_cachecontroller;
    URLCacheConnection *_cacheconnection;
    NSTimeInterval _timeinterval;
}

@property (strong, nonatomic) IBOutlet UIView *viewheader;
@property (strong, nonatomic) IBOutlet SettingShipmentSectionHeaderView *viewsectionheader;
@property (strong, nonatomic) IBOutlet SettingShipmentSectionFooterView *viewfooter;
@property (strong, nonatomic) IBOutlet SettingShipmentSectionFooter2View *viewfooter2;
@property (strong, nonatomic) IBOutlet SettingShipmentSectionFooter3View *viewfooter3;
@property (weak, nonatomic) IBOutlet UIButton *buttonprovinsi;
@property (weak, nonatomic) IBOutlet UITextField *textfieldkodepos;
@property (weak, nonatomic) IBOutlet UITableView *table;

-(void)cancel;
-(void)configureRestKit;
-(void)request;
-(void)requestsuccess:(id)object withOperation:(RKObjectRequestOperation*)operation;
-(void)requestfailure:(id)object;
-(void)requestprocess:(id)object;
-(void)requesttimeout;

-(void)cancelActionShipment;
-(void)configureRestKitActionShipment;
-(void)requestActionShipment:(id)object;
-(void)requestSuccessActionShipment:(id)object withOperation:(RKObjectRequestOperation*)operation;
-(void)requestFailureActionShipment:(id)object;
-(void)requestProcessActionShipment:(id)object;
-(void)requestTimeoutActionShipment;

-(IBAction)tap:(id)sender;
- (IBAction)gesture:(id)sender;

@end

@implementation SettingShipmentViewController

#pragma mark - Initialization
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

#pragma mark - Life Cycle
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    _datainput = [NSMutableDictionary new];
    _shipmentids = [NSMutableArray new];
    _expandedSections = [NSMutableArray new];
    _operationQueue = [NSOperationQueue new];
    _cacheconnection = [URLCacheConnection new];
    _cachecontroller = [URLCacheController new];

    _table.tableHeaderView = _viewheader;
    
    //cache
    NSString *path = [[NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) lastObject]stringByAppendingPathComponent:kTKPDDETAILPRODUCT_CACHEFILEPATH];
    _cachepath = [path stringByAppendingPathComponent:[NSString stringWithFormat:kTKPDDETAILSHOPSHIPPING_APIRESPONSEFILEFORMAT,0]];
    _cachecontroller.filePath = _cachepath;
    _cachecontroller.URLCacheInterval = 86400.0;
	[_cachecontroller initCacheWithDocumentPath:path];
    
    
    UIBarButtonItem *barbutton;
    NSBundle* bundle = [NSBundle mainBundle];
    UIImage *img = [[UIImage alloc] initWithContentsOfFile:[bundle pathForResource:kTKPDIMAGE_ICONBACK ofType:@"png"]];
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7) { // iOS 7
        UIImage * image = [img imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
        barbutton = [[UIBarButtonItem alloc] initWithImage:image style:UIBarButtonItemStylePlain target:self action:@selector(tap:)];
    }
    else
        barbutton = [[UIBarButtonItem alloc] initWithImage:img style:UIBarButtonItemStylePlain target:self action:@selector(tap:)];
	[barbutton setTag:10];
    self.navigationItem.leftBarButtonItem = barbutton;
    
    barbutton = [[UIBarButtonItem alloc] initWithTitle:@"Save" style:UIBarButtonItemStylePlain target:(self) action:@selector(tap:)];
    [barbutton setTintColor:[UIColor blackColor]];
    barbutton.tag = 11;
    self.navigationItem.rightBarButtonItem = barbutton;
    
    [self configureRestKit];
    [self request];
}


#pragma mark - TableView Delegate
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    
    id shipment = _shippinginfo.result.shipment;
    ShippingInfoShipments *shipments = shipment[section];
    SettingShipmentSectionHeaderView *v = [SettingShipmentSectionHeaderView newview];
    v.labeltitle.text = shipments.shipment_name;
    
    NSURLRequest* request = [[NSURLRequest alloc] initWithURL:[NSURL URLWithString:shipments.shipment_image] cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:kTKPDREQUEST_TIMEOUTINTERVAL];
    //request.URL = url;
    
    UIImageView *thumb = v.thumb;
    thumb.image = nil;
    //thumb.hidden = YES;	//@prepareforreuse then @reset
    
    [v.act startAnimating];
    
    [thumb setImageWithURLRequest:request placeholderImage:nil success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-retain-cycles"
        //NSLOG(@"thumb: %@", thumb);
        [thumb setImage:image animated:YES];
        
        [v.act stopAnimating];
#pragma clang diagnosti c pop
        
    } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) {
        [v.act stopAnimating];
    }];
    
    //hide-unhide label not supported
    BOOL sectionIsExanded = [_expandedSections containsObject:[NSNumber numberWithInteger:section]];
    v.labelnotsupported.hidden = sectionIsExanded;
    
    return v;
}

-(UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    BOOL sectionIsExanded = [_expandedSections containsObject:[NSNumber numberWithInteger:section]];
    if (sectionIsExanded) {
        NSArray *shipments = _shippinginfo.result.shipment;
        ShippingInfoShipments *shipment = shipments[section];
        if ([shipment.shipment_name isEqualToString:@"JNE"]) {
            SettingShipmentSectionFooterView *v = [SettingShipmentSectionFooterView newview];
            v.tag = section+10;
            v.labelinfo.text = [NSString stringWithFormat:@"Info Tentang %@",shipment.shipment_name];
            v.delegate = self;
            return v;
        }
        else if ([shipment.shipment_name isEqualToString:@"Tiki"]||[shipment.shipment_name isEqualToString:@"Pos Indonesia"])
        {
            SettingShipmentSectionFooter3View *v = [SettingShipmentSectionFooter3View newview];
            v.tag = section+10;
            v.labelinfo.text = [NSString stringWithFormat:@"Info Tentang %@",shipment.shipment_name];
            v.delegate = self;
            if ([shipment.shipment_name isEqualToString:@"Pos Indonesia"]) {
                NSInteger integer = _shippinginfo.result.pos_min_weight.min_weight;
                v.switchweightmin.on = (integer == 0)?NO:YES;
                v.labelweightmin.text = [NSString stringWithFormat:@"%d",integer];
                integer = _shippinginfo.result.tiki_fee;
                v.switchfee.on = (integer == 0)?NO:YES;
                v.textfieldfee.text = [NSString stringWithFormat:@"%d",integer];
            }
            else if ([shipment.shipment_name isEqualToString:@"Tiki"])
            {
                NSInteger integer = _shippinginfo.result.tiki_fee;
                v.switchfee.on = (integer == 0)?NO:YES;
                v.textfieldfee.text = [NSString stringWithFormat:@"%d",integer];
            }
            return v;
        }
        else
        {
            SettingShipmentSectionFooter2View *v = [SettingShipmentSectionFooter2View newview];
            v.tag = section+10;
            v.labelinfo.text = [NSString stringWithFormat:@"Info Tentang %@",shipment.shipment_name];
            v.delegate = self;
            return v;
        }
    }
    else return nil;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return _viewsectionheader.frame.size.height;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    BOOL sectionIsExanded = [_expandedSections containsObject:[NSNumber numberWithInteger:section]];
    if (sectionIsExanded) {
        id shipment = _shippinginfo.result.shipment;
        ShippingInfoShipments *shipments = shipment[section];
        if ([shipments.shipment_name isEqualToString:@"JNE"]) {
            return _viewfooter.frame.size.height;
        }
        else if ([shipments.shipment_name isEqualToString:@"Tiki"]||[shipments.shipment_name isEqualToString:@"Pos Indonesia"])
        {
            return _viewfooter3.frame.size.height;
        }
        else
        {
            return _viewfooter2.frame.size.height;
        }
    } else return 0;
    

}


#pragma mark -
#pragma mark  What will be the height of the section, Make it dynamic

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    BOOL sectionIsExanded = [_expandedSections containsObject:[NSNumber numberWithInteger:indexPath.section]];
    if (sectionIsExanded) {
        return 45;
    } else return 0;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return _shippinginfo.result.shipment.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    BOOL sectionIsExanded = [_expandedSections containsObject:[NSNumber numberWithInteger:section]];
    if (sectionIsExanded) {
        id shipment = _shippinginfo.result.shipment;
        ShippingInfoShipments *shipments = shipment[section];
        return shipments.shipment_package.count;
    }else return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell* cell = nil;
    if (!_isnodata) {
        
        NSString *cellid = kTKPDSETTINGSHIPMENTCELLIDENTIFIER;
		
		cell = (SettingShipmentCell*)[tableView dequeueReusableCellWithIdentifier:cellid];
		if (cell == nil) {
			cell = [SettingShipmentCell newcell];
			((SettingShipmentCell*)cell).delegate = self;
		}
        
        BOOL sectionIsExanded = [_expandedSections containsObject:[NSNumber numberWithInteger:indexPath.section]];
        if (sectionIsExanded) {
            NSArray *shipments = _shippinginfo.result.shipment;
            ShippingInfoShipments *shipment = shipments[indexPath.section];
            NSArray *packages = shipment.shipment_package;
            ShippingInfoShipmentPackage *package = packages[indexPath.row];
            
            ((SettingShipmentCell*)cell).labelpackage.text = package.name;
            ((SettingShipmentCell*)cell).indexpath = indexPath;
            ((SettingShipmentCell*)cell).switchpackage.on = package.active;
            ((SettingShipmentCell*)cell).packageid = package.sp_id;
            ((SettingShipmentCell*)cell).shipmentid = shipment.shipment_id;
        }
	} else {
		static NSString *CellIdentifier = kTKPDDETAIL_STANDARDTABLEVIEWCELLIDENTIFIER;
		
		cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
		if (cell == nil) {
			cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
			cell.selectionStyle = UITableViewCellSelectionStyleNone;
		}
		
		cell.textLabel.text = kTKPDDETAIL_NODATACELLTITLE;
		cell.detailTextLabel.text = kTKPDDETAIL_NODATACELLDESCS;
	}


    
    //cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    //if (cell == nil) {
    //    cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    //    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    //}
    //
    //switch (indexPath.section) {
    //    case 0:
    //        [cell addSubview:_viewjne];
    //        break;
    //    case 1:
    //        [cell addSubview:_viewtiki];
    //        break;
    //    case 2:
    //        [cell addSubview:_viewrpx];
    //        break;
    //    case 3:
    //        [cell addSubview:_viewwahana];
    //        break;
    //    case 4:
    //        [cell addSubview:_viewpos];
    //        break;
    //    case 5:
    //        [cell addSubview:_viewpandu];
    //        break;
    //    case 6:
    //        [cell addSubview:_viewfirst];
    //        break;
    //    default:
    //        return 0;
    //        break;
    //}
    
    return cell;
}

#pragma mark - View Action
- (IBAction)tap:(id)sender {
    [_activetextfield resignFirstResponder];
    if ([sender isKindOfClass:[UIButton class]]) {
        UIButton *btn = (UIButton*)sender;
        switch (btn.tag) {
            case 10:
            {
                //Select Provincy
                NSArray *districts = _shippinginfo.result.district;
                NSInteger districtid = [[_datainput objectForKey:kTKPDFILTER_APISELECTEDDISTRICTIDKEY]integerValue]?:_shippinginfo.result.shop_shipping.district_id;
                FilterLocationViewController *vc = [FilterLocationViewController new];
                NSIndexPath *indexpath = [_datainput objectForKey:kTKPDFILTERLOCATION_DATAINDEXPATHKEY]?:[NSIndexPath indexPathForRow:0 inSection:0];
                vc.data = @{kTKPDFILTER_APITYPEKEY:@(kTKPDFILTER_DATATYPESHOPSHIPPINGPROVINCYKEY),
                            kTKPDFILTERLOCATION_DATALOCATIONARRAYKEY:districts,
                            kTKPDFILTER_DATAINDEXPATHKEY:indexpath,
                            kTKPDFILTER_APISELECTEDDISTRICTIDKEY:@(districtid)
                            };
                vc.delegate = self;
                [self.navigationController pushViewController:vc animated:YES];
                break;
            }
            default:
                break;
        }
    }
    
    if ([sender isKindOfClass:[UIBarButtonItem class]]) {
        UIBarButtonItem *btn = (UIBarButtonItem *)sender;
        switch (btn.tag) {
            case 10:
            {
                //back
                [self.navigationController popViewControllerAnimated:YES];
                break;
            }
            case 11:
            {
                //submit
                NSMutableArray *messages = [NSMutableArray new];
                [self requestActionShipment:_datainput];
                NSLog(@"%@",messages);
            }
            default:
                break;
        }
    }
}

- (IBAction)gesture:(id)sender {
    [_activetextfield resignFirstResponder];
}


#pragma mark - Memory Management
-(void)dealloc{
    NSLog(@"%@ : %@",[self class], NSStringFromSelector(_cmd));
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
    RKObjectMapping *shippingMapping = [RKObjectMapping mappingForClass:[ShippingInfo class]];
    [shippingMapping addAttributeMappingsFromDictionary:@{kTKPD_APIERRORMESSAGEKEY:kTKPD_APIERRORMESSAGEKEY,
                                                          kTKPD_APISTATUSKEY:kTKPD_APISTATUSKEY,
                                                          kTKPD_APISERVERPROCESSTIMEKEY:kTKPD_APISERVERPROCESSTIMEKEY}];

    
    RKObjectMapping *resultMapping = [RKObjectMapping mappingForClass:[ShippingInfoResult class]];
    [resultMapping addAttributeMappingsFromDictionary:@{kTKPDSHOPSHIPMENT_APITIKIFEEKEY:kTKPDSHOPSHIPMENT_APITIKIFEEKEY,
                                                      kTKPDSHOPSHIPMENT_APIISALLOWKEY:kTKPDSHOPSHIPMENT_APIISALLOWKEY,
                                                      kTKPDSHOPSHIPMENT_APIPOSFEEKEY:kTKPDSHOPSHIPMENT_APIPOSFEEKEY,
                                                      kTKPDSHOPSHIPMENT_APISHOPNAMEKEY:kTKPDSHOPSHIPMENT_APISHOPNAMEKEY,
                                                      }];
    
    RKObjectMapping *districtMapping = [RKObjectMapping mappingForClass:[District class]];
    [districtMapping addAttributeMappingsFromDictionary:@{kTKPDSHOPSHIPMENT_APIDISTRICTIDKEY:kTKPDSHOPSHIPMENT_APIDISTRICTIDKEY,
                                                         kTKPDSHOPSHIPMENT_APIDISTRICTSHIPPINGSUPPORTEDKEY:kTKPDSHOPSHIPMENT_APIDISTRICTSHIPPINGSUPPORTEDKEY,
                                                         kTKPDSHOPSHIPMENT_APIDISTRICTNAMEKEY:kTKPDSHOPSHIPMENT_APIDISTRICTNAMEKEY
                                                          }];
    
    RKObjectMapping *shipmentsMapping = [RKObjectMapping mappingForClass:[ShippingInfoShipments class]];
    [shipmentsMapping addAttributeMappingsFromDictionary:@{kTKPDSHOPSHIPMENT_APISHIPMENTNAMEKEY:kTKPDSHOPSHIPMENT_APISHIPMENTNAMEKEY,
                                                          kTKPDSHOPSHIPMENT_APISHIPMENTIDKEY:kTKPDSHOPSHIPMENT_APISHIPMENTIDKEY,
                                                          kTKPDSHOPSHIPMENT_APISHIPMENTIMAGEKEY:kTKPDSHOPSHIPMENT_APISHIPMENTIMAGEKEY
                                                          }];
    
    RKObjectMapping *shipmentspackageMapping = [RKObjectMapping mappingForClass:[ShippingInfoShipmentPackage class]];
    [shipmentspackageMapping addAttributeMappingsFromDictionary:@{kTKPDSHOPSHIPMENT_APIDESCKEY:kTKPDSHOPSHIPMENT_APIDESCKEY,
                                                           kTKPDSHOPSHIPMENT_APIACTIVEKEY:kTKPDSHOPSHIPMENT_APIACTIVEKEY,
                                                           kTKPDSHOPSHIPMENT_APINAMEKEY:kTKPDSHOPSHIPMENT_APINAMEKEY,
                                                           kTKPDSHOPSHIPMENT_APISPIDKEY:kTKPDSHOPSHIPMENT_APISPIDKEY
                                                           }];
    
    RKObjectMapping *posweightMapping = [RKObjectMapping mappingForClass:[PosMinWeight class]];
    [posweightMapping addAttributeMappingsFromDictionary:@{kTKPDSHOPSHIPMENT_APIMINWEIGHTKEY:kTKPDSHOPSHIPMENT_APIMINWEIGHTKEY,
                                                                  kTKPDSHOPSHIPMENT_APIDIFFDISTRICTKEY:kTKPDSHOPSHIPMENT_APIDIFFDISTRICTKEY
                                                                  }];
    
    RKObjectMapping *shopshippingMapping = [RKObjectMapping mappingForClass:[ShopShipping class]];
    [shopshippingMapping addAttributeMappingsFromDictionary:@{kTKPDSHOPSHIPMENT_APIDISTRICTIDKEY:kTKPDSHOPSHIPMENT_APIDISTRICTIDKEY,
                                                              kTKPDSHOPSHIPMENT_APIPOSTALCODEKEY:kTKPDSHOPSHIPMENT_APIPOSTALCODEKEY,
                                                              kTKPDSHOPSHIPMENT_APIORIGINKEY:kTKPDSHOPSHIPMENT_APIORIGINKEY,
                                                              kTKPDSHOPSHIPMENT_APISHIPPINGIDKEY:kTKPDSHOPSHIPMENT_APISHIPPINGIDKEY,
                                                              kTKPDSHOPSHIPMENT_APIDISTRICTNAMEKEY:kTKPDSHOPSHIPMENT_APIDISTRICTNAMEKEY,
                                                              kTKPDSHOPSHIPMENT_APIDISCTRICTSUPPORTEDKEY:kTKPDSHOPSHIPMENT_APIDISCTRICTSUPPORTEDKEY
                                                           }];

    // Relationship Mapping
    RKRelationshipMapping *districtRel = [RKRelationshipMapping relationshipMappingFromKeyPath:kTKPDSHOPSHIPMENT_APIDISTRICTKEY toKeyPath:kTKPDSHOPSHIPMENT_APIDISTRICTKEY withMapping:districtMapping];
    [resultMapping addPropertyMapping:districtRel];
    
    RKRelationshipMapping *shipmentsRel = [RKRelationshipMapping relationshipMappingFromKeyPath:kTKPDSHOPSHIPMENT_APISHIPMENTKEY toKeyPath:kTKPDSHOPSHIPMENT_APISHIPMENTKEY withMapping:shipmentsMapping];
    [resultMapping addPropertyMapping:shipmentsRel];
    
    RKRelationshipMapping *shipmentpackagesRel = [RKRelationshipMapping relationshipMappingFromKeyPath:kTKPDSHOPSHIPMENT_APISHIPMENTPACKAGEKEY toKeyPath:kTKPDSHOPSHIPMENT_APISHIPMENTPACKAGEKEY withMapping:shipmentspackageMapping];
    [shipmentsMapping addPropertyMapping:shipmentpackagesRel];
    
    [resultMapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:kTKPDSHOPSHIPMENT_APIPOSMINWEIGHTKEY toKeyPath:kTKPDSHOPSHIPMENT_APIPOSMINWEIGHTKEY withMapping:posweightMapping]];
    
    [resultMapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:kTKPDSHOPSHIPMENT_APISHOPSHIPPINGKEY toKeyPath:kTKPDSHOPSHIPMENT_APISHOPSHIPPINGKEY withMapping:shopshippingMapping]];
    
    [shippingMapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:kTKPD_APIRESULTKEY toKeyPath:kTKPD_APIRESULTKEY withMapping:resultMapping]];
    
    
    // Response Descriptor
    RKResponseDescriptor *responseDescriptor = [RKResponseDescriptor responseDescriptorWithMapping:shippingMapping method:RKRequestMethodGET pathPattern:kTKPDDETAILSHOPEDITOR_APIPATH keyPath:@"" statusCodes:kTkpdIndexSetStatusCodeOK];
    
    [_objectmanager addResponseDescriptor:responseDescriptor];
}

- (void)request
{
    if (_request.isExecuting) return;
    
    _requestcount++;
    
	NSDictionary* param = @{
                            kTKPDDETAIL_APIACTIONKEY : kTKPDDETAIL_APIGETSHOPSHIPPINGINFOKEY,
                            };
    
    _request = [_objectmanager appropriateObjectRequestOperationWithObject:self method:RKRequestMethodGET path:kTKPDDETAILSHOPEDITOR_APIPATH parameters:param];
	[_cachecontroller getFileModificationDate];
	_timeinterval = fabs([_cachecontroller.fileDate timeIntervalSinceNow]);
	if (_timeinterval > _cachecontroller.URLCacheInterval) {
        
        NSTimer *timer;
        
        //[_act startAnimating];
        
        //[_cachecontroller clearCache];
        [_request setCompletionBlockWithSuccess:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
            [timer invalidate];
            //[_act stopAnimating];
            [self requestsuccess:mappingResult withOperation:operation];
        } failure:^(RKObjectRequestOperation *operation, NSError *error) {
            /** failure **/
            [timer invalidate];
            //[_act stopAnimating];
            [self requestfailure:error];
        }];
        
        [_operationQueue addOperation:_request];
        
        timer = [NSTimer scheduledTimerWithTimeInterval:kTKPDREQUEST_TIMEOUTINTERVAL target:self selector:@selector(requesttimeout) userInfo:nil repeats:NO];
        [[NSRunLoop currentRunLoop] addTimer:timer forMode:NSRunLoopCommonModes];
        
    }
    else {
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setTimeStyle:NSDateFormatterShortStyle];
        [dateFormatter setDateStyle:NSDateFormatterMediumStyle];
        NSLog(@"Updated: %@",[dateFormatter stringFromDate:_cachecontroller.fileDate]);
        NSLog(@"cache and updated in last 24 hours.");
        [self requestfailure:nil];
	}
}

-(void)requestsuccess:(id)object withOperation:(RKObjectRequestOperation *)operation
{
    NSDictionary *result = ((RKMappingResult*)object).dictionary;
    id stats = [result objectForKey:@""];
    _shippinginfo = stats;
    BOOL status = [_shippinginfo.status isEqualToString:kTKPDREQUEST_OKSTATUS];
    
    if (status) {
        [_cacheconnection connection:operation.HTTPRequestOperation.request didReceiveResponse:operation.HTTPRequestOperation.response];
        [_cachecontroller connectionDidFinish:_cacheconnection];
        //save response data to plist
        [operation.HTTPRequestOperation.responseData writeToFile:_cachepath atomically:YES];
        
        [self requestprocess:object];
    }
}

-(void)requestfailure:(id)object
{
    if (_timeinterval > _cachecontroller.URLCacheInterval) {
        [self requestprocess:object];
    }
    else{
        NSError* error;
        NSData *data = [NSData dataWithContentsOfFile:_cachepath];
        id parsedData = [RKMIMETypeSerialization objectFromData:data MIMEType:RKMIMETypeJSON error:&error];
        if (parsedData == nil && error) {
            NSLog(@"parser error");
        }
        
        NSMutableDictionary *mappingsDictionary = [[NSMutableDictionary alloc] init];
        for (RKResponseDescriptor *descriptor in _objectmanager.responseDescriptors) {
            [mappingsDictionary setObject:descriptor.mapping forKey:descriptor.keyPath];
        }
        
        RKMapperOperation *mapper = [[RKMapperOperation alloc] initWithRepresentation:parsedData mappingsDictionary:mappingsDictionary];
        NSError *mappingError = nil;
        BOOL isMapped = [mapper execute:&mappingError];
        if (isMapped && !mappingError) {
            RKMappingResult *mappingresult = [mapper mappingResult];
            NSDictionary *result = mappingresult.dictionary;
            id stats = [result objectForKey:@""];
            _shippinginfo = stats;
            BOOL status = [_shippinginfo.status isEqualToString:kTKPDREQUEST_OKSTATUS];
            
            if (status) {
                [self requestprocess:mappingresult];
            }
        }
    }
}

-(void)requestprocess:(id)object
{
    if (object) {
        if ([object isKindOfClass:[RKMappingResult class]]) {
            NSDictionary *result = ((RKMappingResult*)object).dictionary;
            id stats = [result objectForKey:@""];
            _shippinginfo = stats;
            BOOL status = [_shippinginfo.status isEqualToString:kTKPDREQUEST_OKSTATUS];
            
            if (status) {
                _table.hidden = NO;
                _isnodata = NO;
                NSArray *shipment = _shippinginfo.result.shipment;
                for (int i = 0; i<shipment.count; i++) {
                    [_expandedSections addObject:@(i)];
                }
                [_buttonprovinsi setTitle:_shippinginfo.result.shop_shipping.district_name?:@"Pilih Provinsi" forState:UIControlStateNormal];
                _textfieldkodepos.text = [_shippinginfo.result.shop_shipping.postal_code stringValue]?:@"-";
                [self updateLogisticDistrictSupporteds:_shippinginfo.result.shop_shipping.district_shipping_supported];
            }
        }else{
            [self cancel];
            NSLog(@" REQUEST FAILURE ERROR %@", [(NSError*)object description]);
            if ([(NSError*)object code] == NSURLErrorCancelled) {
                if (_requestcount<kTKPDREQUESTCOUNTMAX) {
                    NSLog(@" ==== REQUESTCOUNT %d =====",_requestcount);
                    //_table.tableFooterView = _footer;
                    //[_act startAnimating];
                    [self performSelector:@selector(configureRestKit) withObject:nil afterDelay:kTKPDREQUEST_DELAYINTERVAL];
                    [self performSelector:@selector(request) withObject:nil afterDelay:kTKPDREQUEST_DELAYINTERVAL];
                }
                else
                {
                    //[_act stopAnimating];
                }
            }
            else
            {
                //[_act stopAnimating];
            }
        }
    }
}

-(void)requesttimeout
{
    [self cancel];
}

#pragma mark - Request Action Shipment
-(void)cancelActionShipment
{
    [_requestActionShipment cancel];
    _requestActionShipment = nil;
    [_objectmanagerActionShipment.operationQueue cancelAllOperations];
    _objectmanagerActionShipment = nil;
}

-(void)configureRestKitActionShipment
{
    _objectmanagerActionShipment = [RKObjectManager sharedClient];
    
    // setup object mappings
    RKObjectMapping *statusMapping = [RKObjectMapping mappingForClass:[ShopSettings class]];
    [statusMapping addAttributeMappingsFromDictionary:@{kTKPD_APISTATUSMESSAGEKEY:kTKPD_APISTATUSMESSAGEKEY,
                                                        kTKPD_APIERRORMESSAGEKEY:kTKPD_APIERRORMESSAGEKEY,
                                                        kTKPD_APISTATUSKEY:kTKPD_APISTATUSKEY,
                                                        kTKPD_APISERVERPROCESSTIMEKEY:kTKPD_APISERVERPROCESSTIMEKEY,
                                                        }];
    
    RKObjectMapping *resultMapping = [RKObjectMapping mappingForClass:[ShopSettingsResult class]];
    [resultMapping addAttributeMappingsFromDictionary:@{kTKPDDETAIL_APIISSUCCESSKEY:kTKPDDETAIL_APIISSUCCESSKEY}];
    
    [statusMapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:kTKPD_APIRESULTKEY toKeyPath:kTKPD_APIRESULTKEY withMapping:resultMapping]];
    
    // register mappings with the provider using a response descriptor
    RKResponseDescriptor *responseDescriptor = [RKResponseDescriptor responseDescriptorWithMapping:statusMapping method:RKRequestMethodGET pathPattern:kTKPDDETAILSHOPEDITORACTION_APIPATH keyPath:@"" statusCodes:kTkpdIndexSetStatusCodeOK];
    
    [_objectmanagerActionShipment addResponseDescriptor:responseDescriptor];
    
}

-(void)requestActionShipment:(id)object
{
    if (_requestActionShipment.isExecuting) return;
    NSTimer *timer;
    
    NSDictionary *userinfo = (NSDictionary*)object;
    NSString *postalcode = [userinfo objectForKey:kTKPDSHOPSHIPMENT_APIPOSTALCODEKEY];
    NSString *origin = [userinfo objectForKey:kTKPDFILTER_APISELECTEDDISTRICTIDKEY];
    
    NSDictionary* param = @{kTKPDDETAIL_APIACTIONKEY:kTKPDDETAIL_APIEDITSHIPPINGINFOKEY,
                            kTKPDSHOPSHIPMENT_APICOURIRORIGINKEY : origin,
                            kTKPDSHOPSHIPMENT_APIPOSTALKEY : postalcode
//                            kTKPDSHOPSHIPMENT_APIDIFFDISTRICTKEY
//                            kTKPDSHOPSHIPMENT_APIMINWEIGHTKEY
//                            kTKPDSHOPSHIPMENT_APIMINWEIGHTVALUEKEY
//                            kTKPDSHOPSHIPMENT_APITIKIFEEKEY
//                            kTKPDSHOPSHIPMENT_APITIKIFEEVALUEKEY
//                            kTKPDSHOPSHIPMENT_APIPOSMINWEIGHTKEY
//                            kTKPDSHOPSHIPMENT_APIPOSMINWEIGHTVALUEKEY
//                            kTKPDSHOPSHIPMENT_APIJNEFEEKEY
//                            kTKPDSHOPSHIPMENT_APIJNEFEEVALUEKEY
//                            kTKPDSHOPSHIPMENT_APIJNETICKETKEY
//                            kTKPDSHOPSHIPMENT_APIRPXPACKETKEY
//                            kTKPDSHOPSHIPMENT_APIRPXTICKETKEY
//                            kTKPDSHOPSHIPMENT_APISHIPMENTIDS
                            };
    _requestcount ++;
    
    _requestActionShipment = [_objectmanagerActionShipment appropriateObjectRequestOperationWithObject:self method:RKRequestMethodGET path:kTKPDDETAILSHOPEDITORACTION_APIPATH parameters:param];
    
    [_requestActionShipment setCompletionBlockWithSuccess:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
        [self requestSuccessActionShipment:mappingResult withOperation:operation];
        [timer invalidate];
    } failure:^(RKObjectRequestOperation *operation, NSError *error) {
        [self requestFailureActionShipment:error];
        [timer invalidate];
    }];
    
    [_operationQueue addOperation:_requestActionShipment];
    
    timer= [NSTimer scheduledTimerWithTimeInterval:kTKPDREQUEST_TIMEOUTINTERVAL target:self selector:@selector(requestTimeoutActionShipment) userInfo:nil repeats:NO];
    [[NSRunLoop currentRunLoop] addTimer:timer forMode:NSRunLoopCommonModes];
}

-(void)requestSuccessActionShipment:(id)object withOperation:(RKObjectRequestOperation *)operation
{
    NSDictionary *result = ((RKMappingResult*)object).dictionary;
    id stat = [result objectForKey:@""];
    ShopSettings *setting = stat;
    BOOL status = [setting.status isEqualToString:kTKPDREQUEST_OKSTATUS];
    
    if (status) {
        [self requestProcessActionShipment:object];
    }
}

-(void)requestFailureActionShipment:(id)object
{
    [self requestProcessActionShipment:object];
}

-(void)requestProcessActionShipment:(id)object
{
    if (object) {
        if ([object isKindOfClass:[RKMappingResult class]]) {
            NSDictionary *result = ((RKMappingResult*)object).dictionary;
            id stat = [result objectForKey:@""];
            ShopSettings *setting = stat;
            BOOL status = [setting.status isEqualToString:kTKPDREQUEST_OKSTATUS];
            
            if (status) {
                if (!setting.message_error) {
                    if (setting.result.is_success) {
                        //TODO:: add alert
                    }
                }
            }
        }
        else{
            
            [self cancelActionShipment];
            NSLog(@" REQUEST FAILURE ERROR %@", [(NSError*)object description]);
            if ([(NSError*)object code] == NSURLErrorCancelled) {
                if (_requestcount<kTKPDREQUESTCOUNTMAX) {
                    NSLog(@" ==== REQUESTCOUNT %d =====",_requestcount);
                    //TODO:: Reload handler
                }
                else
                {
                }
            }
            else
            {
            }
        }
    }
}

-(void)requestTimeoutActionShipment
{
    [self cancelActionShipment];
}

#pragma mark - Footer Delegate
-(void)SettingShipmentSectionFooterView:(UIView *)view
{
    [self MovetoInfoIndex:view.tag-10];
}

-(void)SettingShipmentSectionFooter2View:(UIView *)view
{
    [self MovetoInfoIndex:view.tag-10];
}
-(void)SettingShipmentSectionFooter3View:(UIView *)view
{
    [self MovetoInfoIndex:view.tag-10];
}

#pragma mark - Filter Delegate
-(void)FilterLocationViewController:(UIViewController *)viewcontroller withdata:(NSDictionary *)data
{
    [_buttonprovinsi setTitle:[data objectForKey:kTKPDFILTER_APILOCATIONNAMEKEY]?:@"Pilih Provinsi" forState:UIControlStateNormal];
    NSIndexPath *indexpath = [data objectForKey:kTKPDFILTERLOCATION_DATAINDEXPATHKEY]?:[NSIndexPath indexPathForRow:0 inSection:0];
    [_datainput setObject:indexpath forKey:kTKPDFILTERLOCATION_DATAINDEXPATHKEY];
    
    NSArray *districts = _shippinginfo.result.district;
    District *district = districts[indexpath.row];
    [_datainput setObject:@(district.district_id) forKey:kTKPDFILTER_APISELECTEDDISTRICTIDKEY];
    [self updateLogisticDistrictSupporteds:district.district_shipping_supported];
}

#pragma mark - Methods
-(void)MovetoInfoIndex:(NSInteger)index
{
    SettingShipmentInfoViewController *vc = [SettingShipmentInfoViewController new];
    NSArray *shipments = _shippinginfo.result.shipment;
    ShippingInfoShipments *shipment = shipments[index];
    NSArray *package = shipment.shipment_package;
    
    NSMutableArray *infoarray = [NSMutableArray new];
    for (int i = 0; i<package.count; i++) {
        ShippingInfoShipmentPackage *packages = package[i];
        [infoarray addObject:packages.desc];
    }
    NSString * info = [NSString stringWithFormat:@"Jenis Paket %@\n\n %@",shipment.shipment_name,[[infoarray valueForKey:@"description"] componentsJoinedByString:@"\n\n"]];
    vc.data = @{kTKPDDETAIL_DATAINFOLOGISTICKEY:info?:@"-"};
    [self.navigationController pushViewController:vc animated:YES];
}

-(void)updateLogisticDistrictSupporteds:(NSArray*)districs
{

    NSArray *districtsupporteds = districs;
    
    NSMutableArray *shipmentids = [NSMutableArray new];
    NSArray *shipments = _shippinginfo.result.shipment;
    for (int i = 0; i<shipments.count; i++) {
        ShippingInfoShipments *shipment = shipments[i]; 
        [shipmentids addObject:@(shipment.shipment_id)];
    }
    
    [_expandedSections removeAllObjects];
    for (int i = 0; i<districtsupporteds.count; i++) {
        NSNumber *shipmentid=[NSNumber numberWithInteger:[districtsupporteds[i] integerValue]];
        NSUInteger anIndex=[shipmentids indexOfObject:shipmentid];
        if(NSNotFound == anIndex) {
            NSLog(@"not found");
        }
        [_expandedSections addObject:@(anIndex)];
    }
    [_table reloadData];
}

#pragma mark - Setting Shipment Cell Delegate
-(void)SettingShipmentCell:(UITableViewCell *)cell withindexpath:(NSIndexPath *)indexpath
{
    NSInteger shipmentid = ((SettingShipmentCell*)cell).shipmentid;
    NSInteger packageid = ((SettingShipmentCell*)cell).packageid;
    
    NSMutableDictionary *packages = [NSMutableDictionary new];
    //packages setObject:@(YES) forKey:
    //[_shipmentids addObject:shipmentid];
}

#pragma mark - Text Field Delegate
-(BOOL)textFieldShouldBeginEditing:(UITextField *)textField{
    _activetextfield = textField;
    [textField resignFirstResponder];
    return YES;
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField{
    
    [textField resignFirstResponder];
    return YES;
}

-(BOOL)textFieldShouldEndEditing:(UITextField *)textField
{
    if (textField == _textfieldkodepos) {
        [_datainput setObject:textField.text forKey:kTKPDSHOPSHIPMENT_APIPOSTALCODEKEY];
    }
    return YES;
}

@end
