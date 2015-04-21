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

#import "GeneralTableViewController.h"

#import "StickyAlertView.h"

#define TAG_ALERT_HELPER 10
#define TAG_CHANGE_SOLUTION 11

@interface ResolutionCenterInputViewController () <UIAlertViewDelegate, UITextViewDelegate, SyncroDelegate, GenerateHostDelegate, CameraCollectionViewControllerDelegate, CameraControllerDelegate, RequestUploadImageDelegate>
{
    NSMutableArray *_uploadedPhotos;
    GenerateHost *_generatehost;
    NSMutableArray *_uploadingPhotos;
    
    NSOperationQueue *_operationQueue;
    
    __weak RKObjectManager *_objectManagerComplain;
    __weak RKManagedObjectRequestOperation *_requestComplain;
    
    __weak RKObjectManager *_objectManagerUploadPhoto;
    NSURLRequest *_requestActionUploadPhoto;
    
    __weak RKObjectManager *_objectManagerGenerateHost;
    __weak RKManagedObjectRequestOperation *_requestGenerateHost;
    
    BOOL _isFinishUploadingImage;
    
    CGPoint _keyboardPosition;
    CGSize _keyboardSize;
    CGSize _scrollviewContentSize;
    
    NSMutableArray *_selectedImagesCameraController;
    NSMutableArray *_selectedIndexPathCameraController;
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
@property (strong, nonatomic) IBOutletCollection(UIImageView) NSArray *thumbImages;
@property (strong, nonatomic) IBOutlet UIScrollView *imageScrollView;
@property (weak, nonatomic) IBOutlet UIView *imageContentView;

@property (strong, nonatomic) IBOutletCollection(UIButton) NSArray *attachButtons;


@end
#define TAG_BAR_BUTTON_TRANSACTION_BACK 10
#define TAG_BAR_BUTTON_TRANSACTION_SEND 11

@implementation ResolutionCenterInputViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _operationQueue = [NSOperationQueue new];
    _generatehost = [GenerateHost new];
    
    _uploadingPhotos = [NSMutableArray new];
    _uploadedPhotos = [[NSMutableArray alloc]initWithObjects:@"",@"",@"",@"",@"", nil];
    _selectedImagesCameraController = [NSMutableArray new];
    _selectedIndexPathCameraController = [NSMutableArray new];
    
    _uploadButtons = [NSArray sortViewsWithTagInArray:_uploadButtons];
    _cancelButtons = [NSArray sortViewsWithTagInArray:_cancelButtons];
    _thumbImages = [NSArray sortViewsWithTagInArray:_thumbImages];
    
    [_cancelButtons makeObjectsPerformSelector:@selector(setHidden:)withObject:@(YES)];
    [_uploadButtons makeObjectsPerformSelector:@selector(setEnabled:)withObject:@(NO)];
    
    UIBarButtonItem *barButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Batal" style:UIBarButtonItemStylePlain target:(self) action:@selector(tap:)];
    [barButtonItem setTintColor:[UIColor whiteColor]];
    barButtonItem.tag = TAG_BAR_BUTTON_TRANSACTION_BACK;
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
    
    RequestGenerateHost *requestHost = [RequestGenerateHost new];
    [requestHost configureRestkitGenerateHost];
    [requestHost requestGenerateHost];
    requestHost.delegate = self;
    
    _isFinishUploadingImage = YES;
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"dd MMMM yyyy HH:mm"];
    
    _createDateLabel.text = [formatter stringFromDate:[NSDate date]];
}
-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    _messageTextView.autocorrectionType = UITextAutocorrectionTypeNo;
    [_messageTextView becomeFirstResponder];
    

    if ( [self totalUploadedAndUploadingImage] >= 3) {
        _imageScrollView.contentSize = _imageContentView.frame.size;
    }
}

