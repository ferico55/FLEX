//
//  GiveReviewDetailViewController.m
//  Tokopedia
//
//  Created by Kenneth Vincent on 1/29/16.
//  Copyright © 2016 TOKOPEDIA. All rights reserved.
//

#import "GiveReviewDetailViewController.h"
#import "TKPDTextView.h"
#import "DetailReputationReview.h"
#import "ReviewSummaryViewController.h"
#import "CameraAlbumListViewController.h"
#import "CameraCollectionViewController.h"
#import "RequestGenerateHost.h"
#import "RequestUploadImage.h"
#import "CameraController.h"
#import "RequestGenerateHost.h"
#import "ProductAddCaptionViewController.h"
#import <QuartzCore/QuartzCore.h>

@interface GiveReviewDetailViewController () <TokopediaNetworkManagerDelegate, CameraCollectionViewControllerDelegate, GenerateHostDelegate, CameraControllerDelegate, RequestUploadImageDelegate, ProductAddCaptionDelegate> {
    NSMutableArray *_selectedImagesCameraController;
    NSMutableArray *_selectedIndexPathCameraController;
    NSMutableArray *_attachedImageURL;
    
    NSMutableArray *_uploadingImages;
    NSMutableArray *_uploadedImages;
    
    NSOperationQueue *_operationQueue;
    
    GenerateHost *_generateHost;
    GeneratedHost *_generatedHost;
    
    BOOL _isFinishedUploadingImage;
}

@property (weak, nonatomic) IBOutlet UIImageView *productImage;
@property (weak, nonatomic) IBOutlet UILabel *productName;
@property (weak, nonatomic) IBOutlet TKPDTextView *reviewDetailTextView;
@property (weak, nonatomic) IBOutlet UIView *attachedImageView;
@property (strong, nonatomic) IBOutletCollection(UIImageView) NSArray *attachedImagesArray;


@end

@implementation GiveReviewDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = _isEdit?@"Ubah Ulasan":@"Tulis Ulasan";
    _reviewDetailTextView.placeholder = @"Tulis Ulasan Anda";
    
    _attachedImagesArray = [NSArray sortViewsWithTagInArray:_attachedImagesArray];
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Lanjut"
                                                                              style:UIBarButtonItemStyleDone
                                                                             target:self
                                                                             action:@selector(tapToContinue:)];
    
    [self initData];
    
    _operationQueue = [NSOperationQueue new];
    _generateHost = [GenerateHost new];
    _generatedHost = [GeneratedHost new];
    
    _uploadingImages = [NSMutableArray new];
    _selectedImagesCameraController = [[NSMutableArray alloc] initWithObjects:@"", @"", @"", @"", @"", nil];
    _selectedIndexPathCameraController = [[NSMutableArray alloc] initWithObjects:@"", @"", @"", @"", @"", nil];
    _attachedImageURL = [[NSMutableArray alloc] initWithObjects:@"", @"", @"", @"", @"", nil];
    
    _isFinishedUploadingImage = YES;
    
    RequestGenerateHost *requestHost = [RequestGenerateHost new];
    [requestHost configureRestkitGenerateHost];
    [requestHost requestGenerateHost];
    requestHost.delegate = self;
    
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark - Methods
- (void)initData {
    _productName.text = [NSString convertHTML:_detailReputationReview.product_name];
    
    // Set Product Image
    NSURLRequest *request = [[NSURLRequest alloc] initWithURL:[NSURL URLWithString:_detailReputationReview.product_image]
                                                  cachePolicy:NSURLRequestUseProtocolCachePolicy
                                              timeoutInterval:kTKPDREQUEST_TIMEOUTINTERVAL];
    
    [_productImage setImageWithURLRequest:request
                         placeholderImage:[UIImage imageNamed:@"icon_toped_loading_grey-01.png"]
                                  success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-retain-cycles"
                                      [_productImage setImage:image];
#pragma clang diagnostic pop
                                  }
                                  failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) {
                                      NSLog(@"Failed get image");
                                  }];
    
    if (_isEdit) {
        _reviewDetailTextView.text = [NSString convertHTML:_detailReputationReview.review_message];
    }
}

- (void)initCameraIcon {
    for (UIImageView *image in _attachedImagesArray) {
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

- (BOOL)isSuccessValidateMessage {
    if ([_reviewDetailTextView.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]].length == 0) {
        StickyAlertView *stickyAlertView = [[StickyAlertView alloc] initWithErrorMessages:@[@"Ulasan harus diisi."] delegate:self];
        [stickyAlertView show];
        return NO;
    } else if ([_reviewDetailTextView.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]].length < 30) {
        StickyAlertView *stickyAlertView = [[StickyAlertView alloc] initWithErrorMessages:@[@"Ulasan yang diberikan harus minimal 30 karakter."] delegate:self];
        [stickyAlertView show];
        return NO;
    } else {
        return YES;
    }
}

#pragma mark - Actions
- (IBAction)tapToContinue:(id)sender {
    if ([self isSuccessValidateMessage]) {
        ReviewSummaryViewController *vc = [ReviewSummaryViewController new];
        vc.detailReputationReview = _detailReputationReview;
        vc.isEdit = _isEdit;
        vc.qualityRate = _qualityRate;
        vc.accuracyRate = _accuracyRate;
        vc.reviewMessage = _reviewDetailTextView.text;
        vc.hasAttachedImages = NO;
        
        [self.navigationController pushViewController:vc animated:YES];
    }
}

#pragma mark - Request Generate Host
- (void)setGenerateHost:(GeneratedHost *)generateHost {
    _generatedHost = generateHost;
}

- (void)successGenerateHost:(GenerateHost *)generateHost {
    _generateHost = generateHost;
    [_delegate setGenerateHost:_generateHost.result.generated_host];
}

- (void)failedGenerateHost:(NSArray *)errorMessages {
    StickyAlertView *alert = [[StickyAlertView alloc]initWithErrorMessages:errorMessages delegate:self];
    [alert show];
}

@end
