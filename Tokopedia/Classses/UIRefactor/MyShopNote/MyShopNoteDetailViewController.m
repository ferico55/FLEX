//
//  MyShopNoteDetailViewController.m
//  Tokopedia
//
//  Created by IT Tkpd on 11/21/14.
//  Copyright (c) 2014 TOKOPEDIA. All rights reserved.
//

#import "NoteDetail.h"
#import "ShopSettings.h"
#import "detail.h"
#import "MyShopNoteDetailViewController.h"
#import "URLCacheController.h"
#import "TKPDTextView.h"
#import "UserAuthentificationManager.h"

#pragma mark - MyShopNoteDetailViewController
@interface MyShopNoteDetailViewController ()
<
    UITextFieldDelegate,
    UITextViewDelegate
>
{
    NSInteger _requestcount;
    NoteDetail *_note;
    
    NSInteger _type;
    
    NSMutableDictionary *_auth;
    NSMutableDictionary *_datainput;
    
    UITextView *_activetextview;
    
    UIBarButtonItem *_barbuttonedit;
    UserAuthentificationManager *_userManager;
    
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
    
    BOOL _isBeingPresented;
    BOOL _isNewNoteReturnableProduct;
}

@property (weak, nonatomic) IBOutlet UITextField *titleNoteTextField;
@property (weak, nonatomic) IBOutlet UILabel *timeNoteLabel;
@property (weak, nonatomic) IBOutlet UITextView *contentNoteTextView;

-(void)cancelActionNote;
-(void)configureRestKitActionNote;
-(void)requestActionNote:(id)object;
-(void)requestSuccessActionNote:(id)object withOperation:(RKObjectRequestOperation*)operation;
-(void)requestFailureActionNote:(id)object;
-(void)requestProcessActionNote:(id)object;
-(void)requestTimeoutActionNote;

@end

