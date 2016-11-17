//
//  MyShopNoteDetailViewController.m
//  Tokopedia
//
//  Created by IT Tkpd on 11/21/14.
//  Copyright (c) 2014 TOKOPEDIA. All rights reserved.
//

#import "ShopSettings.h"
#import "detail.h"
#import "MyShopNoteDetailViewController.h"
#import "URLCacheController.h"
#import "TKPDTextView.h"
#import "UserAuthentificationManager.h"
#import "DetailShopResult.h"

#import "Tokopedia-Swift.h"

#pragma mark - MyShopNoteDetailViewController

@interface MyShopNoteDetailViewController ()
<
    UITextFieldDelegate,
    UITextViewDelegate,
    MyShopNoteDetailDelegate
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

    switch (_type) {
        case kTKPDSETTINGEDIT_DATATYPENEWVIEWKEY:
            self.title = kTKPDTITLE_NEW_NOTE;
            _barbuttonedit.tag = 11;
            [_titleNoteTextField becomeFirstResponder];
            _timeNoteLabel.hidden = NO;
            break;
        case kTKPDSETTINGEDIT_DATATYPEEDITVIEWKEY:
            self.title = kTKPDTILTE_EDIT_NOTE;
            _barbuttonedit.tag = 11;
            _timeNoteLabel.hidden = NO;
            [_titleNoteTextField becomeFirstResponder];
            break;
        case kTKPDSETTINGEDIT_DATATYPEEDITWITHREQUESTVIEWKEY:
            self.title = kTKPDTILTE_EDIT_NOTE;
            _barbuttonedit.tag = 11;
            _barbuttonedit.enabled = NO;
            _timeNoteLabel.hidden = NO;
            [_titleNoteTextField becomeFirstResponder];
            break;
        case kTKPDSETTINGEDIT_DATATYPEDETAILVIEWKEY:
            self.title = [_data objectForKey:kTKPDNOTES_APINOTETITLEKEY];
            _barbuttonedit.tag = 12;
            _barbuttonedit.enabled = NO;
            _titleNoteTextField.enabled = NO;
            break;
        case NOTES_RETURNABLE_PRODUCT:
            self.title = @"Tambah Catatan";
            _barbuttonedit.tag = 11;
            _titleNoteTextField.enabled = NO;
            break;
        default:
            break;
    }
    
    NSString *shopId;
    if([[_data objectForKey:@"shop_id"] isKindOfClass:[NSString class]]) {
        shopId = [_data objectForKey:@"shop_id"];
    } else if ([[_data objectForKey:@"auth"] objectForKey:@"shop_id"]) {
        shopId = [[[_data objectForKey:@"auth"] objectForKey:@"shop_id"] stringValue];
    } else {
        shopId = [[_data objectForKey:@"shop_id"] stringValue];
    }
    
    if ([[_data objectForKey:kTKPDNOTES_APINOTESTATUSKEY] isEqualToString:@"2"]) {
        _titleNoteTextField.enabled = NO;
    }

    if([_userManager isMyShopWithShopId:shopId] || _type == NOTES_RETURNABLE_PRODUCT) {
        self.navigationItem.rightBarButtonItem = _barbuttonedit;
    }
    
    [_titleNoteTextField addTarget:self
                            action:@selector(textFieldValueChanged:)
                  forControlEvents:UIControlEventEditingChanged];

    NSString *path = [[NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) lastObject]stringByAppendingPathComponent:kTKPDDETAILSHOP_CACHEFILEPATH];
    _cachepath = [path stringByAppendingPathComponent:[NSString stringWithFormat:kTKPDDETAILSHOPNOTES_APIRESPONSEFILEFORMAT,[[_data objectForKey:kTKPDNOTES_APINOTEIDKEY]integerValue]]];
    
    _cachecontroller.filePath = _cachepath;
    _cachecontroller.URLCacheInterval = 0;
    [_cachecontroller initCacheWithDocumentPath:path];
    
    _contentNoteTextView.contentInset = UIEdgeInsetsMake(8, 0, 0, 0);
    _contentNoteTextView.delegate = self;
    

    
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
                NSMutableArray *messages = [NSMutableArray new];
                NSString *notetitle = [_datainput objectForKey:kTKPDNOTE_APINOTESTITLEKEY]?:[_note.result.detail.notes_title kv_decodeHTMLCharacterEntities]?:@"";
                NSString *content = [_datainput objectForKey:kTKPDNOTE_APINOTESCONTENTKEY]?:[_note.result.detail.notes_content kv_decodeHTMLCharacterEntities];
                
                notetitle = [notetitle stringByTrimmingCharactersInSet: [NSCharacterSet whitespaceCharacterSet]];
                content = [content stringByTrimmingCharactersInSet:
                [NSCharacterSet whitespaceCharacterSet]];
                
                if (_type == NOTES_RETURNABLE_PRODUCT &&
                    content && ![content isEqualToString:@""]) {
                    [self UpdateNote];
                }
                else if (notetitle && ![notetitle isEqualToString:@""] &&
                    content && ![content isEqualToString:@""])
                {
                    [self UpdateNote];
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
                if (messages.count > 0) {
                    NSArray *array = messages;
                    StickyAlertView *stickyAlertView = [[StickyAlertView alloc] initWithErrorMessages:array delegate:self];
                    [stickyAlertView show];
                }
                break;
            }
            case 12: {  
                //edit
                MyShopNoteDetailViewController *vc = [MyShopNoteDetailViewController new];
                vc.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
                vc.delegate = self;
                vc.noteList = _noteList;
                vc.data = @{kTKPD_AUTHKEY: [_data objectForKey:kTKPD_AUTHKEY]?:@{},
                            kTKPDDETAIL_DATATYPEKEY : @(kTKPDSETTINGEDIT_DATATYPEEDITVIEWKEY),
                            kTKPDDETAIL_DATANOTEKEY : _note?:@"",
                            kTKPDNOTES_APINOTEIDKEY : [_data objectForKey:kTKPDNOTES_APINOTEIDKEY]?:@(0),
                            kTKPDNOTES_APINOTESTATUSKEY : [_data objectForKey:kTKPDNOTES_APINOTESTATUSKEY],
                            kTKPD_SHOPIDKEY : [_data objectForKey:kTKPD_SHOPIDKEY]?:@"",
                            };
                
                UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:vc];
                nav.navigationBar.translucent = NO;
                
                [self.navigationController presentViewController:nav animated:YES completion:nil];
                [_titleNoteTextField becomeFirstResponder];
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
-(void)showShopNoteDetail
{
    MyShopNoteRequest *requestManager = [MyShopNoteRequest new];
    [requestManager requestNoteDetail:@([[_auth objectForKey:kTKPD_SHOPIDKEY]integerValue] ?:[[_data objectForKey:kTKPD_SHOPIDKEY]integerValue])
                               noteId:@([[_data objectForKey:kTKPDNOTES_APINOTEIDKEY]integerValue])
                                terms:(_type == NOTES_RETURNABLE_PRODUCT)? @1:@0
                            onSuccess:^(NoteDetail *noteDetail, RKObjectRequestOperation *operation) {
                                [_cacheconnection connection:operation.HTTPRequestOperation.request didReceiveResponse:operation.HTTPRequestOperation.response];
                                [_cachecontroller connectionDidFinish:_cacheconnection];
                                [operation.HTTPRequestOperation.responseData writeToFile:_cachepath atomically:YES];
                                
                                [self actionUponSuccessfulRequestNoteDetail:noteDetail];
                            }
                            onFailure:^(NSError * error) {
                                if ([error code] == NSURLErrorCancelled) {
                                    if (_requestcount<kTKPDREQUESTCOUNTMAX) {
                                        NSLog(@" ==== REQUESTCOUNT %zd =====",_requestcount);
                                    }
                                }
                                else
                                {
                                    NSLog(@" ==== Failure on requesting note detail ====");
                                }
                            }];
}

