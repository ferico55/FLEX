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

#import "GeneralTableViewController.h"

#import "StickyAlertView.h"

#define DATA_PHOTO_UPLOADING @"data_photo_uploading"
#define DATA_IMAGEVIEW_UPLOADING @"data_imageview_uploading"
#define TAG_ALERT_HELPER 10

@interface ResolutionCenterInputViewController () <UIAlertViewDelegate, UITextViewDelegate, InboxResolutionCenterOpenViewControllerDelegate, GenerateHostDelegate, CameraCollectionViewControllerDelegate, CameraControllerDelegate>
{
    NSMutableArray *_uploadedPhotos;
    GenerateHost *_generatehost;
    NSMutableArray *_photos;
    
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
}
@property (weak, nonatomic) IBOutlet UITextView *messageTextView;
@property (weak, nonatomic) IBOutlet UIView *oneButtonView;

@property (strong, nonatomic) IBOutlet UIView *threeButtonsView;
@property (weak, nonatomic) IBOutlet UILabel *lastSolutionLabel;
@property (weak, nonatomic) IBOutlet UILabel *buyerSellerLabel;
@property (weak, nonatomic) IBOutlet UILabel *createDateLabel;
@property (strong, nonatomic) IBOutlet UIView *headerView;
@property (weak, nonatomic) IBOutlet UIButton *attachButton;
@property (weak, nonatomic) IBOutlet UIButton *helperButton;
@property (weak, nonatomic) IBOutlet UIButton *editSolutionButton;
@property (strong, nonatomic) IBOutlet UIView *twoButtonView;
@property (strong, nonatomic) IBOutlet UIView *footerView;
@property (weak, nonatomic) IBOutlet UIButton *secondFooterButton;

@property (strong, nonatomic) IBOutletCollection(UIButton) NSArray *uploadButtons;
@property (strong, nonatomic) IBOutletCollection(UIImageView) NSArray *uploadedImages;
@property (strong, nonatomic) IBOutlet UIScrollView *imageScrollView;
@property (weak, nonatomic) IBOutlet UIView *imageContentView;

@end
#define TAG_BAR_BUTTON_TRANSACTION_BACK 10
#define TAG_BAR_BUTTON_TRANSACTION_SEND 11

@implementation ResolutionCenterInputViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _operationQueue = [NSOperationQueue new];
    _generatehost = [GenerateHost new];
    _photos = [NSMutableArray new];
    _uploadingPhotos = [NSMutableArray new];
    _uploadedPhotos = [NSMutableArray new];
    
    UIBarButtonItem *barButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Batal" style:UIBarButtonItemStylePlain target:(self) action:@selector(tap:)];
    [barButtonItem setTintColor:[UIColor whiteColor]];
    barButtonItem.tag = TAG_BAR_BUTTON_TRANSACTION_BACK;
    self.navigationItem.leftBarButtonItem = barButtonItem;
    
    [self setTextViewPlaceholder:@"Isi pesan diskusi disini..."];
        
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
}
-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    _messageTextView.autocorrectionType = UITextAutocorrectionTypeNo;
    [_messageTextView becomeFirstResponder];
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