@implementation MyShopNoteDetailViewController

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
    _auth = [NSMutableDictionary new];
    _userManager = [UserAuthentificationManager new];
    
    TKPDSecureStorage* secureStorage = [TKPDSecureStorage standardKeyChains];
    NSDictionary* auth = [secureStorage keychainDictionary];
    _auth = [auth mutableCopy];
    
    [self setDefaultData:_data];
    
    _isBeingPresented = self.navigationController.isBeingPresented;
    if (_isBeingPresented) {
        UIBarButtonItem *barButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Batal"
                                                                          style:UIBarButtonItemStyleBordered
                                                                         target:self
                                                                         action:@selector(tap:)];
        barButtonItem.tag = 10;
        self.navigationItem.leftBarButtonItem = barButtonItem;   
    }
    
    NSString *barButtonTitle;
    switch (_type) {
        case kTKPDSETTINGEDIT_DATATYPENEWVIEWKEY:
        case kTKPDSETTINGEDIT_DATATYPEEDITVIEWKEY:
        case kTKPDSETTINGEDIT_DATATYPEEDITWITHREQUESTVIEWKEY:
        case NOTES_RETURNABLE_PRODUCT:
            barButtonTitle = @"Simpan";
            break;
        case kTKPDSETTINGEDIT_DATATYPEDETAILVIEWKEY:
            barButtonTitle = @"Ubah";
            _barbuttonedit.enabled = NO;
        default:
            break;
    }
    
    _barbuttonedit = [[UIBarButtonItem alloc] initWithTitle:barButtonTitle
                                                      style:UIBarButtonItemStyleDone
                                                     target:(self)
                                                     action:@selector(tap:)];
    self.navigationItem.rightBarButtonItem = _barbuttonedit;

    switch (_type) {
        case kTKPDSETTINGEDIT_DATATYPENEWVIEWKEY:
            self.title = kTKPDTITLE_NEW_NOTE;
            _barbuttonedit.tag = 11;
            break;
        case kTKPDSETTINGEDIT_DATATYPEEDITVIEWKEY:
            self.title = kTKPDTILTE_EDIT_NOTE;
            _barbuttonedit.tag = 11;
            break;
        case kTKPDSETTINGEDIT_DATATYPEEDITWITHREQUESTVIEWKEY:
            self.title = kTKPDTILTE_EDIT_NOTE;
            _barbuttonedit.tag = 11;
            _barbuttonedit.enabled = NO;
            break;
        case kTKPDSETTINGEDIT_DATATYPEDETAILVIEWKEY:
            self.title = [_data objectForKey:kTKPDNOTES_APINOTETITLEKEY];
            _barbuttonedit.tag = 12;
            _barbuttonedit.enabled = NO;
            break;
        case NOTES_RETURNABLE_PRODUCT:
            self.title = @"Tambah Catatan";
            _barbuttonedit.tag = 11;
            break;
        default:
            break;
    }
    
    
    NSString *shopId;
    if([[_data objectForKey:@"shop_id"] isKindOfClass:[NSString class]]) {
        shopId = [_data objectForKey:@"shop_id"];
    } else {
        shopId = [[_data objectForKey:@"shop_id"] stringValue];
    }
    
    if([_userManager isMyShopWithShopId:shopId] || _type == NOTES_RETURNABLE_PRODUCT) {
        self.navigationItem.rightBarButtonItem = _barbuttonedit;
    }


    NSString *path = [[NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) lastObject]stringByAppendingPathComponent:kTKPDDETAILSHOP_CACHEFILEPATH];
    _cachepath = [path stringByAppendingPathComponent:[NSString stringWithFormat:kTKPDDETAILSHOPNOTES_APIRESPONSEFILEFORMAT,[[_data objectForKey:kTKPDNOTES_APINOTEIDKEY]integerValue]]];
    
    _cachecontroller.filePath = _cachepath;
    _cachecontroller.URLCacheInterval = 0;
    [_cachecontroller initCacheWithDocumentPath:path];
    
    _contentNoteTextView.contentInset = UIEdgeInsetsMake(8, 0, 0, 0);
    _contentNoteTextView.delegate = self;
    
    [_titleNoteTextField becomeFirstResponder];
    
    if (_titleNoteTextField.text.length > 0 && _contentNoteTextView.text.length > 0) {
        _barbuttonedit.enabled = YES;
        _barbuttonedit.tintColor = [UIColor whiteColor];
    }
    
    NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];
    [notificationCenter addObserver:self
                           selector:@selector(keyboardWillShow:)
                               name:UIKeyboardWillShowNotification
                             object:nil];
    [notificationCenter addObserver:self
                           selector:@selector(didEditNote:)
                               name:kTKPD_ADDNOTEPOSTNOTIFICATIONNAMEKEY
                             object:nil];
    
    if ([[_data objectForKey:kTKPDNOTES_APINOTESTATUSKEY] isEqualToString:@"2"]) {
        _titleNoteTextField.enabled = NO;
    }
    
    [_titleNoteTextField addTarget:self action:@selector(textFieldValueChanged:) forControlEvents:UIControlEventEditingChanged];
    
    _isNewNoteReturnableProduct = NO;

}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
}

#pragma mark - Memory Management
-(void)dealloc{
    NSLog(@"%@ : %@",[self class], NSStringFromSelector(_cmd));
}

