//
//  ResolutionCenterInputViewController.m
//  Tokopedia
//
//  Created by IT Tkpd on 3/6/15.
//  Copyright (c) 2015 TOKOPEDIA. All rights reserved.
//

#import "ResolutionCenterInputViewController.h"
#import "InboxResolutionCenterOpenViewController.h"
#import "string_inbox_resolution_center.h"

#import "UploadImage.h"
#import "GenerateHost.h"
#import "camera.h"
#import "CameraController.h"
#import "detail.h"
#import "GenerateHost.h"
#import "requestGenerateHost.h"
#import "CameraAlbumListViewController.h"
#import "CameraCollectionViewController.h"
#import "RequestUploadImage.h"
#import "RequestResolutionData.h"
#import "Tokopedia-Swift.h"
#import "ResolutionCenterCreateViewController.h"

#import "GeneralTableViewController.h"

#import "StickyAlertView.h"

#define TAG_ALERT_HELPER 10
#define TAG_CHANGE_SOLUTION 11

@interface ResolutionCenterInputViewController () <UIAlertViewDelegate, UITextViewDelegate, SyncroDelegate>
{
    CGPoint _keyboardPosition;
    CGSize _keyboardSize;
    CGSize _scrollviewContentSize;
    
    NSMutableArray <DKAsset*>*_selectedImages;
}
@property (weak, nonatomic) IBOutlet UITextView *messageTextView;
@property (weak, nonatomic) IBOutlet UIView *oneButtonView;

@property (strong, nonatomic) IBOutlet UIView *threeButtonsView;
@property (weak, nonatomic) IBOutlet UILabel *lastSolutionLabel;
@property (weak, nonatomic) IBOutlet UILabel *buyerSellerLabel;
@property (weak, nonatomic) IBOutlet UILabel *createDateLabel;
@property (strong, nonatomic) IBOutlet UIView *headerView;
@property (weak, nonatomic) IBOutlet UIButton *helperButton;
@property (weak, nonatomic) IBOutlet UIButton *editSolutionButton;
@property (strong, nonatomic) IBOutlet UIView *twoButtonView;
@property (strong, nonatomic) IBOutlet UIView *footerView;
@property (weak, nonatomic) IBOutlet UIButton *secondFooterButton;

@property (strong, nonatomic) IBOutletCollection(UIButton) NSArray *uploadButtons;
@property (strong, nonatomic) IBOutletCollection(UIButton) NSArray *cancelButtons;
@property (strong, nonatomic) IBOutlet UIScrollView *imageScrollView;
@property (strong, nonatomic) IBOutlet UIView *imageContentView;

@property (strong, nonatomic) IBOutletCollection(UIButton) NSArray *attachButtons;


@end
#define TAG_BAR_BUTTON_TRANSACTION_BACK 10
#define TAG_BAR_BUTTON_TRANSACTION_SEND 11

@implementation ResolutionCenterInputViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    CGRect screenRect = [[UIScreen mainScreen] bounds];
    CGFloat screenWidth = screenRect.size.width;
    
    CGRect frame = _headerView.frame;
    frame.size.width = screenWidth;
    _headerView.frame = frame;
    
    _selectedImages = [NSMutableArray new];
    
    _uploadButtons = [NSArray sortViewsWithTagInArray:_uploadButtons];
    _cancelButtons = [NSArray sortViewsWithTagInArray:_cancelButtons];
    
    UIBarButtonItem *barButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Batal" style:UIBarButtonItemStylePlain target:(self) action:@selector(tapCancel:)];
    [barButtonItem setTintColor:[UIColor whiteColor]];
    self.navigationItem.leftBarButtonItem = barButtonItem;
    
    if ([_messageTextView.text isEqualToString:@""]) {
        [self setTextViewPlaceholder:@"Isi pesan diskusi disini..."];
    }
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillShow:)
                                                 name:UIKeyboardWillShowNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillHide:)
                                                 name:UIKeyboardWillHideNotification object:nil];
    
    [self adjustFooterButton];
    [self adjustActionLabel];
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"dd MMMM yyyy HH:mm"];
    
    _createDateLabel.text = [formatter stringFromDate:[NSDate date]];
    
    [_lastSolutionLabel setCustomAttributedText:_lastSolution];
    
    [_messageTextView becomeFirstResponder];
}