-(void)actionUponSuccessfulRequestNoteDetail:(NoteDetail *)noteDetail
{
    _note = noteDetail;
    
    if ([_note.result.detail.notes_update_time isEqualToString:@""]|| _note.result.detail.notes_update_time == nil) {
        _note.result.detail.notes_update_time = _note.result.detail.notes_create_time;
    }
    _barbuttonedit.enabled = YES;
    
    NSMutableParagraphStyle *style = [[NSMutableParagraphStyle alloc] init];
    style.lineSpacing = 5.0;
    
    NSMutableDictionary *attributes = [[NSMutableDictionary alloc] init];
    
    UIFont *font = [UIFont smallTheme];
    [attributes setObject:font forKey:NSFontAttributeName];
    
    NSString *contentNote = [_note.result.detail.notes_content isEqualToString:@"0"]?@"":[_note.result.detail.notes_content kv_decodeHTMLCharacterEntities];
    contentNote = [contentNote stringByReplacingOccurrencesOfString:@"\n" withString:@""];
    
    if ([contentNote isEqualToString:@""] && _type == NOTES_RETURNABLE_PRODUCT) {
        _isNewNoteReturnableProduct = YES;
    }
    
    NSData *data = [contentNote dataUsingEncoding:NSUnicodeStringEncoding];
    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithData:data
                                                                                          options:@{ NSDocumentTypeDocumentAttribute: NSHTMLTextDocumentType }
                                                                               documentAttributes:nil
                                                                                            error:nil];
    NSRange range = (NSRange){0,[attributedString length]};
    [attributedString enumerateAttribute:NSFontAttributeName
                                 inRange:range options:NSAttributedStringEnumerationLongestEffectiveRangeNotRequired
                              usingBlock:^(id value, NSRange range, BOOL *stop) {
                                  [attributedString addAttribute:NSFontAttributeName value:font range:range];
                                  [attributedString addAttribute:NSParagraphStyleAttributeName value:style range:range];
                              }];
    _contentNoteTextView.attributedText = attributedString;
    
    if (_type == NOTES_RETURNABLE_PRODUCT)
    {
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
    else
    {
        if (_type == kTKPDSETTINGEDIT_DATATYPEDETAILVIEWKEY) {
            _timeNoteLabel.text = [_note.result.detail.notes_update_time isEqual:@"0"]?@"":_note.result.detail.notes_update_time;
            _timeNoteLabel.hidden = NO;
        }
        _titleNoteTextField.text = [_note.result.detail.notes_title isEqual:@"0"]?@"":[_note.result.detail.notes_title kv_decodeHTMLCharacterEntities];
    }
    
    if (_titleNoteTextField.text.length > 0 && _contentNoteTextView.text.length > 0) {
        _barbuttonedit.enabled = YES;
        _barbuttonedit.tintColor = [UIColor whiteColor];
    }
}

