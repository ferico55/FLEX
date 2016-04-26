//
//  ImagePickerCategoryController.m
//  Tokopedia
//
//  Created by Tokopedia on 2/24/16.
//  Copyright © 2016 TOKOPEDIA. All rights reserved.
//

#import "ImagePickerCategoryController.h"
#import "SearchResultViewController.h"
#import "UIImageEffects.h"

@interface ImagePickerCategoryController () <UITableViewDataSource, UITableViewDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) IBOutlet UIView *tableHeaderView;
@property (strong, nonatomic) NSArray *categories;
@property (strong, nonatomic) NSDictionary *selectedCategory;

@end

@implementation ImagePickerCategoryController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"Hasil Pencarian";
    self.navigationItem.rightBarButtonItem = [self rightButton];
    self.navigationItem.backBarButtonItem = [self backButton];
    self.tableView.tableHeaderView = _tableHeaderView;
    self.categories = [self getCategories];
    self.tableView.allowsMultipleSelection = NO;
    
    [TPAnalytics trackScreenName:@"Snap Search Category"];
}


- (UIBarButtonItem *)backButton {
    UIBarButtonItem *backButton = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStylePlain target:nil action:nil];
    return backButton;
}

- (UIBarButtonItem *)rightButton {
    UIBarButtonItem *continueButton = [[UIBarButtonItem alloc] initWithTitle:@"Lanjutkan" style:UIBarButtonItemStyleDone target:self action:@selector(tapContinueButton:)];
    continueButton.enabled = NO;
    continueButton.tintColor = [[UIColor whiteColor] colorWithAlphaComponent:0.5];
    return continueButton;
}

-(NSArray *)getCategories{
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    TAGContainer *gtmContainer = appDelegate.container;
    
    NSString *categoryString = [gtmContainer stringForKey:@"image_search_categories"]?:@"Semua Kategori:0,Aksesoris:91,Aksesoris Rambut:1228,Baju Korea:84,Baju Muslim:86,Barang Couple:85,Batik:88,Fashion & Aksesoris Lainnya:1128,Jam Tangan:93,Kaos:87,Pakaian Anak Laki-Laki:83,Pakaian Anak Perempuan:82,Pakaian Pria:81,Pakaian Wanita:80,Sepatu:90,Perhiasan:92,Tas Pria & Wanita:89";
    
    NSArray *arrayFromGTM = [[NSMutableArray alloc] initWithArray:[categoryString componentsSeparatedByString:@","]];
    NSMutableArray *arrayCategory = [NSMutableArray new];
    for (NSString *category in arrayFromGTM) {
        NSArray *tempArray= [[NSMutableArray alloc] initWithArray:[category componentsSeparatedByString:@":"]];
        NSDictionary *categoryDictionary = @{@"title":tempArray[0],
                                             @"id":tempArray[1]
                                             };
        [arrayCategory addObject:categoryDictionary];
    }
    
    return [arrayCategory copy];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.categories.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 25;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"categories"];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"categories"];
    }
    cell.textLabel.text = self.categories[indexPath.row][@"title"];
    cell.textLabel.font = [UIFont fontWithName:@"GothamBook" size:14];
    if ([_categories[indexPath.row] isEqual:_selectedCategory]) {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    } else {
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
    return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    _selectedCategory = _categories[indexPath.row];
    [_tableView reloadData];
    
    self.navigationItem.rightBarButtonItem.enabled = YES;
    self.navigationItem.rightBarButtonItem.tintColor = [UIColor whiteColor];
}

- (void)tapContinueButton:(UIBarButtonItem *)sender {
    [TPAnalytics trackSnapSearchCategory:_selectedCategory[@"title"]];
    
    SearchResultViewController *controller = [SearchResultViewController new];
    controller.isFromAutoComplete = NO;
    controller.isFromImageSearch = YES;
    controller.title = @"Hasil Pencarian";
    controller.hidesBottomBarWhenPushed = YES;
    controller.data = @{@"type":@"search_product", @"department_id":_selectedCategory[@"id"]};
    controller.imageQueryInfo = _imageQuery;
    controller.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    [self.navigationController pushViewController:controller animated:YES];
}

@end
