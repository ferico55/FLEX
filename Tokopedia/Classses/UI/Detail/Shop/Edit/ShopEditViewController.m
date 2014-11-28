//
//  ShopEditViewController.m
//  Tokopedia
//
//  Created by IT Tkpd on 11/14/14.
//  Copyright (c) 2014 TOKOPEDIA. All rights reserved.
//

#import "camera.h"
#import "detail.h"

#import "Shop.h"
#import "ShopSettings.h"
#import "GenerateHost.h"
#import "UploadImage.h"

#import "ShopEditViewController.h"
#import "ShopEditStatusViewController.h"
#import "CameraController.h"

#pragma mark - Shop Edit View Controller
@interface ShopEditViewController () <UITextViewDelegate, ShopEditStatusViewControllerDelegate,CameraControllerDelegate>
{
    UITextView *_activetextview;
    
    CGPoint _keyboardPosition;
    CGSize _keyboardSize;
    
    CGRect _containerDefault;
    CGSize _scrollviewContentSize;
    
    NSMutableDictionary *_datainput;
    
    GenerateHost *_generatehost;
    DetailShopResult *_shop;
    ShopSettings *_settings;
    UploadImage *_images;
    
    BOOL _isnodata;
    NSInteger _requestcount;
    
    __weak RKObjectManager *_objectmanager;
    __weak RKManagedObjectRequestOperation *_request;
    
    __weak RKObjectManager *_objectmanagerGenerateHost;
    __weak RKManagedObjectRequestOperation *_requestGenerateHost;
    
    __weak RKObjectManager *_objectmanagerUploadPhoto;
    __weak RKManagedObjectRequestOperation *_requestActionUploadPhoto;
    
    RKResponseDescriptor *_responseDescriptor;
    NSOperationQueue *_operationQueue;
}

@property (weak, nonatomic) IBOutlet UIView *viewmembership;
@property (weak, nonatomic) IBOutlet UILabel *labelmembership;
@property (weak, nonatomic) IBOutlet UILabel *labelregularmembership;
@property (weak, nonatomic) IBOutlet UIView *viewcontent;
@property (weak, nonatomic) IBOutlet UIButton *buttonlearnmore;
@property (weak, nonatomic) IBOutlet UIView *viewotherdesc;
@property (weak, nonatomic) IBOutlet UIImageView *thumb;
@property (weak, nonatomic) IBOutlet UIButton *buttoneditimage;
@property (weak, nonatomic) IBOutlet UILabel *labelshopname;
@property (weak, nonatomic) IBOutlet UITextView *textviewslogan;
@property (weak, nonatomic) IBOutlet UILabel *labelslogancharcount;
@property (weak, nonatomic) IBOutlet UITextView *textviewdesc;
@property (weak, nonatomic) IBOutlet UILabel *labeldesccharcount;
@property (weak, nonatomic) IBOutlet UIButton *buttonshopstatus;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollview;
@property (weak, nonatomic) IBOutlet UILabel *labelsloganplaceholder;
@property (weak, nonatomic) IBOutlet UILabel *labeldeskripsiplaceholder;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *actthumb;

-(void)cancel;
-(void)configureRestKit;
-(void)requestaction:(id)object;
-(void)requestsuccessaction:(id)object withOperation:(RKObjectRequestOperation*)operation;
-(void)requestfailureaction:(id)object;
-(void)requestprocessaction:(id)object;
-(void)requesttimeout;

- (IBAction)tap:(id)sender;
- (IBAction)gesture:(id)sender;

@end

@implementation ShopEditViewController

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
    _operationQueue = [NSOperationQueue new];
    
    UIBarButtonItem *barbutton1;
    NSBundle* bundle = [NSBundle mainBundle];
    //TODO:: Change image
    UIImage *img = [[UIImage alloc] initWithContentsOfFile:[bundle pathForResource:kTKPDIMAGE_ICONBACK ofType:@"png"]];
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7) { // iOS 7
        UIImage * image = [img imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
        barbutton1 = [[UIBarButtonItem alloc] initWithImage:image style:UIBarButtonItemStylePlain target:self action:@selector(tap:)];
    }
    else
        barbutton1 = [[UIBarButtonItem alloc] initWithImage:img style:UIBarButtonItemStylePlain target:self action:@selector(tap:)];
    [barbutton1 setTag:10];
    self.navigationItem.leftBarButtonItem = barbutton1;
    
    barbutton1 = [[UIBarButtonItem alloc] initWithTitle:@"Save" style:UIBarButtonItemStylePlain target:(self) action:@selector(tap:)];
    [barbutton1 setTintColor:[UIColor whiteColor]];
    barbutton1.tag = 11;
    self.navigationItem.rightBarButtonItem = barbutton1;
    
    // register for keyboard notifications
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardDidShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardDidHideNotification object:nil];
    
    _labelsloganplaceholder.hidden = NO;
    _labeldeskripsiplaceholder.hidden = NO;
    
    _shop = [_data objectForKey:kTKPDDETAIL_DATASHOPSKEY];
    
    [self configureRestkitGenerateHost];
    [self requestGenerateHost];
    _buttoneditimage.enabled = NO;
    
    //TODO:: add constraint when landscape
    //NSLayoutConstraint *leftConstraint = [NSLayoutConstraint constraintWithItem:_viewcontent
    //                                                                  attribute:NSLayoutAttributeLeading
    //                                                                  relatedBy:0
    //                                                                     toItem:self.view
    //                                                                  attribute:NSLayoutAttributeLeft
    //                                                                 multiplier:1.0
    //                                                                   constant:0];
    //[self.view addConstraint:leftConstraint];
    //
    //NSLayoutConstraint *rightConstraint = [NSLayoutConstraint constraintWithItem:_viewcontent
    //                                                                   attribute:NSLayoutAttributeTrailing
    //                                                                   relatedBy:0
    //                                                                      toItem:self.view
    //                                                                   attribute:NSLayoutAttributeRight
    //                                                                  multiplier:1.0
    //                                                                    constant:0];
    //[self.view addConstraint:rightConstraint];

}

