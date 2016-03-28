//
//  ShippingSettingViewController.m
//  Test2
//
//  Created by Feizal Badri Asmoro on 12/2/14.
//  Copyright (c) 2014 Tokopedia. All rights reserved.
//

#import "MyShopShipmentViewController.h"

#import "detail.h"
#import "ShippingInfo.h"
#import "ShopSettings.h"

#import "URLCacheController.h"
#import "URLCacheConnection.h"

#import "sortfiltershare.h"
#import "FilterLocationViewController.h"
#import "MyShopShipmentViewController.h"
#import "MyShopShipmentInfoViewController.h"

@interface MyShopShipmentViewController () <FilterLocationViewControllerDelegate> {
    
    NSMutableDictionary *_dataInput;
    
    NSMutableArray *_sections;
    NSArray *_shipments;
    
    ShippingInfo *_shippinginfo;
    
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
    
    NSArray *_availableCourierId;
    
    NSMutableDictionary *_values;
    
    UIActivityIndicatorView *_act;
    
}

@property (weak, nonatomic) IBOutlet UITextField *postCodeTextField;
@property (weak, nonatomic) IBOutlet UILabel *provinceLabel;
@property (weak, nonatomic) IBOutlet UIView *topView;

-(void)configureRestKit;
-(void)request;
-(void)requestsuccess:(id)object withOperation:(RKObjectRequestOperation*)operation;
-(void)requestprocess:(id)object;

@end

