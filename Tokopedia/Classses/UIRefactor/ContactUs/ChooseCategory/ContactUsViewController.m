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
#import "ContactUsCategoryCell.h"

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
    TicketCategory *_mainCategory;
    NSMutableArray *_subCategories;
    NSIndexPath *_selectedCollectionIndexPath;
    CGFloat _problemSolutionCellHeight;
    BOOL _showContactUsButton;
}

@property (strong, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) IBOutlet UITableViewCell *problemTypeCell;
@property (strong, nonatomic) IBOutlet UITableViewCell *problemSolutionCell;
@property (strong, nonatomic) IBOutlet UIView *typeHeaderView;
@property (strong, nonatomic) IBOutlet UIView *problemHeaderView;
@property (strong, nonatomic) IBOutlet UIView *solutionHeaderView;
@property (strong, nonatomic) IBOutlet UIView *footerView;
@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@property (weak, nonatomic) IBOutlet UICollectionViewFlowLayout *flowLayout;
@property (weak, nonatomic) IBOutlet UIButton *contactUsButton;
@property (strong, nonatomic) UIWebView *descriptionWebView;
@property (strong, nonatomic) IBOutlet UIView *loadingView;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicatorView;

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
    
    [self.flowLayout setSectionInset:UIEdgeInsetsZero];
    [self.collectionView setCollectionViewLayout:_flowLayout];

    self.contactUsButton.layer.cornerRadius = 3;
    
    _categories = [NSArray new];
    _subCategories = [NSMutableArray new];
    
    [self.eventHandler updateView];
    
    self.tableView.tableHeaderView = _loadingView;
    [self.activityIndicatorView startAnimating];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(resetView)
                                                 name:@"ResetContactUsForm"
                                               object:nil];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self.view endEditing:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)resetView {
    [self.tableView setContentOffset:CGPointZero animated:YES];
    [_subCategories removeAllObjects];
    _mainCategory = nil;
    _selectedCollectionIndexPath = nil;
    _showContactUsButton = NO;
    [self.tableView reloadData];
    [self.collectionView reloadData];
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
        if (_subCategories.count > 0) {
            TicketCategory *category = [_subCategories objectAtIndex:_subCategories.count - 1];
            if (category.ticket_category_child.count > 0) {
                rows = _subCategories.count + 1;
            } else {
                rows = _subCategories.count;
            }
        } else {
            if (_mainCategory) {
                rows = 1;
            }
        }
    } else if (section == 2) {
        if (_subCategories.count > 0) {
            TicketCategory *category = [_subCategories objectAtIndex:_subCategories.count - 1];
            if (category.ticket_category_child.count == 0) {
                rows = 1;
            } else {
                rows = 0;
            }
        } else {
            rows = 0;
        }
    }
    return rows;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell;
    if (indexPath.section == 0) {
        cell = _problemTypeCell;
    } else if (indexPath.section == 1) {
        cell = [tableView dequeueReusableCellWithIdentifier:@"ContactUsCategoryCell"];
        if (cell == nil) {
            cell = [[ContactUsCategoryCell alloc] init];
        }

        if (indexPath.row == _subCategories.count) {
            cell.detailTextLabel.text = @"Pilih";
        } else {
            TicketCategory *category = _subCategories[indexPath.row];
            cell.detailTextLabel.text = category.ticket_category_name;
        }
        
        if (indexPath.row == 0) {
            cell.textLabel.text = @"Pilih Masalah";
        } else {
            cell.textLabel.text = @"Pilih Detail Masalah";
        }
    } else if (indexPath.section == 2) {
        cell = _problemSolutionCell;
        [cell addSubview:_descriptionWebView];
    }
    return cell;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    UIView *view;
    if (section == 0) {
        view = _typeHeaderView;
    } else if (section == 1 && _mainCategory) {
        view = _problemHeaderView;
    } else if (section == 2) {
        if (_subCategories.count > 0) {
            TicketCategory *category = [_subCategories objectAtIndex:_subCategories.count - 1];
            if (category.ticket_category_child.count == 0) {
                view = _solutionHeaderView;
            }
        }
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
        NSInteger numberOfRows = (_categories.count / 2) + (_categories.count % 2);
        height = numberOfRows * 170;
    } else if (indexPath.section == 1) {
        height = 44;
    } else if (indexPath.section == 2) {
        height = _problemSolutionCellHeight;
    }
    return height;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    if (section == 2 && _showContactUsButton) {
        return _footerView;
    } else {
        return nil;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    if (section == 2 && _showContactUsButton) {
        return _footerView.frame.size.height;
    } else {
        return 0;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (indexPath.section == 1) {
        if (_subCategories.count > 0) {
            if (indexPath.row < _subCategories.count) {
                TicketCategory *parentCategory;
                if (indexPath.row == 0) {
                    parentCategory = _mainCategory;
                } else {
                    parentCategory = _subCategories[indexPath.row - 1];
                }
                TicketCategory *currentCategory = _subCategories[indexPath.row];
                [self.eventHandler didSelectCategoryChoices:parentCategory.ticket_category_child
                                       withSelectedCategory:currentCategory
                                            senderIndexPath:indexPath
                                             fromNavigation:self.navigationController];
            } else {
                TicketCategory *parentCategory = _subCategories[indexPath.row - 1];
                [self.eventHandler didSelectCategoryChoices:parentCategory.ticket_category_child
                                       withSelectedCategory:nil
                                            senderIndexPath:indexPath
                                             fromNavigation:self.navigationController];
            }
        } else {
            [self.eventHandler didSelectCategoryChoices:_mainCategory.ticket_category_child
                                   withSelectedCategory:nil
                                        senderIndexPath:indexPath
                                         fromNavigation:self.navigationController];
        }
    }
}

#pragma mark - Collection view data source

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return _categories.count;
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
    } else {
        cell.imageView.backgroundColor = [UIColor colorWithRed:230.0/255.0
                                                         green:231.0/255.0
                                                          blue:232.0/255.0
                                                         alpha:1];
        cell.imageView.image = nil;
        
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
    CGFloat width = self.view.frame.size.width / 2;
    CGFloat height = 170.0f;
    [self.flowLayout setFooterReferenceSize:CGSizeMake(width, height)];
    return CGSizeMake(width, height);
}

