//
//  MyShopPaymentViewController.m
//  Tokopedia
//
//  Created by IT Tkpd on 11/18/14.
//  Copyright (c) 2014 TOKOPEDIA. All rights reserved.
//
#import "AddShop.h"
#import "AddShopResult.h"
#import "BerhasilBukaTokoViewController.h"
#import "CreateShopViewController.h"
#import "detail.h"
#import "SettingPayment.h"
#import "ShopSettings.h"
#import "MyShopShipmentTableViewController.h"
#import "MyShopPaymentViewController.h"
#import "MyShopPaymentCell.h"
#import "MoreViewController.h"
#import "OpenShopPictureResult.h"
#import "OpenShopPicture.h"
#import "URLCacheController.h"
#import "Upload.h"
#import "RequestUploadImage.h"
#import "RequestGenerateHost.h"
#import "ShippingInfoShipmentPackage.h"
#import "ShippingInfoShipments.h"
#import "ShippingInfoResult.h"
#import "string_create_shop.h"
#import "string_more.h"
#import "StickyAlertView.h"
#import "TokopediaNetworkManager.h"

#define CTagOpenShop 11
#define CTagOpenShopPicture 12
#define CTagOpenShopValidation 13
#define CTagOpenShopSubmit 14

#pragma mark - Setting Payment View Controller
@interface MyShopPaymentViewController ()
<
    UITableViewDataSource,UITableViewDelegate,
    MyShopPaymentCellDelegate,
    TokopediaNetworkManagerDelegate,
    RequestUploadImageDelegate,
    GenerateHostDelegate
>
{
    SettingPayment *_payment;
    BOOL _isnodata;
    NSArray *_list;
    NSMutableDictionary *_datainput;
    NSInteger _requestcount;
    NSTimer *_timer;
    
    BOOL _isrefreshview;
    UIRefreshControl *_refreshControl;
    
    __weak RKObjectManager *_objectmanager;
    __weak RKManagedObjectRequestOperation *_request;
    
    __weak RKObjectManager *_objectmanagerActionPayment;
    __weak RKManagedObjectRequestOperation *_requestActionPayment;
    
    NSOperationQueue *_operationQueue;
    
    NSString *_cachepath, *filePath, *strPostKey, *strFileUploaded;
    URLCacheController *_cachecontroller;
    URLCacheConnection *_cacheconnection;
    NSTimeInterval _timeinterval;
    
    RequestUploadImage *uploadImageRequest;
    RKObjectManager *objectOpenShop, *objectOpenShopPicture;
    GenerateHost *_generateHost;
    TokopediaNetworkManager *tokopediaNetworkManager, *tokopediaNetworkManagerOpenShopPict, *tokopediaNetworkManagerOpenShopVal, *tokopediaNetworkMangerOpenShopSubmit;
    UIBarButtonItem *btnLanjut;
    UIActivityIndicatorView *activityIndicator;
}

@property (weak, nonatomic) IBOutlet UITableView *table;
@property (strong, nonatomic) IBOutlet UIView *noteView;
@property (strong, nonatomic) IBOutlet UIView *footerView;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *act;
@property (strong, nonatomic) IBOutlet UIView *headerview;

-(void)cancel;
-(void)configureRestKit;
-(void)request;
-(void)requestsuccess:(id)object withOperation:(RKObjectRequestOperation*)operation;
-(void)requestfailure:(id)object;
-(void)requestprocess:(id)object;
-(void)requesttimeout;

- (IBAction)tap:(id)sender;
@end

@implementation MyShopPaymentViewController
@synthesize myShopShipmentTableViewController, arrDataPayment;
#pragma mark - Initialization
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        _isnodata = YES;
        _isrefreshview = NO;
        self.title = kTKPTITLE_PAYMENT;
        
    }
    return self;
}

#pragma mark - View Lifecycle
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.title = @"Pembayaran";
    
    _list = [NSArray new];
    
    _cacheconnection = [URLCacheConnection new];
    _cachecontroller = [URLCacheController new];
    _operationQueue = [NSOperationQueue new];
    
    //cache
    NSDictionary *auth = [_data objectForKey:kTKPD_AUTHKEY];
    NSString *path = [[NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) lastObject]stringByAppendingPathComponent:kTKPDDETAILSHOP_CACHEFILEPATH];
    _cachepath = [path stringByAppendingPathComponent:[NSString stringWithFormat:kTKPDDETAILSHOPPAYMENT_APIRESPONSEFILEFORMAT,[[auth objectForKey:kTKPDDETAIL_APISHOPIDKEY] integerValue]]];
    _cachecontroller.filePath = _cachepath;
    _cachecontroller.URLCacheInterval = 86400.0;
	[_cachecontroller initCacheWithDocumentPath:path];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    if(myShopShipmentTableViewController == nil)
    {
		[self configureRestKit]; 
		[self request];
    }
    else
    {
        btnLanjut = [[UIBarButtonItem alloc] initWithTitle:CStringLanjut style:UIBarButtonItemStylePlain target:self action:@selector(lanjut:)];
        self.navigationItem.rightBarButtonItem = btnLanjut;
        _list = [arrDataPayment mutableCopy];
        if(_list!=nil && _list.count>0)
            _isnodata = NO;
    }
    self.table.contentOffset = CGPointMake(0, 0);
    self.table.contentInset = UIEdgeInsetsMake(-36, 0, 0, 0);
}

-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [self cancel];
}

-(void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
}

#pragma mark - Memory Management
-(void)dealloc{
    NSLog(@"%@ : %@",[self class], NSStringFromSelector(_cmd));
    [tokopediaNetworkManager requestCancel];
    tokopediaNetworkManager.delegate = nil;
    tokopediaNetworkManager = nil;
    
    uploadImageRequest.delegate = nil;
    [uploadImageRequest cancelActionUploadPhoto];
    uploadImageRequest = nil;
    
    
    [tokopediaNetworkManagerOpenShopPict requestCancel];
    tokopediaNetworkManagerOpenShopPict.delegate = nil;
    tokopediaNetworkManagerOpenShopPict = nil;
}

#pragma mark - Table View Data Source
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
#ifdef kTKPDHOTLISTRESULT_NODATAENABLE
    return _isnodata?1:_list.count;
#else
    return _isnodata?0:_list.count;
