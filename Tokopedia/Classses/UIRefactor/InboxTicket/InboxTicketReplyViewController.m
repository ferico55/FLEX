//
//  InboxTicketReplyViewController.m
//  Tokopedia
//
//  Created by Feizal Badri Asmoro on 6/11/15.
//  Copyright (c) 2015 TOKOPEDIA. All rights reserved.
//


#import "string_inbox_ticket.h"

#import "InboxTicketReplyViewController.h"
#import "TKPDTextView.h"
#import "TokopediaNetworkManager.h"
#import "ReplyInboxTicket.h"

#import "GenerateHost.h"
#import "RequestGenerateHost.h"

#import "camera.h"
#import "CameraAlbumListViewController.h"
#import "CameraCollectionViewController.h"

#import "UploadImage.h"
#import "UploadImageParams.h"
#import "RequestUploadImage.h"

@interface InboxTicketReplyViewController ()
<
    TokopediaNetworkManagerDelegate,
    CameraAlbumListDelegate,
    CameraCollectionViewControllerDelegate,
    GenerateHostDelegate
>
{
    TokopediaNetworkManager *_firstStepNetworkManager;
    TokopediaNetworkManager *_secondStepNetworkManager;
    TokopediaNetworkManager *_thirdStepNetworkManager;
    GenerateHost *_generateHost;

    NSString *_attachmentString;
    NSString *_serverID;
    NSString *_postKey;
    NSString *_fileUploaded;
    
    BOOL _isRequestingValidation;
    BOOL _isRequestingUpload;
    
    NSMutableArray *_photos;
    
    NSMutableArray *_selectedImagesCameraController;
    NSMutableArray *_selectedIndexPathCameraController;
    
    CGRect _keyboardFrameBeginRect;
    
    BOOL _cameraButtonClicked;
    
    RKObjectManager *_objectManager;
}

@property (weak, nonatomic) IBOutlet TKPDTextView *textView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *textViewBottomConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *attachmentButtonBottomConstraint;
@property (strong, nonatomic) IBOutlet UIView *scrollViewContentView;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;

@end

@implementation InboxTicketReplyViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"Balas Pesan";
    
    UIBarButtonItem *cancelButton = [[UIBarButtonItem alloc] initWithTitle:@"Batal"
                                                                     style:UIBarButtonItemStyleBordered
                                                                    target:self
                                                                    action:@selector(didTouchUpCancelButton:)];
    self.navigationItem.leftBarButtonItem = cancelButton;
    
    UIBarButtonItem *doneButton = [[UIBarButtonItem alloc] initWithTitle:@"Kirim"
                                                                   style:UIBarButtonItemStyleDone
                                                                  target:self
                                                                  action:@selector(didTouchUpDoneButton:)];
    self.navigationItem.rightBarButtonItem = doneButton;
    
    self.textView.placeholder = @"Isi pesan disini ...";
    self.textView.contentInset = UIEdgeInsetsMake(7, 0, 0, 0);
    
    _firstStepNetworkManager = [TokopediaNetworkManager new];
    _firstStepNetworkManager.tagRequest = 1;
    _firstStepNetworkManager.delegate = self;
    
    _secondStepNetworkManager = [TokopediaNetworkManager new];
    _secondStepNetworkManager.tagRequest = 2;
    _secondStepNetworkManager.delegate = self;
    
    _thirdStepNetworkManager = [TokopediaNetworkManager new];
    _thirdStepNetworkManager.tagRequest = 3;
    _thirdStepNetworkManager.delegate = self;
    
    _photos = [NSMutableArray new];
    
    [self.scrollView addSubview:_scrollViewContentView];
    self.scrollView.contentSize = CGSizeMake(self.scrollViewContentView.frame.size.width,
                                             self.scrollViewContentView.frame.size.height);
    
    CGRect frame = _scrollViewContentView.frame;
    frame.origin = CGPointZero;
    _scrollViewContentView.frame = frame;
    
    _cameraButtonClicked = NO;
    
    _generateHost = [GenerateHost new];
    
    RequestGenerateHost *requestHost = [RequestGenerateHost new];
    [requestHost configureRestkitGenerateHost];
    [requestHost requestGenerateHost];
    requestHost.delegate = self;
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillShow:)
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardDidShow:)
                                                 name:UIKeyboardDidShowNotification
                                               object:nil];
    
    [self.textView becomeFirstResponder];
    
    if (_keyboardFrameBeginRect.size.height) {
        self.textViewBottomConstraint.constant = _keyboardFrameBeginRect.size.height + 45;
        self.attachmentButtonBottomConstraint.constant = _keyboardFrameBeginRect.size.height;
    }
    
    self.scrollView.contentOffset = CGPointZero;

    if (_selectedImagesCameraController.count > 0) {
        NSInteger maxWidth = _selectedImagesCameraController.count * 90;
        maxWidth += 10; // add right margin
        self.scrollView.contentSize = CGSizeMake(maxWidth, self.scrollView.frame.size.height);
        self.scrollView.hidden = NO;
    } else {
        self.scrollView.hidden = YES;
    }
    
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}