-(NSInteger)totalUploadedAndUploadingImage
{
    NSMutableArray *fileThumbImage = [NSMutableArray new];
    for (NSString *image in _uploadedPhotos) {
        if (![image isEqualToString:@""]) {
            [fileThumbImage addObject:image];
        }
    }
    
    return fileThumbImage.count + _uploadingPhotos.count;
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

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)viewDidLayoutSubviews
{
    UIEdgeInsets inset = _messageTextView.textContainerInset;
    inset.left = 15;
    inset.top = _headerView.frame.size.height + 10;
    _messageTextView.textContainerInset = inset;
}

-(void)scrollViewWillBeginDecelerating:(UIScrollView *)scrollView
{
    [_messageTextView resignFirstResponder];
}

-(void)adjustFooterButton
{
    int buttonCount = 0;
    if (_resolution.resolution_can_conversation == 1) {
        buttonCount+=1;
        UIBarButtonItem *barButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Kirim" style:UIBarButtonItemStylePlain target:(self) action:@selector(tap:)];
        [barButtonItem setTintColor:[UIColor whiteColor]];
        barButtonItem.tag = TAG_BAR_BUTTON_TRANSACTION_SEND;
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
    
    if (!_isFinishUploadingImage) {
        [errorMessage addObject:@"Belum selesai mengupload image."];
        isValid = NO;
    }
    
    if (!isValid) {
        StickyAlertView *alert = [[StickyAlertView alloc]initWithErrorMessages:errorMessage delegate:self];
        [alert show];
    }
    
    return  isValid;
}

- (IBAction)tap:(id)sender {
    [_messageTextView resignFirstResponder];
    if ([sender isKindOfClass:[UIBarButtonItem class]]) {
        UIBarButtonItem *barbutton = (UIBarButtonItem*)sender;
        if (barbutton.tag == TAG_BAR_BUTTON_TRANSACTION_BACK) {
            [self.navigationController popViewControllerAnimated:YES];
        }
        else if (barbutton.tag == TAG_BAR_BUTTON_TRANSACTION_SEND) {
            if ([self isValid]) {
                NSString *photos = [[_uploadedPhotos valueForKey:@"description"] componentsJoinedByString:@"~"]?:@"";
                [_delegate message:_messageTextView.text
                             photo:photos?:@""
                          serverID:_generatehost.result.generated_host.server_id?:@""];
                [self.navigationController popViewControllerAnimated:YES];
            }
        }
    }
    
    else
    {
        UIButton *button = (UIButton*)sender;
        switch (button.tag) {
            case 10:
            {
                if ([self totalUploadedAndUploadingImage] == 0)
                {
                    [self didTapImageButton:(UIButton*)sender];
                }
                else
                {
                    for (UIImageView *imageView in _thumbImages) {
                        if (imageView.image == nil)
                        {
                            UIButton *button = [UIButton new];
                            button.tag = imageView.tag;
                            [self didTapImageButton:button];
                            break;
                        }
                    }

                }
            }
                break;
            case 11:
                //Bantuan
                [self didTapReportButton];
                break;
            case 12:
                //ubah solusi
                [self didTapEditSolutionButton];
                break;
            case 13:
            {
                if (_resolution.resolution_button.button_edit == 1) {
                    [self didTapEditSolutionButton];
                }
                else if (_resolution.resolution_button.button_report == 1) {
                    [self didTapReportButton];
                }
            }
                break;
            default:
                break;
        }
    }
}

- (IBAction)tapUploadImage:(id)sender {
    [self didTapImageButton:(UIButton*)sender];
}

- (IBAction)tapDeleteImage:(UIButton*)sender {
    
    [_uploadedPhotos replaceObjectAtIndex:sender.tag-10 withObject:@""];
    [_selectedImagesCameraController replaceObjectAtIndex:sender.tag - 10 withObject:@""];
    [_selectedIndexPathCameraController replaceObjectAtIndex:sender.tag -10 withObject:@""];
    
    if ([self totalUploadedAndUploadingImage] == 0) {
        [_imageScrollView removeFromSuperview];
    }
    
    for (UIImageView *imageView in _thumbImages) {
        if (imageView.tag == sender.tag)
        {
            imageView.image = nil;
        }
    }
    for (UIButton *button in _cancelButtons) {
        if (button.tag == sender.tag)
        {
            button.hidden = YES;
        }
    }
    for (UIButton *button in _uploadButtons) {
        if (button.tag == sender.tag)
        {
            button.hidden = NO;
        }
    }
}

-(void)didTapImageButton:(UIButton*)sender
{
    CGRect frame = _imageScrollView.frame;
    frame.origin.y = _messageTextView.contentSize.height;
    if (frame.origin.y <= 33) {
        frame.origin.y += _headerView.frame.size.height;
    }
    _imageScrollView.frame = frame;
    [_messageTextView addSubview:_imageScrollView];
    
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

-(void)didTapReportButton
{
    UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Konfirmasi Bantuan" message:@"Apakah Anda yakin ingin meminta bantuan Tokopedia untuk memutuskan resolusinya?" delegate:self cancelButtonTitle:@"Batal" otherButtonTitles:@"Ya", nil];
    alert.tag = TAG_ALERT_HELPER;
    [alert show];
}

-(void)didTapEditSolutionButton
{
    
    BOOL isGotTheOrder = [_resolution.resolution_last.last_flag_received boolValue];
    if (isGotTheOrder) {
        [self resolutionOpenIsGotTheOrder:isGotTheOrder];
    }
    else
    {
        UIAlertView *alertChangeSolution = [[UIAlertView alloc]initWithTitle:@"Apakah barang telah diterima?" message:@"Anda tidak bisa mengubah menjadi tidak terima barang, setelah Anda konfirmasi terima barang." delegate:self cancelButtonTitle:@"Batal" otherButtonTitles:@"Ya",@"Tidak", nil];
        alertChangeSolution.tag = TAG_CHANGE_SOLUTION;
        [alertChangeSolution show];
    }
}

-(void)resolutionOpenIsGotTheOrder:(BOOL)isGotTheOrder
{
    InboxResolutionCenterOpenViewController *vc = [InboxResolutionCenterOpenViewController new];
    vc.isGotTheOrder = isGotTheOrder;
    vc.isChangeSolution = YES;
    vc.detailOpenAmount = _resolution.resolution_order.order_open_amount;
    vc.detailOpenAmountIDR = _resolution.resolution_order.order_open_amount_idr;
    vc.shippingPriceIDR = _resolution.resolution_order.order_shipping_price_idr;
    vc.selectedProblem = [self trouble];
    vc.selectedSolution = [self solution];
    vc.invoice = _resolution.resolution_order.order_invoice_ref_num;
    vc.note = _messageTextView.text;
    NSArray *viewControllers = self.navigationController.viewControllers;
    UIViewController *destinationVC = viewControllers[viewControllers.count-2];
    vc.delegate = destinationVC;
    vc.syncroDelegate = self;
    NSMutableArray *thumbs = [NSMutableArray new];
    for (NSString *thumb in _uploadedPhotos) {
        if (![thumb isEqualToString:@""]) {
            [thumbs addObject:thumb];
        }
    }
    vc.uploadedPhotos = thumbs;
    vc.controllerTitle = @"Ubah Solusi";
    NSString *totalRefund = [_resolution.resolution_last.last_refund_amt stringValue];
    NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
    [formatter setGroupingSeparator:@"."];
    [formatter setGroupingSize:3];
    NSString *num = totalRefund;
    NSString *str = [formatter stringFromNumber:[NSNumber numberWithDouble:[num doubleValue]]];
    totalRefund = str;
    vc.totalRefund = totalRefund;
    
    if (_resolution.resolution_by.by_customer == 1) {
        vc.shopName = _resolution.resolution_shop.shop_name;
        vc.shopPic = _resolution.resolution_shop.shop_image;
        vc.buyerSellerLabel.text = @"Pembelian dari";
        vc.isCanEditProblem = YES;
    }
    if (_resolution.resolution_by.by_seller == 1) {
        vc.shopName = _resolution.resolution_customer.customer_name;
        vc.shopPic = _resolution.resolution_customer.customer_image;
        vc.buyerSellerLabel.text = @"Pembelian oleh";
        vc.isActionBySeller = YES;
        vc.isCanEditProblem = NO;
    }
    
    [self.navigationController pushViewController:vc animated:YES];
}

-(void)syncroImages:(NSArray *)images message:(NSString *)message
{
    [_uploadedPhotos removeAllObjects];
    [_uploadedPhotos addObjectsFromArray:images];
    
    NSMutableArray *listImage = [NSMutableArray new];
    for (NSString *image in images) {
        if (![image isEqualToString:@""]) {
            [listImage addObject:image];
        }
    }
    for (int i = 0; i<_thumbImages.count; i++) {
        ((UIImageView*)_thumbImages[i]).image = nil;
        ((UIButton*)_cancelButtons[i]).hidden = YES;
        ((UIButton*)_uploadButtons[i]).hidden = YES;
    }
    
    [self setImages:listImage];
    
    _messageTextView.text = message;
}

- (void)setImages:(NSArray *)images
{
    if (images.count>0) {
        for (int i = 0; i<images.count; i++) {
            NSURLRequest* request = [[NSURLRequest alloc] initWithURL:[NSURL URLWithString:images[i]] cachePolicy:
                                     NSURLRequestUseProtocolCachePolicy timeoutInterval:kTKPDREQUEST_TIMEOUTINTERVAL];
            
            UIImageView *thumb = (UIImageView*)_thumbImages[i];
            thumb.image = nil;
            [thumb setImageWithURLRequest:request placeholderImage:nil success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-retain-cycles"
                [thumb setImage:image animated:YES];
#pragma clang diagnostic pop
            } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) {
            }];
            
            [(UIButton*)_cancelButtons[i] setHidden:NO];
            [(UIButton*)_uploadButtons[i] setHidden:YES];
            if (i<_uploadButtons.count-1) {
                [(UIButton*)_uploadButtons[i+1] setHidden:NO];
            }
        }
    }
}