@implementation MyShopShipmentViewController

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    _isnodata =YES;
    _isrefreshview = NO;
    
    UIBarButtonItem *backBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"icon_arrow_white.png"]
                                                                          style:UIBarButtonItemStyleBordered
                                                                         target:self
                                                                         action:@selector(backButtonTap:)];
    backBarButtonItem.tintColor = [UIColor whiteColor];
    backBarButtonItem.tag = 12;
    self.navigationItem.leftBarButtonItem = backBarButtonItem;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _topView.hidden = YES;
    
    _dataInput = [NSMutableDictionary new];
    _shipments = [NSArray new];
    _operationQueue = [NSOperationQueue new];
    _cacheconnection = [URLCacheConnection new];
    _cachecontroller = [URLCacheController new];
    
    _values = [NSMutableDictionary dictionaryWithDictionary:@{@"MinimumPengirimanJNE" : [NSNumber numberWithInteger:0],
                                                              @"PengirimanLuarJNE" : [NSNumber numberWithInteger:0],
                                                              @"BiayaTambahanJNE" : [NSNumber numberWithInteger:0],
                                                              @"AWBOtomatisJNE" : [NSNumber numberWithInteger:0],
                                                              @"BiayaTambahanTiki" : [NSNumber numberWithInteger:0],
                                                              @"MinimumPengirimanPos" : [NSNull null],
                                                              @"BiayaTambahanPos" : [NSNull null],
                                                              }];
    
    //_act= [[UIActivityIndicatorView alloc] initWithFrame:CGRectMake(0, 0, 20, 20)];
    //UIBarButtonItem *barButtonLoading = [[UIBarButtonItem alloc] initWithCustomView:_act];
    //self.navigationItem.rightBarButtonItem = barButtonLoading;
    //[_act startAnimating];
    
    self.provinceLabel.userInteractionEnabled = YES;
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(provinceButtonDidTap)];
    [self.provinceLabel addGestureRecognizer:tapGesture];
    
    //cache
    NSString *path = [[NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) lastObject]stringByAppendingPathComponent:kTKPDDETAILPRODUCT_CACHEFILEPATH];
    _cachepath = [path stringByAppendingPathComponent:[NSString stringWithFormat:kTKPDDETAILSHOPSHIPPING_APIRESPONSEFILEFORMAT,0]];
    _cachecontroller.filePath = _cachepath;
    _cachecontroller.URLCacheInterval = 86400.0;
    [_cachecontroller initCacheWithDocumentPath:path];
    
    [self configureRestKit];
    [self request];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return _sections.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [[_sections objectAtIndex:section] count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSDictionary *row = [[_sections objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
    return [[row objectForKey:@"rowHeight"] floatValue];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSDictionary *row = [[_sections objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
    NSString *cellIdentifier = [row objectForKey:@"type"];
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier forIndexPath:indexPath];
    
    UILabel *label = (UILabel *)[cell viewWithTag:1];
    label.text = [row objectForKey:@"title"];
    
    UISwitch *switchButton = (UISwitch *)[cell viewWithTag:2];
    [switchButton addTarget:self action:@selector(didTapSwitch:) forControlEvents:UIControlEventValueChanged];
    
    if ([cellIdentifier isEqualToString:@"TextField"]) {
        
        UITextField *textField = (UITextField *)[cell viewWithTag:3];
        [textField addTarget:self
                      action:@selector(textFieldDidChange:)
            forControlEvents:UIControlEventEditingChanged];
        textField.text = @"";
        if (![[row objectForKey:@"value"] isEqual:[NSNull null]]) {
            textField.text = [row objectForKey:@"value"];
        }
        
        if ([[row objectForKey:@"expand"] boolValue]) {
            [switchButton setOn:YES];
        } else {
            [switchButton setOn:NO];
        }
        
    } else if ([cellIdentifier isEqualToString:@"Stepper"]) {
        
        UILabel *subTitleLabel = (UILabel *)[cell viewWithTag:3];
        subTitleLabel.text = [row objectForKey:@"subtitle"];
        
        UIStepper *stepper = (UIStepper *)[cell viewWithTag:5];
        stepper.value = [[row objectForKey:@"value"] intValue];
        [stepper addTarget:self action:@selector(changeValueStepper:) forControlEvents:UIControlEventValueChanged];
        
        UILabel *valueLabel = (UILabel *)[cell viewWithTag:4];
        valueLabel.text = [NSString stringWithFormat:@"%@", [NSNumber numberWithInteger:stepper.value]];
        
        if ([[row objectForKey:@"expand"] boolValue]) {
            [switchButton setOn:YES];
        } else {
            [switchButton setOn:NO];
        }
        
        NSLog(@"%@", row);
        
    } else {
        if ([[row objectForKey:@"value"] integerValue] > 0) {
            [switchButton setOn:YES];
        } else {
            [switchButton setOn:NO];
        }
    }
    
    return cell;
}

- (void)changeValueStepper:(UIStepper *)stepper
{
    CGPoint center = [stepper center];
    CGPoint rootViewPoint = [[stepper superview] convertPoint:center toView:self.tableView];
    NSIndexPath *indexPath = [self.tableView indexPathForRowAtPoint:rootViewPoint];
    NSMutableDictionary *row = [[[_sections objectAtIndex:indexPath.section] objectAtIndex:indexPath.row] mutableCopy];
    UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
    
    //update label value
    UILabel *label = (UILabel *)[cell viewWithTag:4];
    label.text = [NSString stringWithFormat:@"%d", (int)stepper.value];
    
    //update value in row dictionary
    [row setObject:[NSNumber numberWithFloat:stepper.value] forKey:@"value"];
    
    [[_sections objectAtIndex:indexPath.section] setObject:row atIndex:indexPath.row];
    
    if ([[row objectForKey:@"shipmentName"] isEqualToString:@"JNE"]) {
        [_values setValue:[NSNumber numberWithInteger:stepper.value] forKey:@"MinimumPengirimanJNE"];
    }
    else if ([[row objectForKey:@"shipmentName"] isEqualToString:@"Pos Indonesia"]) {
        [_values setValue:[NSNumber numberWithInteger:stepper.value] forKey:@"MinimumPengirimanPos"];
    }
    
    NSLog(@"%@", _values);
}

- (void)didTapSwitch:(id)sender
{
    UISwitch *switchButton = (UISwitch *)sender;
    CGPoint center = [switchButton center];
    CGPoint rootViewPoint = [[sender superview] convertPoint:center toView:self.tableView];
    NSIndexPath *indexPath = [self.tableView indexPathForRowAtPoint:rootViewPoint];
    NSMutableDictionary *row = [[[_sections objectAtIndex:indexPath.section] objectAtIndex:indexPath.row] mutableCopy];
    NSString *type = [row objectForKey:@"type"];
    UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
    
    if ([type isEqualToString:@"TextField"] ||
        [type isEqualToString:@"Stepper"]) {
        
        // update dictionary. set row to expand
        if ([sender isOn]) {
            [row setObject:[NSNumber numberWithBool:YES] forKey:@"expand"];
            [row setObject:[NSNumber numberWithInt:88] forKey:@"rowHeight"];
            
            if ([type isEqualToString:@"Stepper"]) {
                if (indexPath.section == 0) {
                    [_values setObject:[NSNumber numberWithInteger:1] forKey:@"MinimumPengirimanJNE"];
                }
                if (indexPath.section == 2) {
                    [_values setObject:[NSNumber numberWithInteger:1] forKey:@"MinimumPengirimanPos"];
                }
            }
            
            // update dictionary. collapse row
        } else {
            [row setObject:[NSNumber numberWithBool:NO] forKey:@"expand"];
            [row setObject:[NSNumber numberWithInt:44] forKey:@"rowHeight"];
            
            //reset text field value
            if ([type isEqualToString:@"TextField"]) {
                UITextField *textField = (UITextField *)[cell viewWithTag:3];
                textField.text = @"";
                [row setObject:[NSNull null] forKey:@"value"];
                
                if (indexPath.section == 0) {
                    [_values setObject:[NSNull null] forKey:@"BiayaTambahanJNE"];
                }
                else if (indexPath.section == 1) {
                    [_values setObject:[NSNull null] forKey:@"BiayaTambahanTiki"];
                }
                else if (indexPath.section == 2) {
                    [_values setObject:[NSNull null] forKey:@"BiayaTambahanPos"];
                }
                
                //reset stepper value
            } else if ([type isEqualToString:@"Stepper"]) {
                UIStepper *stepper = (UIStepper *)[cell viewWithTag:5];
                stepper.value = 1;
                [row setObject:[NSNumber numberWithInt:1] forKey:@"value"];
                
                // RESET VALUE IN VALUEDICTIONARY
                if (indexPath.section == 0) {
                    [_values setObject:[NSNumber numberWithInteger:0] forKey:@"MinimumPengirimanJNE"];
                }
                
                // RESET VALUE IN VALUEDICTIONARY
                if (indexPath.section == 2) {
                    [_values setObject:[NSNumber numberWithInteger:0] forKey:@"MinimumPengirimanPos"];
                }
            }
            
        }
    } else {
        if ([sender isOn]) {
            [row setObject:[NSNumber numberWithBool:YES] forKey:@"value"];
        } else {
            [row setObject:[NSNumber numberWithBool:NO] forKey:@"value"];
        }
    }
    
    if ([[row objectForKey:@"title"] isEqualToString:@"OKE"]) {
        NSMutableDictionary *row5 = [[[_sections objectAtIndex:indexPath.section] objectAtIndex:4] mutableCopy];
        NSMutableDictionary *row6 = [[[_sections objectAtIndex:indexPath.section] objectAtIndex:5] mutableCopy];
        if ([sender isOn]) {
            [row5 setObject:[NSNumber numberWithBool:NO] forKey:@"expand"];
            [row5 setObject:[NSNumber numberWithInt:44] forKey:@"rowHeight"];
            [row6 setObject:[NSNumber numberWithBool:NO] forKey:@"expand"];
            [row6 setObject:[NSNumber numberWithInt:64] forKey:@"rowHeight"];
        } else {
            [row5 setObject:[NSNumber numberWithBool:NO] forKey:@"expand"];
            [row5 setObject:[NSNumber numberWithInt:0] forKey:@"rowHeight"];
            [row5 setObject:[NSNumber numberWithBool:1] forKey:@"value"];
            
            [row6 setObject:[NSNumber numberWithBool:NO] forKey:@"expand"];
            [row6 setObject:[NSNumber numberWithInt:0] forKey:@"rowHeight"];
            [row6 setObject:[NSNumber numberWithBool:0] forKey:@"value"];
        }
        
        [[_sections objectAtIndex:indexPath.section] setObject:row5 atIndex:4];
        [[_sections objectAtIndex:indexPath.section] setObject:row6 atIndex:5];
        
    } else if ([[row objectForKey:@"title"] isEqualToString:@"Reguler"]) {
        NSMutableDictionary *row2 = [[[_sections objectAtIndex:indexPath.section] objectAtIndex:1] mutableCopy];
        if ([sender isOn]) {
            [row2 setObject:[NSNumber numberWithBool:NO] forKey:@"expand"];
            [row2 setObject:[NSNumber numberWithInt:44] forKey:@"rowHeight"];
        } else {
            [row2 setObject:[NSNumber numberWithBool:NO] forKey:@"expand"];
            [row2 setObject:[NSNumber numberWithInt:0] forKey:@"rowHeight"];
        }
        [[_sections objectAtIndex:indexPath.section] setObject:row2 atIndex:1];
        
    } else if ([[row objectForKey:@"title"] isEqualToString:@"Hanya Dapat Melayani Pengiriman Luar Kota"]) {
        [_values setObject:[NSNumber numberWithBool:[switchButton isOn]] forKey:@"PengirimanLuarJNE"];
        
    } else if ([[row objectForKey:@"title"] isEqualToString:@"Sistem AWB Otomatis"]) {
        [_values setObject:[NSNumber numberWithBool:[switchButton isOn]] forKey:@"AWBOtomatisJNE"];
    }
    
    [[_sections objectAtIndex:indexPath.section] setObject:row atIndex:indexPath.row];
    
    [self.tableView reloadData];
    
    NSLog(@"%@", _values);
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 40;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    ShippingInfoShipments *shipment = [_shipments objectAtIndex:section];
    
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, tableView.sectionHeaderHeight)];
    headerView.backgroundColor = [UIColor redColor];
    
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(15, 0, self.view.frame.size.width, 40)];
    label.text = shipment.shipment_name;
    [headerView addSubview:label];
    
    NSURLRequest* request = [[NSURLRequest alloc] initWithURL:[NSURL URLWithString:shipment.shipment_image] cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:kTKPDREQUEST_TIMEOUTINTERVAL];
    UIImageView *thumb = [[UIImageView alloc] initWithFrame:CGRectMake(self.view.frame.size.width-65, -5, 50, 50)];
    thumb.image = nil;
    thumb.contentMode = UIViewContentModeScaleAspectFit;
    thumb.clipsToBounds = YES;
    [headerView addSubview:thumb];
    [thumb setImageWithURLRequest:request placeholderImage:nil success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-retain-cycles"
        
        [thumb setImage:image animated:YES];
        
#pragma clang diagnosti c pop
        
    } failure:nil];
    
    return headerView;
}