#pragma mark - Actions

- (void)didTouchUpCancelButton:(UIBarButtonItem *)button {
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
}

- (void)didTouchUpDoneButton:(UIBarButtonItem *)button {
    [_firstStepNetworkManager doRequest];
}

- (IBAction)didTouchUpCameraButton:(UIButton *)sender {
    
    _cameraButtonClicked = YES;

    [self.textView resignFirstResponder];
    self.textViewBottomConstraint.constant = 0;
    self.attachmentButtonBottomConstraint.constant = 0;
    
    CameraAlbumListViewController *albumVC = [CameraAlbumListViewController new];
    albumVC.title = @"Album";
    albumVC.delegate = self;
    CameraCollectionViewController *photoVC = [CameraCollectionViewController new];
    photoVC.title = @"All Picture";
    photoVC.delegate = self;
    photoVC.tag = sender.tag;
    NSMutableArray *selectedImage = [NSMutableArray new];
    for (NSIndexPath *selected in _selectedImagesCameraController) {
        if (![selected isEqual:@""]) {
            [selectedImage addObject: selected];
        }
    }
    photoVC.selectedImagesArray = [selectedImage copy];
    NSMutableArray *selectedIndexPath = [NSMutableArray new];
    for (NSIndexPath *selected in _selectedIndexPathCameraController) {
        if (![selected isEqual:@""]) {
            [selectedIndexPath addObject: selected];
        }
    }
    photoVC.selectedIndexPath = selectedIndexPath;
    UINavigationController *nav = [[UINavigationController alloc]init];
    nav.navigationBar.backgroundColor = [UIColor colorWithCGColor:[UIColor colorWithRed:18.0/255.0 green:199.0/255.0 blue:0.0/255.0 alpha:1].CGColor];
    nav.navigationBar.translucent = NO;
    nav.navigationBar.tintColor = [UIColor whiteColor];
    NSArray *controllers = @[albumVC,photoVC];
    [nav setViewControllers:controllers];
    [self.navigationController presentViewController:nav animated:YES completion:nil];
}

#pragma mark - Keyboard notification

- (void)keyboardWillShow:(NSNotification *)notification {

    if (_cameraButtonClicked == NO) {
        [UIView setAnimationsEnabled:YES];
    } else {
        [UIView setAnimationsEnabled:NO];
    }
    
    NSDictionary *keyboardInfo = [notification userInfo];
    NSValue *keyboardFrameBegin = [keyboardInfo valueForKey:UIKeyboardFrameBeginUserInfoKey];
    _keyboardFrameBeginRect = [keyboardFrameBegin CGRectValue];
    
    if (_selectedImagesCameraController.count > 0) {
        self.textViewBottomConstraint.constant = _keyboardFrameBeginRect.size.height + 145;
        self.attachmentButtonBottomConstraint.constant = _keyboardFrameBeginRect.size.height;
    } else {
        self.textViewBottomConstraint.constant = _keyboardFrameBeginRect.size.height + 45;
        self.attachmentButtonBottomConstraint.constant = _keyboardFrameBeginRect.size.height;
    }
}