#pragma mark - Request Action Note
-(void)UpdateNote
{
    MyShopNoteRequest *requestManager = [MyShopNoteRequest new];
    
    NSString *noteTitle = [_datainput objectForKey:kTKPDNOTE_APINOTESTITLEKEY]?:[_note.result.detail.notes_title kv_decodeHTMLCharacterEntities]?:@"";
    if (_type == NOTES_RETURNABLE_PRODUCT) {
        noteTitle = @"Kebijakan Pengembalian Produk";
    }
    NSString *noteContent = [_datainput objectForKey:kTKPDNOTE_APINOTESCONTENTKEY]?:[NSString convertHTML:[_note.result.detail.notes_content kv_decodeHTMLCharacterEntities]]?:@"";
    NSString *terms = (_type == NOTES_RETURNABLE_PRODUCT)?@"1":@"0";
    
    if (_type == kTKPDSETTINGEDIT_DATATYPENEWVIEWKEY || _isNewNoteReturnableProduct) {
        //add
        [AnalyticsManager trackEventName:@"clickNotes" category:GA_EVENT_CATEGORY_SHOP_NOTES action:GA_EVENT_ACTION_CLICK label:@"Add"];
        [requestManager requestAddNoteWithTitle:noteTitle
                                    noteContent:noteContent
                                          terms:terms
                                      onSuccess:^(NoteAction * noteAction) {
                                          [self actionUponSuccessfulUpdateNote: noteAction];
                                      }
                                      onFailure:^(NSError * error) {
                                          [self actionUponFailUpdateNote:error];
                                      }];
    }
    else
    {
        //edit
        [AnalyticsManager trackEventName:@"clickNotes" category:GA_EVENT_CATEGORY_SHOP_NOTES action:GA_EVENT_ACTION_EDIT label:@"Notes"];
        NSString *noteId = [_data objectForKey:kTKPDNOTES_APINOTEIDKEY];
        
        [requestManager requestEditNote:noteId
                              noteTitle:noteTitle
                            noteContent:noteContent
                                  terms:terms
                              onSuccess:^(NoteAction * noteAction) {
                                    [self actionUponSuccessfulUpdateNote: noteAction];
                              }
                              onFailure:^(NSError * error) {
                                    [self actionUponFailUpdateNote:error];
                              }];
    }
}