#pragma mark - View Action
- (IBAction)tap:(id)sender {
    [_activetextview resignFirstResponder];
    
    if ([sender isKindOfClass:[UIBarButtonItem class]]) {
        UIBarButtonItem *btn = (UIBarButtonItem *)sender;
        switch (btn.tag) {
            case 10: {
                [self.navigationController dismissViewControllerAnimated:YES completion:nil];
                break;
            }
            case 11: {
                //save
                NSMutableArray *messages;
                NSString *notetitle = [_datainput objectForKey:kTKPDNOTE_APINOTESTITLEKEY]?:_note.result.detail.notes_title?:@"";
                NSString *content = [_datainput objectForKey:kTKPDNOTE_APINOTESCONTENTKEY]?:_note.result.detail.notes_content;
                
                if (_type == NOTES_RETURNABLE_PRODUCT &&
                    content && ![content isEqualToString:@""]) {
                    [self configureRestKitActionNote];
                    [self requestActionNote:_datainput];
                }
                else if (notetitle && ![notetitle isEqualToString:@""] &&
                    content && ![content isEqualToString:@""])
                {
                    [self configureRestKitActionNote];
                    [self requestActionNote:_datainput];
                }
                else
                {
                    if ((!notetitle || [notetitle isEqualToString:@""])&& _type!=NOTES_RETURNABLE_PRODUCT) {
                        [messages addObject:@"Title harus diisi."];
                    }
                    if (!content || [content isEqualToString:@""]) {
                        [messages addObject:@"Content harus diisi."];
                    }
                }
                if (messages) {
                    NSArray *array = messages;
                    NSDictionary *info = [NSDictionary dictionaryWithObjectsAndKeys:array,@"messages", nil];
                    [[NSNotificationCenter defaultCenter] postNotificationName:kTKPD_SETUSERSTICKYSUCCESSMESSAGEKEY object:nil userInfo:info];
                }
                break;
            }
            case 12: {
                //edit
                MyShopNoteDetailViewController *vc = [MyShopNoteDetailViewController new];
                vc.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
                vc.data = @{kTKPD_AUTHKEY: [_data objectForKey:kTKPD_AUTHKEY]?:@{},
                            kTKPDDETAIL_DATATYPEKEY : @(kTKPDSETTINGEDIT_DATATYPEEDITVIEWKEY),
                            kTKPDDETAIL_DATANOTEKEY : _note?:@"",
                            kTKPDNOTES_APINOTEIDKEY : [_data objectForKey:kTKPDNOTES_APINOTEIDKEY]?:@(0)
                            };
                
                UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:vc];
                nav.navigationBar.translucent = NO;
                
                [self.navigationController presentViewController:nav animated:YES completion:nil];
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
                                                        kTKPDNOTE_APINOTESCONTENTKEY:kTKPDNOTE_APINOTESCONTENTKEY,
                                                        NOTE_CREATE_TIME:NOTE_CREATE_TIME
                                                        }];
    
    //add relationship mapping
    [statusMapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:kTKPD_APIRESULTKEY
                                                                                  toKeyPath:kTKPD_APIRESULTKEY
                                                                                withMapping:resultMapping]];
    
    [resultMapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:kTKPDDETAIL_APIDETAILKEY
                                                                                  toKeyPath:kTKPDDETAIL_APIDETAILKEY
                                                                                withMapping:detailMapping]];
    
    // register mappings with the provider using a response descriptor
    RKResponseDescriptor *responseDescriptorStatus = [RKResponseDescriptor responseDescriptorWithMapping:statusMapping
                                                                                                  method:RKRequestMethodPOST
                                                                                             pathPattern:kTKPDDETAILNOTES_APIPATH
                                                                                                 keyPath:@""
                                                                                             statusCodes:kTkpdIndexSetStatusCodeOK];
    
    [_objectmanager addResponseDescriptor:responseDescriptorStatus];
}

