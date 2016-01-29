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
@property (weak, nonatomic) IBOutlet UIButton *continueButton;

@end

@implementation GiveReviewRatingViewController {
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = _isEdit?@"Ubah Ulasan":@"Tulis Ulasan";
    
    _navigate = [NavigateViewController new];
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Lanjut"
                                                                              style:UIBarButtonItemStyleDone
                                                                             target:self
                                                                             action:@selector(tapToContinue:)];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Actions
- (IBAction)tapToContinue:(id)sender {
    GiveReviewDetailViewController *vc = [GiveReviewDetailViewController new];
    
    vc.isEdit = _isEdit;
    vc.qualityRate = _qualityRate;
    vc.accuracyRate = _accuracyRate;
    
    [self.navigationController pushViewController:vc animated:YES];
}

- (IBAction)tapProduct:(id)sender {
    [_navigate navigateToProductFromViewController:self withData:@{@"product_id":_detailReputationReview.product_id}];
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
- (void)setQualityLabel {
    switch (_qualityRate) {
        case 0:
            _qualityLabel.text = @"";
            break;
        case 1:
            _qualityLabel.text = @"Sangat Buruk";
            break;
        case 2:
            _qualityLabel.text = @"Buruk";
            break;
        case 3:
            _qualityLabel.text = @"Netral";
            break;
        case 4:
            _qualityLabel.text = @"Bagus";
            break;
        case 5:
            _qualityLabel.text = @"Sangat Bagus";
            break;
        default:
            break;
    }
}

- (void)setAccuracyLabel {
    switch (_accuracyRate) {
        case 0:
            _accuracyLabel.text = @"";
            break;
        case 1:
            _accuracyLabel.text = @"Sangat Buruk";
            break;
        case 2:
            _accuracyLabel.text = @"Buruk";
            break;
        case 3:
            _accuracyLabel.text = @"Netral";
            break;
        case 4:
            _accuracyLabel.text = @"Bagus";
            break;
        case 5:
            _accuracyLabel.text = @"Sangat Bagus";
            break;
        default:
            break;
    }
}

@end
