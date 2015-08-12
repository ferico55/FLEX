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
#import "RequestGenerateHost.h"
#import "RequestUploadImage.h"

#import "TokopediaNetworkManager.h"

#import "TKPDTextView.h"
#import "TKPDPhotoPicker.h"

#pragma mark - Shop Edit View Controller
@interface ShopEditViewController ()
<
    UITextViewDelegate,
    ShopEditStatusViewControllerDelegate,
    GenerateHostDelegate,
    RequestUploadImageDelegate,
    TKPDPhotoPickerDelegate,
	TokopediaNetworkManagerDelegate
>
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
    UIBarButtonItem *_barbuttonsave;
    
    __weak RKObjectManager *_objectmanager;
    __weak RKManagedObjectRequestOperation *_request;
    
    __weak RKObjectManager *_objectmanagerGenerateHost;
    __weak RKManagedObjectRequestOperation *_requestGenerateHost;
    
    __weak RKObjectManager *_objectmanagerUploadPhoto;
    __weak RKManagedObjectRequestOperation *_requestActionUploadPhoto;
    
    RKResponseDescriptor *_responseDescriptor;
    NSOperationQueue *_operationQueue;
    
    TokopediaNetworkManager *_networkManagerShopPict;
    
    UIImage *_snappedImage;
    
    TKPDPhotoPicker *_photoPicker;
    id _uploadImageObject;
}

#define TAG_REQUEST_SHOP_PICT 10

@property (weak, nonatomic) IBOutlet UIView *viewmembership;
@property (weak, nonatomic) IBOutlet UILabel *labelmembership;
@property (weak, nonatomic) IBOutlet UIView *viewcontent;
@property (strong, nonatomic) IBOutlet UIImageView *thumb;
@property (weak, nonatomic) IBOutlet UIButton *buttoneditimage;
@property (weak, nonatomic) IBOutlet UILabel *labelshopname;
@property (weak, nonatomic) IBOutlet TKPDTextView *textviewslogan;
@property (weak, nonatomic) IBOutlet UILabel *labelslogancharcount;
@property (weak, nonatomic) IBOutlet TKPDTextView *textviewdesc;
@property (weak, nonatomic) IBOutlet UILabel *labeldesccharcount;
@property (weak, nonatomic) IBOutlet UIButton *buttonshopstatus;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollview;
@property (weak, nonatomic) IBOutlet UIImageView *badgesMembership;

-(void)cancel;
-(void)configureRestKit;
-(void)requestaction:(id)object;
-(void)requestsuccessaction:(id)object withOperation:(RKObjectRequestOperation*)operation;
-(void)requestfailureaction:(id)object;
-(void)requestprocessaction:(id)object;
-(void)requesttimeout;

- (IBAction)tap:(id)sender;

@end

@implementation ShopEditViewController

#pragma mark - Initialization
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.title = kTKPDTITLE_EDIT_INFO;
    }
    return self;
}

#pragma mark - Life Cycle
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    _networkManagerShopPict = [TokopediaNetworkManager new];
    _networkManagerShopPict.delegate = self;
    _networkManagerShopPict.tagRequest = TAG_REQUEST_SHOP_PICT;
    
    _datainput = [NSMutableDictionary new];
    _operationQueue = [NSOperationQueue new];
    
    UIBarButtonItem *barButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStyleBordered target:self action:@selector(tap:)];
    UIViewController *previousVC = [self.navigationController.viewControllers objectAtIndex:self.navigationController.viewControllers.count - 2];
    barButtonItem.tag = 10;
    [previousVC.navigationItem setBackBarButtonItem:barButtonItem];
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
    
    _barbuttonsave = [[UIBarButtonItem alloc] initWithTitle:@"Simpan" style:UIBarButtonItemStyleDone target:(self) action:@selector(tap:)];
    [_barbuttonsave setTintColor:[UIColor whiteColor]];
    _barbuttonsave.tag = 11;
    self.navigationItem.rightBarButtonItem = _barbuttonsave;
    
    // register for keyboard notifications
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
    
    _shop = [_data objectForKey:kTKPDDETAIL_DATASHOPSKEY];
    
    RequestGenerateHost *requestHost = [RequestGenerateHost new];
    [requestHost configureRestkitGenerateHost];
    [requestHost requestGenerateHost];
    requestHost.delegate = self;
    _buttoneditimage.enabled = NO;
    
    [self setDefaultData:_data];
    
    _textviewdesc.placeholder = @"Tulis Deskripsi";
    _textviewslogan.placeholder = @"Tulis Slogan";
    
}