#pragma mark - Collection view delegate

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    _selectedCollectionIndexPath = indexPath;
    _mainCategory = [_categories objectAtIndex:indexPath.row];
    [_subCategories removeAllObjects];
    _showContactUsButton = NO;
    [collectionView reloadData];
    [self.tableView reloadData];
}

#pragma mark - Action

- (IBAction)didTapContactUsButton:(UIButton *)sender {
    [self.eventHandler didTapContactUsButtonWithMainCategory:_mainCategory
                                               subCategories:_subCategories
                                              fromNavigation:self.navigationController];
}

#pragma mark - View delegate

- (void)showContactUsFormData:(NSArray *)data {
    _categories = data;
    self.tableView.tableHeaderView = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, self.tableView.bounds.size.width, 0.01f)];
    [self.tableView reloadData];
    [self.activityIndicatorView stopAnimating];
}

- (void)setErrorView {
    
}

- (void)setRetryView {
    
}

- (void)setCategory:(TicketCategory *)category atIndexPath:(NSIndexPath *)indexPath {
    if (_subCategories.count > 0) {
        if (_subCategories.count > indexPath.row) {
            NSMutableIndexSet *indexes = [NSMutableIndexSet new];
            for (int i = 0; i < _subCategories.count; i++) {
                if (i == indexPath.row) {
                    [_subCategories replaceObjectAtIndex:i withObject:category];
                } else if (i > indexPath.row) {
                    [indexes addIndex:i];
                }
            }
            [_subCategories removeObjectsAtIndexes:indexes];
        }
        // if user click empty cell
        else {
            [_subCategories addObject:category];
        }
    } else {
        [_subCategories addObject:category];
    }
    _showContactUsButton = NO;
    if (category.ticket_category_child.count == 0) {
        [self showSolution];
    }
    [self.tableView reloadData];
}

