//
//  InboxTicketReplyViewController.m
//  Tokopedia
//
//  Created by Feizal Badri Asmoro on 6/22/15.
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

#import "InboxTicketDetailAttachment.h"

//only visible in this file
static NSInteger const EACH_PHOTO_WITH_SPACING_WIDTH = 90;
static NSInteger const MAX_PHOTO_COUNT = 5;

@interface InboxTicketReplyViewController ()
<
    TokopediaNetworkManagerDelegate,
    CameraAlbumListDelegate,
    CameraCollectionViewControllerDelegate,
    GenerateHostDelegate,
    RequestUploadImageDelegate,
    UITextViewDelegate,
    UIScrollViewDelegate,
    UIGestureRecognizerDelegate,
    UIAlertViewDelegate
>
{
    TokopediaNetworkManager *_firstStepNetworkManager;
    TokopediaNetworkManager *_secondStepNetworkManager;
    TokopediaNetworkManager *_thirdStepNetworkManager;
    GenerateHost *_generateHost;
    
    NSString *_serverID;
    NSString *_postKey;
    NSString *_fileUploaded;
    
    BOOL _isRequestingUpload;
    
    NSMutableArray *_uploadedPhotos;
    NSMutableArray *_uploadedPhotosURL;
    
    NSMutableArray *_selectedImagesCameraController;
    NSMutableArray *_selectedIndexPathCameraController;
    
    CGRect _keyboardFrameBeginRect;
    
    BOOL _cameraButtonClicked;
    
    RKObjectManager *_objectManager;
    
    UIBarButtonItem *_doneButton;
    
    RequestGenerateHost *_requestHost;
}

@property (strong, nonatomic) IBOutlet UITapGestureRecognizer *imageTapRecognizer;
@property (weak, nonatomic) IBOutlet TKPDTextView *textView;
@property (weak, nonatomic) IBOutlet UIScrollView *pageScrollView;
@property (weak, nonatomic) IBOutlet UIScrollView *photoScrollView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *textViewHeightConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *attachmentButtonBottomConstraint;
@property (strong, nonatomic) IBOutlet UIView *scrollViewContentView;
@property (strong, nonatomic) IBOutlet UIView *scrollViewInputContent;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *scrollViewBottomConstraint;
@property (strong, nonatomic) IBOutletCollection(UIImageView) NSArray *photosImageView;
@property (strong, nonatomic) IBOutletCollection(UIButton) NSArray *removePhotoButton;

@end