-(void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    [self setDefaultData:_data];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];

}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    // unregister for keyboard notifications
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardDidShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardDidHideNotification object:nil];
}

// need this for scrollview with autolayout
-(void)viewWillLayoutSubviews
{
    [super viewWillLayoutSubviews];
    _scrollview.contentSize = _viewcontent.frame.size;
}

#pragma mark - Memory Management
- (void)dealloc{
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
    RKObjectMapping *statusMapping = [RKObjectMapping mappingForClass:[ShopSettings class]];
    [statusMapping addAttributeMappingsFromDictionary:@{kTKPD_APISTATUSMESSAGEKEY:kTKPD_APISTATUSMESSAGEKEY,
                                                    kTKPD_APIERRORMESSAGEKEY:kTKPD_APIERRORMESSAGEKEY,
                                                    kTKPD_APISTATUSKEY:kTKPD_APISTATUSKEY,
                                                    kTKPD_APISERVERPROCESSTIMEKEY:kTKPD_APISERVERPROCESSTIMEKEY}];

    RKObjectMapping *resultMapping = [RKObjectMapping mappingForClass:[ShopSettingsResult class]];
    [resultMapping addAttributeMappingsFromDictionary:@{kTKPD_APIISSUCCESSKEY:kTKPD_APIISSUCCESSKEY
                                                    }];

    // Relationship Mapping
    [statusMapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:kTKPD_APIRESULTKEY toKeyPath:kTKPD_APIRESULTKEY withMapping:resultMapping]];

    RKResponseDescriptor *responseDescriptor = [RKResponseDescriptor responseDescriptorWithMapping:statusMapping method:RKRequestMethodGET pathPattern:kTKPDDETAILSHOPEDITORACTION_APIPATH keyPath:@"" statusCodes:kTkpdIndexSetStatusCodeOK];
    
    [_objectmanager addResponseDescriptor:responseDescriptor];
}

- (void)requestaction:(id)object
{
    if (_request.isExecuting) return;
    
    _requestcount++;
    
    NSDictionary *data = (NSDictionary *)object;
    NSString *shopdesc = [data objectForKey:kTKPDSHOPEDIT_APISHORTDESCKEY]?:_shop.info.shop_description?:@"";
    NSString *tagline = [data objectForKey:kTKPDSHOPEDIT_APITAGLINEKEY]?:_shop.info.shop_tagline?:@"";
    NSDate *closeuntil = [data objectForKey:kTKPDSHOPEDIT_APICLOSEUNTILKEY]?:_shop.closed_info.until?:@"";
    NSString *closenote = [data objectForKey:kTKPDSHOPEDIT_APICLOSEDNOTEKEY]?:_shop.closed_info.reason?:@"";
    NSInteger status = [[data objectForKey:kTKPDSHOPEDIT_APISTATUSKEY] integerValue]?:[_shop.is_open integerValue]?:0;

	NSDictionary* param = @{
                            kTKPDDETAIL_APIACTIONKEY : kTKPDDETAIL_APISETSHOPINFOKEY,
                            kTKPDSHOPEDIT_APISHORTDESCKEY: shopdesc,
                            kTKPDSHOPEDIT_APITAGLINEKEY : tagline,
                            kTKPDSHOPEDIT_APISTATUSKEY : @(status),
                            kTKPDSHOPEDIT_APICLOSEUNTILKEY:closeuntil,
                            kTKPDSHOPEDIT_APICLOSEDNOTEKEY: closenote
                            };
    
    _request = [_objectmanager appropriateObjectRequestOperationWithObject:self method:RKRequestMethodGET path:kTKPDDETAILSHOPEDITORACTION_APIPATH parameters:param];

    NSTimer *timer;
    
    //[_act startAnimating];
    
    [_request setCompletionBlockWithSuccess:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
        [timer invalidate];
        //[_act stopAnimating];
        [self requestsuccessaction:mappingResult withOperation:operation];
    } failure:^(RKObjectRequestOperation *operation, NSError *error) {
        /** failure **/
        [timer invalidate];
        //[_act stopAnimating];
        [self requestfailureaction:error];
    }];
    
    [_operationQueue addOperation:_request];
    
    timer = [NSTimer scheduledTimerWithTimeInterval:kTKPDREQUEST_TIMEOUTINTERVAL target:self selector:@selector(requesttimeout) userInfo:nil repeats:NO];
    [[NSRunLoop currentRunLoop] addTimer:timer forMode:NSRunLoopCommonModes];
}