#endif
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    UITableViewCell* cell = nil;
    if (!_isnodata) {
        
        NSString *cellid = kTKPDMYSHOPPAYMENTCELL_IDENTIFIER;
		
		cell = (MyShopPaymentCell*)[tableView dequeueReusableCellWithIdentifier:cellid];
		if (cell == nil) {
			cell = [MyShopPaymentCell newcell];
			((MyShopPaymentCell*)cell).delegate = self;
		}
        
        if (_list.count > indexPath.row) {
            Payment *payment = _list[indexPath.row];
            
            NSMutableParagraphStyle *style = [[NSMutableParagraphStyle alloc] init];
            style.alignment = NSTextAlignmentCenter;
            style.lineSpacing = 6.0;

            NSDictionary *titleAttributes = @{
                NSFontAttributeName            : [UIFont fontWithName:@"GothamMedium" size:14],
                NSParagraphStyleAttributeName  : style,
            };

            NSDictionary *textAttributes = @{
                NSFontAttributeName            : [UIFont fontWithName:@"GothamBook" size:14],
                NSParagraphStyleAttributeName  : style,
            };
            
            ((MyShopPaymentCell*)cell).nameLabel.attributedText = [[NSAttributedString alloc] initWithString:payment.payment_name
                                                                                                  attributes:titleAttributes];
            
            NSString *description = [NSString convertHTML:payment.payment_info];
            ((MyShopPaymentCell*)cell).descriptionLabel.attributedText = [[NSAttributedString alloc] initWithString:description
                                                                                                         attributes:textAttributes];
            [((MyShopPaymentCell*)cell).descriptionLabel sizeToFit];
            
            ((MyShopPaymentCell*)cell).indexPath = indexPath;
            
            NSURL *url = [NSURL URLWithString:payment.payment_image];
            NSURLRequest* request = [[NSURLRequest alloc] initWithURL:url
                                                          cachePolicy:NSURLRequestUseProtocolCachePolicy
                                                      timeoutInterval:kTKPDREQUEST_TIMEOUTINTERVAL];
            
            UIImageView *thumb = ((MyShopPaymentCell*)cell).thumbnailImageView;
            thumb.image = nil;
            
            [thumb setImageWithURLRequest:request placeholderImage:nil
                                  success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-retain-cycles"
                //NSLOG(@"thumb: %@", thumb);
                [thumb setImage:image];
#pragma clang diagnosti c pop
            } failure:nil];
        }
        
		return cell;
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
    
    // Remove seperator inset
    if ([cell respondsToSelector:@selector(setSeparatorInset:)]) {
        [cell setSeparatorInset:UIEdgeInsetsZero];
    }
    
    // Prevent the cell from inheriting the Table View's margin settings
    if ([cell respondsToSelector:@selector(setPreservesSuperviewLayoutMargins:)]) {
        [cell setPreservesSuperviewLayoutMargins:NO];
    }
    
    // Explictly set your cell's layout margins
    if ([cell respondsToSelector:@selector(setLayoutMargins:)]) {
        [cell setLayoutMargins:UIEdgeInsetsZero];
    }
}
#pragma mark - View Action
- (void)isLoading:(BOOL)isLoading
{
    if(isLoading)
    {
        if(activityIndicator == nil)
        {
            activityIndicator = [[UIActivityIndicatorView alloc] initWithFrame:CGRectMake(0, 0, 40, 40)];
            activityIndicator.color = [UIColor whiteColor];
        }
        [activityIndicator startAnimating];
        self.navigationItem.rightBarButtonItem.customView = activityIndicator;
    }
    else
    {
        self.navigationItem.rightBarButtonItem.customView = nil;
        self.navigationItem.rightBarButtonItem = btnLanjut;
        [activityIndicator stopAnimating];
    }
}

- (void)lanjut:(id)sender
{
    [self isLoading:YES];
    
    if([myShopShipmentTableViewController.createShopViewController getDictContentPhoto] != nil) {
        RequestGenerateHost *requestHost = [RequestGenerateHost new];
        [requestHost configureRestkitGenerateHost];
        [requestHost requestGenerateHost];
        requestHost.delegate = self;
    }
    else {
        strFileUploaded = strFileUploaded = filePath = @"";
        [[self getNetworkManager:CTagOpenShopValidation] doRequest];
    }
}

- (IBAction)tap:(id)sender {
    if ([sender isKindOfClass:[UIBarButtonItem class]]) {
        [self.navigationController popViewControllerAnimated:YES];
    }
}

#pragma mark - Request and Mapping
-(void)cancel
{
    [_request cancel];
    _request = nil;
    [_objectmanager.operationQueue cancelAllOperations];
    _objectmanager = nil;
}

- (void)configureRestKit
{
    // initialize RestKit
    _objectmanager =  [RKObjectManager sharedClient];
    
    // setup object mappings
    RKObjectMapping *statusMapping = [RKObjectMapping mappingForClass:[SettingPayment class]];
    [statusMapping addAttributeMappingsFromDictionary:@{kTKPD_APISTATUSKEY:kTKPD_APISTATUSKEY,
                                                        kTKPD_APISERVERPROCESSTIMEKEY:kTKPD_APISERVERPROCESSTIMEKEY,
                                                        kTKPD_APIERRORMESSAGEKEY : kTKPD_APIERRORMESSAGEKEY,
                                                        kTKPD_APISTATUSMESSAGEKEY:kTKPD_APISTATUSMESSAGEKEY
                                                        }];
    
    RKObjectMapping *resultMapping = [RKObjectMapping mappingForClass:[SettingPaymentResult class]];
    [resultMapping addAttributeMappingsFromArray:@[
                                                   kTKPDDETAILSHOP_APIPAYMENTLOCKEY,
                                                   kTKPDDETAILSHOP_APIPAYMENTNOTEKEY
                                                   ]];
    
    RKObjectMapping *listMapping = [RKObjectMapping mappingForClass:[Payment class]];
    [listMapping addAttributeMappingsFromArray:@[kTKPDDETAILSHOP_APIPAYMENTKEY,
                                                 kTKPDDETAILSHOP_APIPAYMENTIMAGEKEY,
                                                 kTKPDDETAILSHOP_APIPAYMENTIDKEY,
                                                 kTKPDDETAILSHOP_APIPAYMENTNAMEKEY,
                                                 kTKPDDETAILSHOP_APIPAYMENTINFOKEY,
                                                 kTKPDDETAILSHOP_APIPAYMENTDEFAULTSTATUSKEY
                                                 ]];
    
    //add relationship mapping
    [statusMapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:kTKPD_APIRESULTKEY
                                                                                  toKeyPath:kTKPD_APIRESULTKEY
                                                                                withMapping:resultMapping]];
    
    RKRelationshipMapping *listRel = [RKRelationshipMapping relationshipMappingFromKeyPath:kTKPDDETAILSHOP_APIPAYMENTOPTIONKEY
                                                                                 toKeyPath:kTKPDDETAILSHOP_APIPAYMENTOPTIONKEY
                                                                               withMapping:listMapping];
    [resultMapping addPropertyMapping:listRel];
    
    
    // register mappings with the provider using a response descriptor
    RKResponseDescriptor *responseDescriptorStatus = [RKResponseDescriptor responseDescriptorWithMapping:statusMapping
                                                                                                  method:RKRequestMethodPOST
                                                                                             pathPattern:kTKPDDETAILSHOPPAYMENT_APIPATH
                                                                                                 keyPath:@""
                                                                                             statusCodes:kTkpdIndexSetStatusCodeOK];
    
    [_objectmanager addResponseDescriptor:responseDescriptorStatus];
}