-(void)actionUponSuccessfulUpdateNote: (NoteAction *)noteAction
{
    if ([noteAction.result.is_success isEqual: @"1"]) {
        
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
            case NOTES_RETURNABLE_PRODUCT:
            {
                TKPDSecureStorage *secureStorage = [TKPDSecureStorage standardKeyChains];
                [secureStorage setKeychainWithValue:@"100" withKey:@"shop_has_terms"];
                [[NSNotificationCenter defaultCenter] postNotificationName:DID_UPDATE_SHOP_HAS_TERM_NOTIFICATION_NAME object:nil userInfo:nil];
            }
                break;
            default:
                defaultMessage = @[@"Sukses"];
                break;
        }
        
        NSArray *successMessages = noteAction.message_status?:defaultMessage;
        StickyAlertView *alert = [[StickyAlertView alloc] initWithSuccessMessages:successMessages delegate:self];
        [alert show];
        
        if (_type == kTKPDSETTINGEDIT_DATATYPENEWVIEWKEY) {
            if ([_delegate respondsToSelector:@selector(successCreateNewNote)]) {
                [_delegate successCreateNewNote];
            }
        } else {
            if ([_delegate respondsToSelector:@selector(successEditNote:)]) {
                _noteList.note_title = _titleNoteTextField.text;
                _noteList.note_status = _contentNoteTextView.text;
                [_delegate successEditNote:_noteList];
            }
        }
        
        [self.navigationController dismissViewControllerAnimated:YES completion:nil];
    }
    else
    {
        //The program flow shouldn't be able to go here
        NSArray *errorMessages = @[@"Maaf, terjadi kendala saat menyimpan note!"];
        StickyAlertView *stickyAlertView = [[StickyAlertView alloc] initWithErrorMessages:errorMessages delegate:self];
        [stickyAlertView show];
    }
}

-(void)actionUponFailUpdateNote: (NSError *)error
{
    
}

#pragma mark - Text Field delegate

- (void)textFieldValueChanged:(UITextField *)textField
{
    [_datainput setObject:textField.text forKey:kTKPDNOTE_APINOTESTITLEKEY];
    [self updateSaveTabbarTitle:textField.text content:_contentNoteTextView.text];
}

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    if ([[_data objectForKey:kTKPDNOTES_APINOTESTATUSKEY] integerValue] == 2) {
        return NO;
    } else {
        return YES;
    }
}

#pragma mark - Text View Delegate

- (void)textViewDidChange:(UITextView *)textView
{
    [_datainput setObject:textView.text forKey:kTKPDNOTE_APINOTESCONTENTKEY];
    [self updateSaveTabbarTitle:_titleNoteTextField.text content:textView.text];
}