-(void)requestsuccessaction:(id)object withOperation:(RKObjectRequestOperation *)operation
{
    NSDictionary *result = ((RKMappingResult*)object).dictionary;
    id stats = [result objectForKey:@""];
    _settings = stats;
    BOOL status = [_settings.status isEqualToString:kTKPDREQUEST_OKSTATUS];

    if (status) {
        
        [self requestprocessaction:object];
    }
}

-(void)requestfailureaction:(id)object
{
    [self requestprocessaction:object];
}

-(void)requestprocessaction:(id)object
{
    if (object) {
        if ([object isKindOfClass:[RKMappingResult class]]) {
        NSDictionary *result = ((RKMappingResult*)object).dictionary;
        id stats = [result objectForKey:@""];
        _settings = stats;
        BOOL status = [_settings.status isEqualToString:kTKPDREQUEST_OKSTATUS];

        if (status) {
            if (_settings.message_status) {
                NSArray *array = _settings.message_status;//[[NSArray alloc] initWithObjects:KTKPDMESSAGE_DELIVERED, nil];
                NSDictionary *info = [NSDictionary dictionaryWithObjectsAndKeys:array,@"messages", nil];
                [[NSNotificationCenter defaultCenter] postNotificationName:kTKPD_SETUSERSTICKYSUCCESSMESSAGEKEY object:nil userInfo:info];
            }
            else if(_settings.message_error)
            {
                NSArray *array = _settings.message_error;//[[NSArray alloc] initWithObjects:KTKPDMESSAGE_UNDELIVERED, nil];
                NSDictionary *info = [NSDictionary dictionaryWithObjectsAndKeys:array,@"messages", nil];
                [[NSNotificationCenter defaultCenter] postNotificationName:kTKPD_SETUSERSTICKYERRORMESSAGEKEY object:nil userInfo:info];
            }
            if (_settings.result.is_success) {
                //[[NSNotificationCenter defaultCenter] postNotificationName:kTKPD_EDITSHOPPOSTNOTIFICATIONNAMEKEY object:nil userInfo:nil];
            }
        }
        }else{
            [self cancel];
            NSLog(@" REQUEST FAILURE ERROR %@", [(NSError*)object description]);
            if ([(NSError*)object code] == NSURLErrorCancelled) {
                if (_requestcount<kTKPDREQUESTCOUNTMAX) {
                    NSLog(@" ==== REQUESTCOUNT %d =====",_requestcount);
                    //_table.tableFooterView = _footer;
                    //[_act startAnimating];
                    //[self performSelector:@selector(configureRestKit) withObject:nil afterDelay:kTKPDREQUEST_DELAYINTERVAL];
                    //[self performSelector:@selector(request) withObject:nil afterDelay:kTKPDREQUEST_DELAYINTERVAL];
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

#pragma mark Request Generate Host
-(void)configureRestkitGenerateHost
{
    _objectmanagerGenerateHost =  [RKObjectManager sharedClient];
    
    // setup object mappings
    RKObjectMapping *statusMapping = [RKObjectMapping mappingForClass:[GenerateHost class]];
    [statusMapping addAttributeMappingsFromDictionary:@{kTKPD_APIERRORMESSAGEKEY:kTKPD_APIERRORMESSAGEKEY,
                                                        kTKPD_APISTATUSKEY:kTKPD_APISTATUSKEY,
                                                        kTKPD_APISERVERPROCESSTIMEKEY:kTKPD_APISERVERPROCESSTIMEKEY}];
    
    RKObjectMapping *resultMapping = [RKObjectMapping mappingForClass:[GenerateHostResult class]];
    
    RKObjectMapping *generatedhostMapping = [RKObjectMapping mappingForClass:[GeneratedHost class]];
    [generatedhostMapping addAttributeMappingsFromDictionary:@{
                                                               kTKPDGENERATEDHOST_APISERVERIDKEY:kTKPDGENERATEDHOST_APISERVERIDKEY,
                                                               kTKPDGENERATEDHOST_APIUPLOADHOSTKEY:kTKPDGENERATEDHOST_APIUPLOADHOSTKEY,
                                                               kTKPDGENERATEDHOST_APIUSERIDKEY:kTKPDGENERATEDHOST_APIUSERIDKEY
                                                               }];
    // Relationship Mapping
    [statusMapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:kTKPD_APIRESULTKEY toKeyPath:kTKPD_APIRESULTKEY withMapping:resultMapping]];
    [resultMapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:kTKPDGENERATEDHOST_APIGENERATEDHOSTKEY toKeyPath:kTKPDGENERATEDHOST_APIGENERATEDHOSTKEY withMapping:generatedhostMapping]];
    
    RKResponseDescriptor *responseDescriptor = [RKResponseDescriptor responseDescriptorWithMapping:statusMapping method:RKRequestMethodGET pathPattern:kTKPDDETAIL_UPLOADIMAGEAPIPATH keyPath:@"" statusCodes:kTkpdIndexSetStatusCodeOK];
    
    [_objectmanagerGenerateHost addResponseDescriptor:responseDescriptor];
}

-(void)cancelGenerateHost
{
    [_requestGenerateHost cancel];
    _requestGenerateHost = nil;
    
    [_objectmanagerGenerateHost.operationQueue cancelAllOperations];
    _objectmanagerGenerateHost = nil;
}

- (void)requestGenerateHost
{
    if(_requestGenerateHost.isExecuting) return;
    
    _requestcount ++;
    
    NSTimer *timer;
    
	NSDictionary* param = @{
                            kTKPDDETAIL_APIACTIONKEY : kTKPDDETAIL_APIUPLOADGENERATEHOSTKEY
                            };
    
    _requestGenerateHost = [_objectmanagerGenerateHost appropriateObjectRequestOperationWithObject:self method:RKRequestMethodGET path:kTKPDDETAIL_UPLOADIMAGEAPIPATH parameters:param];
    
    [_requestGenerateHost setCompletionBlockWithSuccess:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
        [self requestsuccessGenerateHost:mappingResult withOperation:operation];
        [timer invalidate];
        
    } failure:^(RKObjectRequestOperation *operation, NSError *error) {
        /** failure **/
        [self requestfailureGenerateHost:error];
        [timer invalidate];
    }];
    
    [_operationQueue addOperation:_requestGenerateHost];
    
    timer = [NSTimer scheduledTimerWithTimeInterval:kTKPDREQUEST_TIMEOUTINTERVAL target:self selector:@selector(requesttimeoutGenerateHost) userInfo:nil repeats:NO];
    [[NSRunLoop currentRunLoop] addTimer:timer forMode:NSRunLoopCommonModes];
}


-(void)requestsuccessGenerateHost:(id)object withOperation:(RKObjectRequestOperation*)operation
{
    NSDictionary *result = ((RKMappingResult*)object).dictionary;
    id info = [result objectForKey:@""];
    _generatehost = info;
    NSString *statusstring = _generatehost.status;
    BOOL status = [statusstring isEqualToString:kTKPDREQUEST_OKSTATUS];
    
    if (status) {
        [self requestprocessGenerateHost:object];
    }
}

-(void)requestfailureGenerateHost:(id)object
{
    
}

-(void)requestprocessGenerateHost:(id)object
{
    if (object) {
        if ([object isKindOfClass:[RKMappingResult class]]) {
            NSDictionary *result = ((RKMappingResult*)object).dictionary;
            id info = [result objectForKey:@""];
            _generatehost = info;
            NSString *statusstring = _generatehost.status;
            BOOL status = [statusstring isEqualToString:kTKPDREQUEST_OKSTATUS];
            
            if (status) {
                _buttoneditimage.enabled = YES;
            }
        }
    }
}

-(void)requesttimeoutGenerateHost
{
    [self cancelGenerateHost];
}

#pragma mark Request Action Upload Photo
-(void)configureRestkitUploadPhoto
{
    _objectmanagerUploadPhoto =  [RKObjectManager sharedClient];
    
    // setup object mappings
    RKObjectMapping *statusMapping = [RKObjectMapping mappingForClass:[UploadImage class]];
    [statusMapping addAttributeMappingsFromDictionary:@{kTKPD_APIERRORMESSAGEKEY:kTKPD_APIERRORMESSAGEKEY,
                                                        kTKPD_APISTATUSKEY:kTKPD_APISTATUSKEY,
                                                        kTKPD_APISERVERPROCESSTIMEKEY:kTKPD_APISERVERPROCESSTIMEKEY}];
    
    RKObjectMapping *resultMapping = [RKObjectMapping mappingForClass:[UploadImageResult class]];
    [resultMapping addAttributeMappingsFromDictionary:@{kTKPDSHOPEDIT_APIUPLOADFILEPATHKEY:kTKPDSHOPEDIT_APIUPLOADFILEPATHKEY,
                                                        kTKPDSHOPEDIT_APIUPLOADFILETHUMBKEY:kTKPDSHOPEDIT_APIUPLOADFILETHUMBKEY
                                                        }];
    
    // Relationship Mapping
    [statusMapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:kTKPD_APIRESULTKEY toKeyPath:kTKPD_APIRESULTKEY withMapping:resultMapping]];
    
    RKResponseDescriptor *responseDescriptor = [RKResponseDescriptor responseDescriptorWithMapping:statusMapping method:RKRequestMethodGET pathPattern:kTKPDDETAIL_UPLOADIMAGEAPIPATH keyPath:@"" statusCodes:kTkpdIndexSetStatusCodeOK];
    
    [_objectmanagerUploadPhoto addResponseDescriptor:responseDescriptor];
    
    [_objectmanagerUploadPhoto setAcceptHeaderWithMIMEType:RKMIMETypeJSON];
    [_objectmanagerUploadPhoto setRequestSerializationMIMEType:RKMIMETypeJSON];
}


- (void)cancelActionUploadPhoto
{
	[_requestActionUploadPhoto cancel];
	_requestActionUploadPhoto = nil;
	
    [_objectmanagerUploadPhoto.operationQueue cancelAllOperations];
    _objectmanagerUploadPhoto = nil;
}

- (void)requestActionUploadPhoto:(id)object
{
    
    if (_requestActionUploadPhoto.isExecuting) return;
    
	NSDictionary* userInfo = object;
    
    NSDictionary* camera = [userInfo objectForKey:kTKPDCAMERA_DATACAMERAKEY];
    NSDictionary* photo = [userInfo objectForKey:kTKPDCAMERA_DATAPHOTOKEY];
    
    NSDictionary* param;
    
    param = @{kTKPDDETAIL_APIACTIONKEY:kTKPDDETAIL_APIUPLOADSHOPIMAGEKEY,
              kTKPDSHOPEDIT_APIUSERIDKEY:@(_generatehost.result.generated_host.user_id),
              kTKPDGENERATEDHOST_APISERVERIDKEY :@(_generatehost.result.generated_host.server_id),
              };
    
    NSData* imageData;
    //UIImage *image = [UIImage imageNamed:@"icon_location.png"];
    UIImage* image = [photo objectForKey:kTKPDCAMERA_DATAPHOTOKEY];
    UIGraphicsBeginImageContextWithOptions(kTKPDCAMERA_UPLOADEDIMAGESIZE, NO, image.scale);
    [image drawInRect:kTKPDCAMERA_UPLOADEDIMAGERECT];
    image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    imageData = UIImagePNGRepresentation(image);
    //imageData = UIImageJPEGRepresentation(image,1);
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    
    //Set Params
    [request setHTTPShouldHandleCookies:NO];
    [request setTimeoutInterval:60];
    [request setHTTPMethod:@"POST"];
    
    //Create boundary, it can be anything
    NSString *boundary = @"------VohpleBoundary4QuqLuM1cE5lMwCy";
    
    //set Content-Type in HTTP header
    NSString *contentType = [NSString stringWithFormat:@"multipart/form-data; boundary=%@", boundary];
    [request setValue:contentType forHTTPHeaderField: @"Content-Type"];
    
    //post body
    NSMutableData *body = [NSMutableData data];
    
    //Populate a dictionary with all the regular values you would like to send.?action=upload_profile_image?
    NSMutableDictionary *parameters = [[NSMutableDictionary alloc] init];
    [parameters setValue:kTKPDDETAIL_APIUPLOADSHOPIMAGEKEY forKeyPath:kTKPDDETAIL_APIACTIONKEY];
    [parameters setValue:@(_generatehost.result.generated_host.user_id) forKeyPath:kTKPDSHOPEDIT_APIUSERIDKEY];
    [parameters setValue:@(_generatehost.result.generated_host.server_id) forKeyPath:kTKPDGENERATEDHOST_APISERVERIDKEY];
    
    //add params (all params are strings)
    for (NSString *param in parameters) {
        [body appendData:[[NSString stringWithFormat:@"--%@\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
        [body appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"%@\"\r\n\r\n", param] dataUsingEncoding:NSUTF8StringEncoding]];
        [body appendData:[[NSString stringWithFormat:@"%@\r\n", [parameters objectForKey:param]] dataUsingEncoding:NSUTF8StringEncoding]];
        [body appendData:[[NSString stringWithFormat:@"--%@--\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
    }
    
    //add image data
    [body appendData:[[NSString stringWithFormat:@"--%@\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
    [body appendData:[@"Content-Disposition: attachment; name=\"logo\"; filename=\"icon_location.png\"\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
    [body appendData:[@"Content-Type: application/octet-stream\r\n\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
    [body appendData:[NSData dataWithData:imageData]];
    [body appendData:[@"\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
    
    //Close off the request with the boundary
    [body appendData:[[NSString stringWithFormat:@"--%@--\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
    
    //setting the body of the post to the request
    [request setHTTPBody:body];
    
    NSString *url = @"http://www.tkpdevel-pg.api/ws/action/upload-image.pl";
    
    [request setURL:[NSURL URLWithString:url]];
    
    [NSURLConnection sendAsynchronousRequest:request
                                       queue:[NSOperationQueue mainQueue]
                           completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
                               
                               NSHTTPURLResponse* httpResponse = (NSHTTPURLResponse*)response;
                               
                               NSString *responsestring = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
                               if ([httpResponse statusCode] == 200) {
                                   id parsedData = [RKMIMETypeSerialization objectFromData:data MIMEType:RKMIMETypeJSON error:&error];
                                   if (parsedData == nil && error) {
                                       NSLog(@"parser error");
                                   }
                                   
                                   NSMutableDictionary *mappingsDictionary = [[NSMutableDictionary alloc] init];
                                   for (RKResponseDescriptor *descriptor in _objectmanagerUploadPhoto.responseDescriptors) {
                                       [mappingsDictionary setObject:descriptor.mapping forKey:descriptor.keyPath];
                                   }
                                   
                                   RKMapperOperation *mapper = [[RKMapperOperation alloc] initWithRepresentation:parsedData mappingsDictionary:mappingsDictionary];
                                   NSError *mappingError = nil;
                                   BOOL isMapped = [mapper execute:&mappingError];
                                   if (isMapped && !mappingError) {
                                       NSLog(@"result %@",[mapper mappingResult]);
                                       RKMappingResult *mappingresult = [mapper mappingResult];
                                       NSDictionary *result = mappingresult.dictionary;
                                       id stat = [result objectForKey:@""];
                                       _images = stat;
                                       BOOL status = [_images.status isEqualToString:kTKPDREQUEST_OKSTATUS];
                                       
                                       if (status) {
                                           [self requestProcessUploadPhoto:mappingresult];
                                       }
                                   }
                                   
                               }
                               NSLog(@"%@",responsestring);
                           }];
}

- (void)requestSuccessUploadPhoto:(id)object withOperation:(RKObjectRequestOperation *)operation
{
    NSDictionary *result = ((RKMappingResult*)object).dictionary;
    id info = [result objectForKey:@""];
    _images = info;
    NSString *statusstring = _images.status;
    BOOL status = [statusstring isEqualToString:kTKPDREQUEST_OKSTATUS];
    
    if (status) {
        [self requestProcessUploadPhoto:object];
    }
}

- (void)requestFailureUploadPhoto:(id)object
{
    [self requestProcessUploadPhoto:object];
}

- (void)requestProcessUploadPhoto:(id)object
{
    if (object) {
        if ([object isKindOfClass:[RKMappingResult class]]) {
            NSDictionary *result = ((RKMappingResult*)object).dictionary;
            id info = [result objectForKey:@""];
            _images = info;
            NSString *statusstring = _images.status;
            BOOL status = [statusstring isEqualToString:kTKPDREQUEST_OKSTATUS];
            
            if (status) {
                if (!_images.message_error) {
                    NSURLRequest* request = [[NSURLRequest alloc] initWithURL:[NSURL URLWithString:_images.result.file_th] cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:kTKPDREQUEST_TIMEOUTINTERVAL];
                    //request.URL = url;
                    
                    UIImageView *thumb = _thumb;
                    thumb = [UIImageView circleimageview:thumb];
                    
                    thumb.image = nil;
                    //thumb.hidden = YES;	//@prepareforreuse then @reset
                    
                    [thumb setImageWithURLRequest:request placeholderImage:nil success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-retain-cycles"
                        //NSLOG(@"thumb: %@", thumb);
                        [thumb setImage:image];
#pragma clang diagnostic pop
                        
                    } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) {
                    }];
                    
                    NSDictionary *userinfo = @{kTKPDSHOPEDIT_APIUPLOADFILETHUMBKEY :_images.result.file_th?:@"",
                                               kTKPDSHOPEDIT_APIUPLOADFILEPATHKEY:_images.result.file_path?:@""
                                               };
                    
                    [[NSNotificationCenter defaultCenter] postNotificationName:kTKPD_EDITSHOPPOSTNOTIFICATIONNAMEKEY object:nil userInfo:userinfo];
                }
                else
                {
                    NSLog(@"%@ : %@",NSStringFromSelector(_cmd), _images.message_error);
                }
            }
        }
        else
        {
            //[self performSelector:@selector(configureRestkitProfileForm) withObject:nil afterDelay:kTKPDREQUEST_DELAYINTERVAL];
            //[self performSelector:@selector(requestActionUploadPhoto:) withObject:nil afterDelay:kTKPDREQUEST_DELAYINTERVAL];
        }
    }
}
-(void)requesttimeoutUploadPhoto
{
    [self cancelActionUploadPhoto];
}


#pragma mark - View Action
-(IBAction)tap:(id)sender
{
    [_activetextview resignFirstResponder];
    if ([sender isKindOfClass:[UIBarButtonItem class]]) {
        UIBarButtonItem *btn = (UIBarButtonItem*)sender;
        switch (btn.tag) {
            case 10:
            {
                // back
                [self.navigationController popViewControllerAnimated:YES];
                break;
            }
            case 11:
            {
                //save
                NSMutableArray *message = [NSMutableArray new];
                NSString *shopdesc = [_datainput objectForKey:kTKPDSHOPEDIT_APISHORTDESCKEY]?:_shop.info.shop_description;
                NSString *tagline = [_datainput objectForKey:kTKPDSHOPEDIT_APITAGLINEKEY]?:_shop.info.shop_description;
                
                if (shopdesc && ![shopdesc isEqualToString:@""] &&
                    tagline && ![tagline isEqualToString:@""] //&&
                    ){ //status) {
                    [self configureRestKit];
                    [self requestaction:_datainput];
                }
                else
                {
                    if (!tagline || [tagline isEqualToString:@""]) {
                        [message addObject:@"Slogan harus diisi."];
                    }
                    if (!shopdesc || [shopdesc isEqualToString:@""]) {
                        [message addObject:@"Deskripsi harus diisi."];
                    }
                }
                if (message.count>0) {
                    NSDictionary *info = [NSDictionary dictionaryWithObjectsAndKeys:message ,@"messages", nil];
                    [[NSNotificationCenter defaultCenter] postNotificationName:kTKPD_SETUSERSTICKYERRORMESSAGEKEY object:nil userInfo:info];
                }
                break;
            }
            default:
                break;
        }
    }
    if ([sender isKindOfClass:[UIButton class]]) {
        UIButton *btn = (UIButton *)sender;
        switch (btn.tag) {
            case 10:
            {
                // learn more regular merchant
                break;
            }
            case 11:
            {   //edit thumbnail
                CameraController* c = [CameraController new];
                c.delegate = self;
                //c.data = data;
                UINavigationController *nav = [[UINavigationController alloc]initWithRootViewController:c];
                nav.wantsFullScreenLayout = YES;
                nav.modalPresentationStyle = UIModalPresentationFullScreen;
                nav.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
                [self.navigationController presentViewController:nav animated:YES completion:nil];
                break;
            }
            case 12:
            {
                // adjust shop status
                ShopEditStatusViewController *vc = [ShopEditStatusViewController new];
                vc.data = @{kTKPDDETAIL_DATASTATUSSHOPKEY: _shop.is_open?:@(0)};
                vc.delegate = self;
                [self.navigationController pushViewController:vc animated:YES];
                break;
            }
            default:
                break;
        }
    }
}

- (IBAction)gesture:(id)sender {
    [_activetextview resignFirstResponder];
}

#pragma mark - Methods
-(void)setDefaultData:(NSDictionary*)data
{
    _data = data;
    if (data) {
        _labelshopname.text = _shop.info.shop_name?:@"";
        NSInteger limit = 48;
        NSString *string = _shop.info.shop_tagline;
        _textviewslogan.text = string?:@"";
        if (string) {
            _labelsloganplaceholder.hidden = YES;
            _labelslogancharcount.text = [NSString stringWithFormat:@"%d", limit - _textviewslogan.text.length + (string.length - string.length)];
        }
        else _labelsloganplaceholder.hidden = NO;
        
        limit = 140;
        string = _shop.info.shop_description;
        _textviewdesc.text = string?:@"";
        if (string) {
            _labeldeskripsiplaceholder.hidden = YES;
            _labeldesccharcount.text = [NSString stringWithFormat:@"%d", limit - _textviewslogan.text.length + (string.length - string.length)];
        }
        else _labeldeskripsiplaceholder.hidden = NO;
        
        NSURLRequest* request = [[NSURLRequest alloc] initWithURL:[NSURL URLWithString:_shop.info.shop_avatar] cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:kTKPDREQUEST_TIMEOUTINTERVAL];
        //request.URL = url;
        
        UIImageView *thumb = _thumb;
        thumb.image = nil;
        //thumb.hidden = YES;	//@prepareforreuse then @reset
        
        [_actthumb startAnimating];
        
        [thumb setImageWithURLRequest:request placeholderImage:nil success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-retain-cycles"
            //NSLOG(@"thumb: %@", thumb);
            [thumb setImage:image animated:YES];
            
            [_actthumb stopAnimating];
#pragma clang diagnosti c pop
            
        } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) {
            [_actthumb stopAnimating];
        }];
        
        NSUInteger type = [[_datainput objectForKey:kTKPDSHOPEDIT_APISTATUSKEY]integerValue]?:[_shop.is_open integerValue];
        NSString *status;
        switch (type) {
            case kTKPDDETAIL_DATASTATUSSHOPCLOSED:
                status = @"Tutup";
                break;
            case kTKPDDETAIL_DATASTATUSSHOPOPEN:
                status = @"Buka";
                break;
            case kTKPDDETAIL_DATASTATUSMODERATED:
                status = @"Moderated";
                break;
            default:
                break;
        }
        [_buttonshopstatus setTitle:status forState:UIControlStateNormal];
        
        //TODO:: if gold merchant
        if (!_shop.info.shop_is_gold) {
            CGRect frame = _viewmembership.frame;
            frame.size.height = 90;
            _viewmembership.frame = frame;
            _labelmembership.text = @"Regular Merchant";
            _labelregularmembership.hidden = NO;
            _buttonlearnmore.hidden = NO;
            
            frame = _viewotherdesc.frame;
            frame.origin.y = _viewmembership.frame.origin.y+_viewmembership.frame.size.height;
            _viewotherdesc.frame = frame;
        }
        else
        {
            _labelmembership.text = @"Gold Merchant";
            _labelregularmembership.hidden = YES;
            _buttonlearnmore.hidden = YES;
        }
    }
}

#pragma mark - TextView Delegate
-(BOOL)textViewShouldBeginEditing:(UITextView *)textView{
    [textView resignFirstResponder];
    _activetextview = textView;
    
    if (textView == _textviewslogan) {
        _labelsloganplaceholder.hidden = YES;
    }
    else if (textView == _textviewdesc)
    {
        _labeldeskripsiplaceholder.hidden = YES;
    }
    
    return YES;
}

-(void) textViewDidChange:(UITextView *)textView
{
    if (textView == _textviewslogan) {
        if(_textviewslogan.text.length == 0){
            _labelsloganplaceholder.hidden = NO;
            [_textviewslogan resignFirstResponder];
        }
    }
    else if (textView == _textviewdesc)
    {
        if(_textviewdesc.text.length == 0){
            _labeldeskripsiplaceholder.hidden = NO;
            [_textviewdesc resignFirstResponder];
        }
    }
}

-(BOOL)textViewShouldEndEditing:(UITextView *)textView
{
    
    if (textView == _textviewslogan) {
        if(textView.text.length != 0 && ![textView.text isEqualToString:@""]){
            [_datainput setObject:textView.text forKey:kTKPDSHOPEDIT_APITAGLINEKEY];
        }
    }
    else if (textView == _textviewdesc)
    {
        if(textView.text.length != 0 && ![textView.text isEqualToString:@""]){
            [_datainput setObject:textView.text forKey:kTKPDSHOPEDIT_APISHORTDESCKEY];
        }
    }
    return YES;
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    int limit = 0;
    if (textView == _textviewslogan) {
        limit = 48;
        if (textView.text.length + (text.length - range.length) <= limit) {
            _labelslogancharcount.text = [NSString stringWithFormat:@"%d", limit - (textView.text.length + (text.length - range.length))];
        }
    }
    else if (textView == _textviewdesc)
    {
        limit = 140;
        if (textView.text.length + (text.length - range.length) <= limit) {
            _labeldesccharcount.text = [NSString stringWithFormat:@"%d",limit - (textView.text.length + (text.length - range.length))];
        }
    }
    return textView.text.length + (text.length - range.length) <= limit;
}

#pragma mark - ShopEditStatusViewController Delegate
-(void)ShopEditStatusViewController:(UIViewController *)vc withData:(NSDictionary *)data
{
    [_datainput addEntriesFromDictionary:data];
    [self setDefaultData:_data];
}

#pragma mark - Delegate Camera Controller
-(void)didDismissCameraController:(UIViewController *)controller withUserInfo:(NSDictionary *)userinfo
{
    [self configureRestkitUploadPhoto];
    [self requestActionUploadPhoto:userinfo];
}

#pragma mark - Keyboard Notification
// Called when the UIKeyboardWillShowNotification is sent
- (void)keyboardWillShow:(NSNotification *)info {
    if(_keyboardSize.height < 0){
        _keyboardPosition = [[[info userInfo]objectForKey:UIKeyboardFrameEndUserInfoKey]CGRectValue].origin;
        _keyboardSize= [[[info userInfo]objectForKey:UIKeyboardFrameEndUserInfoKey]CGRectValue].size;
        
        _scrollviewContentSize = [_scrollview contentSize];
        _scrollviewContentSize.height += _keyboardSize.height;
        [_scrollview setContentSize:_scrollviewContentSize];
    }else{
        [UIView animateWithDuration:TKPD_FADEANIMATIONDURATION
                              delay:0
                            options: UIViewAnimationCurveEaseOut
                         animations:^{
                             _scrollviewContentSize = [_scrollview contentSize];
                             _scrollviewContentSize.height -= _keyboardSize.height;
                             
                             _keyboardPosition = [[[info userInfo]objectForKey:UIKeyboardFrameEndUserInfoKey]CGRectValue].origin;
                             _keyboardSize= [[[info userInfo]objectForKey:UIKeyboardFrameEndUserInfoKey]CGRectValue].size;
                             _scrollviewContentSize.height += _keyboardSize.height;
                             if ((self.view.frame.origin.y + _activetextview.frame.origin.y+_activetextview.frame.size.height)> _keyboardPosition.y) {
                                 UIEdgeInsets inset = _scrollview.contentInset;
                                 inset.top = (_keyboardPosition.y-(self.view.frame.origin.y + _activetextview.frame.origin.y+_activetextview.frame.size.height + 10));
                                 //[_scrollview setContentSize:_scrollviewContentSize];
                                 [_scrollview setContentInset:inset];
                             }
                         }
                         completion:^(BOOL finished){
                         }];
        
    }
}

- (void)keyboardWillHide:(NSNotification *)info {
    //TODO::check
    UIEdgeInsets contentInsets = UIEdgeInsetsZero;
    [UIView animateWithDuration:TKPD_FADEANIMATIONDURATION
                          delay:0
                        options: UIViewAnimationCurveEaseOut
                     animations:^{
                         _scrollview.contentInset = contentInsets;
                         _scrollview.scrollIndicatorInsets = contentInsets;
                     }
                     completion:^(BOOL finished){
                     }];
}
@end
