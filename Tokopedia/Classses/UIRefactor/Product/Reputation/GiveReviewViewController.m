//
//  GiveReviewViewController.m
//  Tokopedia
//
//  Created by Tokopedia on 7/8/15.
//  Copyright (c) 2015 TOKOPEDIA. All rights reserved.
//
#import "DetailReputationReview.h"
#import "DetailMyReviewReputationViewController.h"
#import "GeneralAction.h"
#import "GiveReviewViewController.h"
#import "string_inbox_message.h"
#import "TKPDTextView.h"
#import "TokopediaNetworkManager.h"
#import "UserInfo.h"
#import "CameraAlbumListViewController.h"
#import "CameraCollectionViewController.h"
#import "RequestGenerateHost.h"
#import "RequestUploadImage.h"
#import "CameraController.h"
#import "RequestGenerateHost.h"
#import "ProductAddCaptionViewController.h"
#import <QuartzCore/QuartzCore.h>

#define CStringTidakAdaPerubahan @"Tidak ada perubahan ulasan"
#define CStringAndaTidakDapatMenurunkanRate @"Anda tidak dapat memberi penurunan rating"
#define CStringPleaseFillReviewRating @"Rating harus diisi"
#define CPlaceHolderTulisReview @"Tulis ulasan disini..."
#define CStringPleaseFillReview @"Pesan ulasan harus lebih dari 30 karakter"
#define CTagSubmitReputation 1

@interface GiveReviewViewController ()
<
    TokopediaNetworkManagerDelegate,
    UITextViewDelegate,
    CameraCollectionViewControllerDelegate,
    GenerateHostDelegate,
    CameraControllerDelegate,
    RequestUploadImageDelegate,
    ProductAddCaptionDelegate
>
{
    NSMutableArray *_selectedImagesCameraController;
    NSMutableArray *_selectedIndexPathCameraController;
    NSMutableArray *_attachedImageURLs;
    
    NSMutableArray *_uploadedImages;
    NSMutableArray *_uploadingImages;
    GenerateHost *_generateHost;
    GeneratedHost *_generatedHost;
    
    NSOperationQueue *_operationQueue;
    
    BOOL _isFinishedUploadingImage;
    
    __weak RKObjectManager *_objectManagerGenerateHost;
    __weak RKManagedObjectRequestOperation *_requestGenerateHost;
}

@end

@implementation GiveReviewViewController
{
    BOOL isEdit;
    int nRateKualitas, nRateAkurasi;
    float heightScreenView;
    TokopediaNetworkManager *tokopediaNetworkManager;
    
    TAGContainer *_gtmContainer;
    NSString *baseActionUrl;
    NSString *postActionUrl;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self configureGTM];
    txtDes.placeholder = CPlaceHolderTulisReview;
    txtDes.delegate = self;
    nRateAkurasi = nRateKualitas = 0;
    
    [self isLoading:NO];
    self.navigationItem.rightBarButtonItem.enabled = NO;
    [self initData];
    
    self.title = isEdit? @"Ubah Ulasan":@"Tulis Ulasan";
    [[UIBarButtonItem appearance] setBackButtonTitlePositionAdjustment:UIOffsetMake(0, -60) forBarMetrics:UIBarMetricsDefault];
    
    _operationQueue = [NSOperationQueue new];
    _generateHost = [GenerateHost new];
    _generatedHost = [GeneratedHost new];
    attachedImages = [NSArray sortViewsWithTagInArray:attachedImages];
    
    _uploadingImages = [NSMutableArray new];
    _selectedImagesCameraController = [[NSMutableArray alloc] initWithObjects:@"", @"", @"", @"", @"", nil];
    _selectedIndexPathCameraController = [[NSMutableArray alloc] initWithObjects:@"", @"", @"", @"", @"", nil];
    _attachedImageURLs = [[NSMutableArray alloc] initWithObjects:@"", @"", @"", @"", @"", nil];
    
    _isFinishedUploadingImage = YES;
    
    for (UIButton *pictureButton in addPictureButtons) {
        pictureButton.layer.cornerRadius = 5.0;
        pictureButton.layer.masksToBounds = YES;
        [pictureButton.layer setBorderWidth:1.0f];
        [pictureButton.layer setBorderColor:[[UIColor colorWithRed:(224.0/255) green:(224.0/255) blue:(224.0/255) alpha:1.0] CGColor]];
    }
    
    RequestGenerateHost *requestHost = [RequestGenerateHost new];
    [requestHost configureRestkitGenerateHost];
    [requestHost requestGenerateHost];
    requestHost.delegate = self;
    
    [self initCameraIcon];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    heightScreenView = self.view.bounds.size.height;
    //    heightScreenView = 500;
    constraintHeightScrollView.constant = heightScreenView;
    //    constHeightContentView.constant = heightScreenView;
    [self.view addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(resignKeyboard:)]];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
    [txtDes becomeFirstResponder];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSInteger)totalUploadedAndUploadingImage {
    NSMutableArray *fileThumbImage = [NSMutableArray new];
    for (NSString *image in _uploadedImages) {
        if (![image isEqualToString:@""]) {
            [fileThumbImage addObject:image];
        }
    }
    
    return fileThumbImage.count + _uploadingImages.count;
}