- (void)request
{
    if (_request.isExecuting) return;
    
    _requestcount++;
    
    NSInteger shopID = [[_auth objectForKey:kTKPD_SHOPIDKEY]integerValue] ?:[[_data objectForKey:kTKPD_SHOPIDKEY] integerValue];
    NSInteger noteID = [[_data objectForKey:kTKPDNOTES_APINOTEIDKEY]integerValue];
    NSInteger terms = (_type == NOTES_RETURNABLE_PRODUCT)?1:0;
    
	NSDictionary* param = @{
                            kTKPDDETAIL_APIACTIONKEY : kTKPDDETAIL_APIGETNOTESDETAILKEY,
                            kTKPDDETAIL_APISHOPIDKEY : @(shopID),
                            kTKPDNOTES_APINOTEIDKEY : @(noteID),
                            NOTES_TERMS_FLAG_KEY : @(terms)
                            };
    NSTimer *timer;
    
    [_cachecontroller getFileModificationDate];

    _timeinterval = fabs([_cachecontroller.fileDate timeIntervalSinceNow]);
	
    if (_timeinterval > _cachecontroller.URLCacheInterval) {
        
        _request = [_objectmanager appropriateObjectRequestOperationWithObject:self
                                                                        method:RKRequestMethodPOST
                                                                          path:kTKPDDETAILNOTES_APIPATH
                                                                    parameters:[param encrypt]];
        
        [_request setCompletionBlockWithSuccess:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
            [timer invalidate];
            [self requestsuccess:mappingResult withOperation:operation];
        } failure:^(RKObjectRequestOperation *operation, NSError *error) {
            [timer invalidate];
            [self requestfailure:error];
        }];
        
        [_operationQueue addOperation:_request];
        
        timer = [NSTimer scheduledTimerWithTimeInterval:kTKPDREQUEST_TIMEOUTINTERVAL
                                                 target:self
                                               selector:@selector(requesttimeout)
                                               userInfo:nil
                                                repeats:NO];
        
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
                if ([_note.result.detail.notes_update_time isEqualToString:@""]|| _note.result.detail.notes_update_time == nil) {
                    _note.result.detail.notes_update_time = _note.result.detail.notes_create_time;
                }
                _barbuttonedit.enabled = YES;
                _titleNoteTextField.text = [_note.result.detail.notes_title isEqual:@"0"]?@"":_note.result.detail.notes_title;
                _titleNoteTextField.text = [_note.result.detail.notes_title isEqual:@"0"]?@"":_note.result.detail.notes_title;
                [_titleNoteTextField sizeToFit];
                _titleNoteTextField.enabled = NO;
                _timeNoteLabel.text = [_note.result.detail.notes_update_time isEqual:@"0"]?@"":_note.result.detail.notes_update_time;
                
                NSMutableDictionary *attributes = [[NSMutableDictionary alloc] init];
                
                NSMutableParagraphStyle *style = [[NSMutableParagraphStyle alloc] init];
                style.lineSpacing = 6.0;
                [attributes setObject:style forKey:NSParagraphStyleAttributeName];
                
                UIFont *font = [UIFont fontWithName:@"GothamBook" size:12];
                [attributes setObject:font forKey:NSFontAttributeName];
                
                NSString *contentNote = [_note.result.detail.notes_content isEqualToString:@"0"]?@"":_note.result.detail.notes_content;
                
                if ([contentNote isEqualToString:@""] && _type == NOTES_RETURNABLE_PRODUCT) {
                    _isNewNoteReturnableProduct = YES;
                }
                
//                NSAttributedString *attributedString = [[NSAttributedString alloc] initWithString:contentNote attributes:attributes];
                NSAttributedString *attributedString = [[NSAttributedString alloc] initWithData:[_note.result.detail.notes_content dataUsingEncoding:NSUnicodeStringEncoding] options:@{ NSDocumentTypeDocumentAttribute: NSHTMLTextDocumentType } documentAttributes:nil error:nil];
                _contentNoteTextView.attributedText = attributedString;
                
                if (_titleNoteTextField.text.length > 0 && _contentNoteTextView.text.length > 0) {
                    _barbuttonedit.enabled = YES;
                    _barbuttonedit.tintColor = [UIColor whiteColor];
                }
                
                if (_type == NOTES_RETURNABLE_PRODUCT && [_note.result.detail.notes_title isEqual:@"0"])
                {
                    _titleNoteTextField.text = @"Kebijakan Pengembalian Produk";
                    _titleNoteTextField.enabled = NO;
                    _barbuttonedit.enabled = YES;
                    
                    NSDate *date = [NSDate date];
                    NSDateComponents *components = [[NSCalendar currentCalendar] components:NSDayCalendarUnit | NSMonthCalendarUnit | NSYearCalendarUnit fromDate:date];
                    NSInteger year = [components year];
                    NSInteger day = [components day];
                    
                    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
                    dateFormatter.dateFormat = @"yyyyMMdd";
                    [dateFormatter setLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"id"]];
                    
                    dateFormatter.dateFormat=@"MMMM";
                    NSString * monthString = [[dateFormatter stringFromDate:date] capitalizedString];
                    NSLog(@"month: %@", monthString);
                    [dateFormatter setTimeStyle:NSDateFormatterShortStyle];
                    NSString *currentTime = [dateFormatter stringFromDate:date];
                    
                    _timeNoteLabel.text = [NSString stringWithFormat:@"%zd %@ %zd, %@",
                                           day, monthString, year, currentTime];
                    [_datainput setObject:_timeNoteLabel.text forKey:kTKPDNOTE_APINOTESUPDATETIMEKEY];
                }
            }
        }
        else{
            [self cancel];
            NSLog(@" REQUEST FAILURE ERROR %@", [(NSError*)object description]);
            if ([(NSError*)object code] == NSURLErrorCancelled) {
                if (_requestcount<kTKPDREQUESTCOUNTMAX) {
                    NSLog(@" ==== REQUESTCOUNT %zd =====",_requestcount);
                }
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
    
    [statusMapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:kTKPD_APIRESULTKEY
                                                                                  toKeyPath:kTKPD_APIRESULTKEY
                                                                                withMapping:resultMapping]];
    
    // register mappings with the provider using a response descriptor
    RKResponseDescriptor *responseDescriptor = [RKResponseDescriptor responseDescriptorWithMapping:statusMapping
                                                                                            method:RKRequestMethodPOST
                                                                                       pathPattern:kTKPDDETAILSHOPNOTEACTION_APIPATH
                                                                                           keyPath:@""
                                                                                       statusCodes:kTkpdIndexSetStatusCodeOK];
    
    [_objectmanagerActionNote addResponseDescriptor:responseDescriptor];
    
}