- (void)updateSaveTabbarTitle:(NSString *)title content:(NSString *)content
{
    if ([[_data objectForKey:kTKPDNOTES_APINOTESTATUSKEY] integerValue] != 2) {
        if (title.length == 0 || content.length == 0) {
            _barbuttonedit.enabled = NO;
            _barbuttonedit.tintColor = [[UIColor whiteColor] colorWithAlphaComponent:0.8];
        } else {
            _barbuttonedit.enabled = YES;
            _barbuttonedit.tintColor = [[UIColor whiteColor] colorWithAlphaComponent:1];
        }
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
                _titleNoteTextField.text = [_note.result.detail.notes_title kv_decodeHTMLCharacterEntities];
                _timeNoteLabel.text = _note.result.detail.notes_update_time;
                
                NSMutableParagraphStyle *style = [[NSMutableParagraphStyle alloc] init];
                style.lineSpacing = 5.0;

                UIFont *font = [UIFont smallTheme];
                NSMutableDictionary *attributes = [[NSMutableDictionary alloc] init];
                [attributes setObject:font forKey:NSFontAttributeName];
                [attributes setObject:style forKey:NSParagraphStyleAttributeName];
                
                NSString *note = [_note.result.detail.notes_content kv_decodeHTMLCharacterEntities];
                note = [note stringByReplacingOccurrencesOfString:@"\n" withString:@"<br/>"];
                NSData *data = [note dataUsingEncoding:NSUnicodeStringEncoding];
                NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithData:data
                                                                                                      options:@{ NSDocumentTypeDocumentAttribute: NSHTMLTextDocumentType }
                                                                                           documentAttributes:nil
                                                                                                        error:nil];
                NSRange range = (NSRange){0,[attributedString length]};
                [attributedString enumerateAttribute:NSFontAttributeName
                                             inRange:range
                                             options:NSAttributedStringEnumerationLongestEffectiveRangeNotRequired
                                          usingBlock:^(id value, NSRange range, BOOL *stop) {
                    [attributedString addAttribute:NSFontAttributeName value:font range:range];
                    [attributedString addAttribute:NSParagraphStyleAttributeName value:style range:range];
                }];
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

                _titleNoteTextField.text = [_note.result.detail.notes_title kv_decodeHTMLCharacterEntities];
                _titleNoteTextField.enabled = NO;
                
                _timeNoteLabel.text = _note.result.detail.notes_update_time;

                NSMutableParagraphStyle *style = [[NSMutableParagraphStyle alloc] init];
                style.lineSpacing = 5.0;
                
                UIFont *font = [UIFont smallTheme];
                NSString *note = [_note.result.detail.notes_content kv_decodeHTMLCharacterEntities];
                note = [note stringByReplacingOccurrencesOfString:@"\n" withString:@"<br/>"];
                NSData *data = [note dataUsingEncoding:NSUnicodeStringEncoding];
                NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithData:data
                                                                                                      options:@{ NSDocumentTypeDocumentAttribute: NSHTMLTextDocumentType }
                                                                                           documentAttributes:nil
                                                                                                        error:nil];
                NSRange range = (NSRange){0,[attributedString length]};
                [attributedString enumerateAttribute:NSFontAttributeName
                                             inRange:range
                                             options:NSAttributedStringEnumerationLongestEffectiveRangeNotRequired
                                          usingBlock:^(id value, NSRange range, BOOL *stop) {
                    [attributedString addAttribute:NSFontAttributeName value:font range:range];
                    [attributedString addAttribute:NSParagraphStyleAttributeName value:style range:range];
                }];
                _contentNoteTextView.attributedText = attributedString;
                
                [self showShopNoteDetail];
                break;
            }
            case kTKPDSETTINGEDIT_DATATYPEEDITWITHREQUESTVIEWKEY: {
                [_barbuttonedit setEnabled:YES];
                
                [self showShopNoteDetail];
                break;
            }
            case NOTES_RETURNABLE_PRODUCT:
            {
                _titleNoteTextField.text = @"Kebijakan Pengembalian Produk";
                _titleNoteTextField.enabled = NO;
                _barbuttonedit.enabled = YES;
                
                
                [self setTimeLabelBecomeCurrentDate];
                
                [self showShopNoteDetail];
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
    style.lineSpacing = 5.0;
    [attributes setObject:style forKey:NSParagraphStyleAttributeName];
    
    UIFont *font = [UIFont smallTheme];
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
    _timeNoteLabel.hidden = NO;
}

-(void)didEditNote:(NSNotificationCenter*)notification
{
    [self showShopNoteDetail];
}

#pragma mark - Keyboard notification

- (void)keyboardWillShow:(NSNotification *)notification {
    NSDictionary* keyboardInfo = [notification userInfo];
    NSValue* keyboardFrameBegin = [keyboardInfo valueForKey:UIKeyboardFrameBeginUserInfoKey];
    CGRect keyboardFrameBeginRect = [keyboardFrameBegin CGRectValue];
    self.contentNoteTextView.contentInset = UIEdgeInsetsMake(8, 0, keyboardFrameBeginRect.size.height, 0);
}

#pragma mark - My shop note delegate

- (void)successEditNote:(NotesList *)noteList
{
    _noteList = noteList;
    _note.result.detail.notes_title = noteList.note_title;
    _note.result.detail.notes_content = noteList.note_status;
    
    self.title = _noteList.note_title;
    
    //set the UI
    _titleNoteTextField.text = _noteList.note_title;
    [_titleNoteTextField sizeToFit];
    
    [self setTimeLabelBecomeCurrentDate];
    
    _contentNoteTextView.text = _noteList.note_status;
    
    //set delegate
    if ([_delegate respondsToSelector:@selector(successEditNote:)]) {
        [_delegate successEditNote:_noteList];
    }
}

@end
