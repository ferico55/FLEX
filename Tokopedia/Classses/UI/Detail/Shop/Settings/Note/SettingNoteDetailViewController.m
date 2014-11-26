//
//  SettingNoteDetailViewController.m
//  Tokopedia
//
//  Created by IT Tkpd on 11/21/14.
//  Copyright (c) 2014 TOKOPEDIA. All rights reserved.
//

#import "NoteDetail.h"
#import "ShopSettings.h"
#import "detail.h"
#import "SettingNoteDetailViewController.h"

#import "URLCacheController.h"

#pragma mark - SettingNoteDetailViewController
@interface SettingNoteDetailViewController ()
{
    NSInteger *_requestcount;
    NoteDetail *_note;
    
    NSInteger _type;
    
    NSMutableDictionary *_datainput;
    
    UITextField *_activetextfield;
    UITextView *_activetextview;
    
    UIBarButtonItem *_barbuttonedit;
    
    BOOL _isnodata;
    
    __weak RKObjectManager *_objectmanager;
    __weak RKManagedObjectRequestOperation *_request;
    __weak RKObjectManager *_objectmanagerActionNote;
    __weak RKManagedObjectRequestOperation *_requestActionNote;
    
    NSOperationQueue *_operationQueue;
    
    NSString *_cachepath;
    URLCacheController *_cachecontroller;
    URLCacheConnection *_cacheconnection;
    NSTimeInterval _timeinterval;
}

@property (weak, nonatomic) IBOutlet UILabel *labeltitle;
@property (weak, nonatomic) IBOutlet UILabel *labeltime;
@property (weak, nonatomic) IBOutlet UITextField *textfieldtitle;
@property (weak, nonatomic) IBOutlet UILabel *labelcontent;
@property (weak, nonatomic) IBOutlet UITextView *textviewcontent;

-(void)cancelActionNote;
-(void)configureRestKitActionNote;
-(void)requestActionNote:(id)object;
-(void)requestSuccessActionNote:(id)object withOperation:(RKObjectRequestOperation*)operation;
-(void)requestFailureActionNote:(id)object;
-(void)requestProcessActionNote:(id)object;
-(void)requestTimeoutActionNote;

@end

@implementation SettingNoteDetailViewController

#pragma mark - Initialization
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        _isnodata = YES;
    }
    return self;
}

#pragma mark - Life Cycle
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    _datainput = [NSMutableDictionary new];
    _cacheconnection = [URLCacheConnection new];
    _cachecontroller = [URLCacheController new];
    _operationQueue = [NSOperationQueue new];
    
    [self setDefaultData:_data];
    
    NSString *barbuttontitle;
    
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
    
    switch (_type) {
        case kTKPDSETTINGEDIT_DATATYPENEWVIEWKEY:
        case kTKPDSETTINGEDIT_DATATYPEEDITVIEWKEY:
        case kTKPDSETTINGEDIT_DATATYPEEDITWITHREQUESTVIEWKEY:
            barbuttontitle = @"Save";
            break;
        case kTKPDSETTINGEDIT_DATATYPEDETAILVIEWKEY:
            barbuttontitle = @"Edit";
        default:
            break;
    }
    _barbuttonedit = [[UIBarButtonItem alloc] initWithTitle:barbuttontitle style:UIBarButtonItemStylePlain target:(self) action:@selector(tap:)];
    [_barbuttonedit setTintColor:[UIColor whiteColor]];
    switch (_type) {
        case kTKPDSETTINGEDIT_DATATYPENEWVIEWKEY:
        case kTKPDSETTINGEDIT_DATATYPEEDITVIEWKEY:
        case kTKPDSETTINGEDIT_DATATYPEEDITWITHREQUESTVIEWKEY:
            _barbuttonedit.tag = 11;
            break;
        case kTKPDSETTINGEDIT_DATATYPEDETAILVIEWKEY:
            _barbuttonedit.tag = 12;
        default:
            break;
    }
    self.navigationItem.rightBarButtonItem = _barbuttonedit;
    
    NSString *path = [[NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) lastObject]stringByAppendingPathComponent:kTKPDDETAILSHOP_CACHEFILEPATH];
    _cachepath = [path stringByAppendingPathComponent:[NSString stringWithFormat:kTKPDDETAILSHOPNOTES_APIRESPONSEFILEFORMAT,[[_data objectForKey:kTKPDNOTES_APINOTEIDKEY]integerValue]]];
    
    _cachecontroller.filePath = _cachepath;
    _cachecontroller.URLCacheInterval = 86400.0;
    [_cachecontroller initCacheWithDocumentPath:path];
    
}