- (void)request
{
    if (_request.isExecuting) return;
    
    _requestcount++;
    
    _table.tableFooterView = _footerView;
    [_act startAnimating];

    NSDictionary* auth = [_data objectForKey:kTKPD_AUTHKEY];
    
	NSDictionary* param = @{
                            kTKPDDETAIL_APIACTIONKEY : kTKPDDETAIL_APIGETPAYMENTINFOKEY,
                            kTKPDDETAIL_APISHOPIDKEY : [auth objectForKey:kTKPD_SHOPIDKEY]?:@(0),
                            };
    
    [_cachecontroller getFileModificationDate];
	_timeinterval = fabs([_cachecontroller.fileDate timeIntervalSinceNow]);
    
    _request = [_objectmanager appropriateObjectRequestOperationWithObject:self
                                                                    method:RKRequestMethodPOST
                                                                      path:kTKPDDETAILSHOPPAYMENT_APIPATH
                                                                parameters:[param encrypt]];
    
    [_request setCompletionBlockWithSuccess:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
        [_timer invalidate];
        _timer = nil;
        _table.hidden = NO;
        _act.hidden = YES;
        _isrefreshview = NO;
        [_refreshControl endRefreshing];
        [_act stopAnimating];
        [self requestsuccess:mappingResult withOperation:operation];
    } failure:^(RKObjectRequestOperation *operation, NSError *error) {
        /** failure **/
        [_timer invalidate];
        _timer = nil;
        _isrefreshview = NO;
        [_refreshControl endRefreshing];
        [_act stopAnimating];
        [self requestfailure:error];
    }];
    [_operationQueue addOperation:_request];
    
    _timer = [NSTimer scheduledTimerWithTimeInterval:kTKPDREQUEST_TIMEOUTINTERVAL
                                              target:self
                                            selector:@selector(requesttimeout)
                                            userInfo:nil
                                             repeats:NO];
    
    [[NSRunLoop currentRunLoop] addTimer:_timer forMode:NSRunLoopCommonModes];
}

-(void)requestsuccess:(id)object withOperation:(RKObjectRequestOperation *)operation
{
    NSDictionary *result = ((RKMappingResult*)object).dictionary;
    id stats = [result objectForKey:@""];
    _payment = stats;
    BOOL status = [_payment.status isEqualToString:kTKPDREQUEST_OKSTATUS];
    
    if (status && _payment.result) {
        [_cacheconnection connection:operation.HTTPRequestOperation.request didReceiveResponse:operation.HTTPRequestOperation.response];
        [_cachecontroller connectionDidFinish:_cacheconnection];
        //save response data
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
            _payment = stats;
            BOOL status = [_payment.status isEqualToString:kTKPDREQUEST_OKSTATUS];
            
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
            
            _payment = stats;
            BOOL status = [_payment.status isEqualToString:kTKPDREQUEST_OKSTATUS];
            
            if (status) {
                for (Payment *payment in _payment.result.payment_options) {
                    if ([_payment.result.loc objectForKey:payment.payment_id]) {
                        payment.payment_info = [_payment.result.loc objectForKey:payment.payment_id];
                    }
                }
                
                NSString *notes = @"Pilihan Pembayaran yang ingin Anda berikan kepada pengunjung Toko Online Anda.";
                for (NSString *note in _payment.result.note) {
                    notes = [NSString stringWithFormat:@"%@\n\n%@", notes, note];
                }

                NSMutableParagraphStyle *style = [[NSMutableParagraphStyle alloc] init];
                style.lineSpacing = 4.0;
                
                NSDictionary *attributes = @{
                                             NSFontAttributeName            : [UIFont fontWithName:@"GothamBook" size:14],
                                             NSParagraphStyleAttributeName  : style,
                                             NSForegroundColorAttributeName : [UIColor colorWithRed:117.0/255.0
                                                                                              green:117.0/255.0
                                                                                               blue:117.0/255.0
                                                                                              alpha:1],
                                             };
                
                UILabel *label = (UILabel *)[_noteView viewWithTag:1];
                label.attributedText = [[NSAttributedString alloc] initWithString:notes
                                                                             attributes:attributes];
                [label sizeToFit];
                
                self.table.contentInset = UIEdgeInsetsMake(-36, 0, label.frame.size.height, 0);
                
                _table.tableFooterView = _noteView;
                
                _list = _payment.result.payment_options;
                _isnodata = NO;
                
                [_table reloadData];
            }
        }
        else{
            [self cancel];
            NSLog(@" REQUEST FAILURE ERROR %@", [(NSError*)object description]);
            if ([(NSError*)object code] == NSURLErrorCancelled) {
                if (_requestcount<kTKPDREQUESTCOUNTMAX) {
                    NSLog(@" ==== REQUESTCOUNT %zd =====",_requestcount);
                    //_table.tableFooterView = _footer;
                    [_act startAnimating];
                    [self performSelector:@selector(configureRestKit) withObject:nil afterDelay:kTKPDREQUEST_DELAYINTERVAL];
                    [self performSelector:@selector(request) withObject:nil afterDelay:kTKPDREQUEST_DELAYINTERVAL];
                }
                else
                {
                    [_act stopAnimating];
                    _table.tableFooterView = nil;
                }
            }
            else
            {
                [_act stopAnimating];
                _table.tableFooterView = nil;
            }
        }
    }
}