-(void)adjustActionLabel
{
    NSString *actionByString;
    UIColor *actionByBgColor;
    
    if(_resolution.resolution_by.by_customer == 1)
    {
        actionByString = @"Pembeli";
        actionByBgColor = COLOR_BUYER;
    }
    else
    {
        actionByString = @"Penjual";
        actionByBgColor = COLOR_SELLER;
    }
    
    _buyerSellerLabel.backgroundColor = actionByBgColor;
    _buyerSellerLabel.text = actionByString;
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    _messageTextView.autocorrectionType = UITextAutocorrectionTypeNo;
}

- (void)setTextViewPlaceholder:(NSString *)placeholderText
{
    _messageTextView.delegate = self;
    [_messageTextView addSubview:_headerView];
    
    UIEdgeInsets inset = _messageTextView.textContainerInset;
    inset.left = 18;
    inset.top = _headerView.frame.size.height;
    UILabel *placeholderLabel = [[UILabel alloc] initWithFrame:CGRectMake(inset.left, inset.top, _messageTextView.frame.size.width, 40)];
    placeholderLabel.text = placeholderText;
    placeholderLabel.font = [UIFont fontWithName:_messageTextView.font.fontName size:_messageTextView.font.pointSize];
    placeholderLabel.textColor = [[UIColor blackColor] colorWithAlphaComponent:0.25];
    placeholderLabel.tag = 1;
    [_messageTextView addSubview:placeholderLabel];
    
    CGRect frame = _footerView.frame;
    CGRect screenRect = [[UIScreen mainScreen] bounds];
    CGFloat screenHeight = screenRect.size.height;
    frame.origin.y = screenHeight - _footerView.frame.size.height;
    _footerView.frame = frame;
    [self.view addSubview:_footerView];
}

- (void)textViewDidChange:(UITextView *)textView
{
    UILabel *placeholderLabel = (UILabel *)[textView viewWithTag:1];
    if (textView.text.length > 0) {
        placeholderLabel.hidden = YES;
    } else {
        placeholderLabel.hidden = NO;
    }
    CGRect frame = _imageScrollView.frame;
    frame.origin.y = _messageTextView.contentSize.height;
    _imageScrollView.frame = frame;
}

-(void)viewDidLayoutSubviews
{
    UIEdgeInsets inset = _messageTextView.textContainerInset;
    inset.left = 15;
    inset.top = _headerView.frame.size.height + 10;
    _messageTextView.textContainerInset = inset;
    
    CGRect frame = _footerView.frame;
    frame.size.width = _messageTextView.frame.size.width;
    _footerView.frame = frame;
}

-(void)adjustFooterButton
{
    int buttonCount = 0;
    if (_resolution.resolution_can_conversation == 1) {
        buttonCount+=1;
        UIBarButtonItem *barButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Kirim" style:UIBarButtonItemStyleDone target:(self) action:@selector(tapSendReply:)];
        [barButtonItem setTintColor:[UIColor whiteColor]];
        self.navigationItem.rightBarButtonItem = barButtonItem;
        
        if (_resolution.resolution_button.button_edit == 1) {
            buttonCount+=1;
            [_secondFooterButton setTitle:@"Ubah Solusi" forState:UIControlStateNormal];
        }
        if (_resolution.resolution_button.button_report == 1) {
            buttonCount+=1;
            [_secondFooterButton setTitle:@"Bantuan" forState:UIControlStateNormal];
        }
    }
    
    if (buttonCount == 3) {
        _oneButtonView.hidden = YES;
        _twoButtonView.hidden = YES;
        _threeButtonsView.hidden = NO;
    }
    else if (buttonCount == 2)
    {
        _oneButtonView.hidden = YES;
        _twoButtonView.hidden = NO;
        _threeButtonsView.hidden = YES;
    }
    else
    {
        _oneButtonView.hidden = NO;
        _twoButtonView.hidden = YES;
        _threeButtonsView.hidden = YES;
    }
}