-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [self cancel];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - View Action
- (IBAction)tap:(id)sender {
    [_activetextfield resignFirstResponder];
    [_activetextview resignFirstResponder];
    
    if ([sender isKindOfClass:[UIBarButtonItem class]]) {
        UIBarButtonItem *btn = (UIBarButtonItem *)sender;
        switch (btn.tag) {
            case 10:
                [self.navigationController popViewControllerAnimated:YES];
                break;
            case 11:
            {
                //save
                NSMutableArray *message;
                NSString *notetitle = [_datainput objectForKey:kTKPDNOTE_APINOTESTITLEKEY]?:_note.result.detail.notes_title?:@"";
                NSString *content = [_datainput objectForKey:kTKPDNOTE_APINOTESCONTENTKEY]?:_note.result.detail.notes_content;
                
                if (notetitle && ![notetitle isEqualToString:@""] &&
                    content && ![content isEqualToString:@""]
                    ) {
                    [self configureRestKitActionNote];
                    [self requestActionNote:_datainput];
                }
                else
                {
                    if (!notetitle || [notetitle isEqualToString:@""]) {
                        [message addObject:@"Title harus diisi."];
                    }
                    if (!content || [content isEqualToString:@""]) {
                        [message addObject:@"Content harus diisi."];
                    }
                }
                break;
            }
            case 12:
            {
                //edit
                SettingNoteDetailViewController *vc = [SettingNoteDetailViewController new];
                vc.data = @{kTKPD_AUTHKEY: [_data objectForKey:kTKPD_AUTHKEY],
                            kTKPDDETAIL_DATATYPEKEY : @(kTKPDSETTINGEDIT_DATATYPEEDITVIEWKEY),
                            kTKPDDETAIL_DATANOTEKEY : _note,
                            kTKPDNOTES_APINOTEIDKEY : [_data objectForKey:kTKPDNOTES_APINOTEIDKEY]
                            };
                [self.navigationController pushViewController:vc animated:YES];
                break;
            }
            default:
                break;
        }
    }
}
- (IBAction)gesture:(id)sender {
    [_activetextfield resignFirstResponder];
    [_activetextview resignFirstResponder];
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
    RKObjectMapping *statusMapping = [RKObjectMapping mappingForClass:[NoteDetail class]];
    
    [statusMapping addAttributeMappingsFromDictionary:@{kTKPD_APISTATUSKEY:kTKPD_APISTATUSKEY,
                                                        kTKPD_APISERVERPROCESSTIMEKEY:kTKPD_APISERVERPROCESSTIMEKEY}];
    
    RKObjectMapping *resultMapping = [RKObjectMapping mappingForClass:[NoteDetailResult class]];
    
    
    RKObjectMapping *detailMapping = [RKObjectMapping mappingForClass:[NoteDetails class]];
    [detailMapping addAttributeMappingsFromDictionary:@{kTKPDNOTE_APINOTESTITLEKEY:kTKPDNOTE_APINOTESTITLEKEY,
                                                        kTKPDNOTE_APINOTESUPDATETIMEKEY:kTKPDNOTE_APINOTESUPDATETIMEKEY,
                                                        kTKPDNOTE_APINOTESCONTENTKEY:kTKPDNOTE_APINOTESCONTENTKEY
                                                        }];
    
    //add relationship mapping
    [statusMapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:kTKPD_APIRESULTKEY toKeyPath:kTKPD_APIRESULTKEY withMapping:resultMapping]];
    [resultMapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:kTKPDDETAIL_APIDETAILKEY toKeyPath:kTKPDDETAIL_APIDETAILKEY withMapping:detailMapping]];
    
    // register mappings with the provider using a response descriptor
    RKResponseDescriptor *responseDescriptorStatus = [RKResponseDescriptor responseDescriptorWithMapping:statusMapping method:RKRequestMethodGET pathPattern:kTKPDDETAILNOTES_APIPATH keyPath:@"" statusCodes:kTkpdIndexSetStatusCodeOK];
    
    [_objectmanager addResponseDescriptor:responseDescriptorStatus];
}