- (BOOL)image:(UIImage*)image1 isEqualTo:(UIImage*)image2 {
    return [UIImagePNGRepresentation(image1) isEqual:UIImagePNGRepresentation(image2)];
}

- (BOOL)array:(NSArray*)arr containsObject:(NSDictionary*)object {
    if (object && [object isKindOfClass:[NSDictionary class]]) {
        for (id objectInArray in arr) {
            if ([objectInArray isKindOfClass:[NSDictionary class]]) {
                NSDictionary *photoObjectInArray = [objectInArray objectForKey:@"photo"];
                NSDictionary *photoObject = [object objectForKey:@"photo"];
                if ([self image:[photoObjectInArray objectForKey:@"photo"] isEqualTo:[photoObject objectForKey:@"photo"]]) {
                    return YES;
                }
            }
        }
    }
    return NO;
}

/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */


#pragma mark - Method View
- (void)initData {
    lblProduct.text = [NSString convertHTML:_detailReputationView.product_name];
    
    //Set image product
    NSURLRequest *userImageRequest = [[NSURLRequest alloc] initWithURL:[NSURL URLWithString:_detailReputationView.product_image] cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:kTKPDREQUEST_TIMEOUTINTERVAL];
    
    [imgProduct setImageWithURLRequest:userImageRequest placeholderImage:[UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"icon_toped_loading_grey-01" ofType:@"png"]] success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-retain-cycles"
        [imgProduct setImage:image];
#pragma clang diagnostic pop
    } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) {
        NSLog(@"Failure get image in giveReviewViewController");
    }];
    
    //add gesture to every image
    for(UIImageView *tempImage in arrImgAkurasi) {
        tempImage.userInteractionEnabled = YES;
        [tempImage addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(gestureAkurasi:)]];
    }
    
    for(UIImageView *tempImage in arrImgKualitas) {
        tempImage.userInteractionEnabled = YES;
        [tempImage addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(gestureKualitas:)]];
    }
    
    isEdit = !(_detailReputationView.review_message==nil || [_detailReputationView.review_message isEqualToString:@"0"]);
    if(isEdit) {
        txtDes.text = [NSString convertHTML:_detailReputationView.review_message];
        self.navigationItem.rightBarButtonItem.enabled = (txtDes.text.length>=5);
        
        //Set Akurasi
        nRateAkurasi = (_detailReputationView.product_accuracy_point==nil || _detailReputationView.product_accuracy_point.length==0)? 0:[_detailReputationView.product_accuracy_point intValue];
        if(nRateAkurasi != 0) {
            [self setAkurasiStar];
        }
        
        
        //Set kualitas
        nRateKualitas = (_detailReputationView.product_rating_point==nil || _detailReputationView.product_rating_point.length==0)? 0:[_detailReputationView.product_rating_point intValue];
        if(nRateKualitas != 0) {
            [self setKualitasStar];
        }
    }
}