-(BOOL)isValid
{
    BOOL isValid = YES;
    NSMutableArray *errorMessage = [NSMutableArray new];
    
    if ([_messageTextView.text isEqualToString:@""] ||
        !_messageTextView.text) {
        [errorMessage addObject:ERRORMESSAGE_NULL_MESSAGE];
        isValid = NO;
    }
    
    if (!isValid) {
        StickyAlertView *alert = [[StickyAlertView alloc]initWithErrorMessages:errorMessage delegate:self];
        [alert show];
    }
    
    return  isValid;
}

-(void)tapSendReply:(UIBarButtonItem*)button{
    if ([self isValid]) {
        [self doRequestReplyResolutionButton:button];
    }
}

-(void)tapCancel:(UIBarButtonItem*)button{
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)tapEditSolution:(UIButton *)sender {
    [self didTapEditSolutionButton];
}

- (IBAction)tapHelp:(UIButton *)sender {
    [self didTapReportButton];
}

- (IBAction)tapEditorReportButton:(UIButton *)sender {
    if (_resolution.resolution_button.button_edit == 1) {
        [self didTapEditSolutionButton];
    }
    else if (_resolution.resolution_button.button_report == 1) {
        [self didTapReportButton];
    }
}

- (IBAction)tapDeleteImage:(UIButton*)button {
    [_selectedImages removeObjectAtIndex:button.tag];
    [self setSelectedImages];
}

- (IBAction)tapImageButton:(UIButton*)sender
{
    [self doSelectPhotos];
}

-(void)didTapReportButton
{
    UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Konfirmasi Bantuan" message:@"Apakah Anda yakin ingin meminta bantuan Tokopedia untuk memutuskan resolusinya?" delegate:self cancelButtonTitle:@"Batal" otherButtonTitles:@"Ya", nil];
    alert.tag = TAG_ALERT_HELPER;
    [alert show];
}

-(void)didTapEditSolutionButton
{
    BOOL isSeller = (_resolution.resolution_by.by_seller == 1);
    BOOL isGotTheOrder = [_resolution.resolution_last.last_flag_received boolValue];

    if (isSeller) {
        [self doChangeSolutionIsGotTheOrder:isGotTheOrder isSeller:isSeller];
    }
    else
    {
        if (isGotTheOrder) {
            [self doChangeSolutionIsGotTheOrder:isGotTheOrder isSeller:isSeller];
        }
        else
        {
            UIAlertView *alertChangeSolution = [[UIAlertView alloc]initWithTitle:@"Apakah barang telah diterima?" message:@"Anda tidak bisa mengubah menjadi tidak terima barang, setelah Anda konfirmasi terima barang." delegate:self cancelButtonTitle:@"Batal" otherButtonTitles:@"Ya",@"Tidak", nil];
            alertChangeSolution.tag = TAG_CHANGE_SOLUTION;
            [alertChangeSolution show];
        }
    }
}