-(void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    _scrollview.contentSize = _viewcontent.frame.size;
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];

}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
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
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
    
    [_networkManagerShopPict requestCancel];
    _networkManagerShopPict.delegate = nil;
    _networkManagerShopPict = nil;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Network Manager
-(id)getObjectManager:(int)tag
{
    if (tag == TAG_REQUEST_SHOP_PICT) {
        return [self objectManagerUpload];
    }
    return nil;
}

-(NSString *)getPath:(int)tag
{
    if (tag == TAG_REQUEST_SHOP_PICT) {
        return @"action/myshop-info.pl";
    }
    
    return nil;
}

-(NSDictionary *)getParameter:(int)tag
{
    if (tag == TAG_REQUEST_SHOP_PICT) {
        UserAuthentificationManager *auth = [UserAuthentificationManager new];
        NSString* userID = [auth getUserId]?:@"";
        
        NSDictionary *param = @{@"new_add":@(1),
                                @"action":@"update_shop_picture",
                                @"pic_code":_images.result.image.pic_code?:@"",
                                @"pic_src": _images.result.image.pic_src?:@"",
                                @"user_id" : userID,
                                @"server_id" : _generatehost.result.generated_host.server_id?:@""
                                };
        return param;
    }
    
    return nil;
}

-(NSString *)getRequestStatus:(id)result withTag:(int)tag
{
    NSDictionary *resultDict = ((RKMappingResult*)result).dictionary;
    id stats = [resultDict objectForKey:@""];
    
    if (tag == TAG_REQUEST_SHOP_PICT) {
        _settings = stats;
        return _settings.status;
    }
    return nil;
}

-(void)actionBeforeRequest:(int)tag
{
    if (tag == TAG_REQUEST_SHOP_PICT) {
        _buttoneditimage.enabled = NO;
    }
}

-(void)actionAfterRequest:(id)successResult withOperation:(RKObjectRequestOperation *)operation withTag:(int)tag
{
    if (tag == TAG_REQUEST_SHOP_PICT) {
        
        NSDictionary *resultDict = ((RKMappingResult*)successResult).dictionary;
        id stats = [resultDict objectForKey:@""];
        _settings = stats;
        
        if (_settings.result.is_success == 1) {
            StickyAlertView *alert = [[StickyAlertView alloc]initWithSuccessMessages:@[@"Anda telah berhasil mengubah gambar toko"] delegate:self];
            [alert show];
            
            NSDictionary *userinfo = @{kTKPDSHOPEDIT_APIUPLOADFILETHUMBKEY :_images.result.image.pic_src?:@"",
                                       kTKPDSHOPEDIT_APIUPLOADFILEPATHKEY:_images.result.file_path?:@""
                                       };
            [[NSNotificationCenter defaultCenter] postNotificationName:EDIT_SHOP_AVATAR_NOTIFICATION_NAME object:nil userInfo:userinfo];
            [[NSNotificationCenter defaultCenter] postNotificationName:kTKPD_EDITSHOPPOSTNOTIFICATIONNAMEKEY object:nil userInfo:userinfo];
        }
        else
        {
            StickyAlertView *alert = [[StickyAlertView alloc]initWithErrorMessages:_settings.message_error?:@[@"Anda gagal mengubah gambar toko. Mohon coba kembali"] delegate:self];
            [alert show];
            
            NSURLRequest* request = [[NSURLRequest alloc] initWithURL:[NSURL URLWithString:_shop.info.shop_avatar]
                                                          cachePolicy:NSURLRequestUseProtocolCachePolicy
                                                      timeoutInterval:kTKPDREQUEST_TIMEOUTINTERVAL];
            
            UIImageView *thumb = _thumb;
            [UIImageView circleimageview:thumb];
            
            [thumb setImageWithURLRequest:request
                         placeholderImage:[UIImage imageNamed:@"icon_default_shop"]
                                  success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-retain-cycles"
                                      [thumb setImage:image];
#pragma clang diagnosti c pop
                                  } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) {
                                      [thumb setImage:[UIImage imageNamed:@"icon_default_shop"]];
                                      thumb.layer.borderColor = [UIColor colorWithRed:199.0/255.0 green:200.0/255.0 blue:204.0/255.0 alpha:1].CGColor;
                                      thumb.layer.borderWidth = 1;
                                  }];
        }

        
        _thumb.alpha = 1.0;
        _buttoneditimage.enabled = YES;
    }
}