- (void)initCameraIcon {
    for (UIImageView *image in attachedImages) {
        if (image.tag == 20) {
            image.image = [UIImage imageNamed:@"icon_camera.png"];
            image.alpha = 1;
            image.hidden = NO;
            image.userInteractionEnabled = YES;
            image.contentMode = UIViewContentModeCenter;
            [image.layer setBorderColor:[[UIColor colorWithRed:200.0/255 green:199.0/255 blue:204.0/255 alpha:1] CGColor]];
            [image.layer setBorderWidth:1.0];
            image.layer.cornerRadius = 5.0;
            image.layer.masksToBounds = YES;
            
        } else {
            image.image = nil;
        }
    }
}


#pragma mark - Method
- (void)setAkurasiStar {
    for(int i=0;i<arrImgAkurasi.count;i++) {
        UIImageView *tempImage = [arrImgAkurasi objectAtIndex:i];
        tempImage.image = [UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:(i<nRateAkurasi? @"icon_star_active":@"icon_star") ofType:@"png"]];
    }
}

- (void)setKualitasStar {
    for(int i=0;i<arrImgKualitas.count;i++) {
        UIImageView *tempImage = [arrImgKualitas objectAtIndex:i];
        tempImage.image = [UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:(i<nRateKualitas? @"icon_star_active":@"icon_star") ofType:@"png"]];
    }
}

- (BOOL)successValidate {
    if([txtDes.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]].length==0 || [txtDes.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]].length<30) {
        return NO;
    }
    return YES;
}

- (BOOL)successValidateRating {
    if(isEdit) {
        if([_detailReputationView.product_accuracy_point intValue]>nRateAkurasi || [_detailReputationView.product_rating_point intValue]>nRateKualitas) {
            StickyAlertView *stickyAlertView = [[StickyAlertView alloc] initWithErrorMessages:@[CStringAndaTidakDapatMenurunkanRate] delegate:self];
            [stickyAlertView show];
            return NO;
        }
    }
    else {
        if(nRateAkurasi==0 || nRateKualitas==0) {
            StickyAlertView *stickyAlertView = [[StickyAlertView alloc] initWithErrorMessages:@[CStringPleaseFillReviewRating] delegate:self];
            [stickyAlertView show];
            
            return NO;
        }
    }
    
    return YES;
}

- (TokopediaNetworkManager *)getNetworkManager:(int)tag {
    if(tag == CTagSubmitReputation) {
        if(tokopediaNetworkManager == nil) {
            tokopediaNetworkManager = [TokopediaNetworkManager new];
            tokopediaNetworkManager.tagRequest = tag;
            tokopediaNetworkManager.delegate = self;
        }
        
        return tokopediaNetworkManager;
    }
    
    return nil;
}

- (void)isLoading:(BOOL)isLoad {
    if(isLoad) {
        UIActivityIndicatorView *actIndicator = [[UIActivityIndicatorView alloc] initWithFrame:CGRectMake(0, 0, 30, 30)];
        actIndicator.color = [UIColor whiteColor];
        [actIndicator startAnimating];
        self.navigationItem.rightBarButtonItem.customView = actIndicator;
    }
    else {
        self.navigationItem.rightBarButtonItem.customView = nil;
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Kirim" style:UIBarButtonItemStyleDone target:self action:@selector(actionSubmit:)];
    }
}

