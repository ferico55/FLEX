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

#import "InboxTicketDetailAttachment.h"
#import "Tokopedia-Swift.h"

//only visible in this file
static NSInteger const EACH_PHOTO_WITH_SPACING_WIDTH = 90;
static NSInteger const MAX_PHOTO_COUNT = 5;

@interface InboxTicketReplyViewController ()
<
    UITextViewDelegate,
    UIScrollViewDelegate,
    UIGestureRecognizerDelegate,
    UIAlertViewDelegate
>
{
    CGRect _keyboardFrameBeginRect;
    UIBarButtonItem *_doneButton;
    NSMutableArray<AttachedImageObject*>* _selectedImages;
    BOOL _cameraButtonClicked;
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
                                                                     style:UIBarButtonItemStylePlain
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
    
    if (_selectedImages.count > 0) {
        NSInteger maxWidth = _selectedImages.count * EACH_PHOTO_WITH_SPACING_WIDTH;
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
        __weak typeof(self) weakSelf = self;
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:title message:message preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *changeSolution = [UIAlertAction actionWithTitle:@"Ya" style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) {
            [weakSelf requestReplayTicket];
        }];
        [alert addAction: changeSolution];
        UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"Batal" style:UIAlertActionStyleCancel handler:^(UIAlertAction * action) {
            [alert dismissViewControllerAnimated:YES completion:nil];
        }];
        [alert addAction: cancel];
        [self presentViewController:alert animated:YES completion:nil];
        
    } else {
        
        [self requestReplayTicket];

    }
}

- (IBAction)didTouchUpCameraButton:(UIButton *)sender {
    [self openPhotoGallery];
}

- (IBAction)didTapPhotoImageView:(UITapGestureRecognizer *)sender {
    [self openPhotoGallery];
}

- (void)openPhotoGallery {
    self.scrollViewContentView.hidden = NO;
    
    _cameraButtonClicked = YES;
    
    [self.textView resignFirstResponder];
    self.attachmentButtonBottomConstraint.constant = 0;
    
    int maxCountSelectImage = 5;
    
    __weak typeof(self) wself = self;
    [ImagePickerController
     showImagePicker:self
     assetType:DKImagePickerControllerAssetTypeallPhotos
     allowMultipleSelect:YES
     showCancel:YES
     showCamera:YES
     maxSelected: maxCountSelectImage - _selectedImages.count
     selectedAssets:[self getSelectedAssets]
     completion:^(NSArray<DKAsset *> * assets) {
         
         [wself setSelectedAsset:assets];
         
    }];
}

-(NSArray<DKAsset*>*)getSelectedAssets{
    NSMutableArray *assets = [NSMutableArray new];
    for (AttachedImageObject *image in _selectedImages) {
        [assets addObject:image];
    }
    
    return assets;
}

-(void)setSelectedAsset:(NSArray<DKAsset*>*)selectedAssets{
    
    [_selectedImages removeAllObjects];
    
    if (!_selectedImages){
        _selectedImages = [NSMutableArray new];
    }
    
    for (int i= 0; i<selectedAssets.count; i++) {
        AttachedImageObject *object = [AttachedImageObject new];
        object.asset = selectedAssets[i];
        object.imageID = [NSString stringWithFormat:@"%@%zd",[self timeStamp], i];
        [_selectedImages addObject:object];
    }
    
    [self setImageViews];
}

- (NSString *) timeStamp {
    return [NSString stringWithFormat:@"%f",[[NSDate date] timeIntervalSince1970] * 1000];
}

