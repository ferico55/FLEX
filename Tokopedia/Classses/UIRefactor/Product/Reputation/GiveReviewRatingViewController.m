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

@interface GiveReviewRatingViewController () {
    NavigateViewController *_navigate;
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
    
    _qualityStarsArray = [NSArray sortViewsWithTagInArray:_qualityStarsArray];
    _accuracyStarsArray = [NSArray sortViewsWithTagInArray:_accuracyStarsArray];
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Lanjut"
                                                                              style:UIBarButtonItemStyleDone
                                                                             target:self
                                                                             action:@selector(tapToContinue:)];
    
    [self initData];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    self.title = @"";
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.title = _isEdit?@"Ubah Ulasan":@"Tulis Ulasan";
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Actions
- (IBAction)tapToContinue:(id)sender {
    if ([self isSuccessValidateRating]) {
        GiveReviewDetailViewController *vc = [GiveReviewDetailViewController new];
        
        vc.isEdit = _isEdit;
        vc.detailMyReviewReputation = _detailMyReviewReputation;
        vc.qualityRate = _qualityRate;
        vc.accuracyRate = _accuracyRate;
        vc.detailReputationReview = _detailReputationReview;
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
    _productName.text = [NSString convertHTML:_detailReputationReview.product_name];
    
    // Set Product Image
    NSURLRequest *request = [[NSURLRequest alloc] initWithURL:[NSURL URLWithString:_detailReputationReview.product_image]
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
                                                                       attributes:@{NSFontAttributeName:[UIFont fontWithName:@"Gotham Book" size:17.0]}];
        _accuracyLabel.attributedText = [[NSAttributedString alloc] initWithString:@"Akurasi:"
                                                                        attributes:@{NSFontAttributeName:[UIFont fontWithName:@"Gotham Book" size:17.0]}];
    } else {
        _qualityRate = (_detailReputationReview.product_rating_point==nil || _detailReputationReview.product_rating_point.length==0)? 0:[_detailReputationReview.product_rating_point intValue];
        [self setQualityLabel];
        for (int ii = 0; ii < _qualityStarsArray.count; ii++) {
            UIImageView *temp = [_qualityStarsArray objectAtIndex:ii];
            temp.image = [UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:((ii < _qualityRate)? @"icon_star_active":@"icon_star") ofType:@"png"]];
        }
        
        
        _accuracyRate = (_detailReputationReview.product_accuracy_point==nil || _detailReputationReview.product_accuracy_point.length==0)? 0:[_detailReputationReview.product_accuracy_point intValue];
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
                                                                               attributes:@{NSFontAttributeName:[UIFont fontWithName:@"Gotham Book" size:17.0]}];
    
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
                                                                          attributes:@{NSFontAttributeName:[UIFont fontWithName:@"Gotham Medium" size:17.0]}]];
    
    _qualityLabel.attributedText = mutableString;
}

- (void)setAccuracyLabel {
    NSString *accuracy = @"";
    NSMutableAttributedString *mutableString = [[NSMutableAttributedString alloc] initWithString:@"Akurasi:"
                                                                                      attributes:@{NSFontAttributeName:[UIFont fontWithName:@"Gotham Book" size:17.0]}];
    
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
                                                                          attributes:@{NSFontAttributeName:[UIFont fontWithName:@"Gotham Medium" size:17.0]}]];
    
    _accuracyLabel.attributedText = mutableString;
}

- (BOOL)isSuccessValidateRating {
    if (_isEdit) {
        if ([_detailReputationReview.product_accuracy_point intValue] > _accuracyRate || [_detailReputationReview.product_rating_point intValue] > _qualityRate) {
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