#pragma mark - Action
- (void)actionSubmit:(id)sender {
    if(! [self successValidate]) {
        StickyAlertView *stickyAlertView = [[StickyAlertView alloc] initWithErrorMessages:@[CStringPleaseFillReview] delegate:self];
        [stickyAlertView show];
        
        return;
    }
    else if(! [self successValidateRating]) {
        return;
    }
    else if(isEdit) {
        if([_detailReputationView.review_message isEqualToString:txtDes.text] && [_detailReputationView.product_rating_point intValue]==nRateKualitas && [_detailReputationView.product_accuracy_point intValue]==nRateAkurasi) {
            
            StickyAlertView *stickyAlertView = [[StickyAlertView alloc] initWithErrorMessages:@[CStringTidakAdaPerubahan] delegate:self];
            [stickyAlertView show];
            
            return;
        }
    }
    
    [self isLoading:YES];
    [[self getNetworkManager:CTagSubmitReputation] doRequest];
}

- (void)resignKeyboard:(id)sender {
    [txtDes resignFirstResponder];
}

- (void)keyboardWillShow:(NSNotification *)note {
    NSDictionary *info  = note.userInfo;
    NSValue *value = info[UIKeyboardFrameEndUserInfoKey];
    CGRect rawFrame = [value CGRectValue];
    CGRect keyboardFrame = [self.view convertRect:rawFrame fromView:nil];
    constraintHeightScrollView.constant = heightScreenView-keyboardFrame.size.height;
    //    constHeightContentView.constant = viewContentRating.frame.origin.y+viewContentRating.bounds.size.height;
    
    
    if(keyboardFrame.origin.y < viewContentRating.frame.origin.y+viewContentRating.bounds.size.height) {
        scrollView.scrollEnabled = YES;
    }
    
}

- (void)keyboardWillHide:(NSNotification *)note {
    NSNumber *duration = [note.userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey];
    NSNumber *curve = [note.userInfo objectForKey:UIKeyboardAnimationCurveUserInfoKey];
    
    // animations settings
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationBeginsFromCurrentState:YES];
    [UIView setAnimationDuration:[duration doubleValue]];
    [UIView setAnimationCurve:[curve intValue]];
    constraintHeightScrollView.constant = heightScreenView;
    //    constHeightContentView.constant = heightScreenView;
    [UIView commitAnimations];
}



- (void)gestureAkurasi:(UITapGestureRecognizer *)sender {
    nRateAkurasi = (int)sender.view.tag;
    [self setAkurasiStar];
}

- (void)gestureKualitas:(UITapGestureRecognizer *)sender {
    nRateKualitas = (int)sender.view.tag;
    [self setKualitasStar];
}

- (IBAction)gesture:(UITapGestureRecognizer*)sender {
    if ([self image:((UIImageView*)attachedImages[sender.view.tag-20]).image isEqualTo:[UIImage imageNamed:@"icon_camera.png"]]) {
        [self didTapImage:((UIImageView*)attachedImages[sender.view.tag-20])];
    } else {
        ProductAddCaptionViewController *vc = [ProductAddCaptionViewController new];
//        vc.userInfo = _userInfo;
        vc.delegate = self;
        vc.selectedImageTag = (int)sender.view.tag;
        
        UINavigationController *nav = [[UINavigationController alloc]init];
        nav.navigationBar.backgroundColor = [UIColor colorWithCGColor:[UIColor colorWithRed:18.0/255.0 green:199.0/255.0 blue:0.0/255.0 alpha:1].CGColor];
        nav.navigationBar.translucent = NO;
        nav.navigationBar.tintColor = [UIColor whiteColor];
        NSArray *controllers = @[vc];
        [nav setViewControllers:controllers];
        
        [self.navigationController presentViewController:nav animated:YES completion:nil];
    }
}