-(void)requesttimeout
{
    [self cancel];
}

#pragma mark - Request Action Payment
-(void)cancelActionPayment
{
    [_requestActionPayment cancel];
    _requestActionPayment = nil;
    [_objectmanagerActionPayment.operationQueue cancelAllOperations];
    _objectmanagerActionPayment = nil;
}

-(void)configureRestKitActionPayment
{
    _objectmanagerActionPayment = [RKObjectManager sharedClient];
    
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
    RKResponseDescriptor *responseDescriptor = [RKResponseDescriptor responseDescriptorWithMapping:statusMapping method:RKRequestMethodPOST pathPattern:kTKPDDETAILSHOPEDITORACTION_APIPATH keyPath:@"" statusCodes:kTkpdIndexSetStatusCodeOK];
    
    [_objectmanagerActionPayment addResponseDescriptor:responseDescriptor];
    
}

-(void)requestActionPayment:(id)object
{
    if (_requestActionPayment.isExecuting) return;

    NSTimer *timer;
    
    NSString *action = kTKPDDETAIL_APIUPDATEPAYMENTINFOKEY;
    
    NSDictionary* param = @{kTKPDDETAIL_APIACTIONKEY:action,};
    _requestcount ++;
    
    _requestActionPayment = [_objectmanagerActionPayment appropriateObjectRequestOperationWithObject:self method:RKRequestMethodPOST path:kTKPDDETAILSHOPEDITORACTION_APIPATH parameters:[param encrypt]];
    
    [_requestActionPayment setCompletionBlockWithSuccess:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
        [self requestSuccessActionPayment:mappingResult withOperation:operation];
        [timer invalidate];
    } failure:^(RKObjectRequestOperation *operation, NSError *error) {
        [self requestFailureActionPayment:error];
        [timer invalidate];
    }];
    
    [_operationQueue addOperation:_requestActionPayment];
    
    timer= [NSTimer scheduledTimerWithTimeInterval:kTKPDREQUEST_TIMEOUTINTERVAL target:self selector:@selector(requestTimeoutActionPayment) userInfo:nil repeats:NO];
    [[NSRunLoop currentRunLoop] addTimer:timer forMode:NSRunLoopCommonModes];
}

-(void)requestSuccessActionPayment:(id)object withOperation:(RKObjectRequestOperation *)operation
{
    NSDictionary *result = ((RKMappingResult*)object).dictionary;
    id stat = [result objectForKey:@""];
    ShopSettings *setting = stat;
    BOOL status = [setting.status isEqualToString:kTKPDREQUEST_OKSTATUS];
    
    if (status) {
        [self requestProcessActionPayment:object];
    }
}

-(void)requestFailureActionPayment:(id)object
{
    [self requestProcessActionPayment:object];
}

-(void)requestProcessActionPayment:(id)object
{
    if (object) {
        if ([object isKindOfClass:[RKMappingResult class]]) {
            NSDictionary *result = ((RKMappingResult*)object).dictionary;
            id stat = [result objectForKey:@""];
            ShopSettings *setting = stat;
            BOOL status = [setting.status isEqualToString:kTKPDREQUEST_OKSTATUS];
            
            if (status) {
                if (!setting.message_error) {
                    if (setting.result.is_success == 1) {
                    }
                }
                if (setting.message_status) {
                    NSArray *array = setting.message_status;//[[NSArray alloc] initWithObjects:KTKPDMESSAGE_DELIVERED, nil];
                    StickyAlertView *stickyAlertView = [[StickyAlertView alloc] initWithSuccessMessages:array delegate:self];
                    [stickyAlertView show];
                }
                else if(setting.message_error)
                {
                    NSArray *array = setting.message_error;//[[NSArray alloc] initWithObjects:KTKPDMESSAGE_UNDELIVERED, nil];
                    StickyAlertView *alert = [[StickyAlertView alloc] initWithErrorMessages:array delegate:self];
                    [alert show];
                }
                
            }
        }
        else{
            
            [self cancelActionPayment];
            NSLog(@" REQUEST FAILURE ERROR %@", [(NSError*)object description]);
            if ([(NSError*)object code] == NSURLErrorCancelled) {
                if (_requestcount<kTKPDREQUESTCOUNTMAX) {
                    NSLog(@" ==== REQUESTCOUNT %zd =====",_requestcount);
                    //TODO:: Reload handler
                }
            }
        }
    }
}

-(void)requestTimeoutActionPayment
{
    [self cancelActionPayment];
}


#pragma mark - Cell Delegate
-(void)MyShopPaymentCell:(UITableViewCell *)cell withindexpath:(NSIndexPath *)indexpath
{
    Payment *payment = _list[indexpath.row];
    NSString *link = [NSString getLinkFromHTMLString:payment.payment_info];
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:link]];
}



- (TokopediaNetworkManager *)getNetworkManager:(int)tag
{
    if(tag == CTagOpenShop) {
        if(tokopediaNetworkManager == nil) {
            tokopediaNetworkManager = [TokopediaNetworkManager new];
            tokopediaNetworkManager.delegate = self;
            tokopediaNetworkManager.tagRequest = tag;
        }

        return tokopediaNetworkManager;
    }
    else if(tag == CTagOpenShopPicture) {
        if(tokopediaNetworkManagerOpenShopPict == nil) {
            tokopediaNetworkManagerOpenShopPict = [TokopediaNetworkManager new];
            tokopediaNetworkManagerOpenShopPict.delegate = self;
            tokopediaNetworkManagerOpenShopPict.tagRequest = tag;
        }
        
        return tokopediaNetworkManagerOpenShopPict;
    }
    else if(tag == CTagOpenShopValidation) {
        if(tokopediaNetworkManagerOpenShopVal == nil) {
            tokopediaNetworkManagerOpenShopVal = [TokopediaNetworkManager new];
            tokopediaNetworkManagerOpenShopVal.tagRequest = tag;
            tokopediaNetworkManagerOpenShopVal.delegate = self;
        }
        
        return tokopediaNetworkManagerOpenShopVal;
    }
    else if(tag == CTagOpenShopSubmit) {
        if(tokopediaNetworkMangerOpenShopSubmit == nil) {
            tokopediaNetworkMangerOpenShopSubmit = [TokopediaNetworkManager new];
            tokopediaNetworkMangerOpenShopSubmit.delegate = self;
            tokopediaNetworkMangerOpenShopSubmit.tagRequest = tag;
        }
        
        return tokopediaNetworkMangerOpenShopSubmit;
    }
    
    return nil;
}


