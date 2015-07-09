//
//  GiveReviewViewController.m
//  Tokopedia
//
//  Created by Tokopedia on 7/8/15.
//  Copyright (c) 2015 TOKOPEDIA. All rights reserved.
//
#import "DetailReputationReview.h"
#import "GeneralAction.h"
#import "GiveReviewViewController.h"
#import "TKPDTextView.h"
#import "TokopediaNetworkManager.h"
#define CPlaceHolderTulisReview @"Tulis review disini..."
#define CTagSubmitReputation 1

@interface GiveReviewViewController ()<TokopediaNetworkManagerDelegate>

@end

@implementation GiveReviewViewController
{
    BOOL isEdit;
    int nRateKualitas, nRateAkurasi;
    float heightScreenView;
    TokopediaNetworkManager *tokopediaNetworkManager;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    txtDes.placeholder = CPlaceHolderTulisReview;
    nRateAkurasi = nRateKualitas = 0;
    [self initData];
    [self isLoading:NO];
}

- (void)viewWillAppear:(BOOL)animated
{
    heightScreenView = self.view.bounds.size.height;
    constraintHeightScrollView.constant = heightScreenView;
    constHeightContentView.constant = heightScreenView;
    [self.view addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(resignKeyboard:)]];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
}

- (void)viewWillDisappear:(BOOL)animated {
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
    lblProduct.text = _detailReputationView.product_name;

    //Set image product
    NSURLRequest *userImageRequest = [[NSURLRequest alloc] initWithURL:[NSURL URLWithString:_detailReputationView.product_uri] cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:kTKPDREQUEST_TIMEOUTINTERVAL];

    [imgProduct setImageWithURLRequest:userImageRequest placeholderImage:[UIImage imageNamed:@"icon_profile_picture.jpeg"] success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-retain-cycles"
        [imgProduct setImage:image];
#pragma clang diagnostic pop
    } failure:nil];
    
    //add gesture to every image
    for(UIImageView *tempImage in arrImgAkurasi) {
        tempImage.userInteractionEnabled = YES;
        [tempImage addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(gestureAkurasi:)]];
    }
    
    for(UIImageView *tempImage in arrImgKualitas) {
        tempImage.userInteractionEnabled = YES;
        [tempImage addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(gestureKualitas:)]];
    }
    
    isEdit = !(_detailReputationView.review_response==nil || _detailReputationView.review_response.response_message==nil || _detailReputationView.review_response.response_message.length == 0);
    if(isEdit) {
        txtDes.text = _detailReputationView.review_response.response_message;
        
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
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Submit" style:UIBarButtonItemStyleDone target:self action:@selector(actionSubmit:)];
    }
}

#pragma mark - Action
- (void)actionSubmit:(id)sender {
    if(! [self successValidate]) {
#define CStringPleaseFillReview @"Please fill your review with min 30 character."
        StickyAlertView *stickyAlertView = [[StickyAlertView alloc] initWithErrorMessages:@[CStringPleaseFillReview] delegate:self];
        [stickyAlertView show];
        
        return;
    }
    
    [self isLoading:YES];
    [[self getNetworkManager:CTagSubmitReputation] doRequest];
    [[NSRunLoop currentRunLoop] runUntilDate:[NSDate date]];
    [NSThread sleepForTimeInterval:5];
    [self isLoading:NO];
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
    nRateAkurasi = sender.view.tag;
    [self setAkurasiStar];
}

- (void)gestureKualitas:(UITapGestureRecognizer *)sender {
    nRateKualitas = sender.view.tag;
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
                 @"accuracy_rate" : @(nRateAkurasi)
                 };
    }
    
    return nil;
}

- (NSString*)getPath:(int)tag {
    if(tag == CTagSubmitReputation) {
        return @"action/reputation.pl";
    }
    
    return nil;
}

- (id)getObjectManager:(int)tag {
    if(tag == CTagSubmitReputation) {
        RKObjectManager *objectManager = [RKObjectManager sharedClient];

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
//    NSDictionary *resultDict = ((RKMappingResult*) successResult).dictionary;
//    id stat = [resultDict objectForKey:@""];
    
    if(tag == CTagSubmitReputation) {
        [self isLoading:NO];
        StickyAlertView *stickyAlertView = [[StickyAlertView alloc] initWithErrorMessages:@[isEdit? @"Berhasil memperbaharui reputasi review":@"Berhasil mengisi reputasi review"] delegate:self];
        [stickyAlertView show];
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
        StickyAlertView *stickyAlertView = [[StickyAlertView alloc] initWithErrorMessages:@[@"Gagal mengisi reputasi"] delegate:self];
        [stickyAlertView show];
    }
}
@end