#pragma mark - Camera Delegate
-(void)didDismissController:(CameraCollectionViewController *)controller withUserInfo:(NSDictionary *)userinfo
{
    NSArray *selectedImages = [userinfo objectForKey:@"selected_images"];
    
    [_selectedIndexPathCameraController removeAllObjects];
    [_selectedIndexPathCameraController addObjectsFromArray:[userinfo objectForKey:@"selected_indexpath"]];
    
    //Hapus data yg equal @""
    NSMutableArray *selectedImageTemp = [NSMutableArray new];
    for (NSDictionary *selected in _selectedImagesCameraController) {
        if (![selected isEqual:@""]) {
            [selectedImageTemp addObject:selected];
        }
    }
    [_selectedImagesCameraController removeAllObjects];
    [_selectedImagesCameraController addObjectsFromArray:selectedImageTemp];
    
    // Cari Index Image yang kosong
    NSMutableArray *emptyImageIndex = [NSMutableArray new];
    for (UIImageView *image in _thumbImages) {
        if (image.image == nil)
        {
            [emptyImageIndex addObject:@(image.tag - 10)];
        }
    }
    
    //Upload Image yg belum diupload tp dipilih
    int j = 0;
    for (NSDictionary *selected in selectedImages) {
        if (![self Array:[_selectedImagesCameraController copy] containObject:selected])
        {
            [self setImageData:selected tag:[emptyImageIndex[j] integerValue]];
            j++;
        }
    }
    
    if ([self totalUploadedAndUploadingImage] == 0) {
        [_imageScrollView removeFromSuperview];
    }
    
    [_selectedImagesCameraController removeAllObjects];
    [_selectedImagesCameraController addObjectsFromArray:selectedImages];

}

