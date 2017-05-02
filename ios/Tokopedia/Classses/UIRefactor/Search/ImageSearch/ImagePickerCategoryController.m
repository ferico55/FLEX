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

@end

@implementation ImagePickerCategoryController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"Hasil Pencarian";
    self.navigationItem.backBarButtonItem = [self backButton];
    self.tableView.tableHeaderView = _tableHeaderView;
    self.categories = [self getCategories];
    self.tableView.allowsMultipleSelection = NO;
    
    [AnalyticsManager trackScreenName:@"Snap Search Category"];
}


- (UIBarButtonItem *)backButton {
    UIBarButtonItem *backButton = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStylePlain target:nil action:nil];
    return backButton;
}

- (NSArray *)getCategories{
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
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    cell.textLabel.text = self.categories[indexPath.row][@"title"];
    cell.textLabel.font = [UIFont title2Theme];
    return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    NSDictionary *category = self.categories[indexPath.row];
    [AnalyticsManager trackSnapSearchCategory:category[@"title"]];
    
    SearchResultViewController *controller = [SearchResultViewController new];
    controller.isFromAutoComplete = NO;
    controller.isFromImageSearch = YES;
    controller.title = @"Hasil Pencarian";
    controller.hidesBottomBarWhenPushed = YES;
    controller.data = @{@"type": @"search_product", @"sc": category[@"id"]};
    controller.imageQueryInfo = _imageQuery;
    controller.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    [self.navigationController pushViewController:controller animated:YES];
}

@end
