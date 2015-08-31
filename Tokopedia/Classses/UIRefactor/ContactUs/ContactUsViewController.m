//
//  ContactUsViewController.m
//  Tokopedia
//
//  Created by Tonito Acen on 4/8/15.
//  Copyright (c) 2015 TOKOPEDIA. All rights reserved.
//

#import "ContactUsViewController.h"
#import "TokopediaNetworkManager.h"
#import "ContactUsResponse.h"
#import "TicketCategory.h"
#import "string_contact_us.h"
#import "ContactUsFormViewController.h"
#import "ContactUsTypeCell.h"
#import "GeneralTableViewController.h"

@interface ContactUsViewController ()
<
    UITableViewDataSource,
    UITableViewDelegate,
    UICollectionViewDataSource,
    UICollectionViewDelegate,
    UICollectionViewDelegateFlowLayout,
    TokopediaNetworkManagerDelegate,
    GeneralTableViewControllerDelegate
>
{
    TokopediaNetworkManager *_networkManager;
    RKObjectManager *_objectManager;
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
@property (weak, nonatomic) IBOutlet UIWebView *descriptionWebView;

@end

@implementation ContactUsViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.title = @"Hubungi Kami";
    
    _networkManager = [TokopediaNetworkManager new];
    _networkManager.delegate = self;
    [_networkManager doRequest];
    
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
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark - Table view delegate

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
    } else if (section == 1) {
        view = _problemHeaderView;
    } else if (section == 2) {
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

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 1) {
        NSString *title;
        NSMutableArray *choices = [NSMutableArray new];
        TicketCategory *selectedCategory;
        if (indexPath.row == 0) {
            title = @"Pilih Masalah";
            selectedCategory = _selectedProblem;
            for (TicketCategory *category in _selectedType.ticket_category_child) {
                [choices addObject:category.ticket_category_name];
            }
        } else if (indexPath.row == 1) {
            title = @"Pilih Detail Masalah";
            selectedCategory = _selectedDetailProblem;
            for (TicketCategory *category in _selectedProblem.ticket_category_child) {
                [choices addObject:category.ticket_category_name];
            }
        }
        
        GeneralTableViewController *controller = [GeneralTableViewController new];
        controller.title = title;
        controller.delegate = self;
        controller.senderIndexPath = indexPath;
        controller.objects = choices;
        controller.selectedObject = selectedCategory.ticket_category_name;
        
        [self.navigationController pushViewController:controller animated:YES];
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
    cell.imageView.layer.cornerRadius = cell.imageView.frame.size.width / 2;
    cell.imageView.layer.borderWidth = 0;
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
    if (indexPath.section == 1) {
        if (indexPath.row == 0) {
            
        } else if (indexPath.row == 1) {
            
        }
    }
    _selectedType = [_categories objectAtIndex:indexPath.row];
    [collectionView reloadData];
    [self.tableView reloadData];
}

#pragma mark - Network manager

- (NSDictionary *)getParameter:(int)tag {
    NSDictionary *param = @{@"action" : @"get_tree_ticket_category"};
    return param;
}

- (NSString *)getPath:(int)tag {
    return @"contact-us.pl";
}