-(void)didRemoveImageDictionary:(NSDictionary *)removedImage
{
    //Hapus Image dari camera controller
    NSMutableArray *removedImages = [NSMutableArray new];
     for (int i = 0; i<_selectedImagesCameraController.count; i++) {
         NSDictionary *photoObjectInArray = [_selectedImagesCameraController[i] objectForKey:kTKPDCAMERA_DATAPHOTOKEY];
         NSDictionary *photoObject = [removedImage objectForKey:kTKPDCAMERA_DATAPHOTOKEY];
         
         UIImage* imageObject = [photoObject objectForKey:kTKPDCAMERA_DATAPHOTOKEY];
         UIGraphicsBeginImageContextWithOptions(kTKPDCAMERA_UPLOADEDIMAGESIZE, NO, imageObject.scale);
         [imageObject drawInRect:kTKPDCAMERA_UPLOADEDIMAGERECT];
         imageObject = UIGraphicsGetImageFromCurrentImageContext();
         UIGraphicsEndImageContext();
         
         if ([self image:[photoObjectInArray objectForKey:kTKPDCAMERA_DATAPHOTOKEY] isEqualTo:[photoObject objectForKey:kTKPDCAMERA_DATAPHOTOKEY]]) {
             
            NSMutableDictionary *object = [NSMutableDictionary new];
            [object setObject:removedImage forKey:DATA_SELECTED_PHOTO_KEY];
            UIImageView *imageView;

            for (UIImageView *image in _thumbImages) {
                
                if ([self image:image.image isEqualTo:imageObject])
                {
                    imageView = image;
                    break;
                }
            }
            [object setObject:imageView forKey:DATA_SELECTED_IMAGE_VIEW_KEY];

            [removedImages addObject:object];
            [self failedUploadObject:object];
            break;
        }
     }
}