- (void)didTapImage:(UIImageView*)sender {
    CameraAlbumListViewController *albumVC = [CameraAlbumListViewController new];
    albumVC.title = @"Album";
    albumVC.delegate = self;
    CameraCollectionViewController *photoVC = [CameraCollectionViewController new];
    photoVC.title = @"All Picture";
    photoVC.delegate = self;
    photoVC.isAddEditProduct = YES;
    photoVC.tag = sender.tag;
    
    NSMutableArray *notEmptyImageIndex = [NSMutableArray new];
    for (UIImageView *image in attachedImages) {
        if (image.image == nil) {
            [notEmptyImageIndex addObject:@(image.tag - 20)];
        }
    }
    
    NSMutableArray *selectedImage = [NSMutableArray new];
    for (id selected in _selectedImagesCameraController) {
        if (![selected isEqual:@""]) {
            [selectedImage addObject:selected];
        }
    }
    
    NSMutableArray *selectedIndexPath = [NSMutableArray new];
    for (NSIndexPath *selected in _selectedIndexPathCameraController) {
        if (![selected isEqual:@""]) {
            [selectedIndexPath addObject:selected];
        }
    }
    
    photoVC.maxSelected = 5;
    photoVC.selectedImagesArray = selectedImage;
    
    selectedIndexPath = [NSMutableArray new];
    for (NSIndexPath *selected in _selectedIndexPathCameraController) {
        if (![selected isEqual:@""]) {
            [selectedIndexPath addObject:selected];
        }
    }
    
    photoVC.selectedIndexPath = _selectedIndexPathCameraController;
    photoVC.isAddReviewImage = YES;
    
    UINavigationController *nav = [[UINavigationController alloc]init];
    nav.navigationBar.backgroundColor = [UIColor colorWithCGColor:[UIColor colorWithRed:18.0/255.0 green:199.0/255.0 blue:0.0/255.0 alpha:1].CGColor];
    nav.navigationBar.translucent = NO;
    nav.navigationBar.tintColor = [UIColor whiteColor];
    NSArray *controllers = @[albumVC,photoVC];
    [nav setViewControllers:controllers];
    [self.navigationController presentViewController:nav animated:YES completion:nil];
    
}


#pragma mark - TokopediaNetworkManager Delegate
- (NSDictionary*)getParameter:(int)tag {
    if(tag == CTagSubmitReputation) {
        return @{@"action" : (isEdit? @"edit_reputation_review":@"insert_reputation_review"),
                 @"reputation_id" : _detailReputationView.reputation_id,
                 @"shop_id" : _detailReputationView.shop_id,
                 @"product_id" : _detailReputationView.product_id,
                 @"review_message" : [txtDes.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]],
                 @"quality_rate" : @(nRateKualitas),
                 @"accuracy_rate" : @(nRateAkurasi),
                 @"review_id":_detailReputationView.review_id!=nil?_detailReputationView.review_id:@""
                 };
    }
    
    return nil;
}

- (NSString*)getPath:(int)tag {
    if(tag == CTagSubmitReputation) {
        return [postActionUrl isEqualToString:@""] ? @"action/reputation.pl" : postActionUrl;
    }
    
    return nil;
}

- (id)getObjectManager:(int)tag {
    if(tag == CTagSubmitReputation) {
        RKObjectManager *objectManager;
        if([baseActionUrl isEqualToString:kTkpdBaseURLString] || [baseActionUrl isEqualToString:@""]) {
            objectManager = [RKObjectManager sharedClient];
        } else {
            objectManager = [RKObjectManager sharedClient:baseActionUrl];
        }
        
        // setup object mappings
        RKObjectMapping *statusMapping = [RKObjectMapping mappingForClass:[GeneralAction class]];
        [statusMapping addAttributeMappingsFromDictionary:@{kTKPD_APISTATUSKEY:kTKPD_APISTATUSKEY,
                                                            kTKPD_APIERRORMESSAGEKEY:kTKPD_APIERRORMESSAGEKEY,
                                                            kTKPD_APISTATUSMESSAGEKEY:kTKPD_APISTATUSMESSAGEKEY,
                                                            kTKPD_APISERVERPROCESSTIMEKEY:kTKPD_APISERVERPROCESSTIMEKEY}];
        
        RKObjectMapping *resultMapping = [RKObjectMapping mappingForClass:[GeneralActionResult class]];
        [resultMapping addAttributeMappingsFromDictionary:@{kTKPD_APIISSUCCESSKEY:kTKPD_APIISSUCCESSKEY,
                                                            CFeedBackID:CFeedBackID}];
        
        //relation
        RKRelationshipMapping *resulRel = [RKRelationshipMapping relationshipMappingFromKeyPath:kTKPD_APIRESULTKEY toKeyPath:kTKPD_APIRESULTKEY withMapping:resultMapping];
        [statusMapping addPropertyMapping:resulRel];
        
        //register mappings with the provider using a response descriptor
        RKResponseDescriptor *responseDescriptorStatus = [RKResponseDescriptor responseDescriptorWithMapping:statusMapping method:RKRequestMethodGET pathPattern:[self getPath:tag] keyPath:@"" statusCodes:kTkpdIndexSetStatusCodeOK];
        
        [objectManager addResponseDescriptor:responseDescriptorStatus];
        return objectManager;
    }
    
    return nil;
}