#pragma mark - Request and Mapping

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
                                                        kTKPDSHOPSHIPMENT_APIDIFFDISTRICTKEY:kTKPDSHOPSHIPMENT_APIDIFFDISTRICTKEY,
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
    
    RKObjectMapping *JNEMapping = [RKObjectMapping mappingForClass:[JNE class]];
    [JNEMapping addAttributeMappingsFromDictionary:@{kTKPDSHOPSHIPMENT_APIJNEFEEKEY : kTKPDSHOPSHIPMENT_APIJNEFEEKEY,
                                                     kTKPDSHOPSHIPMENT_APIMINWEIGHTKEY : kTKPDSHOPSHIPMENT_APIMINWEIGHTKEY,
                                                     kTKPDSHOPSHIPMENT_APIDIFFDISTRICTKEY : kTKPDSHOPSHIPMENT_APIDIFFDISTRICTKEY,
                                                     kTKPDSHOPSHIPMENT_APIJNETICKETKEY : kTKPDSHOPSHIPMENT_APIJNETICKETKEY,
                                                     }];
    
    RKObjectMapping *POSMapping = [RKObjectMapping mappingForClass:[POSIndonesia class]];
    [POSMapping addAttributeMappingsFromDictionary:@{kTKPDSHOPSHIPMENT_APIPOSFEEKEY : kTKPDSHOPSHIPMENT_APIPOSFEEKEY,
                                                     kTKPDSHOPSHIPMENT_APIPOSMINWEIGHTKEY : kTKPDSHOPSHIPMENT_APIPOSMINWEIGHTKEY,
                                                     }];
    
    RKObjectMapping *tikiMapping = [RKObjectMapping mappingForClass:[Tiki class]];
    [tikiMapping addAttributeMappingsFromDictionary:@{ kTKPDSHOPSHIPMENT_APITIKIFEEKEY : kTKPDSHOPSHIPMENT_APITIKIFEEKEY }];
    
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
    
    RKRelationshipMapping *JNERel = [RKRelationshipMapping relationshipMappingFromKeyPath:kTKPDSHOPSHIPMENT_APIJNEKEY toKeyPath:kTKPDSHOPSHIPMENT_APIJNEKEY withMapping:JNEMapping];
    [resultMapping addPropertyMapping:JNERel];
    
    RKRelationshipMapping *tikiRel = [RKRelationshipMapping relationshipMappingFromKeyPath:kTKPDSHOPSHIPMENT_APITIKIKEY toKeyPath:kTKPDSHOPSHIPMENT_APITIKIKEY withMapping:tikiMapping];
    [resultMapping addPropertyMapping:tikiRel];
    
    RKRelationshipMapping *posRel = [RKRelationshipMapping relationshipMappingFromKeyPath:kTKPDSHOPSHIPMENT_APIPOSKEY toKeyPath:kTKPDSHOPSHIPMENT_APIPOSKEY withMapping:POSMapping];
    [resultMapping addPropertyMapping:posRel];
    
    RKRelationshipMapping *shipmentpackagesRel = [RKRelationshipMapping relationshipMappingFromKeyPath:kTKPDSHOPSHIPMENT_APISHIPMENTPACKAGEKEY toKeyPath:kTKPDSHOPSHIPMENT_APISHIPMENTPACKAGEKEY withMapping:shipmentspackageMapping];
    [shipmentsMapping addPropertyMapping:shipmentpackagesRel];
    
    [resultMapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:kTKPDSHOPSHIPMENT_APIPOSMINWEIGHTKEY toKeyPath:kTKPDSHOPSHIPMENT_APIPOSMINWEIGHTKEY withMapping:posweightMapping]];
    
    [resultMapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:kTKPDSHOPSHIPMENT_APISHOPSHIPPINGKEY toKeyPath:kTKPDSHOPSHIPMENT_APISHOPSHIPPINGKEY withMapping:shopshippingMapping]];
    
    [shippingMapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:kTKPD_APIRESULTKEY toKeyPath:kTKPD_APIRESULTKEY withMapping:resultMapping]];
    
    // Response Descriptor
    RKResponseDescriptor *responseDescriptor = [RKResponseDescriptor responseDescriptorWithMapping:shippingMapping method:RKRequestMethodPOST pathPattern:kTKPDSHOPSHIPMENT_APIPATH keyPath:@"" statusCodes:kTkpdIndexSetStatusCodeOK];
    
    [_objectmanager addResponseDescriptor:responseDescriptor];
}

