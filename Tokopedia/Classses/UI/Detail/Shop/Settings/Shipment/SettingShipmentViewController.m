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
#import "SettingShipmentSectionFooter4View.h"

#import "../../../../SortFilterShare/sortfiltershare.h"
#import "../../../../SortFilterShare/Filter/FilterLocation/FilterLocationViewController.h"

@interface SettingShipmentViewController ()<UITableViewDataSource,UITableViewDelegate, SettingShipmentCellDelegate, SettingShipmentSectionFooterViewDelegate,SettingShipmentSectionFooter2ViewDelegate,SettingShipmentSectionFooter3ViewDelegate,SettingShipmentSectionFooter4ViewDelegate,FilterLocationViewControllerDelegate>
{
    
    NSInteger _footerheightjne;
    NSInteger _footerheightpos;
    NSInteger _footerheighttiki;
    
    NSMutableDictionary *_datainput;
    NSMutableDictionary *_shipments;
    
    UITextField *_activetextfield;
    
    UIBarButtonItem *_barbuttonsave;
    
    ShippingInfo *_shippinginfo;
    NSMutableArray *_expandedSections;
    BOOL _isnodata;
    BOOL _isrefreshview;
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
@property (strong, nonatomic) IBOutlet SettingShipmentSectionFooter4View *viewfooter4;
@property (weak, nonatomic) IBOutlet UIButton *buttonprovinsi;
@property (weak, nonatomic) IBOutlet UITextField *textfieldkodepos;
@property (weak, nonatomic) IBOutlet UITableView *table;

@property (strong, nonatomic) IBOutlet UIView *headerjne;
@property (weak, nonatomic) IBOutlet UIImageView *thumbheaderjne;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *actheaderjne;
@property (weak, nonatomic) IBOutlet UISwitch *switchawb;

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
        _isnodata =YES;
        _isrefreshview = NO;
    }
    return self;
}

#pragma mark - Life Cycle
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    _datainput = [NSMutableDictionary new];
    _shipments = [NSMutableDictionary new];
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
    
    _barbuttonsave = [[UIBarButtonItem alloc] initWithTitle:@"Save" style:UIBarButtonItemStylePlain target:(self) action:@selector(tap:)];
    [_barbuttonsave setTintColor:[UIColor blackColor]];
    _barbuttonsave.tag = 11;
    self.navigationItem.rightBarButtonItem = _barbuttonsave;
    
    _footerheightjne = _viewfooter.frame.size.height;
    _footerheightpos = _viewfooter3.frame.size.height;
    _footerheighttiki = _viewfooter4.frame.size.height;
    
    [self configureRestKit];
    [self request];
}


#pragma mark - TableView Delegate
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    
    id shipment = _shippinginfo.result.shipment;
    ShippingInfoShipments *shipments = shipment[section];
    
    BOOL sectionIsExanded = [_expandedSections containsObject:[NSNumber numberWithInteger:section]];
    if ([shipments.shipment_name isEqualToString:@"JNE"] && sectionIsExanded) {
        NSURLRequest* request = [[NSURLRequest alloc] initWithURL:[NSURL URLWithString:shipments.shipment_image] cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:kTKPDREQUEST_TIMEOUTINTERVAL];
        
        UIImageView *thumb = _thumbheaderjne;
        thumb.image = nil;
        //thumb.hidden = YES;	//@prepareforreuse then @reset
        
        [_actheaderjne startAnimating];
        
        [thumb setImageWithURLRequest:request placeholderImage:nil success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-retain-cycles"
            //NSLOG(@"thumb: %@", thumb);
            [thumb setImage:image animated:YES];
            
            [_actheaderjne stopAnimating];
#pragma clang diagnosti c pop
            
        } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) {
            [_actheaderjne stopAnimating];
        }];

        return _headerjne;
    }
    else {
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
}

