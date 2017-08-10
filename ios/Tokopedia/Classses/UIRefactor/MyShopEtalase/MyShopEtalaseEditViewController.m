//
//  MyShopEtalaseEditViewController.m
//  Tokopedia
//
//  Created by IT Tkpd on 11/19/14.
//  Copyright (c) 2014 TOKOPEDIA. All rights reserved.
//

#import "detail.h"
#import "string_myshop_etalase.h"
#import "EtalaseList.h"
#import "ShopSettings.h"
#import "MyShopEtalaseEditViewController.h"

@interface MyShopEtalaseEditViewController ()
{
    NSInteger _type;
    
    NSInteger _requestcount;
    
    RKObjectManager *_objectmanagerActionAddEtalase;
    RKManagedObjectRequestOperation *_requestActionAddEtalase;
    
    NSOperationQueue *_operationQueue;
    
    NSMutableDictionary *_datainput;
    
    UITextField *_activetextfield;
    NSMutableDictionary *_detailfilter;
    
    CGPoint _keyboardPosition;
    CGSize _keyboardSize;
    
    CGRect _containerDefault;
    CGSize _scrollviewContentSize;
    
    UIBarButtonItem *_barbuttonsave;
    
    BOOL _isBeingPresented;
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

@implementation MyShopEtalaseEditViewController

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

    _isBeingPresented = self.navigationController.isBeingPresented;
    if (_isBeingPresented) {
        UIBarButtonItem *barButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Batal"
                                                                          style:UIBarButtonItemStylePlain
                                                                         target:self
                                                                         action:@selector(tap:)];
        barButtonItem.tag = 10;
        self.navigationItem.leftBarButtonItem = barButtonItem;
    } else {
        UIBarButtonItem *barButtonItem = [[UIBarButtonItem alloc] initWithTitle:@""
                                                                          style:UIBarButtonItemStylePlain
                                                                         target:self
                                                                         action:nil];
        self.navigationItem.backBarButtonItem = barButtonItem;
    }
    
    _barbuttonsave = [[UIBarButtonItem alloc] initWithTitle:@"Simpan"
                                                      style:UIBarButtonItemStyleDone
                                                     target:(self)
                                                     action:@selector(tap:)];
    _barbuttonsave.tag = 11;
    self.navigationItem.rightBarButtonItem = _barbuttonsave;

    [self.textfieldname becomeFirstResponder];
    
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
                if (_isBeingPresented) {
                    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
                } else {
                    [self.navigationController popViewControllerAnimated:YES];                    
                }
                break;
            }
            case 11:
            {
                //submit
                EtalaseList *list = [_data objectForKey:DATA_ETALASE_KEY];

                if ([self isValidEtalaseName] && [list.etalase_id integerValue] != DATA_ADD_NEW_ETALASE_ID) {
                    [self configureRestKitActionAddEtalase];
                    [self requestActionAddEtalase:_datainput];
                }
                if ([self isValidEtalaseName] && [list.etalase_id integerValue] == DATA_ADD_NEW_ETALASE_ID) {
                    EtalaseList *list = [_data objectForKey:DATA_ETALASE_KEY];
                    NSString *etalasename = [_datainput objectForKey:kTKPDSHOP_APIETALASENAMEKEY]?:list.etalase_name?:@"";
                    list.etalase_name = etalasename;
                    NSDictionary *userInfo = @{DATA_ETALASE_KEY: list};
                    [_delegate MyShopEtalaseEditViewController:self withUserInfo:userInfo];
                    
                    NSInteger indexPopViewController = self.navigationController.viewControllers.count -3;
                    UIViewController *popToViewController = self.navigationController.viewControllers[indexPopViewController];
                    [self.navigationController popToViewController:popToViewController animated:YES];
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
    
    [statusMapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:kTKPD_APIRESULTKEY
                                                                                  toKeyPath:kTKPD_APIRESULTKEY
                                                                                withMapping:resultMapping]];
    
    // register mappings with the provider using a response descriptor
    RKResponseDescriptor *responseDescriptor = [RKResponseDescriptor responseDescriptorWithMapping:statusMapping
                                                                                            method:RKRequestMethodPOST
                                                                                       pathPattern:kTKPDDETAILSHOPETALASEACTION_APIPATH
                                                                                           keyPath:@""
                                                                                       statusCodes:kTkpdIndexSetStatusCodeOK];
    
    [_objectmanagerActionAddEtalase addResponseDescriptor:responseDescriptor];
    
}