- (void)request
{
    if (_request.isExecuting) return;
    _requestcount++;
    
    NSDictionary* param = @{kTKPDDETAIL_APIACTIONKEY : kTKPDDETAIL_APIGETSHOPSHIPPINGINFOKEY,};
    
    _request = [_objectmanager appropriateObjectRequestOperationWithObject:self method:RKRequestMethodPOST path:kTKPDSHOPSHIPMENT_APIPATH parameters:[param encrypt]];
    [_cachecontroller getFileModificationDate];
    _timeinterval = fabs([_cachecontroller.fileDate timeIntervalSinceNow]);
    
    NSTimer *timer;
    
    [_request setCompletionBlockWithSuccess:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
        [timer invalidate];
        [self requestsuccess:mappingResult withOperation:operation];
    } failure:nil];
    
    [_operationQueue addOperation:_request];
}

-(void)requestsuccess:(id)object withOperation:(RKObjectRequestOperation *)operation
{
    NSDictionary *result = ((RKMappingResult*)object).dictionary;
    
    id stats = [result objectForKey:@""];
    _shippinginfo = stats;
    
    BOOL status = [_shippinginfo.status isEqualToString:kTKPDREQUEST_OKSTATUS];
    if (status) {
        [self requestprocess:object];
    }
}

-(void)requestprocess:(id)object
{
    
    UIBarButtonItem *barButtonSave = [[UIBarButtonItem alloc] initWithTitle:@"Simpan"
                                                                      style:UIBarButtonItemStyleDone
                                                                     target:self
                                                                     action:@selector(saveButtonTap:)];
    self.navigationItem.rightBarButtonItem = barButtonSave;
    
    if (object) {
        if ([object isKindOfClass:[RKMappingResult class]]) {
            NSDictionary *result = ((RKMappingResult*)object).dictionary;
            
            id stats = [result objectForKey:@""];
            _shippinginfo = stats;
            
            BOOL status = [_shippinginfo.status isEqualToString:kTKPDREQUEST_OKSTATUS];
            if (status) {
                
                _topView.hidden = NO;
                
                _isnodata = NO;
                _shipments = [NSArray arrayWithArray:_shippinginfo.result.shipment];
                
                _provinceLabel.text = _shippinginfo.result.shop_shipping.district_name;
                _postCodeTextField.text = _shippinginfo.result.shop_shipping.postal_code;
                
                NSMutableArray *ids = [NSMutableArray new];
                for (id shipment_id in _shippinginfo.result.shop_shipping.district_shipping_supported) {
                    NSInteger shipment = [shipment_id integerValue];
                    [ids addObject:[NSNumber numberWithInteger:shipment]];
                }
                _availableCourierId = ids;
                [self setRows];
                
                [_values setObject:[NSNumber numberWithInteger:[_shippinginfo.result.jne.jne_min_weight integerValue]] forKey:@"MinimumPengirimanJNE"];
                [_values setObject:[NSNumber numberWithInteger:[_shippinginfo.result.jne.jne_diff_district integerValue]] forKey:@"PengirimanLuarJNE"];
                [_values setObject:[NSNumber numberWithInteger:_shippinginfo.result.jne.jne_fee] forKey:@"BiayaTambahanJNE"];
                [_values setObject:[NSNumber numberWithInteger:[_shippinginfo.result.jne.jne_tiket boolValue]] forKey:@"AWBOtomatisJNE"];
                
                [_values setObject:[NSNumber numberWithInteger:_shippinginfo.result.tiki.tiki_fee]?:[NSNull null] forKey:@"BiayaTambahanTiki"];
                
                [_values setObject:[NSNumber numberWithInteger:_shippinginfo.result.pos.pos_min_weight]?:[NSNull null] forKey:@"MinimumPengirimanPos"];
                [_values setObject:[NSNumber numberWithInteger:_shippinginfo.result.pos.pos_fee]?:[NSNull null] forKey:@"BiayaTambahanPos"];
                
            }
        }
    }
}

