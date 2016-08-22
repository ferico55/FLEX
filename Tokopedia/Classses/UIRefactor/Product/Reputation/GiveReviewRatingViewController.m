//
//  GiveReviewRatingViewController.m
//  Tokopedia
//
//  Created by Kenneth Vincent on 1/29/16.
//  Copyright © 2016 TOKOPEDIA. All rights reserved.
//

#import "GiveReviewRatingViewController.h"
#import "DetailReputationReview.h"
#import "GiveReviewDetailViewController.h"
#import "NavigateViewController.h"
#import "AttachedPicture.h"

@interface GiveReviewRatingViewController () {
    NavigateViewController *_navigate;
    
    NSString *_reviewMessage;
    NSMutableArray *_attachedPictures;
    NSMutableArray *_uploadedPictures;
    NSMutableArray *_tempUploadedPictures;
    
    BOOL _hasImages;
}

@property (weak, nonatomic) IBOutlet UIImageView *productImageView;
@property (weak, nonatomic) IBOutlet UILabel *productName;
@property (weak, nonatomic) IBOutlet UILabel *qualityLabel;
@property (strong, nonatomic) IBOutletCollection(UIImageView) NSArray *qualityStarsArray;
@property (weak, nonatomic) IBOutlet UILabel *accuracyLabel;
@property (strong, nonatomic) IBOutletCollection(UIImageView) NSArray *accuracyStarsArray;

@end

@implementation GiveReviewRatingViewController {
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = _isEdit?@"Ubah Ulasan":@"Tulis Ulasan";
    
    _navigate = [NavigateViewController new];
    
//    _attachedPictures = [NSMutableArray new];
//    _uploadedPictures = [NSMutableArray new];
//    _tempUploadedPictures = [NSMutableArray new];
    
    _qualityStarsArray = [NSArray sortViewsWithTagInArray:_qualityStarsArray];
    _accuracyStarsArray = [NSArray sortViewsWithTagInArray:_accuracyStarsArray];
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Lanjut"
                                                                              style:UIBarButtonItemStyleDone
                                                                             target:self
                                                                             action:@selector(tapToContinue:)];
    
    [self initData];
    
    _giveReviewDetailVC = [GiveReviewDetailViewController new];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    self.title = @"";
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.title = _isEdit?@"Ubah Ulasan":@"Tulis Ulasan";
    
    [TPAnalytics trackScreenName:@"Give Review Rating Page"];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Actions
- (IBAction)tapToContinue:(id)sender {
    if ([self isSuccessValidateRating]) {
        GiveReviewDetailViewController *vc = _giveReviewDetailVC;        
        vc.isEdit = _isEdit;
        vc.myReviewDetailViewController = _myReviewDetailViewController;
        vc.qualityRate = _qualityRate;
        vc.accuracyRate = _accuracyRate;
        vc.review = _review;
        vc.token = _token;
        
        [self.navigationController pushViewController:vc animated:YES];
    }
    
}

- (IBAction)tapQualityStars:(UITapGestureRecognizer *)sender {
    _qualityRate = (int)sender.view.tag;
    
    for (int ii = 0; ii < _qualityStarsArray.count; ii++) {
        UIImageView *tempStar = [_qualityStarsArray objectAtIndex:ii];
        if (ii < _qualityRate) {
            tempStar.image = [UIImage imageNamed:@"icon_star_active.png"];
        } else {
            tempStar.image = [UIImage imageNamed:@"icon_star.png"];
        }
        [self setQualityLabel];
    }
}

- (IBAction)tapAccuracyStars:(UITapGestureRecognizer *)sender {
    _accuracyRate = (int)sender.view.tag;
    
    for (int ii = 0; ii < _accuracyStarsArray.count; ii++) {
        UIImageView *tempStar = [_accuracyStarsArray objectAtIndex:ii];
        if (ii < _accuracyRate) {
            tempStar.image = [UIImage imageNamed:@"icon_star_active.png"];
        } else {
            tempStar.image = [UIImage imageNamed:@"icon_star.png"];
        }
        [self setAccuracyLabel];
    }
}