- (void)request
{
    if (_request.isExecuting) return;
    
    _requestcount++;
    
    NSDictionary *auth = [_data objectForKey:kTKPD_AUTHKEY];
	NSDictionary* param = @{
                            kTKPDDETAIL_APIACTIONKEY : kTKPDDETAIL_APIGETNOTESDETAILKEY,
                            kTKPDDETAIL_APISHOPIDKEY : [auth objectForKey:kTKPDDETAIL_APISHOPIDKEY]?:@(0),
                            kTKPDNOTES_APINOTEIDKEY : [_data objectForKey:kTKPDNOTES_APINOTEIDKEY]?:@(0)
                            };
    NSTimer *timer;
    [_cachecontroller getFileModificationDate];
	_timeinterval = fabs([_cachecontroller.fileDate timeIntervalSinceNow]);
	if (_timeinterval > _cachecontroller.URLCacheInterval) {
        _request = [_objectmanager appropriateObjectRequestOperationWithObject:self method:RKRequestMethodGET path:kTKPDDETAILNOTES_APIPATH parameters:param];
        [_request setCompletionBlockWithSuccess:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
            //[_objectmanager getObjectsAtPath:kTKPDDETAILSHOP_APIPATH parameters:param success:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
            [timer invalidate];
            [self requestsuccess:mappingResult withOperation:operation];
        } failure:^(RKObjectRequestOperation *operation, NSError *error) {
            /** failure **/
            [timer invalidate];
            [self requestfailure:error];
        }];
        [_operationQueue addOperation:_request];
        
        timer = [NSTimer scheduledTimerWithTimeInterval:kTKPDREQUEST_TIMEOUTINTERVAL target:self selector:@selector(requesttimeout) userInfo:nil repeats:NO];
        [[NSRunLoop currentRunLoop] addTimer:timer forMode:NSRunLoopCommonModes];
    }else{
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
    _note = stats;
    BOOL status = [_note.status isEqualToString:kTKPDREQUEST_OKSTATUS];
    
    if (status) {
        [_cacheconnection connection:operation.HTTPRequestOperation.request didReceiveResponse:operation.HTTPRequestOperation.response];
        [_cachecontroller connectionDidFinish:_cacheconnection];
        //save response data
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
            _note = stats;
            BOOL status = [_note.status isEqualToString:kTKPDREQUEST_OKSTATUS];
            
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
            
            _note = stats;
            BOOL status = [_note.status isEqualToString:kTKPDREQUEST_OKSTATUS];
            
            if (status) {
                _barbuttonedit.enabled = YES;
                _labeltitle.text = _note.result.detail.notes_title;
                _labeltime.text = _note.result.detail.notes_update_time;
                _textfieldtitle.text = _note.result.detail.notes_title;
                _textviewcontent.text = _note.result.detail.notes_content;
                
                _labelcontent.text = [NSString convertHTML:_note.result.detail.notes_content];
                [_labelcontent sizeToFit];
                [_labelcontent setNumberOfLines:0];
                
            }
        }
        else{
            [self cancel];
            NSLog(@" REQUEST FAILURE ERROR %@", [(NSError*)object description]);
            if ([(NSError*)object code] == NSURLErrorCancelled) {
                if (_requestcount<kTKPDREQUESTCOUNTMAX) {
                    NSLog(@" ==== REQUESTCOUNT %d =====",_requestcount);
                    //[_act startAnimating];
                    //[self performSelector:@selector(configureRestKit) withObject:nil afterDelay:kTKPDREQUEST_DELAYINTERVAL];
                    //[self performSelector:@selector(loadData) withObject:nil afterDelay:kTKPDREQUEST_DELAYINTERVAL];
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

#pragma mark - Request Action Note
-(void)cancelActionNote
{
    [_requestActionNote cancel];
    _requestActionNote = nil;
    [_objectmanagerActionNote.operationQueue cancelAllOperations];
    _objectmanagerActionNote = nil;
}

-(void)configureRestKitActionNote
{
    _objectmanagerActionNote = [RKObjectManager sharedClient];
    
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
    RKResponseDescriptor *responseDescriptor = [RKResponseDescriptor responseDescriptorWithMapping:statusMapping method:RKRequestMethodGET pathPattern:kTKPDDETAILSHOPNOTEACTION_APIPATH keyPath:@"" statusCodes:kTkpdIndexSetStatusCodeOK];
    
    [_objectmanagerActionNote addResponseDescriptor:responseDescriptor];
    
}

-(void)requestActionNote:(id)object
{
    if (_requestActionNote.isExecuting) return;
    NSTimer *timer;
    
    NSDictionary *userinfo = (NSDictionary*)object;
    
    NSString *action = (_type==2)?kTKPDDETAIL_APIADDNOTESDETAILKEY:kTKPDDETAIL_APIEDITNOTESDETAILKEY;
    NSInteger noteid = [[_data objectForKey:kTKPDNOTES_APINOTEIDKEY]integerValue];
    NSString *notetitle = [userinfo objectForKey:kTKPDNOTE_APINOTESTITLEKEY]?:_note.result.detail.notes_title?:@"";
    NSString *time = [userinfo objectForKey:kTKPDNOTE_APINOTESUPDATETIMEKEY]?:_note.result.detail.notes_update_time?:@"";
    NSString *content = [userinfo objectForKey:kTKPDNOTE_APINOTESCONTENTKEY]?:[NSString convertHTML:_note.result.detail.notes_content]?:@"";
    
    NSDictionary* param = @{kTKPDDETAIL_APIACTIONKEY:action,
                            kTKPDNOTES_APINOTEIDKEY : @(noteid),
                            kTKPDNOTE_APINOTESTITLEKEY : notetitle,
                            kTKPDNOTE_APINOTESUPDATETIMEKEY : time,
                            kTKPDNOTE_APINOTESCONTENTKEY : content
                            };
    _requestcount ++;
    
    _requestActionNote = [_objectmanagerActionNote appropriateObjectRequestOperationWithObject:self method:RKRequestMethodGET path:kTKPDDETAILSHOPNOTEACTION_APIPATH parameters:param];
    
    [_requestActionNote setCompletionBlockWithSuccess:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
        [self requestSuccessActionNote:mappingResult withOperation:operation];
        [timer invalidate];
    } failure:^(RKObjectRequestOperation *operation, NSError *error) {
        [self requestFailureActionNote:error];
        [timer invalidate];
    }];
    
    [_operationQueue addOperation:_requestActionNote];
    
    timer= [NSTimer scheduledTimerWithTimeInterval:kTKPDREQUEST_TIMEOUTINTERVAL target:self selector:@selector(requestTimeoutActionNote) userInfo:nil repeats:NO];
    [[NSRunLoop currentRunLoop] addTimer:timer forMode:NSRunLoopCommonModes];
}

-(void)requestSuccessActionNote:(id)object withOperation:(RKObjectRequestOperation *)operation
{
    NSDictionary *result = ((RKMappingResult*)object).dictionary;
    id stat = [result objectForKey:@""];
    ShopSettings *setting = stat;
    BOOL status = [setting.status isEqualToString:kTKPDREQUEST_OKSTATUS];
    
    if (status) {
        [self requestProcessActionNote:object];
    }
}

-(void)requestFailureActionNote:(id)object
{
    [self requestProcessActionNote:object];
}

-(void)requestProcessActionNote:(id)object
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
                        [[NSNotificationCenter defaultCenter] postNotificationName:kTKPD_ADDNOTEPOSTNOTIFICATIONNAMEKEY object:nil userInfo:userinfo];
                    }
                }
            }
        }
        else{
            
            [self cancelActionNote];
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

-(void)requestTimeoutActionNote
{
    [self cancelActionNote];
}

#pragma mark - Textfield Delegate
-(BOOL)textFieldShouldBeginEditing:(UITextField *)textField{
    [textField resignFirstResponder];
    _activetextfield = textField;
    return YES;
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField{
    [textField resignFirstResponder];
    return YES;
}

-(BOOL)textFieldShouldEndEditing:(UITextField *)textField
{
    
    if (textField == _textfieldtitle) {
        [_datainput setObject:textField.text forKey:kTKPDNOTE_APINOTESTITLEKEY];
    }
    return YES;
}

#pragma mark - Text View Delegate
-(BOOL)textViewShouldBeginEditing:(UITextView *)textView{
    [textView resignFirstResponder];
    [_activetextfield resignFirstResponder];
    _activetextfield = nil;
    _activetextview = textView;
    return YES;
}

-(BOOL)textViewShouldReturn:(UITextView *)textView{
    
    [_activetextfield resignFirstResponder];
    
    return YES;
}

-(BOOL)textViewShouldEndEditing:(UITextView *)textView
{
    if (textView== _textviewcontent) {
        [_datainput setObject:textView.text forKey:kTKPDNOTE_APINOTESCONTENTKEY];
    }
    return YES;
}

-(void) textViewDidChange:(UITextView *)textView
{

}


#pragma mark - Methods
-(void)setDefaultData:(NSDictionary*)data
{
    _data = data;
    if (data) {
        _type = [[_data objectForKey:kTKPDDETAIL_DATATYPEKEY] integerValue];
        switch (_type) {
            case kTKPDSETTINGEDIT_DATATYPENEWVIEWKEY:
                _barbuttonedit.enabled = YES;
            case kTKPDSETTINGEDIT_DATATYPEEDITVIEWKEY:{
                _barbuttonedit.enabled = NO;
                _labeltitle.hidden = YES;
                _labelcontent.hidden = YES;
                _textviewcontent.hidden = NO;
                _textfieldtitle.hidden = NO;
                
                NSDate *date = [NSDate date];
                NSDateComponents *components = [[NSCalendar currentCalendar] components:NSDayCalendarUnit | NSMonthCalendarUnit | NSYearCalendarUnit fromDate:date];
                int year = [components year];
                int day = [components day];
                
                NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
                dateFormatter.dateFormat = @"yyyyMMdd";
                
                // set locale
                /** sv_SE : 2011-10-30 19:09
                 nl_NL : 30-10-11 19:09
                 en_US : 10/30/11 7:09 PM **/
                //[dateFormatter setLocale:[[NSLocale alloc] initWithLocaleIdentifier:NSLocaleIdentifier]];
                [dateFormatter setLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"sv_SE"]];
                
                dateFormatter.dateFormat=@"MMMM";
                NSString * monthString = [[dateFormatter stringFromDate:date] capitalizedString];
                NSLog(@"month: %@", monthString);
                [dateFormatter setTimeStyle:NSDateFormatterShortStyle];
                NSString *currentTime = [dateFormatter stringFromDate:date];
                
                [_labelcontent setNumberOfLines:0];
                [_labelcontent sizeToFit];
                
                _note = [_data objectForKey:kTKPDDETAIL_DATANOTEKEY];
                _textfieldtitle.text = _note.result.detail.notes_title;
                _labeltime.text = [NSString stringWithFormat:@"%d %@ %d, %@",day, monthString,year,currentTime];
                [_datainput setObject:_labeltime.text forKey:kTKPDNOTE_APINOTESUPDATETIMEKEY];

                
                _textviewcontent.text = [NSString convertHTML:_note.result.detail.notes_content];
                [_labelcontent sizeToFit];
                [_labelcontent setNumberOfLines:0];
                
                break;
            }
            case kTKPDSETTINGEDIT_DATATYPEDETAILVIEWKEY:
                _barbuttonedit.enabled = NO;
                _textfieldtitle.hidden = YES;
                _textviewcontent.hidden = YES;
                _labelcontent.hidden = NO;
                _labeltitle.hidden = NO;
                [self configureRestKit];
                [self request];
                break;
            case kTKPDSETTINGEDIT_DATATYPEEDITWITHREQUESTVIEWKEY:
                _barbuttonedit.enabled = NO;
                _labeltitle.hidden = YES;
                _labelcontent.hidden = YES;
                _textviewcontent.hidden = NO;
                _textfieldtitle.hidden = NO;
                [self configureRestKit];
                [self request];
            default:
                break;
        }
        
    }
}

@end