#pragma mark - Method
- (void)successCreateShop:(AddShop *)addShop {
    TKPDSecureStorage* secureStorage = [TKPDSecureStorage standardKeyChains];
    if(secureStorage != nil)
    {
        [secureStorage setKeychainWithValue:addShop.result.shop_id withKey:kTKPD_SHOPIDKEY];
        [secureStorage setKeychainWithValue:[myShopShipmentTableViewController.createShopViewController getNamaToko] withKey:kTKPD_SHOPNAMEKEY];
        [secureStorage setKeychainWithValue:addShop.result.shop_url withKey:kTKPD_SHOPIMAGEKEY];
        [secureStorage setKeychainWithValue:@(0) withKey:kTKPD_SHOPISGOLD];
        [myShopShipmentTableViewController.createShopViewController.moreViewController updateKeyChain];
    }
    
    strFileUploaded = filePath = strPostKey = nil;
    [self isLoading:NO];
    
    NSDictionary *tempDict = [NSDictionary dictionaryWithObjectsAndKeys:[myShopShipmentTableViewController.createShopViewController getNamaToko], kTKPD_SHOPNAMEKEY, addShop.result.shop_url, kTKPD_SHOPURL, nil];
    
    BerhasilBukaTokoViewController *berhasilBukaTokoViewController = [BerhasilBukaTokoViewController new];
    berhasilBukaTokoViewController.dictData = tempDict;
    [self.navigationController pushViewController:berhasilBukaTokoViewController animated:YES];
}

- (void)failedCreateShop {
    StickyAlertView *stickyAlertView = [[StickyAlertView alloc] initWithErrorMessages:@[CStringFailedCreateShop] delegate:self];
    [stickyAlertView show];
    [self isLoading:NO];
}