- (void)showSolution {
    [self.descriptionWebView removeFromSuperview];
    CGRect frame = CGRectMake(7, 10, self.view.frame.size.width - 14, 24);
    self.descriptionWebView = [[UIWebView alloc] initWithFrame:frame];
    self.descriptionWebView.delegate = self;
    self.descriptionWebView.scrollView.scrollEnabled = NO;
    self.descriptionWebView.scrollView.bounces = NO;
    [self loadWebViewContent];
    [self performSelector:@selector(loadWebViewContent) withObject:nil afterDelay:1];
}

- (void)loadWebViewContent {
    UIFont *font = [UIFont largeTheme];
    TicketCategory *lastCategory = _subCategories[_subCategories.count - 1];
    NSString *string = lastCategory.ticket_category_description;
    NSString *description = [self htmlFromBodyString:string
                                            textFont:font
                                           textColor:[UIColor blackColor]];
    [self.descriptionWebView loadHTMLString:description baseURL:nil];
}

#pragma mark - Web view 

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
    if (navigationType == UIWebViewNavigationTypeLinkClicked) {
        NSURL *URL = [request URL];
        if ([[URL absoluteString] rangeOfString:@"../../"].location != NSNotFound) {
            NSString *stringURL = [[request URL] absoluteString];
            stringURL = [stringURL stringByReplacingOccurrencesOfString:@"../../" withString:@""];
            stringURL = [NSString stringWithFormat:@"https://www.tokopedia.com/%@", stringURL];
            URL = [NSURL URLWithString:stringURL];
        }
        else if ([[URL absoluteString] rangeOfString:@"applewebdata"].location != NSNotFound) {
            NSString *stringURL = [[request URL] absoluteString];
            stringURL = [stringURL substringFromIndex:52];
            stringURL = [NSString stringWithFormat:@"https://www.tokopedia.com/%@", stringURL];
            URL = [NSURL URLWithString:stringURL];
        }
        [[UIApplication sharedApplication] openURL:URL];
        return NO;
    }
    return YES;
}

- (void)webViewDidFinishLoad:(UIWebView *)webView {
    CGRect frame = self.descriptionWebView.frame;
    frame.size = CGSizeMake(self.view.frame.size.width - 14, self.descriptionWebView.scrollView.contentSize.height);
    frame.origin = CGPointMake(7, 10);
    self.descriptionWebView.frame = frame;
    
    _problemSolutionCellHeight = self.descriptionWebView.scrollView.contentSize.height + 20;
    
    _showContactUsButton = YES;
    [self.tableView reloadData];
}

-(CGSize)sizeOfText:(NSString *)textToMesure widthOfTextView:(CGFloat)width withFont:(UIFont*)font
{
    CGSize ts = [textToMesure sizeWithFont:font
                         constrainedToSize:CGSizeMake(width-20.0, FLT_MAX)
                             lineBreakMode:NSLineBreakByWordWrapping];
    return ts;
}

- (NSString *)htmlFromBodyString:(NSString *)htmlBodyString
                        textFont:(UIFont *)font
                       textColor:(UIColor *)textColor
{
    int numComponents = CGColorGetNumberOfComponents([textColor CGColor]);
    
    NSAssert(numComponents == 4 || numComponents == 2, @"Unsupported color format");
    
    // E.g. FF00A5
    NSString *colorHexString = nil;
    
    const CGFloat *components = CGColorGetComponents([textColor CGColor]);
    
    if (numComponents == 4) {
        unsigned int red = components[0] * 255;
        unsigned int green = components[1] * 255;
        unsigned int blue = components[2] * 255;
        colorHexString = [NSString stringWithFormat:@"%02X%02X%02X", red, green, blue];
    } else {
        unsigned int white = components[0] * 255;
        colorHexString = [NSString stringWithFormat:@"%02X%02X%02X", white, white, white];
    }
    
    NSString *HTML = [NSString stringWithFormat:@"<html>\n"
                      "<head>\n"
                      "<style type=\"text/css\">\n"
                      "body {font-family: \"%@\"; font-size: %@; color:#%@;}\n"
                      "</style>\n"
                      "</head>\n"
                      "<body>%@</body>\n"
                      "</html>",
                      font.familyName, @(font.pointSize), colorHexString, htmlBodyString];
    
    return HTML;
}

@end