-(UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    BOOL sectionIsExanded = [_expandedSections containsObject:[NSNumber numberWithInteger:section]];
    if (sectionIsExanded) {
        NSArray *shipments = _shippinginfo.result.shipment;
        ShippingInfoShipments *shipment = shipments[section];
        BOOL jneminweight = [[_datainput objectForKey:kTKPDSHOPSHIPMENT_APIMINWEIGHTKEY] boolValue];
        NSInteger jneminweightvalue = [[_datainput objectForKey:kTKPDSHOPSHIPMENT_APIMINWEIGHTVALUEKEY] integerValue];
        BOOL jnefee = [[_datainput objectForKey:kTKPDSHOPSHIPMENT_APIJNEFEEKEY] boolValue];
        NSInteger jnefeevalue = [[_datainput objectForKey:kTKPDSHOPSHIPMENT_APIJNEFEEVALUEKEY] integerValue];
        BOOL diffdistrict = [[_datainput objectForKey:kTKPDSHOPSHIPMENT_APIDIFFDISTRICTKEY] boolValue];
        BOOL tikifee = [[_datainput objectForKey:kTKPDSHOPSHIPMENT_APITIKIFEEKEY] boolValue];
        NSInteger tikifeevalue = [[_datainput objectForKey:kTKPDSHOPSHIPMENT_APITIKIFEEVALUEKEY] integerValue];
        BOOL posminweight = [[_datainput objectForKey:kTKPDSHOPSHIPMENT_APIPOSMINWEIGHTKEY] boolValue];
        NSInteger posminweightvalue = [[_datainput objectForKey:kTKPDSHOPSHIPMENT_APIPOSMINWEIGHTVALUEKEY] integerValue];
        BOOL posfee = [[_datainput objectForKey:kTKPDSHOPSHIPMENT_APIPOSFEEKEY] boolValue];
        NSInteger posfeevalue = [[_datainput objectForKey:kTKPDSHOPSHIPMENT_APIPOSFEEVALUEKEY] integerValue];
        if ([shipment.shipment_name isEqualToString:@"JNE"]) {
            SettingShipmentSectionFooterView *v = [SettingShipmentSectionFooterView newview];
            //TODO::
            v.stepperminweight.value = jneminweightvalue;
            v.switchweightmin.on = jneminweight;
            v.switchfee.on = jnefee;
            v.textfieldfee.text = [NSString stringWithFormat:@"%d",jnefeevalue];
            v.switchdiffdistrict.on = diffdistrict;
            
            v.tag = section+10;
            v.labelinfo.text = [NSString stringWithFormat:@"Info Tentang %@",shipment.shipment_name];
            v.delegate = self;
            return v;
        }
        else if ([shipment.shipment_name isEqualToString:@"Tiki"])
        {
            SettingShipmentSectionFooter4View *v = [SettingShipmentSectionFooter4View newview];
            
            v.switchfee.on = tikifee;
            v.textfieldfee.text = [NSString stringWithFormat:@"%d",tikifeevalue];
            
            v.tag = section+10;
            v.labelinfo.text = [NSString stringWithFormat:@"Info Tentang %@",shipment.shipment_name];
            v.delegate = self;
            //TODO::
            v.switchfee.on = tikifee;
            v.textfieldfee.text = [NSString stringWithFormat:@"%d",tikifeevalue?:_shippinginfo.result.tiki_fee];
            v.labelfee.text = [NSString stringWithFormat:@"Biaya tambahan pengiriman TIKI"];
            return v;
        }
        else if ([shipment.shipment_name isEqualToString:@"Pos Indonesia"])
        {
            SettingShipmentSectionFooter3View *v = [SettingShipmentSectionFooter3View newview];
            v.tag = section+10;
            v.labelinfo.text = [NSString stringWithFormat:@"Info Tentang %@",shipment.shipment_name];
            v.delegate = self;
            
            //TODO::
            v.stepperminweight.value = posminweightvalue?:_shippinginfo.result.pos_min_weight.min_weight;
            v.switchweightmin.on = posminweight;
            v.switchfee.on = posfee;
            v.textfieldfee.text = [NSString stringWithFormat:@"%d",posfeevalue?:_shippinginfo.result.pos_fee];
            
            v.labelfee.text = [NSString stringWithFormat:@"Biaya tambahan pengiriman POS"];
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
    return nil;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    NSArray *shipments = _shippinginfo.result.shipment;
    ShippingInfoShipments *shipment = shipments[section];
    BOOL sectionIsExanded = [_expandedSections containsObject:[NSNumber numberWithInteger:section]];
    if ([shipment.shipment_name isEqualToString:@"JNE"] && (sectionIsExanded))
        return _headerjne.frame.size.height;
    else
        return _viewsectionheader.frame.size.height;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    BOOL sectionIsExanded = [_expandedSections containsObject:[NSNumber numberWithInteger:section]];
    if (sectionIsExanded) {
        id shipment = _shippinginfo.result.shipment;
        ShippingInfoShipments *shipments = shipment[section];
        if ([shipments.shipment_name isEqualToString:@"JNE"]) {
            return _footerheightjne;
        }
        else if ([shipments.shipment_name isEqualToString:@"Tiki"])
        {
            return _footerheighttiki;
        }
        else if ([shipments.shipment_name isEqualToString:@"Pos Indonesia"])
        {
            return _footerheightpos;
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
            NSDictionary *activeshipments = [_shipments objectForKey:[@(shipment.shipment_id)stringValue]];
            BOOL isactive = [[activeshipments objectForKey:[@(package.sp_id)stringValue]] boolValue];
            ((SettingShipmentCell*)cell).switchpackage.on = isactive;
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
    
    return cell;
}

#pragma mark - View Action
- (IBAction)tap:(id)sender {
    [_activetextfield resignFirstResponder];
    if ([sender isKindOfClass:[UISwitch class]]) {
        BOOL awb = _switchawb.on;
        [_datainput setObject:@(awb) forKey:kTKPDSHOPSHIPMENT_APIJNETICKETKEY];
    }
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
                BOOL submit = YES;
                NSMutableArray *messages = [NSMutableArray new];
                
                BOOL jnefee = [[_datainput objectForKey:kTKPDSHOPSHIPMENT_APIJNEFEEKEY] boolValue];
                NSInteger jnefeevalue = [[_datainput objectForKey:kTKPDSHOPSHIPMENT_APIJNEFEEVALUEKEY] integerValue];
                BOOL tikifee = [[_datainput objectForKey:kTKPDSHOPSHIPMENT_APITIKIFEEKEY] boolValue];
                NSInteger tikifeevalue = [[_datainput objectForKey:kTKPDSHOPSHIPMENT_APITIKIFEEVALUEKEY] integerValue];
                BOOL posfee = [[_datainput objectForKey:kTKPDSHOPSHIPMENT_APIPOSFEEKEY] boolValue];
                NSInteger posfeevalue = [[_datainput objectForKey:kTKPDSHOPSHIPMENT_APIPOSFEEVALUEKEY] integerValue];
                
                if (jnefee) {
                    if (jnefeevalue == 0) {
                        [messages addObject:@"Biaya JNE harus diisi."];
                        submit = NO;
                    }
                    if (jnefeevalue > 5000) {
                        [messages addObject:@"Maksimum Biaya Pos adalah Rp 5.000,-"];
                        submit = NO;
                    }

                }
                if (tikifee) {
                    if (tikifeevalue == 0) {
                        [messages addObject:@"Biaya TIKI harus diisi."];
                        submit = NO;
                    }
                    if (jnefeevalue > 5000) {
                        [messages addObject:@"Maksimum Biaya TIKI adalah Rp 5.000,-"];
                        submit = NO;
                    }
                }
                if (posfee) {
                    if (posfeevalue == 0) {
                        [messages addObject:@"Biaya Pos Indonesia harus diisi."];
                        submit = NO;
                    }
                    if (jnefeevalue > 5000) {
                        [messages addObject:@"Maksimum Biaya Pos Indonesia adalah Rp 5.000,-"];
                        submit = NO;
                    }
                }
                
                if (submit) {
                    [self configureRestKitActionShipment];
                    [self requestActionShipment:_datainput];
                }
                else
                {
                    NSDictionary *info = [NSDictionary dictionaryWithObjectsAndKeys:messages,@"messages", nil];
                    [[NSNotificationCenter defaultCenter] postNotificationName:kTKPD_SETUSERSTICKYERRORMESSAGEKEY object:nil userInfo:info];
                }

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
	if (_timeinterval > _cachecontroller.URLCacheInterval || _isrefreshview) {
        
        NSTimer *timer;
        
        _barbuttonsave.enabled = NO;
        //[_cachecontroller clearCache];
        [_request setCompletionBlockWithSuccess:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
            [timer invalidate];
            _barbuttonsave.enabled = YES;
            [self requestsuccess:mappingResult withOperation:operation];
        } failure:^(RKObjectRequestOperation *operation, NSError *error) {
            /** failure **/
            [timer invalidate];
            _barbuttonsave.enabled = YES;
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
    if (_timeinterval > _cachecontroller.URLCacheInterval || _isrefreshview) {
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
                _textfieldkodepos.text = _shippinginfo.result.shop_shipping.postal_code;
                [self updateLogisticDistrictSupporteds:_shippinginfo.result.shop_shipping.district_shipping_supported];
                [_table reloadData];
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
    NSString *postalcode = [userinfo objectForKey:kTKPDSHOPSHIPMENT_APIPOSTALCODEKEY]?:_shippinginfo.result.shop_shipping.postal_code?:@"";
    NSString *origin = [userinfo objectForKey:kTKPDFILTER_APISELECTEDDISTRICTIDKEY]?:@(_shippinginfo.result.shop_shipping.origin)?:@"";
    NSDictionary *shipmentids = [userinfo objectForKey:kTKPDSHOPSHIPMENT_APISHIPMENTIDS];
    BOOL jneminweight = [[userinfo objectForKey:kTKPDSHOPSHIPMENT_APIMINWEIGHTKEY] boolValue];
    NSInteger jneminweightvalue = [[userinfo objectForKey:kTKPDSHOPSHIPMENT_APIMINWEIGHTVALUEKEY] integerValue];
    BOOL jnefee = [[userinfo objectForKey:kTKPDSHOPSHIPMENT_APIJNEFEEKEY] boolValue];
    NSInteger jnefeevalue = [[userinfo objectForKey:kTKPDSHOPSHIPMENT_APIJNEFEEVALUEKEY] integerValue];
    BOOL jneticket = [[userinfo objectForKey:kTKPDSHOPSHIPMENT_APIJNETICKETKEY] boolValue];
    BOOL diffdistrict = [[userinfo objectForKey:kTKPDSHOPSHIPMENT_APIDIFFDISTRICTKEY] boolValue];
    BOOL tikifee = [[userinfo objectForKey:kTKPDSHOPSHIPMENT_APITIKIFEEKEY] boolValue];
    NSInteger tikifeevalue = [[userinfo objectForKey:kTKPDSHOPSHIPMENT_APITIKIFEEVALUEKEY] integerValue];
    BOOL posminweight = [[userinfo objectForKey:kTKPDSHOPSHIPMENT_APIPOSMINWEIGHTKEY] boolValue];
    NSInteger posminweightvalue = [[userinfo objectForKey:kTKPDSHOPSHIPMENT_APIPOSMINWEIGHTVALUEKEY] integerValue];
    BOOL posfee = [[userinfo objectForKey:kTKPDSHOPSHIPMENT_APIPOSFEEKEY] boolValue];
    NSInteger posfeevalue = [[userinfo objectForKey:kTKPDSHOPSHIPMENT_APIPOSFEEVALUEKEY] integerValue];
    
    NSError *error;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:shipmentids
                                                       options:0
                                                         error:&error];
    NSString *JSONString;
    if (!jsonData) {
        NSLog(@"");
    } else {
        
        JSONString = [[NSString alloc] initWithBytes:[jsonData bytes] length:[jsonData length] encoding:NSUTF8StringEncoding];
    }
    
    NSDictionary* param = @{kTKPDDETAIL_APIACTIONKEY:kTKPDDETAIL_APIEDITSHIPPINGINFOKEY,
                            kTKPDSHOPSHIPMENT_APICOURIRORIGINKEY : origin,
                            kTKPDSHOPSHIPMENT_APIPOSTALKEY : postalcode,
                            kTKPDSHOPSHIPMENT_APIDIFFDISTRICTKEY : @(diffdistrict),
                            kTKPDSHOPSHIPMENT_APIMINWEIGHTKEY : @(jneminweight),
                            kTKPDSHOPSHIPMENT_APIMINWEIGHTVALUEKEY: @(jneminweightvalue),
                            kTKPDSHOPSHIPMENT_APITIKIFEEKEY : @(tikifee),
                            kTKPDSHOPSHIPMENT_APITIKIFEEVALUEKEY : @(tikifeevalue),
                            kTKPDSHOPSHIPMENT_APIPOSFEEKEY: @(posfee),
                            kTKPDSHOPSHIPMENT_APIPOSFEEVALUEKEY: @(posfeevalue),
                            kTKPDSHOPSHIPMENT_APIPOSMINWEIGHTKEY : @(posminweight),
                            kTKPDSHOPSHIPMENT_APIPOSMINWEIGHTVALUEKEY : @(posminweightvalue),
                            kTKPDSHOPSHIPMENT_APIJNEFEEKEY : @(jnefee),
                            kTKPDSHOPSHIPMENT_APIJNEFEEVALUEKEY : @(jnefeevalue),                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                   
                            kTKPDSHOPSHIPMENT_APIJNETICKETKEY : @(jneticket),
//                            kTKPDSHOPSHIPMENT_APIRPXPACKETKEY
//                            kTKPDSHOPSHIPMENT_APIRPXTICKETKEY
                            kTKPDSHOPSHIPMENT_APISHIPMENTIDS :JSONString
                            };
    _requestcount ++;
    
    _barbuttonsave.enabled = NO;
    _requestActionShipment = [_objectmanagerActionShipment appropriateObjectRequestOperationWithObject:self method:RKRequestMethodGET path:kTKPDDETAILSHOPEDITORACTION_APIPATH parameters:param];
    
    [_requestActionShipment setCompletionBlockWithSuccess:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
        [self requestSuccessActionShipment:mappingResult withOperation:operation];
        [timer invalidate];
        _barbuttonsave.enabled = YES;
    } failure:^(RKObjectRequestOperation *operation, NSError *error) {
        [self requestFailureActionShipment:error];
        [timer invalidate];
        _barbuttonsave.enabled = YES;
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
                if (setting.message_status) {
                    NSArray *array = setting.message_status;//[[NSArray alloc] initWithObjects:KTKPDMESSAGE_DELIVERED, nil];
                    NSDictionary *info = [NSDictionary dictionaryWithObjectsAndKeys:array,@"messages", nil];
                    [[NSNotificationCenter defaultCenter] postNotificationName:kTKPD_SETUSERSTICKYSUCCESSMESSAGEKEY object:nil userInfo:info];
                }
                else if(setting.message_error)
                {
                    NSArray *array = setting.message_error;//[[NSArray alloc] initWithObjects:KTKPDMESSAGE_UNDELIVERED, nil];
                    NSDictionary *info = [NSDictionary dictionaryWithObjectsAndKeys:array,@"messages", nil];
                    [[NSNotificationCenter defaultCenter] postNotificationName:kTKPD_SETUSERSTICKYERRORMESSAGEKEY object:nil userInfo:info];
                }
                if (setting.result.is_success) {
                    [self refreshView:nil];
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
-(void)MoveToInfoView:(UIView *)view
{
    [self MovetoInfoIndex:view.tag-10];
}

-(void)SettingShipmentSectionFooterView:(UIView *)view
{
    switch (view.tag) {
        case 10:
        {
            //JNE
            BOOL fee = ((SettingShipmentSectionFooterView*)view).switchfee.on;
            //if (fee) _footerheightjne += ((SettingShipmentSectionFooterView*)view).viewswitchfee.frame.size.height;
            //else _footerheightjne -= ((SettingShipmentSectionFooterView*)view).viewswitchfee.frame.size.height;
            [_datainput setObject:@(fee) forKey:kTKPDSHOPSHIPMENT_APIJNEFEEKEY];
            NSInteger feevalue = [((SettingShipmentSectionFooterView*)view).textfieldfee.text integerValue];
            [_datainput setObject:@(feevalue) forKey:kTKPDSHOPSHIPMENT_APIJNEFEEVALUEKEY];
            BOOL minweight = ((SettingShipmentSectionFooterView*)view).switchweightmin.on;
            //if (minweight)_footerheightjne += ((SettingShipmentSectionFooterView*)view).viewminweight.frame.size.height;
            //else _footerheightjne -= ((SettingShipmentSectionFooterView*)view).viewminweight.frame.size.height;
            [_datainput setObject:@(minweight) forKey:kTKPDSHOPSHIPMENT_APIMINWEIGHTKEY];
            NSInteger minweightvalue = [((SettingShipmentSectionFooterView*)view).labelweightmin.text integerValue];
            [_datainput setObject:@(minweightvalue) forKey:kTKPDSHOPSHIPMENT_APIMINWEIGHTVALUEKEY];
            BOOL diffdistrict = ((SettingShipmentSectionFooterView*)view).switchdiffdistrict.on;
            [_datainput setObject:@(diffdistrict) forKey:kTKPDSHOPSHIPMENT_APIDIFFDISTRICTKEY];
            CGRect frame = ((SettingShipmentSectionFooterView*)view).viewinfo.frame;
            _footerheightjne = frame.origin.y + frame.size.height + 20;
            [[_table footerViewForSection:0] setFrame:frame];
            break;
        }
        case 11:
        {
            //TIKI
            BOOL fee = ((SettingShipmentSectionFooter4View*)view).switchfee.on;
            [_datainput setObject:@(fee) forKey:kTKPDSHOPSHIPMENT_APITIKIFEEKEY];
            NSInteger feevalue = [((SettingShipmentSectionFooter4View*)view).textfieldfee.text integerValue];
            [_datainput setObject:@(feevalue) forKey:kTKPDSHOPSHIPMENT_APITIKIFEEVALUEKEY];
            break;
        }
        case 12:
        {
            //POS
            BOOL fee = ((SettingShipmentSectionFooter3View*)view).switchfee.on;
            [_datainput setObject:@(fee) forKey:kTKPDSHOPSHIPMENT_APIPOSFEEKEY];
            NSInteger feevalue = [((SettingShipmentSectionFooter3View*)view).textfieldfee.text integerValue];
            [_datainput setObject:@(feevalue) forKey:kTKPDSHOPSHIPMENT_APIPOSFEEVALUEKEY];
            BOOL minweight = ((SettingShipmentSectionFooter3View*)view).switchweightmin.on;
            [_datainput setObject:@(minweight) forKey:kTKPDSHOPSHIPMENT_APIPOSMINWEIGHTKEY];
            NSInteger minweightvalue = [((SettingShipmentSectionFooter3View*)view).labelweightmin.text integerValue];
            [_datainput setObject:@(minweightvalue) forKey:kTKPDSHOPSHIPMENT_APIPOSMINWEIGHTVALUEKEY];
            break;
        }
        default:
            break;
    }
    
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
        NSArray *shipmentpackage = shipment.shipment_package;
        NSMutableDictionary *packages = [NSMutableDictionary new];
        
        for (int j = 0; j<shipmentpackage.count; j++) {
            ShippingInfoShipmentPackage *package = shipmentpackage[j];
            BOOL value = package.active;
            if (value)[packages setObject:@(value) forKey:[@(package.sp_id) stringValue]];else[packages removeObjectForKey:@(package.sp_id)];
        }
        [_shipments setObject:packages forKey:[@(shipment.shipment_id) stringValue]];
    }

    [_expandedSections removeAllObjects];
    NSMutableDictionary *newshipments = [NSMutableDictionary new];
    for (int i = 0; i<districtsupporteds.count; i++) {
        NSNumber *shipmentid=[NSNumber numberWithInteger:[districtsupporteds[i] integerValue]];
        NSUInteger anIndex=[shipmentids indexOfObject:shipmentid];
        if(NSNotFound == anIndex) {
            NSLog(@"not found");
        }
        NSDictionary *newpackages = [_shipments objectForKey:[shipmentid stringValue]];
        [newshipments setObject:newpackages forKey:[shipmentid stringValue]];
        NSLog(@"ShipmentIDs : %@",newshipments);
        [_expandedSections addObject:@(anIndex)];
    }
    [_datainput setObject:newshipments forKey:kTKPDSHOPSHIPMENT_APISHIPMENTIDS];
    [_table reloadData];
}

#pragma mark - Setting Shipment Cell Delegate
-(void)SettingShipmentCell:(UITableViewCell *)cell withindexpath:(NSIndexPath *)indexpath
{
    NSInteger shipmentid = ((SettingShipmentCell*)cell).shipmentid;
    NSInteger packageid = ((SettingShipmentCell*)cell).packageid;
    BOOL value = ((SettingShipmentCell*)cell).switchpackage.on;
   
    NSMutableDictionary *packages = [NSMutableDictionary new];
    [packages addEntriesFromDictionary:[_shipments objectForKey:[@(shipmentid) stringValue]]];
    if (value)[packages setObject:@(value) forKey:[@(packageid) stringValue]];else[packages removeObjectForKey:[@(packageid)stringValue]];
    
    [_shipments setObject:packages forKey:[@(shipmentid) stringValue]];

    NSLog(@"ShipmentIDs : %@",_shipments);
    [_datainput setObject:_shipments forKey:kTKPDSHOPSHIPMENT_APISHIPMENTIDS];
}

#pragma mark - Methods
-(void)refreshView:(UIRefreshControl*)refresh
{
    [self cancel];
    /** clear object **/

    _requestcount = 0;
    _isrefreshview = YES;
    
    [_table reloadData];
    /** request data **/
    [self configureRestKit];
    [self request];
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
