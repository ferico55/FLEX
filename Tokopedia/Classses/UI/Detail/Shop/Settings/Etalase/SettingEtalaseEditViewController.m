//
//  SettingEtalaseEditViewController.m
//  Tokopedia
//
//  Created by IT Tkpd on 11/19/14.
//  Copyright (c) 2014 TOKOPEDIA. All rights reserved.
//

#import "detail.h"
#import "EtalaseList.h"
#import "ShopSettings.h"
#import "SettingEtalaseEditViewController.h"

@interface SettingEtalaseEditViewController ()
{
    NSInteger _type;
    
    NSInteger _requestcount;
    
    __weak RKObjectManager *_objectmanagerActionAddEtalase;
    __weak RKManagedObjectRequestOperation *_requestActionAddEtalase;
    
    NSOperationQueue *_operationQueue;
    
    NSMutableDictionary *_datainput;
    
    UITextField *_activetextfield;
    NSMutableDictionary *_detailfilter;
    
    CGPoint _keyboardPosition;
    CGSize _keyboardSize;
    
    CGRect _containerDefault;
    CGSize _scrollviewContentSize;
    
    UIBarButtonItem *_barbuttonsave;
    UIActivityIndicatorView *_act;
}

@property (weak, nonatomic) IBOutlet UITextField *textfieldname;

-(void)cancelActionAddEtalase;
-(void)configureRestKitActionAddEtalase;
-(void)requestActionAddEtalase:(id)object;
-(void)requestSuccessActionAddEtalase:(id)object withOperation:(RKObjectRequestOperation*)operation;
-(void)requestFailureActionAddEtalase:(id)object;
-(void)requestProcessActionAddEtalase:(id)object;
-(void)requestTimeoutActionAddEtalase;

@end