- (void)setParameterOpenShop:(NSMutableDictionary *)param {
    [param setObject:[myShopShipmentTableViewController.createShopViewController getNamaDomain] forKey:kTKPDDETAILPRODUCT_APISHOPDOMAINKEY];
    [param setObject:filePath==nil?@"":filePath forKey:kTKPD_SHOP_LOGO];
    [param setObject:[myShopShipmentTableViewController.createShopViewController getNamaToko] forKey:kTKPDDETAIL_APISHOPNAMEKEY];
    [param setObject:[myShopShipmentTableViewController.createShopViewController getDesc] forKey:kTKPD_SHOP_SHORT_DESC];
    [param setObject:[myShopShipmentTableViewController.createShopViewController getSlogan] forKey:kTKPD_SHOP_TAG_LINE];
    [param setObject:[NSString stringWithFormat:@"%d", [myShopShipmentTableViewController getCourirOrigin]] forKey:kTKPD_SHOP_COURIER_ORIGIN];
    [param setObject:[myShopShipmentTableViewController getPostalCode] forKey:kTKPD_SHOP_POSTAL];
    [param setObject:@"" forKey:kTKPDSHOPSHIPMENT_APIRPXPACKETKEY];
    [param setObject:@"" forKey:kTKPDSHOPSHIPMENT_APIRPXTICKETKEY];
    
    //Set Shipping ID
    NSMutableDictionary *shipments = [NSMutableDictionary new];
    NSMutableDictionary *jne = [NSMutableDictionary new];
    if ([[myShopShipmentTableViewController getAvailShipment] containsObject:[myShopShipmentTableViewController getJne].shipment_id]) {
        [param setObject:[myShopShipmentTableViewController getShipment].jne.jne_diff_district forKey:kTKPDSHOPSHIPMENT_APIDIFFDISTRICTKEY];
        [param setObject:[myShopShipmentTableViewController getJneExtraFeeTextField]?@"1":@"0" forKey:kTKPDSHOPSHIPMENT_APIJNEFEEKEY];
        [param setObject:[NSString stringWithFormat:@"%ld", [myShopShipmentTableViewController getShipment].jne.jne_fee] forKey:kTKPDSHOPSHIPMENT_APIJNEFEEVALUEKEY];
        [param setObject:[myShopShipmentTableViewController getJneMinWeightTextField]?@"1":@"0" forKey:kTKPDSHOPSHIPMENT_APIMINWEIGHTKEY];
        [param setObject:[myShopShipmentTableViewController getShipment].jne.jne_min_weight forKey:kTKPDSHOPSHIPMENT_APIMINWEIGHTVALUEKEY];
        [param setObject:[myShopShipmentTableViewController getShipment].jne.jne_tiket forKey:kTKPDSHOPSHIPMENT_APIJNETICKETKEY];
        
        
        if ([[myShopShipmentTableViewController getJnePackageYes].active boolValue]) {
            [jne setValue:@"1" forKey:[myShopShipmentTableViewController getJnePackageYes].sp_id];
        }
        if ([[myShopShipmentTableViewController getJnePackageReguler].active boolValue]) {
            [jne setValue:@"1" forKey:[myShopShipmentTableViewController getJnePackageReguler].sp_id];
        }
        if ([[myShopShipmentTableViewController getJnePackageOke].active boolValue]) {
            [jne setValue:@"1" forKey:[myShopShipmentTableViewController getJnePackageOke].sp_id];
        }
        
        if ([[jne allValues] count] > 0) {
            [shipments setValue:jne forKey:[myShopShipmentTableViewController getJne].shipment_id];
        }
    }
    
    NSMutableDictionary *tiki = [NSMutableDictionary new];
    if ([[myShopShipmentTableViewController getAvailShipment] containsObject:[myShopShipmentTableViewController getTiki].shipment_id]) {
        [param setObject:[myShopShipmentTableViewController getTikiExtraFee]?@"1":@"0" forKey:kTKPDSHOPSHIPMENT_APITIKIFEEKEY];
        [param setObject:[NSString stringWithFormat:@"%ld", [myShopShipmentTableViewController getShipment].tiki.tiki_fee] forKey:kTKPDSHOPSHIPMENT_APITIKIFEEVALUEKEY];
        
        
        if ([[myShopShipmentTableViewController getTikiPackageRegular].active boolValue]) {
            [tiki setValue:@"1" forKey:[myShopShipmentTableViewController getTikiPackageRegular].sp_id];
        }
        if ([[myShopShipmentTableViewController getTikiPackageOn].active boolValue]) {
            [tiki setValue:@"1" forKey:[myShopShipmentTableViewController getTikiPackageOn].sp_id];
        }
        
        if ([[tiki allValues] count] > 0) {
            [shipments setValue:tiki forKey:[myShopShipmentTableViewController getTiki].shipment_id];
        }
    }
    
    NSMutableDictionary *rpx = [NSMutableDictionary new];
    if ([[myShopShipmentTableViewController getAvailShipment] containsObject:[myShopShipmentTableViewController getRpx].shipment_id]) {
        if ([[myShopShipmentTableViewController getRpxPackageNextDay].active boolValue]) {
            [rpx setValue:@"1" forKey:[myShopShipmentTableViewController getRpxPackageNextDay].sp_id];
        }
        if ([[myShopShipmentTableViewController getRpxPackageEco].active boolValue]) {
            [rpx setValue:@"1" forKey:[myShopShipmentTableViewController getRpxPackageEco].sp_id];
        }
        
        if ([[rpx allValues] count] > 0) {
            [shipments setValue:rpx forKey:[myShopShipmentTableViewController getRpx].shipment_id];
        }
    }
    
    NSMutableDictionary *wahana = [NSMutableDictionary new];
    if ([[myShopShipmentTableViewController getAvailShipment] containsObject:[myShopShipmentTableViewController getWahana].shipment_id]) {
        if ([[myShopShipmentTableViewController getWahanaPackNormal].active boolValue]) {
            [wahana setObject:@"1" forKey:[myShopShipmentTableViewController getWahanaPackNormal].sp_id];
        }
        
        if ([[wahana allValues] count] > 0) {
            [shipments setObject:wahana forKey:[myShopShipmentTableViewController getWahana].shipment_id];
        }
    }
    
    NSMutableDictionary *pos = [NSMutableDictionary new];
    if ([[myShopShipmentTableViewController getAvailShipment] containsObject:[myShopShipmentTableViewController getPosIndo].shipment_id]) {
        [param setObject:[myShopShipmentTableViewController getPosExtraFee]?@"1":@"0" forKey:kTKPDSHOPSHIPMENT_APIPOSFEEKEY];
        [param setObject:[NSString stringWithFormat:@"%ld", [myShopShipmentTableViewController getShipment].pos.pos_fee] forKey:kTKPDSHOPSHIPMENT_APIPOSFEEVALUEKEY];
        [param setObject:[myShopShipmentTableViewController getPosMinWeight]?@"1":@"0" forKey:kTKPDSHOPSHIPMENT_APIPOSMINWEIGHTKEY];
        [param setObject:[NSString stringWithFormat:@"%ld", [myShopShipmentTableViewController getShipment].pos.pos_min_weight] forKey:kTKPDSHOPSHIPMENT_APIPOSMINWEIGHTVALUEKEY];
        
        if ([[myShopShipmentTableViewController getPosPackageKhusus].active boolValue]) {
            [pos setObject:@"1" forKey:[myShopShipmentTableViewController getPosPackageKhusus].sp_id];
        }
        if ([[myShopShipmentTableViewController getPosPackageBiasa].active boolValue]) {
            [pos setObject:@"1" forKey:[myShopShipmentTableViewController getPosPackageBiasa].sp_id];
        }
        if ([[myShopShipmentTableViewController getPosPackageExpress].active boolValue]) {
            [pos setObject:@"1" forKey:[myShopShipmentTableViewController getPosPackageExpress].sp_id];
        }
        
        if ([[pos allValues] count] > 0) {
            [shipments setObject:pos forKey:[myShopShipmentTableViewController getPosIndo].shipment_id];
        }
    }
    
    NSMutableDictionary *cahaya = [NSMutableDictionary new];
    if ([[myShopShipmentTableViewController getAvailShipment] containsObject:[myShopShipmentTableViewController getCahaya].shipment_id]) {
        if ([[myShopShipmentTableViewController getCahayaPackageNormal].active boolValue]) {
            [cahaya setObject:@"1" forKey:[myShopShipmentTableViewController getCahayaPackageNormal].sp_id];
        }
        
        if ([[cahaya allValues] count] > 0) {
            [shipments setObject:cahaya forKey:[myShopShipmentTableViewController getCahaya].shipment_id];
        }
    }
    
    NSMutableDictionary *pandu = [NSMutableDictionary new];
    if ([[myShopShipmentTableViewController getAvailShipment] containsObject:[myShopShipmentTableViewController getPandu].shipment_id]) {
        if ([[myShopShipmentTableViewController getPanduPackageRegular].active boolValue]) {
            [pandu setObject:@"1" forKey:[myShopShipmentTableViewController getPanduPackageRegular].sp_id];
        }
        
        if ([[pandu allValues] count] > 0) {
            [shipments setObject:pandu forKey:[myShopShipmentTableViewController getPandu].shipment_id];
        }
    }
    
    NSData *data = [NSJSONSerialization dataWithJSONObject:shipments options:0 error:nil];
    NSString *shipments_ids = [[NSString alloc] initWithBytes:[data bytes] length:[data length] encoding:NSUTF8StringEncoding];
    [param setObject:shipments_ids forKey:kTKPDSHOPSHIPMENT_APISHIPMENTIDS];
    
    
    NSDictionary *dictPayment = [NSDictionary dictionaryWithObjectsAndKeys:@(1), @"1", @(1), @"4", @(1), @"6", @(1), @"7", @(1), @"8", nil];
    data = [NSJSONSerialization dataWithJSONObject:dictPayment options:0 error:nil];
    NSString *payment_ids = [[NSString alloc] initWithBytes:[data bytes] length:[data length] encoding:NSUTF8StringEncoding];
    [param setObject:payment_ids forKey:kTKPDSHOPSHIPMENT_APIPAYMENTIDS];
}