- (BOOL)image:(UIImage *)image1 isEqualTo:(UIImage *)image2
{
    NSData *data1 = UIImagePNGRepresentation(image1);
    NSData *data2 = UIImagePNGRepresentation(image2);
    
    return [data1 isEqual:data2];
}

-(BOOL)Array:(NSArray*)array containObject:(NSDictionary*)object
{
    for (NSDictionary *objectInArray in array) {
        NSDictionary *photoObjectInArray = [objectInArray objectForKey:kTKPDCAMERA_DATAPHOTOKEY];
        NSDictionary *photoObject = [object objectForKey:kTKPDCAMERA_DATAPHOTOKEY];
        if ([self image:[photoObjectInArray objectForKey:kTKPDCAMERA_DATAPHOTOKEY] isEqualTo:[photoObject objectForKey:kTKPDCAMERA_DATAPHOTOKEY]]) {
            return YES;
        }
    }
    return NO;
}

-(void)setImageData:(NSDictionary*)data tag:(NSInteger)tag
{
    NSInteger tagView = tag +10;
    NSMutableDictionary *object = [NSMutableDictionary new];
    [object setObject:data forKey:DATA_SELECTED_PHOTO_KEY];
    UIImageView *imageView;
    
    NSDictionary* photo = [data objectForKey:kTKPDCAMERA_DATAPHOTOKEY];
    
    UIImage* imagePhoto = [photo objectForKey:kTKPDCAMERA_DATAPHOTOKEY];
    UIGraphicsBeginImageContextWithOptions(kTKPDCAMERA_UPLOADEDIMAGESIZE, NO, imagePhoto.scale);
    [imagePhoto drawInRect:kTKPDCAMERA_UPLOADEDIMAGERECT];
    imagePhoto = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    for (UIImageView *image in _thumbImages) {
        if (image.tag == tagView)
        {
            imageView = image;
            image.image = imagePhoto;
            image.hidden = NO;
            image.alpha = 0.5f;
        }
    }
    
    [object setObject:imageView forKey:DATA_SELECTED_IMAGE_VIEW_KEY];
    
    [object setObject:_selectedIndexPathCameraController[tag] forKey:DATA_SELECTED_INDEXPATH_KEY];
    
    for (UIButton *button in _uploadButtons) {
        if (button.tag == tagView) {
            button.hidden = YES;
        }
        if (button.tag == tagView+1)
        {
            for (UIImageView *image in _thumbImages) {
                if (image.tag == tagView+1)
                {
                    if (image.image == nil) {
                        button.hidden = NO;
                    }
                }
            }
        }
    }
    
    [self actionUploadImage:object];
}