@implementation SettingEtalaseEditViewController

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
    
    _datainput = [NSMutableDictionary new];
    _operationQueue = [NSOperationQueue new];
    
    [self setDefaultData:_data];
    
    UIBarButtonItem *barbutton1;
    NSBundle* bundle = [NSBundle mainBundle];
    UIImage *img = [[UIImage alloc] initWithContentsOfFile:[bundle pathForResource:kTKPDIMAGE_ICONBACK ofType:@"png"]];
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7) { // iOS 7
        UIImage * image = [img imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
        barbutton1 = [[UIBarButtonItem alloc] initWithImage:image style:UIBarButtonItemStylePlain target:self action:@selector(tap:)];
    }
    else
        barbutton1 = [[UIBarButtonItem alloc] initWithImage:img style:UIBarButtonItemStylePlain target:self action:@selector(tap:)];
	[barbutton1 setTag:10];
    self.navigationItem.leftBarButtonItem = barbutton1;
    
    _barbuttonsave = [[UIBarButtonItem alloc] initWithTitle:@"Save" style:UIBarButtonItemStylePlain target:(self) action:@selector(tap:)];
    [_barbuttonsave setTintColor:[UIColor whiteColor]];
    _barbuttonsave.tag = 11;
    self.navigationItem.rightBarButtonItem = _barbuttonsave;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - View Action
-(IBAction)tap:(id)sender
{
    [_activetextfield resignFirstResponder];

    if ([sender isKindOfClass:[UIBarButtonItem class]]) {
        UIBarButtonItem *btn = (UIBarButtonItem*)sender;
        switch (btn.tag) {
            case 10:
            {
                [self.navigationController popViewControllerAnimated:YES];
                break;
            }
            case 11:
            {
                //submit
                EtalaseList *list = [_data objectForKey:kTKPDDETAIL_DATAETALASEKEY];
                
                NSMutableArray *messages = [NSMutableArray new];
                
                NSString *etalasename = [_datainput objectForKey:kTKPDSHOP_APIETALASENAMEKEY]?:list.etalase_name?:@"";
                
                if (etalasename && ![etalasename isEqualToString:@""]) {
                    [self configureRestKitActionAddEtalase];
                    [self requestActionAddEtalase:_datainput];
                }
                else
                {
                    if (!etalasename || [etalasename isEqualToString:@""]) {
                        [messages addObject:@"Nama Etalase harus diisi."];
                    }
                }
                
                NSLog(@"%@",messages);
                if (messages) {
                    NSArray *array = messages;
                    NSDictionary *info = [NSDictionary dictionaryWithObjectsAndKeys:array,@"messages", nil];
                    [[NSNotificationCenter defaultCenter] postNotificationName:kTKPD_SETUSERSTICKYSUCCESSMESSAGEKEY object:nil userInfo:info];
                }
                break;
            }
            default:
                break;
        }
    }
}
- (IBAction)gesture:(id)sender {
    [_activetextfield resignFirstResponder];
}


#pragma mark - Request Action AddEtalase
-(void)cancelActionAddEtalase
{
    [_requestActionAddEtalase cancel];
    _requestActionAddEtalase = nil;
    [_objectmanagerActionAddEtalase.operationQueue cancelAllOperations];
    _objectmanagerActionAddEtalase = nil;
}

-(void)configureRestKitActionAddEtalase
{
    _objectmanagerActionAddEtalase = [RKObjectManager sharedClient];
    
    // setup object mappings
    RKObjectMapping *statusMapping = [RKObjectMapping mappingForClass:[ShopSettings class]];
    [statusMapping addAttributeMappingsFromDictionary:@{kTKPD_APISTATUSMESSAGEKEY:kTKPD_APISTATUSMESSAGEKEY,
                                                        kTKPD_APIERRORMESSAGEKEY:kTKPD_APIERRORMESSAGEKEY,
                                                        kTKPD_APISTATUSKEY:kTKPD_APISTATUSKEY,
                                                        kTKPD_APISERVERPROCESSTIMEKEY:kTKPD_APISERVERPROCESSTIMEKEY,
                                                        }];
    
    RKObjectMapping *resultMapping = [RKObjectMapping mappingForClass:[ShopSettingsResult class]];
    [resultMapping addAttributeMappingsFromDictionary:@{kTKPD_APIISSUCCESSKEY:kTKPD_APIISSUCCESSKEY}];
    
    [statusMapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:kTKPD_APIRESULTKEY toKeyPath:kTKPD_APIRESULTKEY withMapping:resultMapping]];
    
    // register mappings with the provider using a response descriptor
    RKResponseDescriptor *responseDescriptor = [RKResponseDescriptor responseDescriptorWithMapping:statusMapping method:RKRequestMethodGET pathPattern:kTKPDDETAILSHOPETALASEACTION_APIPATH keyPath:@"" statusCodes:kTkpdIndexSetStatusCodeOK];
    
    [_objectmanagerActionAddEtalase addResponseDescriptor:responseDescriptor];
    
}