-(void)doChangeSolutionIsGotTheOrder:(BOOL)isGotTheOrder isSeller:(BOOL)isSeller
{
    if (isSeller) {
        EditSolutionSellerViewController *controller = [EditSolutionSellerViewController new];
        controller.isGetProduct = isGotTheOrder;
        controller.resolutionID = _resolutionID;
        [controller didSuccessEdit:^(ResolutionLast *solutionLast, ResolutionConversation * conversationLast, BOOL replyEnable) {
            if ([_delegate respondsToSelector:@selector(addResolutionLast:conversationLast:replyEnable:)]){
                [_delegate addResolutionLast:solutionLast conversationLast:conversationLast replyEnable:YES];
            }
        }];
        [self.navigationController pushViewController:controller animated:YES];
    }else {
        ResolutionCenterCreateViewController *vc = [ResolutionCenterCreateViewController new];
        vc.product_is_received = isGotTheOrder;
        [self.navigationController pushViewController:vc animated:YES];
    }
}

-(void)syncroImages:(NSArray *)images message:(NSString *)message refundAmount:(NSString *)refundAmount
{
    [_selectedImages removeAllObjects];
    [_selectedImages addObjectsFromArray:images];
    [self setSelectedImages];
    _messageTextView.text = message;
}

#pragma mark - Camera Delegate
-(void)doSelectPhotos{
    [_messageTextView resignFirstResponder];
    __weak typeof(self) wself = self;
    [ImagePickerController showImagePicker:self
                                 assetType:DKImagePickerControllerAssetTypeallPhotos
                       allowMultipleSelect:YES
                                showCancel:YES
                                showCamera:YES
                               maxSelected:5
                            selectedAssets:_selectedImages
                                completion:^(NSArray<DKAsset *> * images) {
                                    dispatch_async(dispatch_get_main_queue(), ^{
                                        if (wself != nil) {
                                            typeof(self) sself = wself;
                                            [sself->_selectedImages removeAllObjects];
                                            [sself->_selectedImages addObjectsFromArray:images];
                                            [sself setSelectedImages];
                                        }
                                    });
    }];
}

-(void)setSelectedImages{
    for (UIButton *button in _uploadButtons) {
        button.hidden = YES;
        [button setBackgroundImage:[UIImage imageNamed:@"icon_upload_image.png"] forState:UIControlStateNormal];
    }
    for (UIButton *button in _cancelButtons) { button.hidden = YES; }
    for (int i = 0; i<_selectedImages.count; i++) {
        ((UIButton*)_uploadButtons[i]).hidden = NO;
        ((UIButton*)_cancelButtons[i]).hidden = NO;
        [_uploadButtons[i] setBackgroundImage:_selectedImages[i].thumbnailImage forState:UIControlStateNormal];
    }
    UIButton *uploadedButton = (UIButton*)_uploadButtons[0];
    
    if (_selectedImages.count<_uploadButtons.count) {
        uploadedButton = (UIButton*)_uploadButtons[_selectedImages.count];
    } else{
         uploadedButton = (UIButton*)_uploadButtons[4];
    }
    uploadedButton.hidden = NO;
    _imageScrollView.contentSize = CGSizeMake(uploadedButton.frame.origin.x+uploadedButton.frame.size.width+20, 0);

    if (_selectedImages.count == 0) {
        [_imageScrollView removeFromSuperview];
    } else{
        [_messageTextView addSubview:_imageScrollView];
        CGRect frame = _imageScrollView.frame;
        frame.origin.y = _messageTextView.contentSize.height;
        _imageScrollView.frame = frame;
        frame = _imageScrollView.frame;
    }
}

#pragma mark - alert view Delegate
-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (alertView.tag == TAG_ALERT_HELPER) {
        if (buttonIndex == 1) {
            [self doRequestReport];
        }
    }
    if (alertView.tag == TAG_CHANGE_SOLUTION)
    {
        BOOL isSeller = (_resolution.resolution_by.by_seller == 1);
        [self doChangeSolutionIsGotTheOrder:(buttonIndex == 1) isSeller:isSeller];
    }
}