- (IBAction)tap:(id)sender {
    [_messageTextView resignFirstResponder];
    if ([sender isKindOfClass:[UIBarButtonItem class]]) {
        UIBarButtonItem *barbutton = (UIBarButtonItem*)sender;
        if (barbutton.tag == TAG_BAR_BUTTON_TRANSACTION_BACK) {
            [self.navigationController popViewControllerAnimated:YES];
        }
        else if (barbutton.tag == TAG_BAR_BUTTON_TRANSACTION_SEND) {
            NSMutableArray *fileThumbImage = [NSMutableArray new];
            for (UploadImageResult *image in _uploadedPhotos) {
                [fileThumbImage addObject:image.file_th];
            }
            NSString *photos = [[fileThumbImage valueForKey:@"description"] componentsJoinedByString:@"~"]?:@"";
            
            [_delegate message:_messageTextView.text
                         photo:photos?:@""
                      serverID:_generatehost.result.generated_host.server_id?:@""];
            [self.navigationController popViewControllerAnimated:YES];
        }
    }
    else
    {
        UIButton *button = (UIButton*)sender;
        switch (button.tag) {
            case 10:
                //Image
                [self didTapImageButton:(UIButton*)sender];
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
    CameraCollectionViewController *photoVC = [CameraCollectionViewController new];
    photoVC.title = @"All Picture";
    photoVC.delegate = self;
    photoVC.tag = sender.tag;
    UINavigationController *nav = [[UINavigationController alloc]init];
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
    
    InboxResolutionCenterOpenViewController *vc = [InboxResolutionCenterOpenViewController new];
    vc.isGotTheOrder = ([_resolution.resolution_last.last_flag_received integerValue]==1);
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
    vc.uploadedPhotos = _uploadedPhotos;
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

#pragma mark - Camera Delegate
-(void)didDismissController:(CameraCollectionViewController *)controller withUserInfo:(NSDictionary *)userinfo
{
    [self setImageData:userinfo tag:controller.tag];
}

-(void)setImageData:(NSDictionary*)data tag:(int)tag
{
    NSMutableDictionary *object = [NSMutableDictionary new];
    [object setObject:data forKey:DATA_PHOTO_UPLOADING];
    UIImageView *imageView;
    for (UIImageView *image in _uploadedImages) {
        if (image.tag == tag)
        {
            imageView = image;
        }
    }
    [object setObject:imageView forKey:DATA_IMAGEVIEW_UPLOADING];
    
    NSDictionary* photo = [data objectForKey:kTKPDCAMERA_DATAPHOTOKEY];
    
    UIImage* image = [photo objectForKey:kTKPDCAMERA_DATAPHOTOKEY];
    UIGraphicsBeginImageContextWithOptions(kTKPDCAMERA_UPLOADEDIMAGESIZE, NO, image.scale);
    [image drawInRect:kTKPDCAMERA_UPLOADEDIMAGERECT];
    image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    for (UIButton *button in _uploadButtons) {
        if (button.tag == tag) {
            button.enabled = NO;
            button.hidden = YES;
        }
        if (button.tag == tag+1)
        {
            button.enabled = YES;
            button.hidden = NO;
        }
    }
    
    imageView.image = image;
    imageView.hidden = NO;
    imageView.alpha = 0.5f;
    
    [self configureRestkitUploadPhoto];
    [self requestActionUploadPhoto:object];
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
                             inset.bottom = _keyboardPosition.y - _headerView.frame.size.height;
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
}


#pragma mark Request Action Upload Photo
-(void)configureRestkitUploadPhoto
{
    _objectManagerUploadPhoto =  [RKObjectManager sharedClient];
    
    // setup object mappings
    RKObjectMapping *statusMapping = [RKObjectMapping mappingForClass:[UploadImage class]];
    [statusMapping addAttributeMappingsFromDictionary:@{kTKPD_APIERRORMESSAGEKEY:kTKPD_APIERRORMESSAGEKEY,
                                                        kTKPD_APISTATUSKEY:kTKPD_APISTATUSKEY,
                                                        kTKPD_APISERVERPROCESSTIMEKEY:kTKPD_APISERVERPROCESSTIMEKEY}];
    
    RKObjectMapping *resultMapping = [RKObjectMapping mappingForClass:[UploadImageResult class]];
    [resultMapping addAttributeMappingsFromDictionary:@{kTKPDSHOPEDIT_APIUPLOADFILEPATHKEY:kTKPDSHOPEDIT_APIUPLOADFILEPATHKEY,
                                                        kTKPDSHOPEDIT_APIUPLOADFILETHUMBKEY:kTKPDSHOPEDIT_APIUPLOADFILETHUMBKEY,
                                                        API_UPLOAD_PHOTO_ID_KEY:API_UPLOAD_PHOTO_ID_KEY
                                                        }];
    
    // Relationship Mapping
    [statusMapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:kTKPD_APIRESULTKEY toKeyPath:kTKPD_APIRESULTKEY withMapping:resultMapping]];
    
    RKResponseDescriptor *responseDescriptor = [RKResponseDescriptor responseDescriptorWithMapping:statusMapping method:RKRequestMethodPOST pathPattern:kTKPDDETAIL_UPLOADIMAGEAPIPATH keyPath:@"" statusCodes:kTkpdIndexSetStatusCodeOK];
    
    [_objectManagerUploadPhoto addResponseDescriptor:responseDescriptor];
    
    [_objectManagerUploadPhoto setAcceptHeaderWithMIMEType:RKMIMETypeJSON];
    [_objectManagerUploadPhoto setRequestSerializationMIMEType:RKMIMETypeJSON];
}


- (void)cancelActionUploadPhoto
{
    _requestActionUploadPhoto = nil;
    
    [_operationQueue cancelAllOperations];
    _objectManagerUploadPhoto = nil;
}

- (void)requestActionUploadPhoto:(NSDictionary*)object
{
    for (NSObject *object in _uploadingPhotos) {
        if (![object isEqual:object]) {
            [_uploadingPhotos addObject:object];
        }
    }
    
    NSDictionary *uploadingObject = object;
    NSDictionary *imagePhoto = [uploadingObject objectForKey:DATA_PHOTO_UPLOADING];
    UIImageView *imageView = [uploadingObject objectForKey:DATA_IMAGEVIEW_UPLOADING];
    
    NSDictionary *photo = [imagePhoto objectForKey: kTKPDCAMERA_DATAPHOTOKEY];
    NSData* imageData = [photo objectForKey:DATA_CAMERA_IMAGEDATA];
    NSString* imageName = [photo objectForKey:DATA_CAMERA_IMAGENAME];
    NSString *serverID = _generatehost.result.generated_host.server_id?:@"0";
    
    NSDictionary *param = @{ API_ACTION_KEY:ACTION_UPLOAD_CONTACT_IMAGE,
                             kTKPDGENERATEDHOST_APISERVERIDKEY:serverID,
                             };
    
    
    TKPDSecureStorage* secureStorage = [TKPDSecureStorage standardKeyChains];
    NSDictionary* auth = [secureStorage keychainDictionary];
    
    NSString *userID = [auth objectForKey:kTKPD_USERIDKEY];
    
    NSMutableDictionary *paramDictionary = [NSMutableDictionary new];
    [paramDictionary addEntriesFromDictionary:param];
    [paramDictionary setObject:@"off" forKey:@"enc_dec"];
    [paramDictionary setObject:userID?:@"" forKey:kTKPD_USERIDKEY];
    
    _requestActionUploadPhoto = [NSMutableURLRequest requestUploadImageData:imageData
                                                                   withName:API_UPLOAD_PRODUCT_IMAGE_DATA_NAME
                                                                andFileName:imageName
                                                      withRequestParameters:paramDictionary
                                 ];
    
    
    _isFinishUploadingImage = NO;
    
    UIImageView *thumbProductImage = imageView;
    thumbProductImage.alpha = 0.5f;
    
    [NSURLConnection sendAsynchronousRequest:_requestActionUploadPhoto
                                       queue:[NSOperationQueue mainQueue]
                           completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
                               NSHTTPURLResponse* httpResponse = (NSHTTPURLResponse*)response;
                               NSString *responsestring = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
                               if ([httpResponse statusCode] == 200) {
                                   _isFinishUploadingImage = YES;
                                   id parsedData = [RKMIMETypeSerialization objectFromData:data MIMEType:RKMIMETypeJSON error:&error];
                                   if (parsedData == nil && error) {
                                       NSLog(@"parser error");
                                       [self requestFailureUploadPhoto:photo
                                                           atImageView:thumbProductImage
                                                             withError:nil];
                                       [self requestProcessUploadPhoto];
                                       return;
                                   }
                                   
                                   NSMutableDictionary *mappingsDictionary = [[NSMutableDictionary alloc] init];
                                   for (RKResponseDescriptor *descriptor in _objectManagerUploadPhoto.responseDescriptors) {
                                       [mappingsDictionary setObject:descriptor.mapping forKey:descriptor.keyPath];
                                   }
                                   
                                   RKMapperOperation *mapper = [[RKMapperOperation alloc] initWithRepresentation:parsedData mappingsDictionary:mappingsDictionary];
                                   NSError *mappingError = nil;
                                   BOOL isMapped = [mapper execute:&mappingError];
                                   if (isMapped && !mappingError) {
                                       NSLog(@"result %@",[mapper mappingResult]);
                                       RKMappingResult *mappingresult = [mapper mappingResult];
                                       NSDictionary *result = mappingresult.dictionary;
                                       id stat = [result objectForKey:@""];
                                       UploadImage *image = stat;
                                       BOOL status = [image.status isEqualToString:kTKPDREQUEST_OKSTATUS];
                                       
                                       if (status) {
                                           
                                           if (!image.message_error) {
                                               
                                               [self requestSuccessUploadPhoto:object
                                                                   atImageView:thumbProductImage
                                                             withMappingResult:mappingresult];
                                           }
                                           else
                                           {
                                               NSArray *array = image.message_error?:[[NSArray alloc] initWithObjects:@"Error", nil];
                                               StickyAlertView *alert = [[StickyAlertView alloc]initWithErrorMessages:array delegate:self];
                                               [alert show];
                                               [self requestFailureUploadPhoto:object
                                                                   atImageView:thumbProductImage
                                                                     withError:nil];
                                           }
                                       }
                                       else
                                       {
                                           [self requestFailureUploadPhoto:object
                                                               atImageView:thumbProductImage
                                                                 withError:image.status];
                                       }
                                   }
                                   else
                                   {
                                       [self requestFailureUploadPhoto:object
                                                           atImageView:thumbProductImage
                                                             withError:@"error"];
                                   }
                                   
                               }
                               else
                               {
                                   NSString *errorDescription = error.localizedDescription;
                                   [self requestFailureUploadPhoto:object
                                                       atImageView:thumbProductImage
                                                         withError:errorDescription];
                               }
                               NSLog(@"%@",responsestring);
                               [self requestProcessUploadPhoto];
                           }];
}

- (void)requestSuccessUploadPhoto:(NSDictionary*)object atImageView:(UIImageView*)imageView withMappingResult:(RKMappingResult*)mappingResult
{
    NSDictionary *result = mappingResult.dictionary;
    id stat = [result objectForKey:@""];
    UploadImage *image = stat;
    
    imageView.alpha = 1.0;
    [_photos addObject:image.result];
    [_uploadingPhotos removeObject:object];
}

- (void)requestFailureUploadPhoto:(NSDictionary*)object atImageView:(UIImageView*)imageView withError:(NSString*)error
{
    if (error) {
        UIAlertView *errorAlert = [[UIAlertView alloc]initWithTitle:ERROR_TITLE message:error?:@"Error" delegate:self cancelButtonTitle:ERROR_CANCEL_BUTTON_TITLE otherButtonTitles:nil];
        [errorAlert show];
    }
    
    imageView.image = nil;
    
    for (UIButton *button in _uploadButtons) {
        if (button.tag == imageView.tag) {
            button.enabled = YES;
            button.hidden = NO;
        }
    }
    
    [_uploadingPhotos removeObject:object];
}


- (void)requestProcessUploadPhoto
{
    if (_uploadingPhotos.count > 0) {
        [self configureRestkitUploadPhoto];
        [self requestActionUploadPhoto:[_uploadingPhotos firstObject]];
    }
    
    if (_uploadedPhotos.count == 0) {
        [_imageScrollView removeFromSuperview];
    }
}


@end