- (id)getObjectManager:(int)tag {
    _objectManager = [RKObjectManager sharedClient];
    
    RKObjectMapping *statusMapping = [RKObjectMapping mappingForClass:[ContactUsResponse class]];
    [statusMapping addAttributeMappingsFromDictionary:@{
                                                        kTKPD_APISTATUSKEY:kTKPD_APISTATUSKEY,
                                                        kTKPD_APISERVERPROCESSTIMEKEY:kTKPD_APISERVERPROCESSTIMEKEY,
                                                        }];
    
    RKObjectMapping *resultMapping = [RKObjectMapping mappingForClass:[ContactUsResult class]];
    
    RKObjectMapping *ticketCategoryMapping = [RKObjectMapping mappingForClass:[TicketCategory class]];
    [ticketCategoryMapping addAttributeMappingsFromArray:@[
                                                           API_TICKET_CATEGORY_NAME_KEY,
                                                           API_TICKET_CATEGORY_TREE_NO_KEY,
                                                           API_TICKET_CATEGORY_DESCRIPTION_KEY,
                                                           API_TICKET_CATEGORY_ID_KEY
                                                           ]];
    
    RKObjectMapping *firstChildMapping = [RKObjectMapping mappingForClass:[TicketCategory class]];
    [firstChildMapping addAttributeMappingsFromArray:@[API_TICKET_CATEGORY_NAME_KEY,
                                                       API_TICKET_CATEGORY_TREE_NO_KEY,
                                                       API_TICKET_CATEGORY_DESCRIPTION_KEY,
                                                       API_TICKET_CATEGORY_ID_KEY
                                                       ]];

    RKObjectMapping *secondChildMapping = [RKObjectMapping mappingForClass:[TicketCategory class]];
    [secondChildMapping addAttributeMappingsFromArray:@[API_TICKET_CATEGORY_NAME_KEY,
                                                        API_TICKET_CATEGORY_TREE_NO_KEY,
                                                        API_TICKET_CATEGORY_DESCRIPTION_KEY,
                                                        API_TICKET_CATEGORY_ID_KEY
                                                        ]];

    RKObjectMapping *thirdChildMapping = [RKObjectMapping mappingForClass:[TicketCategory class]];
    [thirdChildMapping addAttributeMappingsFromArray:@[API_TICKET_CATEGORY_NAME_KEY,
                                                       API_TICKET_CATEGORY_TREE_NO_KEY,
                                                       API_TICKET_CATEGORY_DESCRIPTION_KEY,
                                                       API_TICKET_CATEGORY_ID_KEY
                                                       ]];

    RKObjectMapping *fourthChildMapping = [RKObjectMapping mappingForClass:[TicketCategory class]];
    [fourthChildMapping addAttributeMappingsFromArray:@[API_TICKET_CATEGORY_NAME_KEY,
                                                        API_TICKET_CATEGORY_TREE_NO_KEY,
                                                        API_TICKET_CATEGORY_DESCRIPTION_KEY,
                                                        API_TICKET_CATEGORY_ID_KEY
                                                        ]];

    [statusMapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:kTKPD_APIRESULTKEY
                                                                                  toKeyPath:kTKPD_APIRESULTKEY
                                                                                withMapping:resultMapping]];
    
    [resultMapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:kTKPD_APILISTKEY
                                                                                  toKeyPath:kTKPD_APILISTKEY
                                                                                withMapping:ticketCategoryMapping]];

    [ticketCategoryMapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:API_TICKET_CATEGORY_CHILD_KEY
                                                                                          toKeyPath:API_TICKET_CATEGORY_CHILD_KEY
                                                                                        withMapping:firstChildMapping]];

    [firstChildMapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:API_TICKET_CATEGORY_CHILD_KEY
                                                                                      toKeyPath:API_TICKET_CATEGORY_CHILD_KEY
                                                                                    withMapping:secondChildMapping]];

    [secondChildMapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:API_TICKET_CATEGORY_CHILD_KEY
                                                                                       toKeyPath:API_TICKET_CATEGORY_CHILD_KEY
                                                                                     withMapping:thirdChildMapping]];

    [thirdChildMapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:API_TICKET_CATEGORY_CHILD_KEY
                                                                                      toKeyPath:API_TICKET_CATEGORY_CHILD_KEY
                                                                                    withMapping:fourthChildMapping]];

    RKResponseDescriptor *responseDescriptor = [RKResponseDescriptor responseDescriptorWithMapping:statusMapping
                                                                                            method:RKRequestMethodPOST
                                                                                       pathPattern:@"contact-us.pl"
                                                                                           keyPath:@""
                                                                                       statusCodes:kTkpdIndexSetStatusCodeOK];

    [_objectManager addResponseDescriptor:responseDescriptor];
    
    return _objectManager;
}

- (NSString *)getRequestStatus:(RKMappingResult *)mappingResult withTag:(int)tag {
    ContactUsResponse *response = [mappingResult.dictionary objectForKey:@""];
    return response.status;
}

- (void)actionAfterRequest:(RKMappingResult *)mappingResult withOperation:(RKObjectRequestOperation *)operation withTag:(int)tag {
    ContactUsResponse *response = [mappingResult.dictionary objectForKey:@""];
    _categories = response.result.list;
    [self.tableView reloadData];
}

- (void)actionFailAfterRequest:(id)errorResult withTag:(int)tag {
    
}

#pragma mark - Actions

- (IBAction)tap:(id)sender {
    if ([sender isKindOfClass:[UIButton class]]) {
        UIButton *button = sender;
        if (button.tag <= 4) {
            
        } else if (button.tag == 5) {
            ContactUsFormViewController *controller = [ContactUsFormViewController new];
            [self.navigationController pushViewController:controller animated:YES];
        }
    }
}

#pragma mark - General table delegate

- (void)didSelectObject:(id)object senderIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.section == 1) {
        if (indexPath.row == 0) {
            for (TicketCategory *category in _selectedType.ticket_category_child) {
                if ([category.ticket_category_name isEqualToString:object]) {
                    _selectedProblem = category;
                }
            }
        } else if (indexPath.row == 1) {
            for (TicketCategory *category in _selectedProblem.ticket_category_child) {
                if ([category.ticket_category_name isEqualToString:object]) {
                    _selectedDetailProblem = category;
                    NSString *string = category.ticket_category_description;
                    UIFont *font = [UIFont fontWithName:@"Helvetica" size:12];
                    UIColor *color = [UIColor blackColor];
                    NSString *description = [self htmlFromBodyString:string
                                                            textFont:font
                                                           textColor:color];
                    [self.descriptionWebView loadHTMLString:description baseURL:nil];
                    self.descriptionWebView.delegate = self;
                    self.descriptionWebView.scrollView.scrollEnabled = NO;
                    self.descriptionWebView.scrollView.bounces = NO;
                }
            }
        }
    }
    [self.tableView reloadData];
}

#pragma mark - Web view methods

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
    
    if (numComponents == 4)
    {
        unsigned int red = components[0] * 255;
        unsigned int green = components[1] * 255;
        unsigned int blue = components[2] * 255;
        colorHexString = [NSString stringWithFormat:@"%02X%02X%02X", red, green, blue];
    }
    else
    {
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