#pragma mark - Keyboard Notification
- (void)keyboardWillShow:(NSNotification *)aNotification {
        [UIView animateWithDuration:TKPD_FADEANIMATIONDURATION
                              delay:0
                            options: UIViewAnimationOptionCurveEaseOut
                         animations:^{
                             _scrollviewContentSize = [_messageTextView contentSize];
                             _scrollviewContentSize.height -= _keyboardSize.height;
                             
                             _keyboardPosition = [[[aNotification userInfo]objectForKey:UIKeyboardFrameEndUserInfoKey]CGRectValue].origin;
                             _keyboardSize= [[[aNotification userInfo]objectForKey:UIKeyboardFrameEndUserInfoKey]CGRectValue].size;
                             _scrollviewContentSize.height += _keyboardSize.height;
                             
                             CGRect frame = _footerView.frame;
                             frame.origin.y = _keyboardPosition.y - _footerView.frame.size.height - _headerView.frame.size.height + 20;
                             _footerView.frame = frame;
                             
                             UIEdgeInsets inset = _messageTextView.contentInset;
                             inset.bottom = _footerView.frame.origin.y;
                             [_messageTextView setContentInset:inset];
                         }
                         completion:^(BOOL finished){
                         }];
    
}

- (void)keyboardWillHide:(NSNotification *)aNotification {
    NSDictionary* info = [aNotification userInfo];
    CGRect kbFrame = [[info objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
    
    [UIView animateWithDuration:TKPD_FADEANIMATIONDURATION
                          delay:0
                        options: UIViewAnimationOptionCurveEaseInOut
                     animations:^{
                         if (kbFrame.origin.y>self.view.frame.size.height) {
                             
                         }
                         CGRect frame = _footerView.frame;
                         frame.origin.y = self.view.frame.size.height - _footerView.frame.size.height;
                         if (frame.origin.y<self.view.frame.size.height) {
                             _footerView.frame = frame;
                         }
                     }
                     completion:^(BOOL finished){
                     }];
    
    UIEdgeInsets inset = _messageTextView.contentInset;
    inset.bottom = 0;
    [_messageTextView setContentInset:inset];
}

#pragma mark - Request Reply
-(void)doRequestReplyResolutionButton:(UIBarButtonItem*)sendButton{
    sendButton.enabled = NO;
    [RequestResolutionAction fetchReplyResolutionID:_resolutionID?:@""
                                       flagReceived:[_resolution.resolution_last.last_flag_received stringValue]
                                        troubleType:[_resolution.resolution_last.last_solution stringValue]?:@""
                                           solution:[_resolution.resolution_last.last_trouble_type stringValue]?:@""
                                       refundAmount:[_resolution.resolution_last.last_refund_amt stringValue]?:@""
                                            message:_messageTextView.text?:@""
                                     isEditSolution:@"0"
                                       imageObjects:_selectedImages
                                            success:^(ResolutionActionResult *data) {
                                                sendButton.enabled = YES;
                                                if ([_delegate respondsToSelector:@selector(addResolutionLast:conversationLast:replyEnable:)]){
                                                    [_delegate addResolutionLast:data.solution_last conversationLast:data.conversation_last[0] replyEnable:YES];
                                                }
                                                [self.navigationController popViewControllerAnimated:YES];
                                                
                                            } failure:^(NSError *error) {
                                                sendButton.enabled = YES;
                                            }];
}

#pragma mark - Request Report
-(void)doRequestReport{
    [RequestResolutionAction fetchReportResolutionID:_resolutionID?:@""
                                             success:^(ResolutionActionResult *data) {
                                                 if ([_delegate respondsToSelector:@selector(hideReportButton:)]) {
                                                     [_delegate hideReportButton:YES];
                                                 }
                                                 if ([_delegate respondsToSelector:@selector(addResolutionLast:conversationLast:replyEnable:)]){
                                                     [_delegate addResolutionLast:data.solution_last conversationLast:data.conversation_last[0] replyEnable:YES];
                                                 }
                                                 [self.navigationController popViewControllerAnimated:YES];
                                                 
                                             } failure:^(NSError *error) {
                                             }];
}

@end