- (void)keyboardDidShow:(NSNotification *)notification {
    [UIView setAnimationsEnabled:YES];
}

#pragma mark - Network manager delegate

- (NSDictionary *)getParameter:(int)tag {
    NSDictionary *dictionary;
    if (tag == 1) {
        dictionary = @{
                       API_ACTION_KEY                   : API_TICKET_REPLY_VALIDATION,
                       API_TICKET_REPLY_TICKET_ID_KEY   : self.inboxTicket.ticket_id,
                       API_TICKET_REPLY_MESSAGE_KEY     : self.textView.text,
                       API_TICKET_REPLY_ATTACHMENT_STRING_KEY   : _attachmentString?:@"",
                       API_TICKET_REPLY_NEW_TICKET_STATUS_KEY   : @"1",
                       API_TICKET_REPLY_RATE_KEY        : @"",
                       API_TICKET_REPLY_SERVER_ID_KEY   : _serverID,
                       };
    } else if (tag == 2) {
        dictionary = @{
                       API_ACTION_KEY                   : API_TICKET_REPLY_PICTURE,
                       API_TICKET_REPLY_TICKET_ID_KEY   : self.inboxTicket.ticket_id,
                       API_TICKET_REPLY_MESSAGE_KEY     : self.textView.text?:@"",
                       API_TICKET_REPLY_ATTACHMENT_STRING_KEY   : _attachmentString,
                       API_TICKET_REPLY_NEW_TICKET_STATUS_KEY   : @"1",
                       API_TICKET_REPLY_RATE_KEY        : @"",
                       API_TICKET_REPLY_SERVER_ID_KEY   : _serverID,
                       };
    } else if (tag == 3) {
        dictionary = @{
                       API_ACTION_KEY                       : API_TICKET_REPLY_SUBMIT,
                       API_TICKET_REPLY_TICKET_ID_KEY       : self.inboxTicket.ticket_id,
                       API_TICKET_REPLY_POST_KEY            : _postKey,
                       API_TICKET_REPLY_FILE_UPLOADED_KEY   : _fileUploaded,
                       };
    }
    return dictionary;
}

- (NSString *)getPath:(int)tag {
    NSString *path = API_PATH_ACTION;
    return path;
}

- (id)getObjectManager:(int)tag {
    _objectManager = [RKObjectManager sharedClient];

    RKObjectMapping *statusMapping = [RKObjectMapping mappingForClass:[ReplyInboxTicket class]];
    [statusMapping addAttributeMappingsFromArray:@[
                                                   kTKPD_APISTATUSMESSAGEKEY,
                                                   kTKPD_APIERRORMESSAGEKEY,
                                                   kTKPD_APISTATUSKEY,
                                                   kTKPD_APISERVERPROCESSTIMEKEY,
                                                   ]];
    
    RKObjectMapping *resultMapping = [RKObjectMapping mappingForClass:[ReplyInboxTicketResult class]];
    [resultMapping addAttributeMappingsFromArray:@[API_TICKET_REPLY_IS_SUCCESS_KEY,
                                                   API_TICKET_REPLY_FILE_UPLOADED_KEY,
                                                   API_TICKET_REPLY_POST_KEY]];
    
    [statusMapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:kTKPD_APIRESULTKEY
                                                                                  toKeyPath:kTKPD_APIRESULTKEY
                                                                                withMapping:resultMapping]];
    
    // register mappings with the provider using a response descriptor
    RKResponseDescriptor *responseDescriptor = [RKResponseDescriptor responseDescriptorWithMapping:statusMapping
                                                                                            method:RKRequestMethodPOST
                                                                                       pathPattern:API_PATH_ACTION
                                                                                           keyPath:@""
                                                                                       statusCodes:kTkpdIndexSetStatusCodeOK];
    
    [_objectManager addResponseDescriptor:responseDescriptor];
    
    return _objectManager;
}