- (NSString*)getRequestStatus:(id)result withTag:(int)tag {
    NSDictionary *resultDict = ((RKMappingResult*)result).dictionary;
    id stat = [resultDict objectForKey:@""];
    
    if(tag == CTagSubmitReputation) {
        GeneralAction *action = stat;
        return action.status;
    }
    
    return nil;
}

- (void)actionAfterRequest:(id)successResult withOperation:(RKObjectRequestOperation*)operation withTag:(int)tag {
    NSDictionary *resultDict = ((RKMappingResult*) successResult).dictionary;
    id stat = [resultDict objectForKey:@""];
    
    if(tag == CTagSubmitReputation) {
        [self isLoading:NO];
        GeneralAction *action = stat;
        
        if([action.result.is_success isEqualToString:@"1"]) {
            StickyAlertView *stickyAlertView = [[StickyAlertView alloc] initWithSuccessMessages:@[isEdit? @"Anda telah berhasil mengubah ulasan":@"Anda telah berhasil mengisi ulasan"] delegate:self];
            [stickyAlertView show];
            
            NSDateFormatter *formatter = [NSDateFormatter new];
            formatter.dateFormat = @"d MMMM yyyy, HH:mm";
            
            if(!isEdit) {
                _detailReputationView.viewModel.review_is_allow_edit = _detailReputationView.review_is_allow_edit = @"1";
                _detailReputationView.viewModel.review_create_time = _detailReputationView.review_create_time = [formatter stringFromDate:[NSDate new]];
                
                UserAuthentificationManager *user = [UserAuthentificationManager new];
                NSDictionary *userData = [user getUserLoginData];
                _detailReputationView.review_full_name = [userData objectForKey:@"full_name"]?:@"-";
                _detailReputationView.review_user_label = CPembeli;
                if (user.reputation) _detailReputationView.review_user_reputation = user.reputation;
            } else {
                _detailReputationView.viewModel.review_is_allow_edit = _detailReputationView.review_is_allow_edit = @"0";
                _detailReputationView.viewModel.review_update_time = _detailReputationView.review_update_time = [formatter stringFromDate:[NSDate new]];
            }
            
            _detailReputationView.review_id = action.result.feedback_id;
            _detailReputationView.viewModel.review_is_skipable = _detailReputationView.review_is_skipable = @"0";
            _detailReputationView.viewModel.review_message = _detailReputationView.review_message = [txtDes.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
            _detailReputationView.viewModel.product_rating_point = _detailReputationView.product_rating_point = [NSString stringWithFormat:@"%d", nRateKualitas];
            _detailReputationView.viewModel.product_accuracy_point = _detailReputationView.product_accuracy_point = [NSString stringWithFormat:@"%d", nRateAkurasi];
            
            [_delegate successGiveReview];
            [self.navigationController popViewControllerAnimated:YES];
        }
        else {
            StickyAlertView *stickyAlertView;
            if(action.message_error!=nil && action.message_error.count>0) {
                stickyAlertView = [[StickyAlertView alloc] initWithErrorMessages:action.message_error delegate:self];
            }
            else {
                stickyAlertView = [[StickyAlertView alloc] initWithErrorMessages:@[isEdit? @"Anda gagal memperbaharui ulasan":@"Anda gagal mengisi ulasan"] delegate:self];
            }
            
            [stickyAlertView show];
        }
    }
}

- (void)actionFailAfterRequest:(id)errorResult withTag:(int)tag {
}

- (void)actionBeforeRequest:(int)tag {
    
}

- (void)actionRequestAsync:(int)tag {
}

- (void)actionAfterFailRequestMaxTries:(int)tag  {
    if(tag == CTagSubmitReputation) {
        [self isLoading:NO];
        StickyAlertView *stickyAlertView = [[StickyAlertView alloc] initWithErrorMessages:@[isEdit? @"Anda gagal memperbaharui ulasan":@"Anda gagal mengisi ulasan"] delegate:self];
        [stickyAlertView show];
    }
}


#pragma mark - UITextView Delegate
- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    NSString *newString = [textView.text stringByReplacingCharactersInRange:range withString:text];
    self.navigationItem.rightBarButtonItem.enabled = (newString.length>=5);
    
    return YES;
}


