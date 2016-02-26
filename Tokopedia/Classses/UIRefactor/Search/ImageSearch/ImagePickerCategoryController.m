//
//  ImagePickerCategoryController.m
//  Tokopedia
//
//  Created by Tokopedia on 2/24/16.
//  Copyright © 2016 TOKOPEDIA. All rights reserved.
//

#import "ImagePickerCategoryController.h"
#import "SearchResultViewController.h"
#import "UIImage+ImageEffects.h"

@interface ImagePickerCategoryController () <UITableViewDataSource, UITableViewDelegate>

@property (weak, nonatomic) IBOutlet UIImageView *backgroundImageView;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UIButton *searchButton;
@property (strong, nonatomic) NSArray *categories;

@end

@implementation ImagePickerCategoryController{
    NSDictionary *_selectedCategory;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setBlurBackground];
    
    [self setSearchButtonStyle];
    
    self.categories = [self getCategories];
    self.tableView.allowsMultipleSelection = NO;
}

-(NSArray *)getCategories{
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    TAGContainer *gtmContainer = appDelegate.container;
    
    NSString *categoryString = [gtmContainer stringForKey:@"image_search_categories"]?:@"Aksesoris:91,Aksesoris Rambut:1228,Baju Korea:84,Baju Muslim:86,Barang Couple:85,Batik:88,Fashion & Aksesoris Lainnya:1128,Jam Tangan:93,Kaos:87,Pakaian Anak Laki-Laki:83,Pakaian Anak Perempuan:82,Pakaian Pria:81,Pakaian Wanita:80,Sepatu:90,Perhiasan:92,Tas Pria & Wanita:89";
    
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

- (void)setBlurBackground {
    UIImage *image = [_imageQuery objectForKey:UIImagePickerControllerEditedImage];
    self.backgroundImageView.image = [image applyLightEffect];
}

- (void)setSearchButtonStyle {
    self.searchButton.backgroundColor = [[UIColor whiteColor] colorWithAlphaComponent:0.1];
    self.searchButton.layer.cornerRadius = 3;
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.categories.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"categories"];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"categories"];
    }
    cell.textLabel.text = self.categories[indexPath.row][@"title"];
    cell.textLabel.textColor = [UIColor whiteColor];
    cell.textLabel.font = [UIFont fontWithName:@"GothamBook" size:14];
    cell.backgroundColor = [[UIColor whiteColor] colorWithAlphaComponent:0.1];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.separatorInset = UIEdgeInsetsZero;
    cell.tintColor = [UIColor whiteColor];
    
    if ([_categories[indexPath.row] isEqual:_selectedCategory]) {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    } else {
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
    
    return cell;
}

#pragma mark - Table view delegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath   *)indexPath
{
    _selectedCategory = _categories[indexPath.row];
    [_tableView reloadData];
}

//- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
//    [tableView deselectRowAtIndexPath:indexPath animated:YES];
//    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
//    if (cell.accessoryType == UITableViewCellAccessoryNone) {
//        cell.accessoryType = UITableViewCellAccessoryCheckmark;
//        _selectedCategory = _categories[indexPath.row];
//    } else {
//        cell.accessoryType = UITableViewCellAccessoryNone;
//    }
//}

- (IBAction)didTapSearchButton:(UIButton *)sender {
    SearchResultViewController *controller = [SearchResultViewController new];
    controller.isFromAutoComplete = NO;
    controller.isFromImageSearch = YES;
    controller.title = @"Image Search";
    controller.hidesBottomBarWhenPushed = YES;
    controller.data = @{@"type":@"search_product",
                        @"department_id":_selectedCategory[@"id"]};
    controller.imageQueryInfo = _imageQuery;
    controller.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;

    UINavigationController *navigation = [[UINavigationController alloc] initWithRootViewController:controller];
    navigation.navigationBar.translucent = NO;
    
    [self presentViewController:navigation animated:YES completion:nil];
    
    [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationNone];
}

- (IBAction)tapCancelButton:(UIButton *)sender {
    [self dismissViewControllerAnimated:YES completion:NULL];
}

@end
