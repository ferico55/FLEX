//
//  MyReviewDetailViewController.m
//  Tokopedia
//
//  Created by Kenneth Vincent on 2/10/16.
//  Copyright © 2016 TOKOPEDIA. All rights reserved.
//

#import "MyReviewDetailViewController.h"

@interface MyReviewDetailViewController ()

@property (weak, nonatomic) IBOutlet UITableView *reviewDetailTable;

@property (strong, nonatomic) IBOutlet UIView *tableHeaderView;
@property (weak, nonatomic) IBOutlet UIView *userInfoView;
@property (weak, nonatomic) IBOutlet UIView *sellersScoreView;
@property (weak, nonatomic) IBOutlet UIView *buyersScoreView;

@property (weak, nonatomic) IBOutlet UIImageView *shopImage;
@property (weak, nonatomic) IBOutlet UILabel *shopNameLabel;
@property (weak, nonatomic) IBOutlet UIButton *shopScoreButton;

@property (weak, nonatomic) IBOutlet UIButton *sellersScoreButton;
@property (weak, nonatomic) IBOutlet UILabel *isSellersScoreEditedLabel;

@property (weak, nonatomic) IBOutlet UIButton *buyersScoreButton;
@property (weak, nonatomic) IBOutlet UILabel *isBuyersScoreEditedLabel;


@end

@implementation MyReviewDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