#pragma mark - GTM
- (void)configureGTM {
    [TPAnalytics trackUserId];
    
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    _gtmContainer = appDelegate.container;
    
    baseActionUrl = [_gtmContainer stringForKey:GTMKeyInboxActionReputationBase];
    postActionUrl = [_gtmContainer stringForKey:GTMKeyInboxActionReputationPost];
}

#pragma mark - Product Add Caption Delegate
- (void)didDismissController:(ProductAddCaptionViewController*)controller withUserInfo:(NSDictionary *)userinfo {
    _userInfo = userinfo;
    NSArray *selectedImages = [userinfo objectForKey:@"selected_images"];
    NSArray *selectedIndexpaths = [userinfo objectForKey:@"selected_indexpath"];
    
    // Cari Index Image yang kosong
    NSMutableArray *emptyImageIndex = [NSMutableArray new];
    for (UIImageView *image in attachedImages) {
        if (image.image == nil || [self image:image.image isEqualTo:[UIImage imageNamed:@"icon_camera.png"]]) {
            [emptyImageIndex addObject:@(image.tag - 20)];
        }
    }
    
    //Upload Image yg belum diupload tp dipilih
    int j = 0;
    for (NSDictionary *selected in selectedImages) {
        if ([selected isKindOfClass:[NSDictionary class]]) {
            if (j>=emptyImageIndex.count) {
                return;
            }
            if (![self array:[_selectedImagesCameraController copy] containsObject:selected]) {
                NSUInteger index = [emptyImageIndex[j] integerValue];
                [_selectedImagesCameraController replaceObjectAtIndex:index withObject:selected];
                NSMutableDictionary *data = [NSMutableDictionary new];
                [data addEntriesFromDictionary:selected];
                NSUInteger indexIndexPath = [_selectedImagesCameraController indexOfObject:selected];
                [data setObject:selectedIndexpaths[indexIndexPath] forKey:@"selected_indexpath"];
                [self setImageData:[data copy] tag:index];
                j++;
            }
        }
    }
}

-(void)setImageData:(NSDictionary*)data tag:(NSInteger)tag
{
    id selectedIndexpaths = [data objectForKey:@"selected_indexpath"];
    [_selectedIndexPathCameraController replaceObjectAtIndex:tag withObject:selectedIndexpaths?:@""];
    
    NSInteger tagView = tag + 20;
    NSMutableDictionary *object = [NSMutableDictionary new];
    [object setObject:data forKey:@"photo"];
    UIImageView *imageView;
    
    NSDictionary* photo = [data objectForKey:@"photo"];
    
    UIImage* imagePhoto = [photo objectForKey:@"photo"];
    
    for (UIImageView *image in attachedImages) {
        if (image.tag == tagView) {
            imageView = image;
            image.image = imagePhoto;
            image.hidden = NO;
            image.userInteractionEnabled = YES;
            image.contentMode = UIViewContentModeScaleToFill;
        }
        
        if (image.tag == tagView + 1) {
            if (image.image == nil) {
                image.image = [UIImage imageNamed:@"icon_camera.png"];
                image.userInteractionEnabled = YES;
                image.hidden = NO;
                image.contentMode = UIViewContentModeCenter;
                [image.layer setBorderColor:[[UIColor colorWithRed:200.0/255 green:199.0/255 blue:204.0/255 alpha:1] CGColor]];
                [image.layer setBorderWidth:1.0];
                image.layer.cornerRadius = 5.0;
                image.layer.masksToBounds = YES;

            }
        }
    }
    
    if (imageView != nil) {
        [object setObject:imageView forKey:@"data_selected_image_view"];
    }
    
    [object setObject:_selectedImagesCameraController[tag] forKey:@"data_selected_photo"];
    [object setObject:_selectedIndexPathCameraController[tag] forKey:@"data_selected_indexpath"];
    
}