@implementation InboxTicketReplyViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    if (self.isCloseTicketForm) {
        self.title = @"Tutup Kasus";
    } else {
        self.title = @"Balas Pesan";
    }
    
    UIBarButtonItem *cancelButton = [[UIBarButtonItem alloc] initWithTitle:@"Batal"
                                                                     style:UIBarButtonItemStyleBordered
                                                                    target:self
                                                                    action:@selector(didTouchUpCancelButton:)];
    self.navigationItem.leftBarButtonItem = cancelButton;
    
    _doneButton = [[UIBarButtonItem alloc] initWithTitle:@"Kirim"
                                                   style:UIBarButtonItemStyleDone
                                                  target:self
                                                  action:@selector(didTouchUpDoneButton:)];
    self.navigationItem.rightBarButtonItem = _doneButton;
    _doneButton.enabled = NO;
    _doneButton.tintColor = [[UIColor whiteColor] colorWithAlphaComponent:0.5];

    self.textView.placeholder = @"Isi pesan disini ...";
    self.textView.delegate = self;
    self.textView.scrollEnabled = NO;
    
    _firstStepNetworkManager = [TokopediaNetworkManager new];
    _firstStepNetworkManager.tagRequest = 1;
    _firstStepNetworkManager.delegate = self;
    
    _secondStepNetworkManager = [TokopediaNetworkManager new];
    _secondStepNetworkManager.tagRequest = 2;
    _secondStepNetworkManager.delegate = self;
    _secondStepNetworkManager.isParameterNotEncrypted = YES;
    _secondStepNetworkManager.timeInterval = 30;
    
    _thirdStepNetworkManager = [TokopediaNetworkManager new];
    _thirdStepNetworkManager.tagRequest = 3;
    _thirdStepNetworkManager.delegate = self;
    
    _uploadedPhotos = [NSMutableArray new];
    _uploadedPhotosURL = [NSMutableArray new];
    
    self.photoScrollView.delegate = self;
    self.photoScrollView.contentInset = UIEdgeInsetsMake(0, 0, 0, 10);
    [self.photoScrollView addSubview:_scrollViewContentView];
    
    CGFloat screenWidth = [[UIScreen mainScreen] bounds].size.width;

    CGRect frame = _scrollViewContentView.frame;
    frame.origin = CGPointZero;
    frame.size.width = EACH_PHOTO_WITH_SPACING_WIDTH * MAX_PHOTO_COUNT;
    _scrollViewContentView.frame = frame;

    self.scrollViewContentView.hidden = YES;
    
    CGRect scrollViewContentFrame = _scrollViewInputContent.frame;
    scrollViewContentFrame.size.width = screenWidth;
    self.scrollViewInputContent.frame = scrollViewContentFrame;
    
    self.pageScrollView.delegate = self;
    [self.pageScrollView addSubview:_scrollViewInputContent];
    self.pageScrollView.contentSize = CGSizeMake(screenWidth, self.scrollViewInputContent.frame.size.height);
    
    CGRect pageFrame = _scrollViewInputContent.frame;
    pageFrame.origin = CGPointZero;
    _scrollViewInputContent.frame = pageFrame;

    _cameraButtonClicked = NO;
    
    _generateHost = [GenerateHost new];
    
    _requestHost = [RequestGenerateHost new];
    _requestHost.delegate = self;
//    [_requestHost configureRestkitGenerateHost];
    [_requestHost requestGenerateHost];
    
    self.photosImageView = [NSArray sortViewsWithTagInArray:_photosImageView];
    self.removePhotoButton = [NSArray sortViewsWithTagInArray:_removePhotoButton];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(dismissViewController)
                                                 name:TKPDInboxTicketReceiveData
                                               object:nil];
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
        self.attachmentButtonBottomConstraint.constant = _keyboardFrameBeginRect.size.height;
    }
    
    self.photoScrollView.contentOffset = CGPointZero;
    
    if (_selectedImagesCameraController.count > 0) {
        NSInteger maxWidth = _selectedImagesCameraController.count * EACH_PHOTO_WITH_SPACING_WIDTH;
        maxWidth += 10; // add right margin
        self.photoScrollView.contentSize = CGSizeMake(maxWidth, self.photoScrollView.frame.size.height);
    }
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self.textView resignFirstResponder];
}

#pragma mark - Actions

- (void)didTouchUpCancelButton:(UIBarButtonItem *)button {
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
}

- (void)didTouchUpDoneButton:(UIBarButtonItem *)button {
    if (self.isCloseTicketForm) {
        NSString *title = @"Tutup Kasus";
        NSString *message = @"Apakah Anda ingin menutup Tiket Bantuan ini ?";
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title
                                                        message:message
                                                       delegate:self
                                              cancelButtonTitle:@"Batal"
                                              otherButtonTitles:@"Ya", nil];
        alert.delegate = self;
        [alert show];
    } else {
        if (_uploadedPhotos.count == _selectedImagesCameraController.count) {
            UIActivityIndicatorView *indicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
            [indicatorView startAnimating];
            UIBarButtonItem *indicatorBarButton = [[UIBarButtonItem alloc] initWithCustomView:indicatorView];
            self.navigationItem.rightBarButtonItem = indicatorBarButton;
            [_firstStepNetworkManager doRequest];
        } else {
            NSString *errorMessage = @"Anda belum selesai mengunggah gambar";
            StickyAlertView *alert = [[StickyAlertView alloc] initWithErrorMessages:@[errorMessage] delegate:self];
            [alert show];
        }
    }
}

