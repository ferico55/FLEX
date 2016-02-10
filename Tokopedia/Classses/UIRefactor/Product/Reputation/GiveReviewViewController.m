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
#define CStringTidakAdaPerubahan @"Tidak ada perubahan ulasan"
#define CStringAndaTidakDapatMenurunkanRate @"Anda tidak dapat memberi penurunan rating"
#define CStringPleaseFillReviewRating @"Rating harus diisi"
#define CPlaceHolderTulisReview @"Tulis ulasan disini..."
#define CStringPleaseFillReview @"Pesan ulasan harus lebih dari 30 karakter"
#define CTagSubmitReputation 1

@interface GiveReviewViewController ()<TokopediaNetworkManagerDelegate, UITextViewDelegate>

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
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    heightScreenView = self.view.bounds.size.height;
    constraintHeightScrollView.constant = heightScreenView;
    constHeightContentView.constant = heightScreenView;
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
    constHeightContentView.constant = viewContentRating.frame.origin.y+viewContentRating.bounds.size.height;
    
    
    
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
    constHeightContentView.constant = heightScreenView;
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
@end