#pragma mark - TokopediaNetworkManager Delegate
- (NSDictionary*)getParameter:(int)tag
{
    if(tag == CTagOpenShop) {
        NSMutableDictionary *param = [NSMutableDictionary new];
        [param setObject:kTKPD_OPEN_SHOP forKey:kTKPDDETAIL_ACTIONKEY];
        [self setParameterOpenShop:param];
        
        return param;
    }
    else if(tag == CTagOpenShopPicture) {
        TKPDSecureStorage *secureStorage = [TKPDSecureStorage standardKeyChains];
        NSDictionary *tempAuth = [secureStorage keychainDictionary];
        
        //Set Parameter
        NSMutableDictionary *param = [NSMutableDictionary new];
        [param setObject:kTKPD_OPEN_SHOP_PICTURE forKey:kTKPDDETAIL_ACTIONKEY];
        [param setObject:filePath forKey:kTKPD_SHOP_LOGO];
        [param setObject:[[tempAuth objectForKey:kTKPD_USERIDKEY] stringValue] forKey:MORE_USER_ID];
        [param setObject:[myShopShipmentTableViewController.createShopViewController getNamaDomain] forKey:kTKPDDETAILPRODUCT_APISHOPDOMAINKEY];
        [param setObject:_generateHost.result.generated_host.server_id==nil?@"":_generateHost.result.generated_host.server_id forKey:API_SERVER_ID_KEY];
        
        return param;
    }
    else if(tag == CTagOpenShopValidation) {
        NSMutableDictionary *param = [NSMutableDictionary new];
        [param setObject:kTKPD_OPEN_SHOP_VALIDATION forKey:kTKPDDETAIL_ACTIONKEY];
        [self setParameterOpenShop:param];
        
        return param;
    }
    else if(tag == CTagOpenShopSubmit) {
        NSMutableDictionary *param = [NSMutableDictionary new];
        [param setObject:kTKPD_OPEN_SHOP_SUBMIT forKey:kTKPDDETAIL_ACTIONKEY];
        [param setObject:strPostKey forKey:CPostKey];
        
        TKPDSecureStorage *secureStorage = [TKPDSecureStorage standardKeyChains];
        NSDictionary *tempAuth = [secureStorage keychainDictionary];
        [param setObject:[[tempAuth objectForKey:kTKPD_USERIDKEY] stringValue] forKey:MORE_USER_ID];
        [param setObject:strFileUploaded forKey:kTKPD_FILE_UPLOADED];
        
        return param;
    }
    
    return nil;
}

- (NSString*)getPath:(int)tag
{
    if(tag==CTagOpenShop || tag==CTagOpenShopPicture || tag==CTagOpenShopValidation || tag==CTagOpenShopSubmit) {
        return [NSString stringWithFormat:@"action/%@", kTKPMYSHOP_APIPATH];
    }
    
    return nil;
}

- (id)getObjectManager:(int)tag
{
    if(tag==CTagOpenShop || tag==CTagOpenShopValidation || tag==CTagOpenShopSubmit) {
        objectOpenShop =  [RKObjectManager sharedClient];
        RKObjectMapping *statusMapping = [RKObjectMapping mappingForClass:[AddShop class]];
        [statusMapping addAttributeMappingsFromDictionary:@{kTKPD_APISTATUSKEY:kTKPD_APISTATUSKEY,
                                                            kTKPD_APIERRORMESSAGEKEY:kTKPD_APIERRORMESSAGEKEY,
                                                            kTKPD_APISERVERPROCESSTIMEKEY:kTKPD_APISERVERPROCESSTIMEKEY
                                                            }];
        
        RKObjectMapping *resultMapping = [RKObjectMapping mappingForClass:[AddShopResult class]];
        [resultMapping addAttributeMappingsFromDictionary:@{CStatusDomain:CStatusDomain, CShopID:CShopID, CShopURL:CShopURL, CIsSuccess:CIsSuccess, CPostKey:CPostKey}];
        
        
        //relation
        RKRelationshipMapping *resulRel = [RKRelationshipMapping relationshipMappingFromKeyPath:kTKPD_APIRESULTKEY toKeyPath:kTKPD_APIRESULTKEY withMapping:resultMapping];
        [statusMapping addPropertyMapping:resulRel];
        RKResponseDescriptor *responseDescriptorStatus = [RKResponseDescriptor responseDescriptorWithMapping:statusMapping
                                                                                                      method:RKRequestMethodPOST
                                                                                                 pathPattern:[self getPath:tag] keyPath:@""
                                                                                                 statusCodes:kTkpdIndexSetStatusCodeOK];
        
        [objectOpenShop addResponseDescriptor:responseDescriptorStatus];
        
        return objectOpenShop;
    }
    else if(tag == CTagOpenShopPicture) {
        objectOpenShopPicture = [RKObjectManager sharedClient];
        RKObjectMapping *statusMapping = [RKObjectMapping mappingForClass:[OpenShopPicture class]];
        [statusMapping addAttributeMappingsFromDictionary:@{kTKPD_APISTATUSKEY:kTKPD_APISTATUSKEY,
                                                            kTKPD_APIERRORMESSAGEKEY:kTKPD_APIERRORMESSAGEKEY,
                                                            kTKPD_APISERVERPROCESSTIMEKEY:kTKPD_APISERVERPROCESSTIMEKEY
                                                            }];
        
        RKObjectMapping *resultMapping = [RKObjectMapping mappingForClass:[OpenShopPictureResult class]];
        [resultMapping addAttributeMappingsFromDictionary:@{kTKPD_FILE_UPLOADED:kTKPD_FILE_UPLOADED,
                                                            kTKPD_APIISSUCCESSKEY:kTKPD_APIISSUCCESSKEY}];
        
        
        //Relation
        RKRelationshipMapping *resultRel = [RKRelationshipMapping relationshipMappingFromKeyPath:kTKPD_APIRESULTKEY toKeyPath:kTKPD_APIRESULTKEY withMapping:resultMapping];
        [statusMapping addPropertyMapping:resultRel];
        RKResponseDescriptor *responseDescriptorStatus = [RKResponseDescriptor responseDescriptorWithMapping:statusMapping
                                                                                                      method:RKRequestMethodPOST
                                                                                                 pathPattern:[self getPath:tag] keyPath:@""
                                                                                                 statusCodes:kTkpdIndexSetStatusCodeOK];
        [objectOpenShopPicture addResponseDescriptor:responseDescriptorStatus];
        
        return objectOpenShopPicture;
    }
    
    return nil;
}