- (NSString *)getRequestStatus:(RKMappingResult *)mappingResult withTag:(int)tag {
    ReplyInboxTicket *response = [mappingResult.dictionary objectForKey:@""];
    return response.status;
}

- (void)actionBeforeRequest:(int)tag {
    if (tag == 1) {
        _isRequestingValidation = YES;
    } else if (tag == 2) {
        _isRequestingUpload = YES;
    }
}

- (void)actionAfterRequest:(RKMappingResult *)mappingResult withOperation:(RKObjectRequestOperation *)operation withTag:(int)tag {
    ReplyInboxTicket *response = [mappingResult.dictionary objectForKey:@""];
    if (response.message_error) {
        StickyAlertView *alert = [[StickyAlertView alloc] initWithErrorMessages:response.message_error delegate:self];
        [alert show];
    } else {
        if (tag == 1) {
            _postKey = response.result.post_key;
            _isRequestingValidation = NO;
            
            if (!_fileUploaded && _selectedImagesCameraController.count > 0 && !_isRequestingUpload) {
                [_secondStepNetworkManager doRequest];
            } else if (_postKey) {
                [_thirdStepNetworkManager doRequest];
            }
            
        } else if (tag == 2) {
            _fileUploaded = response.result.file_uploaded;
            _isRequestingUpload = NO;
            
            if (!_postKey && !_isRequestingValidation) {
                [_firstStepNetworkManager doRequest];
            } else if (_postKey && _fileUploaded) {
                [_thirdStepNetworkManager doRequest];
            }
            
        } else if (tag == 3) {
            if ([response.result.is_success boolValue]) {
                if ([self.delegate respondsToSelector:@selector(successReplyInboxTicket)]) {
                    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
                    [self.delegate successReplyInboxTicket];
                } else {
                    if (response.message_error) {
                        StickyAlertView *alertView = [[StickyAlertView alloc] initWithErrorMessages:response.message_error
                                                                                           delegate:self];
                        [alertView show];
                    }
                }
            }
        }
    }
}

- (void)actionFailAfterRequest:(id)errorResult withTag:(int)tag {
    
}

- (void)actionAfterFailRequestMaxTries:(int)tag {
    
}

#pragma mark - Camera Delegate

-(void)didDismissController:(CameraCollectionViewController *)controller withUserInfo:(NSDictionary *)userinfo
{
    NSArray *selectedImages = [userinfo objectForKey:@"selected_images"];
    NSArray *selectedIndexPaths = [userinfo objectForKey:@"selected_indexpath"];

    _selectedImagesCameraController = [selectedImages mutableCopy];
    _selectedIndexPathCameraController = [selectedIndexPaths mutableCopy];
    
    NSInteger maxIndex = selectedImages.count;
    for (int i = 0; i < self.scrollViewContentView.subviews.count; i++) {
        UIImageView *imageView = (UIImageView *)[self.scrollViewContentView viewWithTag:i+1];
        if (i < maxIndex) {
            NSDictionary *photo = [[selectedImages objectAtIndex:i] objectForKey:@"photo"];
            UIImage *image = [photo objectForKey:@"photo"];
            imageView.image = image;
        } else {
            imageView.image = nil;
        }
    }
}

#pragma mark Request Generate Host

-(void)successGenerateHost:(GenerateHost *)generateHost
{
    _generateHost = generateHost;
    _serverID = _generateHost.result.generated_host.server_id;
}

- (void)failedGenerateHost:(NSArray *)errorMessages {
    StickyAlertView *alert = [[StickyAlertView alloc]initWithErrorMessages:errorMessages
                                                                  delegate:self];
    [alert show];
}

@end