#pragma mark - Methods
- (void)initData {
    _productName.text = [NSString convertHTML:_review.product_name];
    
    // Set Product Image
    NSURLRequest *request = [[NSURLRequest alloc] initWithURL:[NSURL URLWithString:_review.product_image]
                                                  cachePolicy:NSURLRequestUseProtocolCachePolicy
                                              timeoutInterval:kTKPDREQUEST_TIMEOUTINTERVAL];
    
    [_productImageView setImageWithURLRequest:request
                             placeholderImage:[UIImage imageNamed:@"icon_toped_loading_grey-01.png"]
                                      success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-retain-cycles"
                                          [_productImageView setImage:image];
#pragma clang diagnostic pop
                                      }
                                      failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) {
                                          NSLog(@"Failed get image");
                                      }];
    
    if (!_isEdit) {
        _qualityLabel.attributedText = [[NSAttributedString alloc] initWithString:@"Kualitas:"
                                                                       attributes:@{NSFontAttributeName:[UIFont title1Theme]}];
        _accuracyLabel.attributedText = [[NSAttributedString alloc] initWithString:@"Akurasi:"
                                                                        attributes:@{NSFontAttributeName:[UIFont title1Theme]}];
    } else {
        _qualityRate = (_review.product_rating_point==nil || _review.product_rating_point.length==0)? 0:[_review.product_rating_point intValue];
        [self setQualityLabel];
        for (int ii = 0; ii < _qualityStarsArray.count; ii++) {
            UIImageView *temp = [_qualityStarsArray objectAtIndex:ii];
            temp.image = [UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:((ii < _qualityRate)? @"icon_star_active":@"icon_star") ofType:@"png"]];
        }
        
        
        _accuracyRate = (_review.product_accuracy_point==nil || _review.product_accuracy_point.length==0)? 0:[_review.product_accuracy_point intValue];
        [self setAccuracyLabel];
        for (int ii = 0; ii < _accuracyStarsArray.count; ii++) {
            UIImageView *temp = [_accuracyStarsArray objectAtIndex:ii];
            temp.image = [UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:((ii < _accuracyRate)? @"icon_star_active":@"icon_star") ofType:@"png"]];
        }
    }
}

- (void)setQualityLabel {
    NSString *quality = @"";
    NSMutableAttributedString *mutableString = [[NSMutableAttributedString alloc] initWithString:@"Kualitas:"
                                                                               attributes:@{NSFontAttributeName:[UIFont title1Theme]}];
    
    switch (_qualityRate) {
        case 0:
            quality = @"";
            break;
        case 1:
            quality = @"Sangat Buruk";
            break;
        case 2:
            quality = @"Buruk";
            break;
        case 3:
            quality = @"Netral";
            break;
        case 4:
            quality = @"Bagus";
            break;
        case 5:
            quality = @"Sangat Bagus";
            break;
        default:
            break;
    }
    
    [mutableString appendAttributedString:[[NSAttributedString alloc] initWithString:@" "]];
    [mutableString appendAttributedString:[[NSAttributedString alloc] initWithString:quality
                                                                          attributes:@{NSFontAttributeName:[UIFont title1ThemeMedium]}]];
    
    _qualityLabel.attributedText = mutableString;
}

- (void)setAccuracyLabel {
    NSString *accuracy = @"";
    NSMutableAttributedString *mutableString = [[NSMutableAttributedString alloc] initWithString:@"Akurasi:"
                                                                                      attributes:@{NSFontAttributeName:[UIFont title1Theme]}];
    
    switch (_accuracyRate) {
        case 0:
            accuracy = @"";
            break;
        case 1:
            accuracy = @"Sangat Buruk";
            break;
        case 2:
            accuracy = @"Buruk";
            break;
        case 3:
            accuracy = @"Netral";
            break;
        case 4:
            accuracy = @"Bagus";
            break;
        case 5:
            accuracy = @"Sangat Bagus";
            break;
        default:
            break;
    }
    
    [mutableString appendAttributedString:[[NSAttributedString alloc] initWithString:@" "]];
    [mutableString appendAttributedString:[[NSAttributedString alloc] initWithString:accuracy
                                                                          attributes:@{NSFontAttributeName:[UIFont title1ThemeMedium]}]];
    
    _accuracyLabel.attributedText = mutableString;
}

- (BOOL)isSuccessValidateRating {
    if (_isEdit) {
        if ([_review.product_accuracy_point intValue] > _accuracyRate || [_review.product_rating_point intValue] > _qualityRate) {
            StickyAlertView *stickyAlertView = [[StickyAlertView alloc] initWithErrorMessages:@[@"Anda tidak dapat memberi penurunan rating"] delegate:self];
            [stickyAlertView show];
            return NO;
        }
    } else {
        if (_accuracyRate == 0 && _qualityRate > 0) {
            StickyAlertView *stickyAlertView = [[StickyAlertView alloc] initWithErrorMessages:@[@"Rating akurasi harus diisi"]
                                                                                     delegate:self];
            [stickyAlertView show];
            
            return NO;
        } else if (_accuracyRate > 0 && _qualityRate == 0) {
            StickyAlertView *stickyAlertView = [[StickyAlertView alloc] initWithErrorMessages:@[@"Rating kualitas harus diisi"]
                                                                                     delegate:self];
            [stickyAlertView show];
            
            return NO;
        }
        if (_accuracyRate == 0 && _qualityRate == 0) {
            StickyAlertView *stickyAlertView = [[StickyAlertView alloc] initWithErrorMessages:@[@"Rating kualitas dan akurasi harus diisi"]
                                                                                     delegate:self];
            [stickyAlertView show];
            
            return NO;
        }
    }
    
    return YES;
}

@end
