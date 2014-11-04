//
//  ProfileEditPhoneViewController.m
//  Tokopedia
//
//  Created by IT Tkpd on 11/3/14.
//  Copyright (c) 2014 TOKOPEDIA. All rights reserved.
//

#import "alert.h"
#import "profile.h"
#import "ProfileSettings.h"
#import "ProfileEditPhoneViewController.h"
#import "Alert1ButtonView.h"

@interface ProfileEditPhoneViewController ()
{
    NSInteger _requestcount;
    NSTimer *_timer;
    
    __weak RKObjectManager *_objectmanagerAction;
    __weak RKManagedObjectRequestOperation *_requestAction;
    
    NSOperationQueue *_operationQueue;
}

@property (weak, nonatomic) IBOutlet UITextField *textfieldpass;
@property (weak, nonatomic) IBOutlet UITextField *textfieldphone;

-(void)cancelAction;
-(void)configureActionRestKit;
-(void)requestAction:(id)userinfo;
-(void)requestSuccessAction:(id)object withOperation:(RKObjectRequestOperation*)operation;
-(void)requestFailureAction:(id)object;
-(void)requestProcessAction:(id)object;
-(void)requestTimeoutAction;

@end

@implementation ProfileEditPhoneViewController

#pragma mark - Initialization
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
    }
    return self;
}

#pragma mark - Life Cycle
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self.navigationController.navigationBar setTranslucent:NO];
    [self.navigationController.navigationItem setTitle:kTKPDPROFILEEDIT_TITLE];
    
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
	[barbutton1 setTag:11];
    self.navigationItem.rightBarButtonItem = barbutton1;
    
    _textfieldphone.text = [_data objectForKey:kTKPDPROFILEEDIT_DATAPHONENUMBERKEY];
    
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];

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

#pragma mark - Request + Mapping
-(void)cancelAction
{
    [_requestAction cancel];
    _requestAction = nil;
    [_objectmanagerAction.operationQueue cancelAllOperations];
    _objectmanagerAction = nil;
}

- (void)configureActionRestKit
{
    // initialize AFNetworking HTTPClient + restkit
    //TraktAPIClient *client = [TraktAPIClient sharedClient];
    _objectmanagerAction = [RKObjectManager sharedClient];
    
    
    // setup object mappings
    
    
}

- (void)requestAction:(id)userinfo
{
    if (_requestAction.isExecuting) return;
    
    NSDictionary *data = userinfo;
    
    _requestcount ++;
    [self.view setUserInteractionEnabled:NO];
    
    NSDictionary* param = @{kTKPDPROFILE_APIACTIONKEY:kTKPDPROFILE_APISETPASSWORDKEY,
                            kTKPDPROFILESETTING_APIPASSKEY : [data objectForKey:kTKPDPROFILESETTING_APIPASSKEY],
                            kTKPDPROFILESETTING_APINEWPASSKEY : [data objectForKey:kTKPDPROFILESETTING_APINEWPASSKEY],
                            kTKPDPROFILESETTING_APIPASSCONFIRMKEY :[data objectForKey:kTKPDPROFILESETTING_APINEWPASSKEY]
                            };
    
    _requestAction = [_objectmanagerAction appropriateObjectRequestOperationWithObject:self method:RKRequestMethodGET path:kTKPDPROFILE_PROFILESETTINGAPIPATH parameters:param];
    
    //[_cachecontroller clearCache];
    /* file doesn't exist or hasn't been updated */
    [_requestAction setCompletionBlockWithSuccess:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
        [self requestSuccessAction:mappingResult withOperation:operation];
        [self.view setUserInteractionEnabled:YES];
        [_timer invalidate];
        _timer = nil;
        
    } failure:^(RKObjectRequestOperation *operation, NSError *error) {
        /** failure **/
        [self requestFailureAction:error];
        [self.view setUserInteractionEnabled:YES];
        [_timer invalidate];
        _timer = nil;
    }];
    
    [_operationQueue addOperation:_requestAction];
    
    _timer= [NSTimer scheduledTimerWithTimeInterval:kTKPDREQUEST_TIMEOUTINTERVAL target:self selector:@selector(requestTimeoutAction) userInfo:nil repeats:NO];
    [[NSRunLoop currentRunLoop] addTimer:_timer forMode:NSRunLoopCommonModes];
}

-(void)requestSuccessAction:(id)object withOperation:(RKObjectRequestOperation *)operation{
    NSDictionary *result = ((RKMappingResult*)object).dictionary;
    id stat = [result objectForKey:@""];
    ProfileSettings *setting = stat;
    BOOL status = [setting.status isEqualToString:kTKPDREQUEST_OKSTATUS];
    
    if (status) {
        [self requestProcessAction:object];
    }
}


-(void)requestTimeoutAction
{
    [self cancelAction];
}


-(void)requestFailureAction:(id)object
{
    [self requestProcessAction:object];
}

-(void)requestProcessAction:(id)object
{
    if (object) {
        if ([object isKindOfClass:[RKMappingResult class]]) {
            NSDictionary *result = ((RKMappingResult*)object).dictionary;
            id stat = [result objectForKey:@""];
            ProfileSettings *setting = stat;
            BOOL status = [setting.status isEqualToString:kTKPDREQUEST_OKSTATUS];
            
            if (status) {
                if (!setting.message_error) {
                    if (setting.result.is_success) {
                        Alert1ButtonView *v = [Alert1ButtonView new];
                        v.tag = 10;
                        if (setting.message_status)
                            v.data = @{kTKPDALERTVIEW_DATALABELKEY : setting.message_status};
                        else
                            v.data = @{kTKPDALERTVIEW_DATALABELKEY : @"Success"};
                        v.delegate = self;
                        [v show];
                    }
                }
                else
                {
                    Alert1ButtonView *v = [Alert1ButtonView new];
                    v.tag = 11;
                    v.data = @{kTKPDALERTVIEW_DATALABELKEY :setting.message_error};
                    v.delegate = self;
                    [v show];
                }
            }
        }
        else{
            
            [self cancelAction];
            NSLog(@" REQUEST FAILURE ERROR %@", [(NSError*)object description]);
            if ([(NSError*)object code] == NSURLErrorCancelled) {
                if (_requestcount<kTKPDREQUESTCOUNTMAX) {
                    NSLog(@" ==== REQUESTCOUNT %d =====",_requestcount);
                    //[_act startAnimating];
                    //TODO: Reload handler
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

@end