-(void)actionFailAfterRequest:(id)errorResult withTag:(int)tag
{

}

-(void)actionAfterFailRequestMaxTries:(int)tag
{
    if (tag == TAG_REQUEST_SHOP_PICT) {
        [self failedUploadObject:_uploadImageObject];
        _buttoneditimage.enabled = YES;
    }
}

#pragma mark - Request and Mapping
-(void)cancel
{
    [_objectmanager.operationQueue cancelAllOperations];
    _objectmanager = nil;
}

-(RKObjectManager *)objectManagerUpload
{
    // initialize RestKit
    //NSString *urlString = [NSString stringWithFormat:@"http://%@/ws",_generatehost.result.generated_host.upload_host];
    //RKObjectManager *objectManager = [RKObjectManager managerWithBaseURL:[NSURL URLWithString:urlString]];
    RKObjectManager *objectManager = [RKObjectManager sharedClient];
    
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
    
    RKResponseDescriptor *responseDescriptor = [RKResponseDescriptor responseDescriptorWithMapping:statusMapping method:RKRequestMethodPOST pathPattern:@"action/myshop-info.pl" keyPath:@"" statusCodes:kTkpdIndexSetStatusCodeOK];
    
    [objectManager addResponseDescriptor:responseDescriptor];
    
    return objectManager;
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
    
    RKResponseDescriptor *responseDescriptor = [RKResponseDescriptor responseDescriptorWithMapping:statusMapping method:RKRequestMethodPOST pathPattern:kTKPDDETAILSHOPEDITINFO_APIPATH keyPath:@"" statusCodes:kTkpdIndexSetStatusCodeOK];
    
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
    
    _request = [_objectmanager appropriateObjectRequestOperationWithObject:self method:RKRequestMethodPOST path:kTKPDDETAILSHOPEDITINFO_APIPATH parameters:[param encrypt]];

    NSTimer *timer;
    _barbuttonsave.enabled = NO;
    
    [_request setCompletionBlockWithSuccess:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
        [timer invalidate];
        _barbuttonsave.enabled = YES;
        [self requestsuccessaction:mappingResult withOperation:operation];
    } failure:^(RKObjectRequestOperation *operation, NSError *error) {
        [timer invalidate];
        _barbuttonsave.enabled = YES;
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
                StickyAlertView *alert = [[StickyAlertView alloc] initWithSuccessMessages:@[KTKPDSHOP_SUCCESSEDIT] delegate:self];
                [alert show];
            } else if(_settings.message_error) {
                StickyAlertView *alert = [[StickyAlertView alloc] initWithErrorMessages:_settings.message_error delegate:self];
                [alert show];
            }
            if (_settings.result.is_success) {
                UIViewController *previousVC = [self.navigationController.viewControllers objectAtIndex:self.navigationController.viewControllers.count - 3];
                [self.navigationController popToViewController:previousVC animated:NO];
                [[NSNotificationCenter defaultCenter] postNotificationName:kTKPD_EDITSHOPPOSTNOTIFICATIONNAMEKEY object:nil userInfo:nil];
            }
        }
        }else{
            [self cancel];
            NSLog(@" REQUEST FAILURE ERROR %@", [(NSError*)object description]);
            NSError *error = object;
            if (!([error code] == NSURLErrorCancelled)){
                NSString *errorDescription = error.localizedDescription;
                UIAlertView *errorAlert = [[UIAlertView alloc]initWithTitle:ERROR_TITLE
                                                                    message:errorDescription
                                                                   delegate:self
                                                          cancelButtonTitle:ERROR_CANCEL_BUTTON_TITLE
                                                          otherButtonTitles:nil];
                [errorAlert show];
            }
        }
    }
}