- (NSString*)getRequestStatus:(id)result withTag:(int)tag
{
    NSDictionary *resultDict = ((RKMappingResult*)result).dictionary;
    id stat = [resultDict objectForKey:@""];

    if(tag==CTagOpenShop || tag==CTagOpenShopValidation || tag==CTagOpenShopSubmit) {
        return ((AddShop *) stat).status;
    }
    else if(tag == CTagOpenShopPicture) {
        return ((OpenShopPicture *) stat).status;
    }
    
    return nil;
}

- (void)actionAfterRequest:(id)successResult withOperation:(RKObjectRequestOperation*)operation withTag:(int)tag
{
    if(tag==CTagOpenShop || tag==CTagOpenShopSubmit) {
        NSDictionary *resultDict = ((RKMappingResult*)successResult).dictionary;
        AddShop *addShop = (AddShop *)[resultDict objectForKey:@""];
        if(addShop.message_error!=nil && addShop.message_error.count>0) {//Failed
            strPostKey = filePath = strFileUploaded = nil;
            StickyAlertView *stickAlert = [[StickyAlertView alloc] initWithErrorMessages:addShop.message_error delegate:self];
            [stickAlert show];
            [self isLoading:NO];
        }
        else if([addShop.result.is_success isEqualToString:@"1"])
        {
            [self successCreateShop:addShop];
        }
        else
        {
            strPostKey = filePath = strFileUploaded = nil;
            [self failedCreateShop];
        }
    }
    else if(tag == CTagOpenShopPicture) {
        NSDictionary *resultDict = ((RKMappingResult*)successResult).dictionary;
        OpenShopPicture *openShopPicture = (OpenShopPicture *)[resultDict objectForKey:@""];
        
        if(openShopPicture.message_error!=nil && openShopPicture.message_error.count>0) {
            StickyAlertView *stickyAleryView = [[StickyAlertView alloc] initWithErrorMessages:openShopPicture.message_error delegate:self];
            [stickyAleryView show];
            [self isLoading:NO];
        }
        else if(openShopPicture.result.file_uploaded == nil) {
            strPostKey = filePath = strFileUploaded = nil;
            [self failedCreateShop];
        }
        else {
            strFileUploaded = openShopPicture.result.file_uploaded;
            [[self getNetworkManager:CTagOpenShopSubmit] doRequest];
        }
    }
    else if(tag == CTagOpenShopValidation) {
        NSDictionary *resultDict = ((RKMappingResult*)successResult).dictionary;
        AddShop *addShop = (AddShop *)[resultDict objectForKey:@""];
        if(addShop.message_error!=nil && addShop.message_error.count>0) {//Failed
            StickyAlertView *stickAlert = [[StickyAlertView alloc] initWithErrorMessages:addShop.message_error delegate:self];
            [stickAlert show];
            [self isLoading:NO];
        }
        else {
            BOOL isError = NO;
            if([myShopShipmentTableViewController.createShopViewController getDictContentPhoto] != nil) {
                if(addShop.result.post_key != nil)
                {
                    strPostKey = addShop.result.post_key;
                    [[self getNetworkManager:CTagOpenShopPicture] doRequest];
                }
                else {
                    isError = YES;
                }
            }
            else {
                if(addShop.result.shop_id != nil) {
                    [self successCreateShop:addShop];
                }
                else {
                    isError = YES;
                }
            }
            
            
            
            
            if(isError) {
                strPostKey = filePath = strFileUploaded = nil;
                [self failedCreateShop];
            }
        }
    }
}

- (void)actionFailAfterRequest:(id)errorResult withTag:(int)tag
{
}

- (void)actionBeforeRequest:(int)tag
{
}

- (void)actionRequestAsync:(int)tag
{
}

- (void)actionAfterFailRequestMaxTries:(int)tag
{
    filePath = strPostKey = strFileUploaded = nil;
    if(tag==CTagOpenShop || tag==CTagOpenShopValidation) {
        [self failedCreateShop];
    }
    else if(tag == CTagOpenShopPicture) {
        [self failedGenerateHost];
    }
    else if(tag == CTagOpenShopSubmit) {
        [self failedCreateShop];
    }
}

#pragma mark - RequestUploadImage delegate
- (void)successUploadObject:(id)object withMappingResult:(UploadImage *)uploadImage
{
    filePath = uploadImage.result.upload.src;
    uploadImageRequest.delegate = nil;
    [uploadImageRequest cancelActionUploadPhoto];
    uploadImageRequest = nil;
    
    //Call Open shop validation
    [[self getNetworkManager:CTagOpenShopValidation] doRequest];
}

- (void)failedUploadObject:(id)object
{
    [self failedGenerateHost];
    uploadImageRequest.delegate = nil;
    [uploadImageRequest cancelActionUploadPhoto];
    uploadImageRequest = nil;
}


#pragma mark - RequestGenerateHost Delegate
- (void)successGenerateHost:(GenerateHost *)generateHost
{
    _generateHost = generateHost;
    uploadImageRequest = [RequestUploadImage new];
    uploadImageRequest.imageObject = [myShopShipmentTableViewController.createShopViewController getDictContentPhoto];
    uploadImageRequest.delegate = self;
    uploadImageRequest.generateHost = _generateHost;
    uploadImageRequest.action = kTKPDDETAIL_APIUPLOADSHOPIMAGEKEY;
    uploadImageRequest.fieldName = API_UPLOAD_SHOP_IMAGE_FORM_FIELD_NAME;
    [uploadImageRequest configureRestkitUploadPhoto];
    [uploadImageRequest requestActionUploadPhoto];
}

- (void)failedGenerateHost
{
    StickyAlertView *stickyAlertView = [[StickyAlertView alloc] initWithErrorMessages:@[CStringFailedUploadImage] delegate:self];
    [stickyAlertView show];
    [self isLoading:NO];
}
@end