- (void)setRows
{
    _sections = [NSMutableArray new];
    
    for (ShippingInfoShipments *shipment in _shipments) {
        NSMutableArray *rows = [[NSMutableArray alloc] init];
        if ([_availableCourierId containsObject:[NSNumber numberWithInteger:[shipment.shipment_id integerValue]]]) {
            BOOL OKE = false;
            for (ShippingInfoShipmentPackage *package in shipment.shipment_package) {
                [rows addObject:@{
                                  @"title" : package.name,
                                  @"type" : @"Switch",
                                  @"value" : [NSNumber numberWithInteger:[package.active integerValue]],
                                  @"rowHeight" : [NSNumber numberWithInt:44],
                                  @"shipmentName" : shipment.shipment_name,
                                  @"packageId" : [NSNumber numberWithInteger:[package.sp_id integerValue]],
                                  @"shipmentId" : [NSNumber numberWithInteger:[shipment.shipment_id integerValue]],
                                  }];
                if ([package.name isEqualToString:@"OKE"] && package.active > 0) {
                    OKE = YES;
                }
            }
            if (rows.count == 0) {
                [rows addObject:@{
                                  @"title" : @"Not supported",
                                  @"type" : @"Plain",
                                  @"shipmentName" : shipment.shipment_name,
                                  @"shipmentId" : [NSNumber numberWithInteger:[shipment.shipment_id integerValue]],
                                  }];
            } else {
                if ([shipment.shipment_name isEqualToString:@"JNE"]) {
                    
                    NSInteger heightForMinWeightRow = 0;
                    BOOL expandMinWeightRow = NO;
                    if (OKE) {
                        if (_shippinginfo.result.jne.jne_min_weight > 0) {
                            heightForMinWeightRow = 88;
                            expandMinWeightRow = YES;
                        } else {
                            expandMinWeightRow = NO;
                            heightForMinWeightRow = 44;
                        }
                    }
                    
                    NSInteger heightForExtraFee = 44;
                    BOOL showExtraFeeRow = NO;
                    if (_shippinginfo.result.jne.jne_fee > 0) {
                        heightForExtraFee = 88;
                        showExtraFeeRow = YES;
                    }
                    
                    NSInteger heightForRow3 = 0;
                    if (_shippinginfo.result.jne.jne_diff_district > 0 || OKE) {
                        heightForRow3 = 64;
                    }
                    
                    [rows addObject:[NSMutableDictionary dictionaryWithDictionary:@{
                                                                                    @"title" : @"Sistem AWB Otomatis",
                                                                                    @"type" : @"SwitchWithMargin",
                                                                                    @"value" : [NSNumber numberWithInteger:[_shippinginfo.result.jne.jne_tiket integerValue]],
                                                                                    @"rowHeight" : [NSNumber numberWithInt:68],
                                                                                    @"shipmentName" : shipment.shipment_name,
                                                                                    @"shipmentId" : [NSNumber numberWithInteger:[shipment.shipment_id integerValue]],
                                                                                    }]];
                    [rows addObject:[NSMutableDictionary dictionaryWithDictionary:@{
                                                                                    @"title" : @"Minimum Pengiriman Layanan",
                                                                                    @"subtitle" : @"Berat Minimum (Kg)",
                                                                                    @"type" : @"Stepper",
                                                                                    @"value" : [NSNumber numberWithInteger:[_shippinginfo.result.jne.jne_min_weight integerValue]],
                                                                                    @"expand" : [NSNumber numberWithInteger:expandMinWeightRow],
                                                                                    @"rowHeight" : [NSNumber numberWithInteger:heightForMinWeightRow],
                                                                                    @"shipmentName" : shipment.shipment_name,
                                                                                    @"shipmentId" : [NSNumber numberWithInteger:[shipment.shipment_id integerValue]],
                                                                                    }]];
                    [rows addObject:[NSMutableDictionary dictionaryWithDictionary:@{
                                                                                    @"title" : @"Hanya Dapat Melayani Pengiriman Luar Kota",
                                                                                    @"type" : @"SwitchTwoLines",
                                                                                    @"value" : [NSNumber numberWithInteger:[_shippinginfo.result.jne.jne_diff_district integerValue]],
                                                                                    @"rowHeight" : [NSNumber numberWithFloat:heightForRow3],
                                                                                    @"shipmentName" : shipment.shipment_name,
                                                                                    @"shipmentId" : [NSNumber numberWithInteger:[shipment.shipment_id integerValue]],
                                                                                    }]];
                    [rows addObject:[NSMutableDictionary dictionaryWithDictionary:@{
                                                                                    @"title" : @"Biaya Tambahan Pengiriman",
                                                                                    @"type" : @"TextField",
                                                                                    @"value" : [NSString stringWithFormat:@"%ld", (long)_shippinginfo.result.jne.jne_fee],
                                                                                    @"expand" : [NSNumber numberWithBool:showExtraFeeRow],
                                                                                    @"rowHeight" : [NSNumber numberWithInteger:heightForExtraFee],
                                                                                    @"shipmentName" : shipment.shipment_name,
                                                                                    @"shipmentId" : [NSNumber numberWithInteger:[shipment.shipment_id integerValue]],
                                                                                    }]];
                }
                
                if ([shipment.shipment_name isEqualToString:@"Tiki"]) {
                    
                    NSInteger heightForExtraFee = 44;
                    BOOL showExtraFeeRow = NO;
                    if (_shippinginfo.result.tiki.tiki_fee > 0) {
                        heightForExtraFee = 88;
                        showExtraFeeRow = YES;
                    }
                    
                    [rows addObject:[NSMutableDictionary dictionaryWithDictionary:@{
                                                                                    @"title" : @"Biaya Tambahan Pengiriman",
                                                                                    @"type" : @"TextField",
                                                                                    @"value" : [NSString stringWithFormat:@"%ld", (long)_shippinginfo.result.tiki.tiki_fee],
                                                                                    @"expand" : [NSNumber numberWithBool:showExtraFeeRow],
                                                                                    @"rowHeight" : [NSNumber numberWithInteger:heightForExtraFee],
                                                                                    @"shipmentName" : shipment.shipment_name,
                                                                                    @"shipmentId" : [NSNumber numberWithInteger:[shipment.shipment_id integerValue]],
                                                                                    }]];
                }
                
                if ([shipment.shipment_name isEqualToString:@"Pos Indonesia"]) {
                    
                    NSInteger heightForMinWeightRow = 44;
                    BOOL showMinWeightRow = NO;
                    if (_shippinginfo.result.pos.pos_min_weight > 0) {
                        showMinWeightRow = YES;
                        heightForMinWeightRow = 88;
                    }
                    
                    NSInteger heightForExtraFee = 44;
                    BOOL showExtraFeeRow = NO;
                    if (_shippinginfo.result.pos.pos_fee > 0) {
                        heightForExtraFee = 88;
                        showExtraFeeRow = YES;
                    }
                    
                    [rows addObject:[NSMutableDictionary dictionaryWithDictionary:@{
                                                                                    @"title" : @"Minimum Pengiriman Layanan",
                                                                                    @"subtitle" : @"Berat Minimum (Kg)",
                                                                                    @"type" : @"Stepper",
                                                                                    @"value" : [NSNumber numberWithInteger:_shippinginfo.result.pos.pos_min_weight],
                                                                                    @"expand" : [NSNumber numberWithBool:showMinWeightRow],
                                                                                    @"rowHeight" : [NSNumber numberWithInteger:heightForMinWeightRow],
                                                                                    @"shipmentName" : shipment.shipment_name,
                                                                                    @"shipmentId" : [NSNumber numberWithInteger:[shipment.shipment_id integerValue]],
                                                                                    }]];
                    [rows addObject:[NSMutableDictionary dictionaryWithDictionary:@{
                                                                                    @"title" : @"Biaya Tambahan Pengiriman",
                                                                                    @"type" : @"TextField",
                                                                                    @"value" : [NSString stringWithFormat:@"%ld", (long)_shippinginfo.result.pos.pos_fee],
                                                                                    @"expand" : [NSNumber numberWithBool:showExtraFeeRow],
                                                                                    @"rowHeight" : [NSNumber numberWithInteger:heightForExtraFee],
                                                                                    @"shipmentName" : shipment.shipment_name,
                                                                                    @"shipmentId" : [NSNumber numberWithInteger:[shipment.shipment_id integerValue]],
                                                                                    }]];
                }
                
                [rows addObject:[NSMutableDictionary dictionaryWithDictionary:@{
                                                                                @"title" : [NSString stringWithFormat:@"Info tentang %@", shipment.shipment_name],
                                                                                @"type" : @"Info",
                                                                                @"rowHeight" : [NSNumber numberWithInt:68],
                                                                                @"shipmentName" : shipment.shipment_name,
                                                                                @"shipmentId" : [NSNumber numberWithInteger:[shipment.shipment_id integerValue]],
                                                                                }]];
            }
        } else {
            [rows addObject:@{
                              @"title" : @"Not supported",
                              @"type" : @"Plain",
                              @"rowHeight" : [NSNumber numberWithInt:44],
                              @"shipmentName" : shipment.shipment_name,
                              }];
        }
        [_sections addObject:rows];
    }
    [self.tableView reloadData];
}