-(void)requestActionAddEtalase:(id)object
{
    if (_requestActionAddEtalase.isExecuting) return;
    NSTimer *timer;
    
    NSDictionary *userinfo = (NSDictionary*)object;
    EtalaseList *list = [_data objectForKey:kTKPDDETAIL_DATAETALASEKEY];
    
    NSDictionary *auth = [_data objectForKey:kTKPD_AUTHKEY]?:@{};
    NSInteger shopid = [[auth objectForKey:kTKPD_SHOPIDKEY]integerValue]?:0;
    NSString *action = (_type==1)?kTKPDDETAIL_APIEDITETALASEKEY:kTKPDDETAIL_APIADDETALASEKEY;
    NSInteger etalaseid = list.etalase_id?:0;
    NSString *etalasename = [userinfo objectForKey:kTKPDSHOP_APIETALASENAMEKEY]?:list.etalase_name?:@"";
    
    NSDictionary* param = @{kTKPDDETAIL_APIACTIONKEY:action,
                            kTKPDSHOP_APIETALASEIDKEY :@(etalaseid),
                            kTKPDSHOP_APIETALASENAMEKEY : etalasename,
                            kTKPDDETAIL_APISHOPIDKEY : @(shopid)
                            };
    _requestcount ++;
    
    _barbuttonsave.enabled = NO;
    [_act startAnimating];
    
    _requestActionAddEtalase = [_objectmanagerActionAddEtalase appropriateObjectRequestOperationWithObject:self method:RKRequestMethodGET path:kTKPDDETAILSHOPETALASEACTION_APIPATH parameters:param];
    
    [_requestActionAddEtalase setCompletionBlockWithSuccess:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
        [self requestSuccessActionAddEtalase:mappingResult withOperation:operation];
        [timer invalidate];
        [_act stopAnimating];
        _barbuttonsave.enabled = YES;
    } failure:^(RKObjectRequestOperation *operation, NSError *error) {
        [self requestFailureActionAddEtalase:error];
        [timer invalidate];
        [_act stopAnimating];
        _barbuttonsave.enabled = YES;
    }];
    
    [_operationQueue addOperation:_requestActionAddEtalase];
    
    timer= [NSTimer scheduledTimerWithTimeInterval:kTKPDREQUEST_TIMEOUTINTERVAL target:self selector:@selector(requestTimeoutActionAddEtalase) userInfo:nil repeats:NO];
    [[NSRunLoop currentRunLoop] addTimer:timer forMode:NSRunLoopCommonModes];
}

-(void)requestSuccessActionAddEtalase:(id)object withOperation:(RKObjectRequestOperation *)operation
{
    NSDictionary *result = ((RKMappingResult*)object).dictionary;
    id stat = [result objectForKey:@""];
    ShopSettings *setting = stat;
    BOOL status = [setting.status isEqualToString:kTKPDREQUEST_OKSTATUS];
    
    if (status) {
        [self requestProcessActionAddEtalase:object];
    }
}

-(void)requestFailureActionAddEtalase:(id)object
{
    [self requestProcessActionAddEtalase:object];
}

-(void)requestProcessActionAddEtalase:(id)object
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
                        NSDictionary *userinfo;
                        if (_type == 1){
                            //TODO: Behavior after edit
                            NSArray *viewcontrollers = self.navigationController.viewControllers;
                            NSInteger index = viewcontrollers.count-3;
                            [self.navigationController popToViewController:[viewcontrollers objectAtIndex:index] animated:NO];
                            userinfo = @{kTKPDDETAIL_DATATYPEKEY:[_data objectForKey:kTKPDDETAIL_DATATYPEKEY],
                                         kTKPDDETAIL_DATAINDEXPATHKEY : [_data objectForKey:kTKPDDETAIL_DATAINDEXPATHKEY]
                                         };
                        }
                        else [self.navigationController popViewControllerAnimated:YES];
                        [[NSNotificationCenter defaultCenter] postNotificationName:kTKPD_ADDETALASEPOSTNOTIFICATIONNAMEKEY object:nil userInfo:userinfo];
                    }
                }
            }
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
        }
        else{
            
            [self cancelActionAddEtalase];
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

-(void)requestTimeoutActionAddEtalase
{
    [self cancelActionAddEtalase];
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
    if (textField == _textfieldname) {
        [_datainput setObject:textField.text forKey:kTKPDSHOP_APIETALASENAMEKEY];
    }
    return YES;
}


#pragma mark - Methods
-(void)setDefaultData:(NSDictionary*)data
{
    _data = data;
    if (data) {
        _type = [[_data objectForKey:kTKPDDETAIL_DATATYPEKEY]integerValue]?:0;
        id etalaselist = [_data objectForKey:kTKPDDETAIL_DATAETALASEKEY];
        if (etalaselist && ![etalaselist isEqual:[NSNull null]]) {
            EtalaseList *list = etalaselist;
            _textfieldname.text = list.etalase_name;
        }
    }
}

@end