#pragma mark - alert view Delegate
-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (alertView.tag == TAG_ALERT_HELPER) {
        if (buttonIndex == 1) {
            [_delegate reportResolution];
            [self.navigationController popViewControllerAnimated:YES];
        }
    }
    if (alertView.tag == TAG_CHANGE_SOLUTION)
    {
        if (buttonIndex == 1) {
            [self resolutionOpenIsGotTheOrder:YES];
        }
        else if (buttonIndex == 2)
        {
            [self resolutionOpenIsGotTheOrder:NO];
        }
    }
}

-(void)changeSolution:(NSString *)solutionType troubleType:(NSString *)troubleType refundAmount:(NSString *)refundAmout remark:(NSString *)note photo:(NSString *)photo serverID:(NSString *)serverID
{
    [_delegate solutionType:solutionType troubleType:troubleType refundAmount:refundAmout message:note photo:photo serverID:serverID];
}

-(NSString *)trouble
{
    NSString *trouble;
    if ([_resolution.resolution_last.last_trouble_type isEqual:@(1)]) {
        trouble = ARRAY_PROBLEM_COMPLAIN[0];
    }
    else if ([_resolution.resolution_last.last_trouble_type isEqual:@(2)]) {
        trouble = ARRAY_PROBLEM_COMPLAIN[1];
    }
    else if ([_resolution.resolution_last.last_trouble_type isEqual:@(3)]) {
        trouble = ARRAY_PROBLEM_COMPLAIN[2];
    }
    else if ([_resolution.resolution_last.last_trouble_type isEqual:@(4)]) {
        trouble = ARRAY_PROBLEM_COMPLAIN[3];
    }
    return trouble;
}

-(NSString*)solution
{
    NSString *solution;
    if ([_resolution.resolution_last.last_solution isEqual:@(1)]) {
        solution = ARRAY_SOLUTION_PRODUCT_NOT_SAME_AS_DESCRIPTION[0];
    }
    else if ([_resolution.resolution_last.last_solution isEqual:@(2)]) {
        solution = ARRAY_SOLUTION_PRODUCT_NOT_SAME_AS_DESCRIPTION[1];
    }
    else if ([_resolution.resolution_last.last_solution isEqual:@(3)]) {
        solution = ARRAY_SOLUTION_PRODUCT_NOT_SAME_AS_DESCRIPTION[2];
    }
    else if ([_resolution.resolution_last.last_solution isEqual:@(4)]) {
        solution = ARRAY_SOLUTION_PRODUCT_NOT_SAME_AS_DESCRIPTION[3];
    }
    return solution;
}

#pragma mark - Keyboard Notification
- (void)keyboardWillShow:(NSNotification *)aNotification {
    if(_keyboardSize.height < 0){
        _keyboardPosition = [[[aNotification userInfo]objectForKey:UIKeyboardFrameEndUserInfoKey]CGRectValue].origin;
        _keyboardSize= [[[aNotification userInfo]objectForKey:UIKeyboardFrameEndUserInfoKey]CGRectValue].size;
        _scrollviewContentSize = [_messageTextView contentSize];
        _scrollviewContentSize.height += _keyboardSize.height;
        [_messageTextView setContentSize:_scrollviewContentSize];
    }else{
        [UIView animateWithDuration:TKPD_FADEANIMATIONDURATION
                              delay:0
                            options: UIViewAnimationOptionCurveEaseOut
                         animations:^{
                             _scrollviewContentSize = [_messageTextView contentSize];
                             _scrollviewContentSize.height -= _keyboardSize.height;
                             
                             _keyboardPosition = [[[aNotification userInfo]objectForKey:UIKeyboardFrameEndUserInfoKey]CGRectValue].origin;
                             _keyboardSize= [[[aNotification userInfo]objectForKey:UIKeyboardFrameEndUserInfoKey]CGRectValue].size;
                             _scrollviewContentSize.height += _keyboardSize.height;

                             UIEdgeInsets inset = _messageTextView.contentInset;
                             inset.bottom = _keyboardPosition.y - _headerView.frame.size.height +30;
                             [_messageTextView setContentInset:inset];
                             
                             CGRect frame = _footerView.frame;
                             frame.origin.y = _keyboardPosition.y - _footerView.frame.size.height - _headerView.frame.size.height + 15;
                             _footerView.frame = frame;
                         }
                         completion:^(BOOL finished){
                         }];
        
    }
}