-(void)requesttimeout
{
    [self cancel];
}

#pragma mark Request Generate Host
-(void)successGenerateHost:(GenerateHost *)generateHost
{
    _buttoneditimage.enabled = YES;
    _generatehost = generateHost;
}

- (void)failedGenerateHost:(NSArray *)errorMessages {
    StickyAlertView *alert = [[StickyAlertView alloc]initWithErrorMessages:errorMessages delegate:self];
    [alert show];
}

#pragma mark Request Action Upload Photo
-(void)actionUploadImage:(id)object
{
    _thumb.alpha = 0.5;
    RequestUploadImage *uploadImage = [RequestUploadImage new];
    uploadImage.imageObject = object;
    uploadImage.delegate = self;
    uploadImage.generateHost = _generatehost;
    uploadImage.action = kTKPDDETAIL_APIUPLOADSHOPIMAGEKEY;
    uploadImage.fieldName = API_UPLOAD_SHOP_IMAGE_FORM_FIELD_NAME;
    [uploadImage configureRestkitUploadPhoto];
    [uploadImage requestActionUploadPhoto];
    
    _buttoneditimage.enabled = NO;
}

-(void)successUploadObject:(id)object withMappingResult:(UploadImage *)uploadImage
{
    _images = uploadImage;
    [_networkManagerShopPict doRequest];
}

-(void)failedUploadObject:(id)object
{
    _buttoneditimage.enabled = YES;
    
    NSURLRequest* request = [[NSURLRequest alloc] initWithURL:[NSURL URLWithString:_shop.info.shop_avatar] cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:kTKPDREQUEST_TIMEOUTINTERVAL];
    
    UIImageView *thumb = _thumb;
    thumb.image = nil;
    
    [thumb setImageWithURLRequest:request
                 placeholderImage:[UIImage imageNamed:@"icon_default_shop"]
                          success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-retain-cycles"
        [thumb setImage:image animated:YES];
      thumb.alpha = 1.0;
#pragma clang diagnostic pop
    } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) {
        [thumb setImage:[UIImage imageNamed:@"icon_default_shop"]];
        thumb.alpha = 1.0;
    }];
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
                if (shopdesc.length == 0) {
                    [message addObject:@"Deskripsi harus diisi."];
                } else if (tagline.length == 0) {
                    [message addObject:@"Slogan harus diisi."];
                } else {
                    [self configureRestKit];
                    [self requestaction:_datainput];
                }
                if (message.count>0) {
                    StickyAlertView *alert = [[StickyAlertView alloc] initWithErrorMessages:message delegate:self];
                    [alert show];
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
            {
                //edit thumbnail
                _photoPicker = [[TKPDPhotoPicker alloc] initWithParentViewController:self
                                                              pickerTransistionStyle:UIModalTransitionStyleCoverVertical];
                [_photoPicker setDelegate:self];
                break;
            }
            case 12:
            {
                // adjust shop status
                NSString *closedNote = [_datainput objectForKey:kTKPDSHOPEDIT_APICLOSEDNOTEKEY]?:_shop.closed_info.note;
                NSString *closedUntil = [_datainput objectForKey:kTKPDSHOPEDIT_APICLOSEUNTILKEY]?:_shop.closed_info.until;
                ShopEditStatusViewController *vc = [ShopEditStatusViewController new];
                vc.data = @{kTKPDDETAIL_DATASTATUSSHOPKEY: _shop.is_open?:@(0),
                            kTKPDDETAIL_DATACLOSEDINFOKEY: _shop.closed_info,
                            kTKPDSHOPEDIT_APICLOSEDNOTEKEY:closedNote,
                            kTKPDSHOPEDIT_APICLOSEUNTILKEY:closedUntil
                            };
                vc.delegate = self;
                [self.navigationController pushViewController:vc animated:YES];
                break;
            }
            default:
                break;
        }
    }
}