-(void)requestActionNote:(id)object
{
    if (_requestActionNote.isExecuting) return;
    
    NSTimer *timer= [NSTimer scheduledTimerWithTimeInterval:kTKPDREQUEST_TIMEOUTINTERVAL
                                                              target:self
                                                            selector:@selector(requestTimeoutActionNote)
                                                            userInfo:nil
                                                             repeats:NO];
    
    [[NSRunLoop currentRunLoop] addTimer:timer forMode:NSRunLoopCommonModes];
    
    NSDictionary *userinfo = (NSDictionary*)object;
    
    NSString *action;
    if (_type == kTKPDSETTINGEDIT_DATATYPENEWVIEWKEY || _isNewNoteReturnableProduct) {
        action = kTKPDDETAIL_APIADDNOTESDETAILKEY;
    }
    else
    {
        action =kTKPDDETAIL_APIEDITNOTESDETAILKEY;
    }
    
    NSString *noteID = [_data objectForKey:kTKPDNOTES_APINOTEIDKEY];
    NSString *noteTitle = [userinfo objectForKey:kTKPDNOTE_APINOTESTITLEKEY]?:_note.result.detail.notes_title?:@"";
    if (_type == NOTES_RETURNABLE_PRODUCT) {
        noteTitle = @"Kebijakan Pengembalian Produk";
    }
    NSString *noteContent = [userinfo objectForKey:kTKPDNOTE_APINOTESCONTENTKEY]?:[NSString convertHTML:_note.result.detail.notes_content]?:@"";
     NSInteger terms = (_type == NOTES_RETURNABLE_PRODUCT)?1:0;
    
    NSDictionary* param = @{kTKPDDETAIL_APIACTIONKEY:action,
                            kTKPDNOTES_APINOTEIDKEY : noteID?:@"",
                            kTKPDNOTES_APINOTETITLEKEY : noteTitle,
                            kTKPDNOTES_APINOTECONTENTKEY : noteContent,
                            NOTES_TERMS_FLAG_KEY : @(terms),
                            };
    _requestcount ++;
    
    _barbuttonedit.enabled = NO;
    
    _requestActionNote = [_objectmanagerActionNote appropriateObjectRequestOperationWithObject:self
                                                                                        method:RKRequestMethodPOST
                                                                                          path:kTKPDDETAILSHOPNOTEACTION_APIPATH
                                                                                    parameters:[param encrypt]];
    
    [_requestActionNote setCompletionBlockWithSuccess:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
        [self requestSuccessActionNote:mappingResult withOperation:operation];
        [timer invalidate];
        _barbuttonedit.enabled = YES;
    } failure:^(RKObjectRequestOperation *operation, NSError *error) {
        [self requestFailureActionNote:error];
        [timer invalidate];
        _barbuttonedit.enabled = YES;
    }];
    
    [_operationQueue addOperation:_requestActionNote];
    
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
                if (setting.result.is_success == 1) {
                    [[NSNotificationCenter defaultCenter] postNotificationName:kTKPD_ADDNOTEPOSTNOTIFICATIONNAMEKEY
                                                                        object:nil
                                                                      userInfo:nil];
                    
                    NSArray *defaultMessage;
                    switch (_type) {
                        case kTKPDSETTINGEDIT_DATATYPENEWVIEWKEY:
                            defaultMessage = @[kTKPDNOTE_ADD_NOTE_SUCCESS];
                            break;
                        case kTKPDSETTINGEDIT_DATATYPEEDITVIEWKEY:
                            defaultMessage = @[kTKPDNOTE_EDIT_NOTE_SUCCESS];
                            break;
                        case kTKPDSETTINGEDIT_DATATYPEEDITWITHREQUESTVIEWKEY:
                            defaultMessage = @[kTKPDNOTE_EDIT_NOTE_SUCCESS];
                            break;
                        default:
                            defaultMessage = @[@"Success"];
                            break;
                    }

                    NSArray *successMessages = setting.message_status?:defaultMessage;
                    StickyAlertView *alert = [[StickyAlertView alloc] initWithSuccessMessages:successMessages delegate:self];
                    [alert show];
                
                    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
                }
            }
            if(setting.message_error) {
                NSArray *errorMessages = setting.message_error?:@[kTKPDMESSAGE_ERRORMESSAGEDEFAULTKEY];
                StickyAlertView *alert = [[StickyAlertView alloc] initWithErrorMessages:errorMessages delegate:self];
                [alert show];
            }
        }
        else{
            
            [self cancelActionNote];
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

-(void)requestTimeoutActionNote
{
    [self cancelActionNote];
}

#pragma mark - Text Field delegate

- (void)textFieldValueChanged:(UITextField *)textField
{
    [_datainput setObject:textField.text forKey:kTKPDNOTE_APINOTESTITLEKEY];
    [self updateSaveTabbarTitle:textField.text content:_contentNoteTextView.text];
}

#pragma mark - Text View Delegate

- (void)textViewDidChange:(UITextView *)textView
{
    [_datainput setObject:textView.text forKey:kTKPDNOTE_APINOTESCONTENTKEY];
    [self updateSaveTabbarTitle:_titleNoteTextField.text content:textView.text];
}

- (void)updateSaveTabbarTitle:(NSString *)title content:(NSString *)content
{
    if (title.length == 0 || content.length == 0) {
        _barbuttonedit.enabled = NO;
        _barbuttonedit.tintColor = [[UIColor whiteColor] colorWithAlphaComponent:0.8];
    } else {
        _barbuttonedit.enabled = YES;
        _barbuttonedit.tintColor = [[UIColor whiteColor] colorWithAlphaComponent:1];
    }
}

#pragma mark - Methods
-(void)setDefaultData:(NSDictionary*)data
{
    _data = data;
    if (data) {
        _type = [[_data objectForKey:kTKPDDETAIL_DATATYPEKEY] integerValue];
        switch (_type) {
            case kTKPDSETTINGEDIT_DATATYPENEWVIEWKEY: {
                [_contentNoteTextView setPlaceholder:@"Konten"];
                
                NSAttributedString *attributedString = [[NSAttributedString alloc] initWithString:@""
                                                                                       attributes:[self attributes]];
                _contentNoteTextView.attributedText = attributedString;
                
                [self setTimeLabelBecomeCurrentDate];

                break;
            }
            case kTKPDSETTINGEDIT_DATATYPEEDITVIEWKEY:{

                [_barbuttonedit setEnabled:YES];
                
                _note = [_data objectForKey:kTKPDDETAIL_DATANOTEKEY];
                _titleNoteTextField.text = _note.result.detail.notes_title;
                _timeNoteLabel.text = _note.result.detail.notes_update_time;
                
                NSMutableParagraphStyle *style = [[NSMutableParagraphStyle alloc] init];
                style.lineSpacing = 6.0;

                UIFont *font = [UIFont fontWithName:@"GothamBook" size:12];
                NSMutableDictionary *attributes = [[NSMutableDictionary alloc] init];
                [attributes setObject:font forKey:NSFontAttributeName];
                [attributes setObject:style forKey:NSParagraphStyleAttributeName];
                
//                NSAttributedString *attributedString = [[NSAttributedString alloc] initWithString:[NSString convertHTML:_note.result.detail.notes_content] attributes:attributes];
                NSAttributedString *attributedString = [[NSAttributedString alloc] initWithData:[_note.result.detail.notes_content dataUsingEncoding:NSUnicodeStringEncoding] options:@{ NSDocumentTypeDocumentAttribute: NSHTMLTextDocumentType } documentAttributes:nil error:nil];
                _contentNoteTextView.attributedText = attributedString;
                
               [self setTimeLabelBecomeCurrentDate];
                
                if (_titleNoteTextField.text.length > 0 && _contentNoteTextView.text.length > 0) {
                    _barbuttonedit.enabled = YES;
                    _barbuttonedit.tintColor = [UIColor whiteColor];
                }
                
                break;
            }
            case kTKPDSETTINGEDIT_DATATYPEDETAILVIEWKEY: {

                _contentNoteTextView.editable = NO;
                
                _note = [_data objectForKey:kTKPDDETAIL_DATANOTEKEY];
                _titleNoteTextField.text = _note.result.detail.notes_title;
                _titleNoteTextField.enabled = NO;

                _timeNoteLabel.text = _note.result.detail.notes_update_time;

                NSMutableParagraphStyle *style = [[NSMutableParagraphStyle alloc] init];
                style.lineSpacing = 6.0;
                [attributes setObject:style forKey:NSParagraphStyleAttributeName];
                
                UIFont *font = [UIFont fontWithName:@"GothamBook" size:12];
                [attributes setObject:font forKey:NSFontAttributeName];

//                NSAttributedString *attributedString = [[NSAttributedString alloc] initWithString:[NSString convertHTML:_note.result.detail.notes_content] attributes:attributes];
                
                NSAttributedString *attributedString = [[NSAttributedString alloc] initWithData:[_note.result.detail.notes_content dataUsingEncoding:NSUnicodeStringEncoding] options:@{ NSDocumentTypeDocumentAttribute: NSHTMLTextDocumentType } documentAttributes:nil error:nil];
                _contentNoteTextView.attributedText = attributedString;
                
                [self configureRestKit];
                [self request];
                break;
            }
            case kTKPDSETTINGEDIT_DATATYPEEDITWITHREQUESTVIEWKEY: {
                [_barbuttonedit setEnabled:YES];
                [self configureRestKit];
                [self request];
                break;
            }
            case NOTES_RETURNABLE_PRODUCT:
            {
                _titleNoteTextField.text = @"Kebijakan Pengembalian Produk";
                _titleNoteTextField.enabled = NO;
                _barbuttonedit.enabled = YES;
                
                [self setTimeLabelBecomeCurrentDate];
                
                [self configureRestKit];
                [self request];
                break;
            }
            default:
                break;
        }
    }
    
    if ([_titleNoteTextField.text isEqualToString:@"Kebijakan Pengembalian Produk"]) {
        [self setTimeLabelBecomeCurrentDate];
        
        _titleNoteTextField.enabled = NO;
    }
}

-(NSMutableDictionary*)attributes
{
    
    NSMutableDictionary *attributes = [[NSMutableDictionary alloc] init];
    
    NSMutableParagraphStyle *style = [[NSMutableParagraphStyle alloc] init];
    style.lineSpacing = 6.0;
    [attributes setObject:style forKey:NSParagraphStyleAttributeName];
    
    UIFont *font = [UIFont fontWithName:@"GothamBook" size:12];
    [attributes setObject:font forKey:NSFontAttributeName];
    
    return attributes;
}

-(void)setTimeLabelBecomeCurrentDate
{
    NSDate *date = [NSDate date];
    NSDateComponents *components = [[NSCalendar currentCalendar] components:NSDayCalendarUnit | NSMonthCalendarUnit | NSYearCalendarUnit fromDate:date];
    NSInteger year = [components year];
    NSInteger day = [components day];
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.dateFormat = @"yyyyMMdd";
    [dateFormatter setLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"id"]];
    
    dateFormatter.dateFormat=@"MMMM";
    NSString * monthString = [[dateFormatter stringFromDate:date] capitalizedString];
    NSLog(@"month: %@", monthString);
    [dateFormatter setTimeStyle:NSDateFormatterShortStyle];
    NSString *currentTime = [dateFormatter stringFromDate:date];
    
    _timeNoteLabel.text = [NSString stringWithFormat:@"%zd %@ %zd, %@",
                           day, monthString, year, currentTime];
    [_datainput setObject:_timeNoteLabel.text forKey:kTKPDNOTE_APINOTESUPDATETIMEKEY];
}

-(void)didEditNote:(NSNotificationCenter*)notification
{
    [self configureRestKit];
    [self request];
}

#pragma mark - Keyboard notification

- (void)keyboardWillShow:(NSNotification *)notification {
    NSDictionary* keyboardInfo = [notification userInfo];
    NSValue* keyboardFrameBegin = [keyboardInfo valueForKey:UIKeyboardFrameBeginUserInfoKey];
    CGRect keyboardFrameBeginRect = [keyboardFrameBegin CGRectValue];
    self.contentNoteTextView.contentInset = UIEdgeInsetsMake(8, 0, keyboardFrameBeginRect.size.height, 0);
}

@end