- (void)keyboardWillHide:(NSNotification *)aNotification {
    NSDictionary* info = [aNotification userInfo];
    CGRect kbFrame = [[info objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue];
    
    UIEdgeInsets inset = _messageTextView.contentInset;
    inset.bottom = 0;
    [_messageTextView setContentInset:inset];
    
    [UIView animateWithDuration:TKPD_FADEANIMATIONDURATION
                          delay:0
                        options: UIViewAnimationOptionCurveEaseInOut
                     animations:^{
                         CGRect frame = _footerView.frame;
                         frame.origin.y = kbFrame.origin.y + _footerView.frame.size.height + _headerView.frame.size.height - 15;
                         _footerView.frame = frame;
                     }
                     completion:^(BOOL finished){
                     }];
    
}


#pragma mark Request Generate Host
-(void)successGenerateHost:(GenerateHost *)generateHost
{
    _generatehost = generateHost;
    [_uploadButtons makeObjectsPerformSelector:@selector(setEnabled:)withObject:@(YES)];
}


#pragma mark Request Action Upload Photo
-(void)actionUploadImage:(id)object
{
    if (![_uploadingPhotos containsObject:object]) {
        [_uploadingPhotos addObject:object];
    }
    
    _isFinishUploadingImage = NO;
    RequestUploadImage *uploadImage = [RequestUploadImage new];
    uploadImage.imageObject = object;
    uploadImage.delegate = self;
    uploadImage.generateHost = _generatehost;
    uploadImage.action = ACTION_UPLOAD_CONTACT_IMAGE;
    uploadImage.fieldName = API_UPLOAD_PRODUCT_IMAGE_DATA_NAME;
    [uploadImage configureRestkitUploadPhoto];
    [uploadImage requestActionUploadPhoto];
}

-(void)successUploadObject:(id)object withMappingResult:(UploadImage *)uploadImage
{
    UIImageView *imageView = [object objectForKey:DATA_SELECTED_IMAGE_VIEW_KEY];
    imageView.alpha = 1.0;
    if (![_uploadedPhotos containsObject:uploadImage.result.file_th]) {
        [_uploadedPhotos replaceObjectAtIndex:imageView.tag-10 withObject:uploadImage.result.file_th];
    }
    
    [_uploadingPhotos removeObject:object];
    _isFinishUploadingImage = YES;
    
    for (UIButton *button in _cancelButtons) {
        if (button.tag == imageView.tag)
        {
            button.hidden = NO;
        }
    }
    
    [self requestProcessUploadPhoto];
}

-(void)failedUploadObject:(id)object
{
    UIImageView *imageView = [object objectForKey:DATA_SELECTED_IMAGE_VIEW_KEY];
    imageView.image = nil;
    
    for (UIButton *button in _uploadButtons) {
        if (button.tag == imageView.tag) {
            button.hidden = NO;
        }
    }
    for (UIButton *button in _cancelButtons) {
        if (button.tag == imageView.tag)
        {
            button.hidden = YES;
        }
    }
    
    [_uploadedPhotos replaceObjectAtIndex:imageView.tag-10 withObject:@""];
    
    _isFinishUploadingImage = YES;
    [_uploadingPhotos removeObject:object];
    [_selectedIndexPathCameraController removeObject:[object objectForKey:DATA_SELECTED_INDEXPATH_KEY]];
    [_selectedImagesCameraController removeObject:[object objectForKey:DATA_SELECTED_PHOTO_KEY]];
    [self requestProcessUploadPhoto];
}

- (void)requestProcessUploadPhoto
{
//    if (_uploadingPhotos.count > 0) {
//        [self actionUploadImage:[_uploadingPhotos firstObject]];
//    }
    
//    if ([self totalUploadedAndUploadingImage] == 0) {
//        [_imageScrollView removeFromSuperview];
//    }
}


@end