#pragma mark - Text field delegate

- (void)textFieldDidChange:(UITextField *)textField
{
    CGPoint center = [textField center];
    CGPoint rootViewPoint = [[textField superview] convertPoint:center toView:self.tableView];
    NSIndexPath *indexPath = [self.tableView indexPathForRowAtPoint:rootViewPoint];
    NSMutableDictionary *row = [[_sections objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
    [row setObject:textField.text forKey:@"value"];
    
    if ([[row objectForKey:@"shipmentName"] isEqualToString:@"JNE"]) {
        [_values setValue:textField.text forKey:@"BiayaTambahanJNE"];
    }
    else if ([[row objectForKey:@"shipmentName"] isEqualToString:@"Tiki"]) {
        [_values setValue:textField.text forKey:@"BiayaTambahanTiki"];
    }
    else if ([[row objectForKey:@"shipmentName"] isEqualToString:@"Pos Indonesia"]) {
        [_values setValue:textField.text forKey:@"BiayaTambahanPos"];
    }
    
    NSLog(@"%@", _values);
}

#pragma mark - Scroll view delegate

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    [self.view endEditing:YES];
}

- (void)provinceButtonDidTap
{
    //Select Provincy
    NSArray *districts = _shippinginfo.result.district;
    NSInteger districtid = [[_dataInput objectForKey:kTKPDFILTER_APISELECTEDDISTRICTIDKEY]integerValue]?:_shippinginfo.result.shop_shipping.district_id;
    FilterLocationViewController *vc = [FilterLocationViewController new];
    NSIndexPath *indexpath = [_dataInput objectForKey:kTKPDFILTERLOCATION_DATAINDEXPATHKEY]?:[NSIndexPath indexPathForRow:0 inSection:0];
    vc.data = @{kTKPDFILTER_APITYPEKEY:@(kTKPDFILTER_DATATYPESHOPSHIPPINGPROVINCYKEY),
                kTKPDFILTERLOCATION_DATALOCATIONARRAYKEY:districts,
                kTKPDFILTER_DATAINDEXPATHKEY:indexpath,
                kTKPDFILTER_APISELECTEDDISTRICTIDKEY:@(districtid)
                };
    vc.delegate = self;
    [self.navigationController pushViewController:vc animated:YES];
}


#pragma mark - Filter Delegate

-(void)FilterLocationViewController:(UIViewController *)viewcontroller withdata:(NSDictionary *)data
{
    _topView.hidden = NO;
    
    _provinceLabel.text = [data objectForKey:kTKPDFILTER_APILOCATIONNAMEKEY] ? : @"Pilih Provinsi";
    NSIndexPath *indexpath = [data objectForKey:kTKPDFILTERLOCATION_DATAINDEXPATHKEY]?:[NSIndexPath indexPathForRow:0 inSection:0];
    
    _postCodeTextField.text = @"";
    
    NSArray *districts = _shippinginfo.result.district;
    District *district = districts[indexpath.row];
    NSMutableArray *ids = [NSMutableArray new];
    for (id shipment_id in district.district_shipping_supported) {
        NSInteger shipment = [shipment_id integerValue];
        [ids addObject:[NSNumber numberWithInteger:shipment]];
    }
    _availableCourierId = ids;
    [self setRows];
}

- (IBAction)saveButtonTap:(id)sender {
    NSMutableDictionary *data = [NSMutableDictionary new];
    for (NSArray *rows in _sections) {
        NSMutableDictionary *packages = [NSMutableDictionary new];
        NSString *courierId = @"";
        for (NSDictionary *row in rows) {
            if ([row objectForKey:@"packageId"] && [[row objectForKey:@"value"] isEqualToNumber:[NSNumber numberWithInt:1]]) {
                NSLog(@"%@ %@ %@", [row objectForKey:@"shipmentName"], [row objectForKey:@"packageId"], [row objectForKey:@"value"]);
                [packages setObject:[NSNumber numberWithInteger:1] forKey:[[row objectForKey:@"packageId"] stringValue]];
                courierId = [[row objectForKey:@"shipmentId"] stringValue];
            }
        }
        if (packages.count > 0) {
            [data setObject:packages forKey:courierId];
        }
    }
    
    NSLog(@"%@", data);
    NSLog(@"%@", _values);
    
    NSMutableArray *messages = [NSMutableArray new];
    BOOL valid = YES;
    
    //Validate biaya tambahan pengiriman JNE
    if ([[_sections objectAtIndex:0] count] > 1) {
        NSDictionary *biayaTambahanJNE = [[_sections objectAtIndex:0] objectAtIndex:6];
        if ([[biayaTambahanJNE objectForKey:@"expand"] boolValue]) {
            if ([[_values objectForKey:@"BiayaTambahanJNE"] isEqual:[NSNull null]] ||
                [[_values objectForKey:@"BiayaTambahanJNE"] integerValue] == 0) {
                [messages addObject:@"Biaya Tambahan JNE harus diisi."];
                valid = NO;
            }
            else if ([[_values objectForKey:@"BiayaTambahanJNE"] integerValue] > 5000) {
                [messages addObject:@"Maksimum Biaya JNE adalah Rp 5.000,-"];
                valid = NO;
            }
        }
    }
    
    //Validate biaya tambahan pengiriman Tiki
    if ([[_sections objectAtIndex:1] count] > 1) {
        NSDictionary *biayaTambahanTiki = [[_sections objectAtIndex:1] objectAtIndex:1];
        if ([[biayaTambahanTiki objectForKey:@"expand"] boolValue]) {
            if ([[_values objectForKey:@"BiayaTambahanTiki"] isEqual:[NSNull null]] ||
                [[_values objectForKey:@"BiayaTambahanTiki"] integerValue] == 0) {
                [messages addObject:@"Biaya Tambahan Tiki harus diisi."];
                valid = NO;
            }
            else if ([[_values objectForKey:@"BiayaTambahanTiki"] integerValue] > 5000) {
                [messages addObject:@"Maksimum Biaya Tiki adalah Rp 5.000,-"];
                valid = NO;
            }
        }
    }
    
    //Validate biaya tambahan pengiriman Pos Indonesia
    if ([[_sections objectAtIndex:2] count] > 1) {
        NSDictionary *biayaTambahanPos = [[_sections objectAtIndex:4] objectAtIndex:3];
        if ([[biayaTambahanPos objectForKey:@"expand"] boolValue]) {
            if ([[_values objectForKey:@"BiayaTambahanPos"] isEqual:[NSNull null]] ||
                [[_values objectForKey:@"BiayaTambahanPos"] integerValue] == 0) {
                [messages addObject:@"Biaya Tambahan Pos Indonesia harus diisi."];
                valid = NO;
            }
            else if ([[_values objectForKey:@"BiayaTambahanPos"] integerValue] > 5000) {
                [messages addObject:@"Maksimum Biaya Pos Indonesia adalah Rp 5.000,-"];
                valid = NO;
            }
        }
    }
    
    [_dataInput setObject:_postCodeTextField.text forKey:kTKPDSHOPSHIPMENT_APIPOSTALCODEKEY];
    [_dataInput setObject:[NSNumber numberWithInteger:_shippinginfo.result.shop_shipping.origin] forKey:kTKPDFILTER_APISELECTEDDISTRICTIDKEY];
    
    // set data input for jne weight value and key
    if ([[_values objectForKey:@"MinimumPengirimanJNE"] isEqual:[NSNull null]] ||
        [[[[_sections objectAtIndex:0] objectAtIndex:4] objectForKey:@"expand"] isEqualToNumber:[NSNumber numberWithInteger:0]]) {
        [_dataInput setObject:[NSNumber numberWithBool:NO] forKey:kTKPDSHOPSHIPMENT_APIMINWEIGHTKEY];
        [_dataInput setObject:[NSNumber numberWithInteger:0] forKey:kTKPDSHOPSHIPMENT_APIMINWEIGHTVALUEKEY];
    } else {
        [_dataInput setObject:[NSNumber numberWithBool:YES] forKey:kTKPDSHOPSHIPMENT_APIMINWEIGHTKEY];
        [_dataInput setObject:[_values objectForKey:@"MinimumPengirimanJNE"] forKey:kTKPDSHOPSHIPMENT_APIMINWEIGHTVALUEKEY];
    }
    
    // set data input for jne fee value and key
    if ([[_values objectForKey:@"BiayaTambahanJNE"] isEqual:[NSNull null]] ||
        [[[[_sections objectAtIndex:0] objectAtIndex:6] objectForKey:@"expand"] isEqualToNumber:[NSNumber numberWithInteger:0]]) {
        [_dataInput setObject:[NSNumber numberWithBool:NO] forKey:kTKPDSHOPSHIPMENT_APIJNEFEEKEY];
        [_dataInput setObject:[NSNumber numberWithInteger:0] forKey:kTKPDSHOPSHIPMENT_APIJNEFEEVALUEKEY];
    } else {
        [_dataInput setObject:[NSNumber numberWithBool:YES] forKey:kTKPDSHOPSHIPMENT_APIJNEFEEKEY];
        [_dataInput setObject:[_values objectForKey:@"BiayaTambahanJNE"] forKey:kTKPDSHOPSHIPMENT_APIJNEFEEVALUEKEY];
    }
    
    // set JNE AWB VALUE TO INPUT DATA
    [_dataInput setObject:[_values objectForKey:@"AWBOtomatisJNE"] forKey:kTKPDSHOPSHIPMENT_APIJNETICKETKEY];
    
    // set Pengiriman luar kota JNE ke input data
    [_dataInput setObject:[_values objectForKey:@"PengirimanLuarJNE"] forKey:kTKPDSHOPSHIPMENT_APIDIFFDISTRICTKEY];
    
    // set data input for "Biaya Tambahan Pengiriman TIKI"
    if ([[_values objectForKey:@"BiayaTambahanTiki"] isEqual:[NSNull null]] ||
        [[[[_sections objectAtIndex:1] objectAtIndex:1] objectForKey:@"expand"] isEqualToNumber:[NSNumber numberWithInteger:0]]) {
        [_dataInput setObject:[NSNumber numberWithBool:NO] forKey:kTKPDSHOPSHIPMENT_APITIKIFEEKEY];
        [_dataInput setObject:[NSNumber numberWithInteger:0] forKey:kTKPDSHOPSHIPMENT_APITIKIFEEVALUEKEY];
    } else {
        [_dataInput setObject:[NSNumber numberWithBool:YES] forKey:kTKPDSHOPSHIPMENT_APITIKIFEEKEY];
        [_dataInput setObject:[_values objectForKey:@"BiayaTambahanTiki"] forKey:kTKPDSHOPSHIPMENT_APITIKIFEEVALUEKEY];
    }
    
    // set data input for POS INDONESIA weight value and key
    if ([[_values objectForKey:@"MinimumPengirimanPos"] isEqual:[NSNull null]] ||
        [[[[_sections objectAtIndex:2] objectAtIndex:2] objectForKey:@"expand"] isEqualToNumber:[NSNumber numberWithInteger:0]]) {
        [_dataInput setObject:[NSNumber numberWithBool:NO] forKey:kTKPDSHOPSHIPMENT_APIPOSMINWEIGHTKEY];
        [_dataInput setObject:[NSNumber numberWithInteger:0] forKey:kTKPDSHOPSHIPMENT_APIPOSMINWEIGHTVALUEKEY];
    } else {
        [_dataInput setObject:[NSNumber numberWithBool:YES] forKey:kTKPDSHOPSHIPMENT_APIPOSMINWEIGHTKEY];
        [_dataInput setObject:[_values objectForKey:@"MinimumPengirimanPos"] forKey:kTKPDSHOPSHIPMENT_APIPOSMINWEIGHTVALUEKEY];
    }
    
    // set data input for POS INDONESIA fee value and key
    if ([[_values objectForKey:@"BiayaTambahanPos"] isEqual:[NSNumber numberWithInteger:0]] ||
        [[[[_sections objectAtIndex:2] objectAtIndex:3] objectForKey:@"expand"] isEqualToNumber:[NSNumber numberWithInteger:0]]) {
        [_dataInput setObject:[NSNumber numberWithBool:NO] forKey:kTKPDSHOPSHIPMENT_APIPOSFEEKEY];
        [_dataInput setObject:[NSNumber numberWithInteger:0] forKey:kTKPDSHOPSHIPMENT_APIPOSFEEVALUEKEY];
    } else {
        [_dataInput setObject:[NSNumber numberWithBool:YES] forKey:kTKPDSHOPSHIPMENT_APIPOSFEEKEY];
        [_dataInput setObject:[_values objectForKey:@"BiayaTambahanPos"] forKey:kTKPDSHOPSHIPMENT_APIPOSFEEVALUEKEY];
    }
    
    [_dataInput setObject:data forKey:kTKPDSHOPSHIPMENT_APISHIPMENTIDS];
    
    if (valid) {
        
        [self configureRestKitActionShipment];
        [self requestActionShipment:_dataInput];
        
        _act= [[UIActivityIndicatorView alloc] initWithFrame:CGRectMake(0, 0, 20, 20)];
        UIBarButtonItem *barButtonLoading = [[UIBarButtonItem alloc] initWithCustomView:_act];
        self.navigationItem.rightBarButtonItem = barButtonLoading;
        [_act startAnimating];
        
    } else {
        StickyAlertView *alert = [[StickyAlertView alloc] initWithErrorMessages:messages delegate:self];
        [alert show];
    }
    
    NSLog(@"\n\n\n%@\n\n\n", _dataInput);
    
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
    RKResponseDescriptor *responseDescriptor = [RKResponseDescriptor responseDescriptorWithMapping:statusMapping method:RKRequestMethodPOST pathPattern:kTKPDDETAILSHOPACTIONEDITOR_APIPATH keyPath:@"" statusCodes:kTkpdIndexSetStatusCodeOK];
    
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
    NSInteger jneminweight = [[userinfo objectForKey:kTKPDSHOPSHIPMENT_APIMINWEIGHTKEY] integerValue];
    NSInteger jneminweightvalue = [[userinfo objectForKey:kTKPDSHOPSHIPMENT_APIMINWEIGHTVALUEKEY] integerValue];
    NSInteger jnefee = [[userinfo objectForKey:kTKPDSHOPSHIPMENT_APIJNEFEEKEY] integerValue];
    NSInteger jnefeevalue = [[userinfo objectForKey:kTKPDSHOPSHIPMENT_APIJNEFEEVALUEKEY] integerValue];
    NSInteger jneticket = [[userinfo objectForKey:kTKPDSHOPSHIPMENT_APIJNETICKETKEY] integerValue];
    NSInteger diffdistrict = [[userinfo objectForKey:kTKPDSHOPSHIPMENT_APIDIFFDISTRICTKEY] integerValue];
    NSInteger tikifee = [[userinfo objectForKey:kTKPDSHOPSHIPMENT_APITIKIFEEKEY] integerValue];
    NSInteger tikifeevalue = [[userinfo objectForKey:kTKPDSHOPSHIPMENT_APITIKIFEEVALUEKEY] integerValue];
    NSInteger posminweight = [[userinfo objectForKey:kTKPDSHOPSHIPMENT_APIPOSMINWEIGHTKEY] integerValue];
    NSInteger posminweightvalue = [[userinfo objectForKey:kTKPDSHOPSHIPMENT_APIPOSMINWEIGHTVALUEKEY] integerValue];
    NSInteger posfee = [[userinfo objectForKey:kTKPDSHOPSHIPMENT_APIPOSFEEKEY] integerValue];
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
    
    _requestActionShipment = [_objectmanagerActionShipment appropriateObjectRequestOperationWithObject:self method:RKRequestMethodPOST path:kTKPDDETAILSHOPACTIONEDITOR_APIPATH parameters:[param encrypt]];
    
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
                if (setting.message_status) {
                    StickyAlertView *alert = [[StickyAlertView alloc] initWithSuccessMessages:setting.message_status delegate:self];
                    [alert show];
                } else if(setting.message_error) {
                    StickyAlertView *alert = [[StickyAlertView alloc] initWithErrorMessages:setting.message_error delegate:self];
                    [alert show];
                }
                if (setting.result.is_success == 1) {
                    [self refreshView:nil];
                }
                
                UIBarButtonItem *barButtonSave = [[UIBarButtonItem alloc] initWithTitle:@"Simpan"
                                                                                  style:UIBarButtonItemStyleDone
                                                                                 target:self
                                                                                 action:@selector(saveButtonTap:)];
                self.navigationItem.rightBarButtonItem = barButtonSave;
                
            }
        }
        else{
            
            [self cancelActionShipment];
            NSLog(@" REQUEST FAILURE ERROR %@", [(NSError*)object description]);
            if ([(NSError*)object code] == NSURLErrorCancelled) {
                if (_requestcount<kTKPDREQUESTCOUNTMAX) {
                    NSLog(@" ==== REQUESTCOUNT %zd =====",_requestcount);
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

-(void)cancelActionShipment
{
    [_requestActionShipment cancel];
    _requestActionShipment = nil;
    [_objectmanagerActionShipment.operationQueue cancelAllOperations];
    _objectmanagerActionShipment = nil;
}


#pragma mark - Methods
-(void)refreshView:(UIRefreshControl*)refresh
{
    [self cancel];
    
    _requestcount = 0;
    _isrefreshview = YES;
    
    [self.tableView reloadData];
    [self configureRestKit];
    [self request];
}

-(void)cancel
{
    [_objectmanager.operationQueue cancelAllOperations];
    _objectmanager = nil;
}

- (void)backButtonTap:(UIBarButtonItem *)button
{
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"Description"]) {
        UITableViewCell *cell = (UITableViewCell *)sender;
        NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
        ShippingInfoShipments *shipment = [_shipments objectAtIndex:indexPath.section];
        MyShopShipmentInfoViewController *infoViewController = (MyShopShipmentInfoViewController *)segue.destinationViewController;
        infoViewController.shipment_packages = shipment.shipment_package;
    }
}

@end