-(void)requestActionAddEtalase:(id)object
{
    if (_requestActionAddEtalase.isExecuting) return;
    NSTimer *timer;
    
    NSDictionary *userinfo = (NSDictionary*)object;
    EtalaseList *list = [_data objectForKey:DATA_ETALASE_KEY];
    
    NSDictionary *auth = [_data objectForKey:kTKPD_AUTHKEY]?:@{};
    NSInteger shopid = [[auth objectForKey:kTKPD_SHOPIDKEY]integerValue]?:0;
    NSString *action = (_type==1)?kTKPDDETAIL_APIEDITETALASEKEY:kTKPDDETAIL_APIADDETALASEKEY;
    NSString *etalaseid = list.etalase_id?:@"0";
    NSString *etalasename = [userinfo objectForKey:kTKPDSHOP_APIETALASENAMEKEY]?:list.etalase_name?:@"";
    
    NSDictionary* param = @{kTKPDDETAIL_APIACTIONKEY:action,
                            kTKPDSHOP_APIETALASEIDKEY :etalaseid,
                            kTKPDSHOP_APIETALASENAMEKEY : etalasename,
                            kTKPDDETAIL_APISHOPIDKEY : @(shopid)
                            };
    _requestcount ++;
    
    _barbuttonsave.enabled = NO;
    
    _requestActionAddEtalase = [_objectmanagerActionAddEtalase appropriateObjectRequestOperationWithObject:self
                                                                                                    method:RKRequestMethodPOST
                                                                                                      path:kTKPDDETAILSHOPETALASEACTION_APIPATH
                                                                                                parameters:[param encrypt]];
    
    __weak typeof(self) weakSelf = self;
    __weak UIBarButtonItem *weakBarbuttonsave = _barbuttonsave;
    [_requestActionAddEtalase setCompletionBlockWithSuccess:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
        [weakSelf requestSuccessActionAddEtalase:mappingResult withOperation:operation];
        [timer invalidate];
        weakBarbuttonsave.enabled = YES;
    } failure:^(RKObjectRequestOperation *operation, NSError *error) {
        [weakSelf requestFailureActionAddEtalase:error];
        [timer invalidate];
        weakBarbuttonsave.enabled = YES;
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
    [[NSNotificationCenter defaultCenter] postNotificationName:@"didAddEtalase" object:nil];
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
                if (setting.result.is_success == 1) {
                    NSString *message;
                    if (_type == kTKPDSETTINGEDIT_DATATYPEEDITVIEWKEY) {
                        message = @"Anda telah berhasil memperbaharui nama etalase";
                    } else {
                        message = @"Anda telah berhasil menambah etalase";
                    }
                    NSArray *successMessages = setting.message_status?:@[message];
                    StickyAlertView *alert = [[StickyAlertView alloc] initWithSuccessMessages:successMessages delegate:self];
                    [alert show];
                    
                    //TODO:: add alert
                    NSDictionary *userinfo;
                    if (_type == 1){
                        //TODO: Behavior after edit
                        userinfo = @{
                            kTKPDDETAIL_DATATYPEKEY:[_data objectForKey:kTKPDDETAIL_DATATYPEKEY],
                            kTKPDDETAIL_DATAINDEXPATHKEY : [_data objectForKey:kTKPDDETAIL_DATAINDEXPATHKEY]
                        };
                    }

                    [[NSNotificationCenter defaultCenter] postNotificationName:kTKPD_ADDETALASEPOSTNOTIFICATIONNAMEKEY
                                                                        object:nil
                                                                      userInfo:userinfo];
                    
                    if ([self.delegate respondsToSelector:@selector(successEditEtalase:)]) {
                        [self.delegate successEditEtalase:_textfieldname.text];
                    }
                                    
                    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
                }
            }

            if(setting.message_error) {
                StickyAlertView *alert = [[StickyAlertView alloc] initWithErrorMessages:setting.message_error
                                                                               delegate:self];
                [alert show];
            }
        } else {
            [self cancelActionAddEtalase];
            NSLog(@" REQUEST FAILURE ERROR %@", [(NSError*)object description]);
            if ([(NSError*)object code] == NSURLErrorCancelled) {
                if (_requestcount<kTKPDREQUESTCOUNTMAX) {
                    NSLog(@" ==== REQUESTCOUNT %zd =====",_requestcount);
                    //TODO:: Reload handler
                    StickyAlertView *alert = [[StickyAlertView alloc] initWithErrorMessages:@[@"Error"] delegate:self];
                    [alert show];
                }
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
        NSString *title;
        switch (_type) {
            case kTKPDSETTINGEDIT_DATATYPEDEFAULTVIEWKEY:
                title = kTKPDTITLE_ETALASE;
                break;
            case kTKPDSETTINGEDIT_DATATYPEEDITVIEWKEY:
                title = kTKPDTITLE_EDIT_ETALASE;
                break;
            case kTKPDSETTINGEDIT_DATATYPENEWVIEWKEY:
            case kTKPDSETTINGEDIT_DATATYPENEWVIEWADDPRODUCTKEY:
                title = kTKPDTITLE_NEW_ETALASE;
                break;
            default:
                break;
        }
        self.title = title;
        id etalaselist = [_data objectForKey:DATA_ETALASE_KEY];
        if (etalaselist && ![etalaselist isEqual:[NSNull null]] && _type != kTKPDSETTINGEDIT_DATATYPENEWVIEWADDPRODUCTKEY) {
            EtalaseList *list = etalaselist;
            _textfieldname.text = list.etalase_name;
        }
    }
}

-(BOOL)isValidEtalaseName
{
    BOOL isValid = YES;
    NSMutableArray *messages = [NSMutableArray new];

    EtalaseList *list = [_data objectForKey:DATA_ETALASE_KEY];
    NSString *etalasename = [_datainput objectForKey:kTKPDSHOP_APIETALASENAMEKEY]?:list.etalase_name?:@"";

    if (!etalasename || [etalasename isEqualToString:@""]) {
        isValid = NO;
        [messages addObject:ERRORMESSAGE_NULL_ETALASE_NAME];
    }
    
    if (!isValid) {
        StickyAlertView *alert = [[StickyAlertView alloc] initWithErrorMessages:messages delegate:self];
        [alert show];
    }

    return isValid;
}

@end