#pragma mark - Request Generate Host
- (void)setGenerateHost:(GeneratedHost *)generateHost {
    _generatedHost = generateHost;
}

- (void)successGenerateHost:(GenerateHost *)generateHost {
    _generateHost = generateHost;
    [_del setGenerateHost:_generateHost.result.generated_host];
    [addPictureButtons makeObjectsPerformSelector:@selector(setEnabled:) withObject:@(YES)];
}

- (void)failedGenerateHost:(NSArray *)errorMessages {
    StickyAlertView *alert = [[StickyAlertView alloc]initWithErrorMessages:errorMessages delegate:self];
    [alert show];
}

#pragma mark - Request Action Upload Image
- (void)actionUploadImage:(id)object {
    if (![_uploadingImages containsObject:object]) {
        [_uploadingImages addObject:object];
    }
    
    _isFinishedUploadingImage = NO;
    
    RequestUploadImage *uploadImage = [RequestUploadImage new];
    [uploadImage requestActionUploadObject:object
                             generatedHost:_generateHost.result.generated_host
                                    action:@"upload_contact_image"
                                    newAdd:1
                                 productID:@""
                                 paymentID:@""
                                 fieldName:@"fileToUpload"
                                   success:^(id imageObject, UploadImage *image) {
                                       [self successUploadObject:object withMappingResult:image];
                                   } failure:^(id imageObject, NSError *error) {
                                       [self failedUploadObject:imageObject];
                                   }];
}

- (void)successUploadObject:(id)object withMappingResult:(UploadImage *)uploadImage {
    UIImageView *imageView = [object objectForKey:DATA_SELECTED_IMAGE_VIEW_KEY];
    imageView.alpha = 1.0;
    
    if (![_uploadedImages containsObject:uploadImage.result.file_th]) {
        [_uploadedImages replaceObjectAtIndex:imageView.tag-20 withObject:uploadImage.result.file_th];
    }
    
    [_uploadingImages removeObject:object];
    _isFinishedUploadingImage = YES;
    
}

- (void)failedUploadObject:(id)object {
    UIImageView *imageView = [object objectForKey:DATA_SELECTED_IMAGE_VIEW_KEY];
    imageView.image = nil;
    
    for (UIButton *button in addPictureButtons) {
        if (button.tag == imageView.tag) {
            button.hidden = NO;
            button.enabled = YES;
        }
    }
    
    imageView.hidden = YES;
    
    [_uploadingImages removeObject:object];
    NSMutableArray *objectProductPhoto = [NSMutableArray new];
    objectProductPhoto = _uploadedImages;
    for (int i = 0; i<_selectedImagesCameraController.count; i++) {
        if ([_selectedImagesCameraController[i]isEqual:[object objectForKey:DATA_SELECTED_PHOTO_KEY]]) {
            [_selectedImagesCameraController replaceObjectAtIndex:i withObject:@""];
            [_selectedIndexPathCameraController replaceObjectAtIndex:i withObject:@""];
            [objectProductPhoto replaceObjectAtIndex:i withObject:@""];
        }
    }
}

@end