-(void)setImageViews{
    
    for (UIButton *button in _removePhotoButton) {
        button.hidden = YES;
    }
    
    for (UIImageView *imageView in _photosImageView) {
        imageView.hidden = YES;
        imageView.image  = [UIImage imageNamed:@"icon_upload_image.png"];
        imageView.userInteractionEnabled = YES;
    }
    
    for (int i = 0; i<_selectedImages.count; i++) {
        if (i<_photosImageView.count) {
            ((UIImageView*)_photosImageView[i]).hidden = NO;
            ((UIImageView*)_photosImageView[i]).image = _selectedImages[i].asset.thumbnailImage;
            ((UIButton*)_removePhotoButton[i]).hidden = NO;
            ((UIImageView*)_photosImageView[i]).userInteractionEnabled = NO;
        }
    }
    if (_selectedImages.count<_photosImageView.count) {
        UIImageView *addImageView = _photosImageView[_selectedImages.count];
        addImageView.hidden = NO;
        
        _photoScrollView.contentSize = CGSizeMake(addImageView.frame.origin.x+addImageView.frame.size.width+30, 0);
    }
}


- (IBAction)didTapRemovePhotoButton:(UIButton *)button {
    NSInteger index = button.tag - 1;
    [_selectedImages removeObjectAtIndex:index];
    [self setImageViews];
    
    if (_selectedImages.count > 0) {
        NSInteger maxWidth = _selectedImages.count * EACH_PHOTO_WITH_SPACING_WIDTH;
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
    
    _doneButton.enabled = YES;
    _doneButton.tintColor = [UIColor whiteColor];
}

#pragma mark - Network manager delegate

-(NSString*)newTicketStatus{
    NSString *newTicketStatus;
    if ([self.inboxTicket.ticket_status isEqualToString:@"1"]) {
        newTicketStatus = self.isCloseTicketForm?@"2":@"";
    } else {
        newTicketStatus = self.isCloseTicketForm?@"2":@"1";
    }
    
    return newTicketStatus;
}


-(void)notifySuccessReplay{
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd'T'HH:mm'Z'"];
    
    UserAuthentificationManager *auth = [UserAuthentificationManager new];
    NSDictionary *userData = [auth getUserLoginData];
    
    
    NSMutableArray *attachments = [NSMutableArray new];
    for (int i= 0;i< _selectedImages.count; i++) {
        InboxTicketDetailAttachment *attachment = [InboxTicketDetailAttachment new];
        attachment.img = _selectedImages[i].asset.thumbnailImage;
        [attachments addObject:attachment];
    }

    InboxTicketDetail *ticket = [InboxTicketDetail new];
    ticket.ticket_detail_create_time = [dateFormatter stringFromDate:[NSDate new]];
    ticket.ticket_detail_user_name = [userData objectForKey:@"full_name"];
    ticket.ticket_detail_user_image = [userData objectForKey:@"user_image"];
    ticket.ticket_detail_is_cs = @"0";
    ticket.ticket_detail_message = self.textView.text;
    ticket.ticket_detail_attachment = attachments;
    [[NSNotificationCenter defaultCenter] postNotificationName:TKPDInboxAddNewTicket object:ticket];
}

#pragma mark - Request
-(ReplayTicketRequestObject*)objectRequest{
    ReplayTicketRequestObject *object = [ReplayTicketRequestObject new];
    object.selectedImages = _selectedImages;
    object.rate = _rating;
    object.newTicketStatus = [self newTicketStatus];
    object.ticketID = _inboxTicket.ticket_id;
    object.message = self.textView.text;
    return object;
}

-(void)requestReplayTicket{
    
    UIActivityIndicatorView *indicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
    [indicatorView startAnimating];
    UIBarButtonItem *indicatorBarButton = [[UIBarButtonItem alloc] initWithCustomView:indicatorView];
    self.navigationItem.rightBarButtonItem = indicatorBarButton;
    
    [InboxTicketRequest fetchReplayTicket:[self objectRequest] onSuccess:^{
        
        [self notifySuccessReplay];
        self.navigationItem.rightBarButtonItem = _doneButton;
        
    } onFailure:^{
        
        self.navigationItem.rightBarButtonItem = _doneButton;
        
    }];
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
