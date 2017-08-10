//
//  SettingUserPhoneViewController.m
//  Tokopedia
//
//  Created by IT Tkpd on 11/3/14.
//  Copyright (c) 2014 TOKOPEDIA. All rights reserved.
//

#import "string_alert.h"
#import "profile.h"
#import "ChangePhoneNumber.h"
#import "SettingUserPhoneViewController.h"

#pragma mark - Profile Edit Phone View Controller
@interface SettingUserPhoneViewController () <UIAlertViewDelegate>
{
    NSInteger _requestcount;
    NSTimer *_timer;
    
    RKObjectManager *_objectmanagerAction;
    RKManagedObjectRequestOperation *_requestAction;
    
    NSOperationQueue *_operationQueue;
    
    UIBarButtonItem *_saveBarButtonItem;
}

@property (weak, nonatomic) IBOutlet UITextField *textfieldpass;
@property (weak, nonatomic) IBOutlet UITextField *textfieldphone;

@end

@implementation SettingUserPhoneViewController

#pragma mark - Life Cycle
- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"Ubah Nomor HP";
    
    _operationQueue = [NSOperationQueue new];
    
    _saveBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Simpan"
                                                          style:UIBarButtonItemStyleDone
                                                         target:(self)
                                                         action:@selector(tap:)];

    _saveBarButtonItem.tag = 11;
    self.navigationItem.rightBarButtonItem = _saveBarButtonItem;
    
    _textfieldphone.text = [_data objectForKey:kTKPDPROFILEEDIT_DATAPHONENUMBERKEY];
}

#pragma mark - View Action
-(IBAction)tap:(id)sender {
    if ([sender isKindOfClass:[UIBarButtonItem class]]) {
        [self request];
    }
}

#pragma mark - Request + Mapping

-(void)cancelAction {
    [_requestAction cancel];
    _requestAction = nil;

    [_objectmanagerAction.operationQueue cancelAllOperations];
    _objectmanagerAction = nil;
}

- (void)configureActionRestKit {
    _objectmanagerAction = [RKObjectManager sharedClient];
    
    RKObjectMapping *statusMapping = [RKObjectMapping mappingForClass:[ChangePhoneNumber class]];
    [statusMapping addAttributeMappingsFromArray:@[kTKPD_APIERRORMESSAGEKEY,
                                                   kTKPD_APISTATUSKEY,
                                                   kTKPD_APISERVERPROCESSTIMEKEY]];

    RKObjectMapping *resultMapping = [RKObjectMapping mappingForClass:[ChangePhoneNumberResult class]];
    [resultMapping addAttributeMappingsFromArray:@[kTKPD_APIISSUCCESSKEY]];
    
    [statusMapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:kTKPD_APIRESULTKEY
                                                                                  toKeyPath:kTKPD_APIRESULTKEY
                                                                                withMapping:resultMapping]];
    
    RKResponseDescriptor *responseDescriptor = [RKResponseDescriptor responseDescriptorWithMapping:statusMapping
                                                                                            method:RKRequestMethodPOST
                                                                                       pathPattern:kTKPDPROFILE_VERIFICATIONNUMBERAPIPATH
                                                                                           keyPath:@""
                                                                                       statusCodes:kTkpdIndexSetStatusCodeOK];
    
    [_objectmanagerAction addResponseDescriptor:responseDescriptor];
}

- (void)request {
    if (_requestAction.isExecuting) return;
    
    _requestcount ++;
    
    NSDictionary* param = @{
                            kTKPDPROFILE_APIACTIONKEY               : kTKPDPROFILE_SEND_EMAIL_CHANGE_PHONE_NUMBER,
                            kTKPDPROFILESETTING_APIPASSKEY          : _textfieldpass.text,
                            };
    
    _requestAction = [_objectmanagerAction appropriateObjectRequestOperationWithObject:self
                                                                                method:RKRequestMethodPOST
                                                                                  path:kTKPDPROFILE_VERIFICATIONNUMBERAPIPATH
                                                                            parameters:[param encrypt]];
    
    __weak typeof(self) weakSelf = self;
    __weak NSTimer *weakTimer = _timer;
    [_requestAction setCompletionBlockWithSuccess:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
    
        [weakSelf requestSuccessAction:mappingResult withOperation:operation];
        [weakSelf.view setUserInteractionEnabled:YES];
        
        [weakTimer invalidate];

    } failure:^(RKObjectRequestOperation *operation, NSError *error) {
        
        [weakSelf requestFailureAction:error];
        [weakSelf.view setUserInteractionEnabled:YES];
    
        [weakTimer invalidate];
        
    }];
    
    [_operationQueue addOperation:_requestAction];
    
    _timer = [NSTimer scheduledTimerWithTimeInterval:kTKPDREQUEST_TIMEOUTINTERVAL
                                              target:self
                                            selector:@selector(requestTimeoutAction)
                                            userInfo:nil
                                             repeats:NO];

    [[NSRunLoop currentRunLoop] addTimer:_timer forMode:NSRunLoopCommonModes];
}

-(void)requestSuccessAction:(RKMappingResult *)mappingResult withOperation:(RKObjectRequestOperation *)operation {
    ChangePhoneNumber *response = [mappingResult.dictionary objectForKey:@""];
    BOOL status = [response.status isEqualToString:kTKPDREQUEST_OKSTATUS];
    if (status) {
        [self requestProcessAction:response];
    }
}


-(void)requestTimeoutAction {
    [self cancelAction];
}

-(void)requestFailureAction:(id)object {
    [self requestProcessAction:object];
}

-(void)requestProcessAction:(id)object {
    if (object) {
        if ([object isKindOfClass:[ChangePhoneNumber class]]) {
            ChangePhoneNumber *response = (ChangePhoneNumber *)object;
            if(response.message_error) {
                NSArray *errorMessages = response.message_error?:@[kTKPDMESSAGE_ERRORMESSAGEDEFAULTKEY];
                StickyAlertView *alert = [[StickyAlertView alloc] initWithErrorMessages:errorMessages
                                                                               delegate:self];
                [alert show];
            }
            if (response.result.is_success == 1) {
                NSString *message = @"Tokopedia telah mengirimkan email konfirmasi kepada Anda yang berisikan langkah berikutnya yang harus Anda lakukan untuk mengubah nomor telepon. Silahkan cek email tersebut untuk melanjutkan langkah berikutnya.";
                UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Silahkan cek email Anda"
                                                               message:message
                                                              delegate:self
                                                     cancelButtonTitle:@"Ok"
                                                     otherButtonTitles:nil];
                alert.delegate = self;
                [alert show];
            }
        } else {
            [self cancelAction];
            
            NSError *error = object;
            UIAlertView *errorAlert = [[UIAlertView alloc]initWithTitle:ERROR_TITLE
                                                                message:error.localizedDescription
                                                               delegate:self
                                                      cancelButtonTitle:ERROR_CANCEL_BUTTON_TITLE
                                                      otherButtonTitles:nil];
            [errorAlert show];
        }
    }
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    [self.navigationController popViewControllerAnimated:YES];
}

@end
