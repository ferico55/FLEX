//
//  ContactUsViewController.m
//  Tokopedia
//
//  Created by Tonito Acen on 4/8/15.
//  Copyright (c) 2015 TOKOPEDIA. All rights reserved.
//

#import "ContactUsViewController.h"
#import "TicketCategory.h"
#import "string_contact_us.h"
#import "ContactUsTypeCell.h"
#import "ContactUsPresenter.h"

@interface ContactUsViewController ()
<
    UITableViewDataSource,
    UITableViewDelegate,
    UICollectionViewDataSource,
    UICollectionViewDelegate,
    UICollectionViewDelegateFlowLayout,
    UIWebViewDelegate
>
{
    NSArray *_categories;
    NSIndexPath *_selectedCollectionIndexPath;
    TicketCategory *_selectedType;
    TicketCategory *_selectedProblem;
    TicketCategory *_selectedDetailProblem;
}

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) IBOutlet UITableViewCell *problemTypeCell;
@property (strong, nonatomic) IBOutlet UITableViewCell *problemCell;
@property (strong, nonatomic) IBOutlet UITableViewCell *problemDetailCell;
@property (strong, nonatomic) IBOutlet UITableViewCell *problemSolutionCell;
@property (strong, nonatomic) IBOutlet UIView *typeHeaderView;
@property (strong, nonatomic) IBOutlet UIView *problemHeaderView;
@property (strong, nonatomic) IBOutlet UIView *solutionHeaderView;
@property (strong, nonatomic) IBOutlet UIView *footerView;
@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@property (weak, nonatomic) IBOutlet UICollectionViewFlowLayout *flowLayout;
@property (strong, nonatomic) IBOutlet UIWebView *descriptionWebView;

@end

@implementation ContactUsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"Hubungi Kami";

    self.hidesBottomBarWhenPushed = YES;
    
    UIBarButtonItem *backButton = [[UIBarButtonItem alloc] initWithTitle:@""
                                                                   style:UIBarButtonItemStyleBordered
                                                                  target:self
                                                                  action:nil];
    self.navigationItem.backBarButtonItem = backButton;
    
    UINib *nib = [UINib nibWithNibName:@"ContactUsTypeCell" bundle:nil];
    [self.collectionView registerNib:nib forCellWithReuseIdentifier:@"ContactUsTypeCell"];
    
    [self.flowLayout setFooterReferenceSize:CGSizeMake(160, 160)];
    [self.flowLayout setSectionInset:UIEdgeInsetsZero];
    [self.collectionView setCollectionViewLayout:_flowLayout];

    [self.eventHandler updateView];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    NSInteger sections;
    if (_categories.count > 0) {
        sections = 3;
    } else {
        sections = 0;
    }
    return sections;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSInteger rows = 0;
    if (section == 0) {
        rows = 1;
    } else if (section == 1) {
        if (_selectedType) {
            rows = 1;
        }
        if (_selectedProblem) {
            rows = 2;
        }
    } else if (section == 2 && _selectedDetailProblem) {
        rows = 1;
    }
    return rows;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell;
    if (indexPath.section == 0) {
        cell = _problemTypeCell;
    } else if (indexPath.section == 1) {
        if (indexPath.row == 0) {
            cell = _problemCell;
            if (_selectedProblem) cell.detailTextLabel.text = _selectedProblem.ticket_category_name?:@"Pilih";
        } else if (indexPath.row == 1) {
            cell = _problemDetailCell;
            if (_selectedDetailProblem) cell.detailTextLabel.text = _selectedDetailProblem.ticket_category_name?:@"Pilih";
        }
    } else if (indexPath.section == 2) {
        cell = _problemSolutionCell;
    }
    return cell;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    UIView *view;
    if (section == 0) {
        view = _typeHeaderView;
    } else if (section == 1 && _selectedType) {
        view = _problemHeaderView;
    } else if (section == 2 && _selectedDetailProblem) {
        view = _solutionHeaderView;
    }
    return view;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    CGFloat height = _typeHeaderView.frame.size.height;
    return height;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    CGFloat height;
    if (indexPath.section == 0) {
        height = 340;
    } else if (indexPath.section == 1) {
        height = 44;
    } else if (indexPath.section == 2) {
        height = 200;
    }
    return height;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (indexPath.section == 1) {
        if (indexPath.row == 0) {
            [self.eventHandler didSelectContactUsType:_selectedType
                                      selectedProblem:_selectedProblem
                                       fromNavigation:self.navigationController];
        } else if (indexPath.row == 1) {
            [self.eventHandler didSelectProblem:_selectedProblem
                          selectedDetailProblem:_selectedDetailProblem
                                 fromNavigation:self.navigationController];
        }
    }
}

#pragma mark - Collection view data source

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return 4;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    ContactUsTypeCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"ContactUsTypeCell" forIndexPath:indexPath];
    TicketCategory *category = [_categories objectAtIndex:indexPath.row];
    cell.titleLabel.text = category.ticket_category_name;
    cell.imageView.layer.cornerRadius = cell.imageView.frame.size.width / 2;
    cell.imageView.layer.borderWidth = 0;
    if ([category.ticket_category_id isEqualToString:@"101"]) {
        cell.imageView.image = [UIImage imageNamed:@"icon_problem_new_user.png"];
    } else if ([category.ticket_category_id isEqualToString:@"102"]) {
        cell.imageView.image = [UIImage imageNamed:@"icon_problem_buyer.png"];
    } else if ([category.ticket_category_id isEqualToString:@"103"]) {
        cell.imageView.image = [UIImage imageNamed:@"icon_problem_shopper.png"];
    } else if ([category.ticket_category_id isEqualToString:@"104"]) {
        cell.imageView.image = [UIImage imageNamed:@"icon_problem_about_account.png"];
    }
    if (_selectedCollectionIndexPath) {
        cell.alpha = 0.5;
        if (indexPath.row == _selectedCollectionIndexPath.row) {
            cell.imageView.layer.borderWidth = 5;
            cell.imageView.layer.borderColor = [UIColor colorWithRed:18/255.0
                                                               green:199/255.0
                                                                blue:0/255.0
                                                               alpha:1].CGColor;
            cell.alpha = 1;
        }
    } else {
        cell.alpha = 1;
    }
    return cell;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    return CGSizeMake(160, 160);
}

#pragma mark - Collection view delegate

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    _selectedCollectionIndexPath = indexPath;
    _selectedType = [_categories objectAtIndex:indexPath.row];
    [collectionView reloadData];
    [self.tableView reloadData];
}

#pragma mark - Action

- (IBAction)didTapContactUsButton:(UIButton *)sender {
    [self.eventHandler didTapContactUsButtonWithType:_selectedType
                                     selectedProblem:_selectedProblem
                               selectedDetailProblem:_selectedDetailProblem
                                      fromNavigation:self.navigationController];
}

#pragma mark - View delegate

- (void)showContactUsFormData:(NSArray *)data {
    _categories = data;
    [self.tableView reloadData];
}

- (void)setErrorView {
    
}

- (void)setRetryView {
    
}

- (void)setSelectedProblem:(TicketCategory *)problem {
    _selectedProblem = problem;
    [self.tableView reloadData];
}

- (void)setSelectedDetailProblem:(TicketCategory *)detailProblem {
    _selectedDetailProblem = detailProblem;
    [self.descriptionWebView loadHTMLString:_selectedDetailProblem.ticket_category_description baseURL:nil];
    self.tableView.tableFooterView = _footerView;
    [self.tableView reloadData];
}

@end