- (IBAction)didTouchUpCameraButton:(UIButton *)sender {
    [self openPhotoGallery];
}

- (IBAction)didTapPhotoImageView:(UITapGestureRecognizer *)sender {
    UIImageView *imageView = (UIImageView *)sender.view;
    if (imageView.isUserInteractionEnabled) {
        [self openPhotoGallery];
    }
}

- (void)openPhotoGallery {
    self.scrollViewContentView.hidden = NO;
    
    _cameraButtonClicked = YES;
    
    [self.textView resignFirstResponder];
    self.attachmentButtonBottomConstraint.constant = 0;
    
    CameraAlbumListViewController *albumVC = [CameraAlbumListViewController new];
    albumVC.title = @"Album";
    albumVC.delegate = self;
    CameraCollectionViewController *photoVC = [CameraCollectionViewController new];
    photoVC.title = @"All Picture";
    photoVC.delegate = self;
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

- (IBAction)didTapRemovePhotoButton:(UIButton *)button {
    NSInteger index = button.tag - 1;
    [_uploadedPhotos removeObjectAtIndex:index];
    [_uploadedPhotosURL removeObjectAtIndex:index];
    [_selectedImagesCameraController removeObjectAtIndex:index];
    [_selectedIndexPathCameraController removeObjectAtIndex:index];
    
    NSInteger maxIndex = _selectedImagesCameraController.count;
    for (int i = 0; i < self.photosImageView.count; i++) {
        UIImageView *imageView = [self.photosImageView objectAtIndex:i];
        UIButton *button = [self.removePhotoButton objectAtIndex:i];
        if (i < maxIndex) {
            NSDictionary *photo = [[_selectedImagesCameraController objectAtIndex:i] objectForKey:@"photo"];
            UIImage *image = [photo objectForKey:@"photo"];
            imageView.image = image;
            button.hidden = NO;
        } else {
            imageView.image = nil;
            button.hidden = YES;
        }
    }
    
    if (_selectedImagesCameraController.count > 0) {
        NSInteger maxWidth = _selectedImagesCameraController.count * EACH_PHOTO_WITH_SPACING_WIDTH;
        maxWidth += 10; // add right margin
        self.photoScrollView.contentSize = CGSizeMake(maxWidth, self.photoScrollView.frame.size.height);
        self.photoScrollView.hidden = NO;
    } else {
        self.photoScrollView.hidden = YES;
    }
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
    CGFloat height = _keyboardFrameBeginRect.size.height;
    self.attachmentButtonBottomConstraint.constant = height;
    self.scrollViewBottomConstraint.constant = height + 45;
}

- (void)keyboardDidShow:(NSNotification *)notification {
    [UIView setAnimationsEnabled:YES];
}

#pragma mark - Textview delegate

- (void)textViewDidChange:(UITextView *)textView {
    CGFloat fixedWidth = textView.frame.size.width;
    CGSize newSize = [textView sizeThatFits:CGSizeMake(fixedWidth, MAXFLOAT)];
    self.textViewHeightConstraint.constant = newSize.height;
    
    CGRect frame = self.scrollViewInputContent.frame;
    frame.size.height = newSize.height + self.scrollViewContentView.frame.size.height;
    self.scrollViewInputContent.frame = frame;
    
    self.pageScrollView.contentSize = CGSizeMake(self.view.frame.size.width, self.scrollViewInputContent.frame.size.height);
    
    if (textView.text.length > 9 && _serverID && _generateHost) {
        _doneButton.enabled = YES;
        _doneButton.tintColor = [UIColor whiteColor];
    } else {
        _doneButton.enabled = NO;
        _doneButton.tintColor = [[UIColor whiteColor] colorWithAlphaComponent:0.5];
    }
}

#pragma mark - Network manager delegate

- (NSDictionary *)getParameter:(int)tag {
    NSDictionary *dictionary;
    
    NSString *attachmentString = @"";
    for (NSString *url in _uploadedPhotosURL) {
        attachmentString = [NSString stringWithFormat:@"%@%@~", attachmentString, url];
    }
    
    NSString *newTicketStatus;
    if ([self.inboxTicket.ticket_status isEqualToString:@"1"]) {
        newTicketStatus = self.isCloseTicketForm?@"2":@"";
    } else {
        newTicketStatus = self.isCloseTicketForm?@"2":@"1";
    }
    
    if (tag == 1) {
        dictionary = @{
                       API_ACTION_KEY                   : API_TICKET_REPLY_VALIDATION,
                       API_TICKET_REPLY_TICKET_ID_KEY   : self.inboxTicket.ticket_id,
                       API_TICKET_REPLY_MESSAGE_KEY     : self.textView.text,
                       API_TICKET_REPLY_ATTACHMENT_STRING_KEY   : attachmentString?:@"",
                       API_TICKET_REPLY_NEW_TICKET_STATUS_KEY   : newTicketStatus,
                       API_TICKET_REPLY_RATE_KEY        : self.rating?:@"",
                       API_TICKET_REPLY_SERVER_ID_KEY   : _serverID,
                       };
    } else if (tag == 2) {
        UserAuthentificationManager *auth = [UserAuthentificationManager new];
        dictionary = @{
                       API_ACTION_KEY                   : API_TICKET_REPLY_PICTURE,
                       API_TICKET_REPLY_TICKET_ID_KEY   : self.inboxTicket.ticket_id,
                       API_TICKET_REPLY_MESSAGE_KEY     : self.textView.text?:@"",
                       API_TICKET_REPLY_ATTACHMENT_STRING_KEY   : attachmentString?:@"",
                       API_TICKET_REPLY_NEW_TICKET_STATUS_KEY   : newTicketStatus,
                       API_TICKET_REPLY_RATE_KEY        : self.rating?:@"",
                       API_TICKET_REPLY_SERVER_ID_KEY   : _serverID,
                       kTKPD_USERIDKEY                  : [auth getUserId],
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
    if (tag == 2) {
        return API_PATH_ACTION_UPLOAD_IMAGE;
    } else {
        return API_PATH_ACTION;
    }
}

- (id)getObjectManager:(int)tag {
    
    if (tag == 2) {
        NSString *path = [NSString stringWithFormat:@"http://%@/ws", _generateHost.result.generated_host.upload_host];
        _objectManager = [RKObjectManager sharedClient:path];
    } else {
        _objectManager = [RKObjectManager sharedClient];
    }
    
    
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
    
    NSString *pathPattern;
    if (tag == 2) {
        pathPattern = API_PATH_ACTION_UPLOAD_IMAGE;
    } else {
        pathPattern = API_PATH_ACTION;
    }
    
    // register mappings with the provider using a response descriptor
    RKResponseDescriptor *responseDescriptor = [RKResponseDescriptor responseDescriptorWithMapping:statusMapping
                                                                                            method:RKRequestMethodPOST
                                                                                       pathPattern:pathPattern
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
    
}

- (void)actionAfterRequest:(RKMappingResult *)mappingResult withOperation:(RKObjectRequestOperation *)operation withTag:(int)tag {
    ReplyInboxTicket *response = (ReplyInboxTicket *)[mappingResult.dictionary objectForKey:@""];
    if (response.message_error) {
        StickyAlertView *alert = [[StickyAlertView alloc] initWithErrorMessages:response.message_error delegate:self];
        [alert show];

        self.navigationItem.rightBarButtonItem = _doneButton;

        if (self.textView.text.length > 9 && _serverID && _generateHost) {
            _doneButton.enabled = YES;
            _doneButton.tintColor = [UIColor whiteColor];
        } else {
            _doneButton.enabled = NO;
            _doneButton.tintColor = [[UIColor whiteColor] colorWithAlphaComponent:0.7];
        }

    } else {
        UserAuthentificationManager *auth = [UserAuthentificationManager new];
        NSDictionary *userData = [auth getUserLoginData];
        
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"yyyy-MM-dd'T'HH:mm'Z'"];
        
        NSMutableArray *attachments = [NSMutableArray new];
        for (UIImageView *imageView in self.photosImageView) {
            InboxTicketDetailAttachment *attachment = [InboxTicketDetailAttachment new];
            attachment.img = imageView.image;
            if (!imageView.isUserInteractionEnabled) {
                [attachments addObject:attachment];                
            }
        }
        
        InboxTicketDetail *ticket = [InboxTicketDetail new];
        ticket.ticket_detail_create_time = [dateFormatter stringFromDate:[NSDate new]];
        ticket.ticket_detail_user_name = [userData objectForKey:@"full_name"];
        ticket.ticket_detail_user_image = [userData objectForKey:@"user_image"];
        ticket.ticket_detail_is_cs = @"0";
        ticket.ticket_detail_message = self.textView.text;
        ticket.ticket_detail_attachment = attachments;
        
        if (tag == 1) {
            if (response.result.post_key) {
                _postKey = response .result.post_key;
                [_secondStepNetworkManager doRequest];
            } else {
                [[NSNotificationCenter defaultCenter] postNotificationName:TKPDInboxAddNewTicket object:ticket];
            }
        } else if (tag == 2) {
            if (response.result.file_uploaded) {
                _fileUploaded = response.result.file_uploaded;
                [_thirdStepNetworkManager doRequest];
            } else {
                StickyAlertView *alert = [[StickyAlertView alloc] initWithErrorMessages:@[@"Error"] delegate:self];
                [alert show];
            }
        } else if (tag == 3) {
            if ([response.result.is_success boolValue]) {
                [[NSNotificationCenter defaultCenter] postNotificationName:TKPDInboxAddNewTicket object:ticket];
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
    
    [_uploadedPhotos removeAllObjects];
    [_uploadedPhotosURL removeAllObjects];
    
    self.photoScrollView.hidden = NO;
    
    NSInteger maxIndex = selectedImages.count;
    for (int i = 0; i < self.photosImageView.count; i++) {
        UIImageView *imageView = [self.photosImageView objectAtIndex:i];
        imageView.userInteractionEnabled = NO;
        if (i < maxIndex) {
            NSDictionary *photo = [[selectedImages objectAtIndex:i] objectForKey:@"photo"];
            UIImage *image = [photo objectForKey:@"photo"];
            imageView.image = image;
            imageView.hidden = NO;
            imageView.alpha = 0.7;
        } else {
            imageView.hidden = YES;
        }
        UIButton *button = [self.removePhotoButton objectAtIndex:i];
        button.hidden = YES;
    }
    
    if (selectedImages.count < MAX_PHOTO_COUNT) {
        CGFloat width = (EACH_PHOTO_WITH_SPACING_WIDTH * maxIndex) + EACH_PHOTO_WITH_SPACING_WIDTH;
        self.photoScrollView.contentSize = CGSizeMake(width, self.photoScrollView.frame.size.height);
    } else {
        CGFloat width = EACH_PHOTO_WITH_SPACING_WIDTH * maxIndex;
        self.photoScrollView.contentSize = CGSizeMake(width, self.photoScrollView.frame.size.height);
    }
    
    if (_generateHost) {
        for (NSDictionary *photo in _selectedImagesCameraController) {
            [self requestUploadImage:@{DATA_SELECTED_PHOTO_KEY : photo}];
        }
    } else {
        [_requestHost requestGenerateHost];
    }

    UIActivityIndicatorView *indicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
    [indicatorView startAnimating];
    UIBarButtonItem *indicatorBarButton = [[UIBarButtonItem alloc] initWithCustomView:indicatorView];
    self.navigationItem.rightBarButtonItem = indicatorBarButton;
}

- (void)requestUploadImage:(NSDictionary *)object {
    RequestUploadImage *uploadImage = [RequestUploadImage new];
    uploadImage.imageObject = object;
    uploadImage.delegate = self;
    uploadImage.generateHost = _generateHost;
    uploadImage.action = API_UPLOAD_CONTACT_IMAGE_KEY;
    uploadImage.fieldName = API_FILE_TO_UPLOAD_KEY;
    [uploadImage configureRestkitUploadPhoto];
    [uploadImage requestActionUploadPhoto];
}

#pragma mark - Request upload photo delegate

- (void)successUploadObject:(id)object withMappingResult:(UploadImage *)uploadImage {
    NSDictionary *data = [object objectForKey:DATA_SELECTED_PHOTO_KEY];
    NSDictionary *photo = [data objectForKey:kTKPDCAMERA_DATAPHOTOKEY];
    UIImage *image = [photo objectForKey:@"photo"];
    if (![_uploadedPhotos containsObject:image]) {
        [_uploadedPhotos addObject:image];
        [_uploadedPhotosURL addObject:uploadImage.result.file_path];
    }
    
    for (UIImageView *imageView in self.photosImageView) {
        if ([imageView.image isEqual:image]) {
            imageView.alpha = 1;
            imageView.hidden = NO;
            UIButton *button = [self.removePhotoButton objectAtIndex:imageView.tag-1];
            button.hidden = NO;
        }
    }
    
    if (self.textView.text.length > 10) {
        _doneButton.enabled = YES;
        _doneButton.tintColor = [UIColor whiteColor];
        self.navigationItem.rightBarButtonItem = _doneButton;
    } else {
        _doneButton.enabled = NO;
        _doneButton.tintColor = [[UIColor whiteColor] colorWithAlphaComponent:0.7];
        self.navigationItem.rightBarButtonItem = _doneButton;
    }
    
    if (_uploadedPhotos.count == _selectedImagesCameraController.count) {
        if (_uploadedPhotos.count < MAX_PHOTO_COUNT) {
            UIImageView *imageView = [self.photosImageView objectAtIndex:_uploadedPhotos.count];
            imageView.image = [UIImage imageNamed:@"icon_upload_image.png"];
            imageView.userInteractionEnabled = YES;
            imageView.hidden = NO;
            
            UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(didTapPhotoImageView:)];
            [imageView addGestureRecognizer:tap];
        }
    }
    
    if (_uploadedPhotos.count < MAX_PHOTO_COUNT) {
        CGFloat width;
        if (_uploadedPhotos.count == _selectedImagesCameraController.count) {
            width = (EACH_PHOTO_WITH_SPACING_WIDTH * _uploadedPhotos.count) + EACH_PHOTO_WITH_SPACING_WIDTH;
        } else {
            width = EACH_PHOTO_WITH_SPACING_WIDTH * _uploadedPhotos.count;
        }
        self.photoScrollView.contentSize = CGSizeMake(width, self.photoScrollView.frame.size.height);
    } else {
        CGFloat width = EACH_PHOTO_WITH_SPACING_WIDTH * _uploadedPhotos.count;
        self.photoScrollView.contentSize = CGSizeMake(width, self.photoScrollView.frame.size.height);
    }
}

- (void)failedUploadObject:(id)object {
    NSDictionary *data = [object objectForKey:DATA_SELECTED_PHOTO_KEY];
    NSInteger index = [_selectedImagesCameraController indexOfObject:data];

    [_selectedImagesCameraController removeObjectAtIndex:index];
    [_selectedIndexPathCameraController removeObjectAtIndex:index];
    
    for (UIImageView *imageView in self.photosImageView) {
        imageView.image = nil;
    }
    
    NSInteger maxIndex = _selectedImagesCameraController.count;
    for (int i = 0; i < self.photosImageView.count; i++) {
        UIImageView *imageView = [self.photosImageView objectAtIndex:i];
        UIButton *button = [self.removePhotoButton objectAtIndex:i];
        if (i < maxIndex) {
            NSDictionary *photo = [[_selectedImagesCameraController objectAtIndex:i] objectForKey:@"photo"];
            UIImage *image = [photo objectForKey:@"photo"];
            imageView.image = image;
            imageView.alpha = 1;
            imageView.hidden = NO;
            button.hidden = NO;
        } else {
            imageView.hidden = YES;
            button.hidden = YES;
        }
    }
    
    if (self.textView.text.length > 10) {
        _doneButton.enabled = YES;
        _doneButton.tintColor = [UIColor whiteColor];
        self.navigationItem.rightBarButtonItem = _doneButton;
    } else {
        _doneButton.enabled = NO;
        _doneButton.tintColor = [[UIColor whiteColor] colorWithAlphaComponent:0.7];
        self.navigationItem.rightBarButtonItem = _doneButton;
    }
    
    if (_uploadedPhotos.count == _selectedImagesCameraController.count) {
        if (_uploadedPhotos.count < MAX_PHOTO_COUNT) {
            UIImageView *imageView = [self.photosImageView objectAtIndex:_uploadedPhotos.count];
            imageView.image = [UIImage imageNamed:@"icon_upload_image.png"];
            imageView.userInteractionEnabled = YES;
            imageView.hidden = NO;
            
            UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(didTapPhotoImageView:)];
            [imageView addGestureRecognizer:tap];
        }
    }
    
    if (_uploadedPhotos.count < MAX_PHOTO_COUNT) {
        CGFloat width;
        if (_uploadedPhotos.count == _selectedImagesCameraController.count) {
            width = (EACH_PHOTO_WITH_SPACING_WIDTH * _uploadedPhotos.count) + EACH_PHOTO_WITH_SPACING_WIDTH;
        } else {
            width = EACH_PHOTO_WITH_SPACING_WIDTH * _uploadedPhotos.count;
        }
        self.photoScrollView.contentSize = CGSizeMake(width, self.photoScrollView.frame.size.height);
    } else {
        CGFloat width = EACH_PHOTO_WITH_SPACING_WIDTH * _uploadedPhotos.count;
        self.photoScrollView.contentSize = CGSizeMake(width, self.photoScrollView.frame.size.height);
    }
    
    if (_uploadedPhotos.count == 0) {
        self.scrollViewContentView.hidden = YES;
    }
}

-(void)failedUploadErrorMessage:(NSArray *)errorMessage
{
    StickyAlertView *stickyAlertView = [[StickyAlertView alloc] initWithErrorMessages:errorMessage delegate:self];
    [stickyAlertView show];
    if (_uploadedPhotos.count == 0) {
        self.scrollViewContentView.hidden = YES;
    }
}

#pragma mark Request Generate Host

- (void)successGenerateHost:(GenerateHost *)generateHost
{
    _generateHost = generateHost;
    _serverID = _generateHost.result.generated_host.server_id;
    
    for (NSDictionary *photo in _selectedImagesCameraController) {
        [self requestUploadImage:@{DATA_SELECTED_PHOTO_KEY : photo}];
    }
}

- (void)failedGenerateHost:(NSArray *)errorMessages {
    StickyAlertView *alert = [[StickyAlertView alloc]initWithErrorMessages:errorMessages
                                                                  delegate:self];
    [alert show];
}

#pragma mark - Alert delegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 1) {
        if (_uploadedPhotos.count == _selectedImagesCameraController.count) {
            UIActivityIndicatorView *indicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
            [indicatorView startAnimating];
            UIBarButtonItem *indicatorBarButton = [[UIBarButtonItem alloc] initWithCustomView:indicatorView];
            self.navigationItem.rightBarButtonItem = indicatorBarButton;
            [_firstStepNetworkManager doRequest];
        } else {
            NSString *errorMessage = @"Anda belum selesai mengunggah gambar";
            StickyAlertView *alert = [[StickyAlertView alloc] initWithErrorMessages:@[errorMessage] delegate:self];
            [alert show];
        }
    }
}

- (void)dismissViewController {
    NSString *message;
    if (self.isCloseTicketForm) {
        if (self.rating) {
            message = @"Anda telah berhasil menutup kasus ini.";
        } else {
            message = @"Anda telah berhasil menutup tiket bantuan.";
        }
    } else {
        message = @"Anda telah berhasil mengirim pesan.";
    }
    
    StickyAlertView *alert = [[StickyAlertView alloc] initWithSuccessMessages:@[message] delegate:self];
    [alert show];
    
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
}

@end;