-(void)scrollViewWillBeginDecelerating:(UIScrollView *)scrollView
{
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
            _labelslogancharcount.text = [NSString stringWithFormat:@"%u", limit - _textviewslogan.text.length];
        }
        
        limit = 140;
        string = _shop.info.shop_description;
        _textviewdesc.text = string?:@"";
        if (string) {
            _labeldesccharcount.text = [NSString stringWithFormat:@"%zd", limit - _textviewdesc.text.length];
        }
        
        NSURLRequest* request = [[NSURLRequest alloc] initWithURL:[NSURL URLWithString:_shop.info.shop_avatar]
                                                      cachePolicy:NSURLRequestUseProtocolCachePolicy
                                                  timeoutInterval:kTKPDREQUEST_TIMEOUTINTERVAL];

        UIImageView *thumb = _thumb;
        [UIImageView circleimageview:thumb];
        
        [thumb setImageWithURLRequest:request
                     placeholderImage:[UIImage imageNamed:@"icon_default_shop"]
                              success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-retain-cycles"
            [thumb setImage:image];                                  
#pragma clang diagnosti c pop
        } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) {
            [thumb setImage:[UIImage imageNamed:@"icon_default_shop"]];
            thumb.layer.borderColor = [UIColor colorWithRed:199.0/255.0 green:200.0/255.0 blue:204.0/255.0 alpha:1].CGColor;
            thumb.layer.borderWidth = 1;
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
        
        
        //if gold merchant
        if (!_shop.info.shop_is_gold) {
            _labelmembership.text = @"Regular Merchant";
            _badgesMembership.hidden = YES;
        } else {
            _labelmembership.text = @"Gold Merchant";
            _badgesMembership.hidden = NO;
        }
    }
}

#pragma mark - TextView Delegate

-(BOOL)textViewShouldBeginEditing:(UITextView *)textView{
    _activetextview = textView;
    return YES;
}

-(BOOL)textViewShouldEndEditing:(UITextView *)textView
{
    if (textView == _textviewslogan) {
        if(textView.text.length != 0 && ![textView.text isEqualToString:@""]){
            [_datainput setObject:textView.text forKey:kTKPDSHOPEDIT_APITAGLINEKEY];
        }
    } else if (textView == _textviewdesc) {
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
    } else if (textView == _textviewdesc) {
        limit = 140;
    }
    return textView.text.length + (text.length - range.length) <= limit;
}

- (void)textViewDidChange:(UITextView *)textView
{
    if (textView == _textviewslogan) {
        _labelslogancharcount.text = [NSString stringWithFormat:@"%zd", 48 - textView.text.length];
    } else if (textView == _textviewdesc) {
        _labeldesccharcount.text = [NSString stringWithFormat:@"%zd", 140 - textView.text.length];
    }
}

#pragma mark - ShopEditStatusViewController Delegate
-(void)ShopEditStatusViewController:(UIViewController *)vc withData:(NSDictionary *)data
{
    [_datainput addEntriesFromDictionary:data];
    [self setDefaultData:_data];
}

#pragma mark - Photo picker delegate

- (void)photoPicker:(TKPDPhotoPicker *)picker didDismissCameraControllerWithUserInfo:(NSDictionary *)userInfo {

    NSDictionary *object = @{DATA_SELECTED_PHOTO_KEY : userInfo,
                             DATA_SELECTED_IMAGE_VIEW_KEY : _thumb};
    
    NSDictionary *photo = [userInfo objectForKey:kTKPDCAMERA_DATAPHOTOKEY];
    UIImage* image = [photo objectForKey:kTKPDCAMERA_DATAPHOTOKEY];
    
    _thumb.image = image;
    _uploadImageObject = object;
    [self actionUploadImage:object];
}

#pragma mark - Keyboard Notification
- (void)keyboardWillShow:(NSNotification *)info {
    _keyboardPosition = [[[info userInfo]objectForKey:UIKeyboardFrameEndUserInfoKey]CGRectValue].origin;
    _keyboardSize= [[[info userInfo]objectForKey:UIKeyboardFrameEndUserInfoKey]CGRectValue].size;
    
    CGPoint cgpoint = CGPointMake(0, _keyboardSize.height + 20);
    _scrollview.contentOffset = cgpoint;
}

- (void)keyboardWillHide:(NSNotification *)info {
    _scrollview.contentOffset = CGPointZero;
}

@end