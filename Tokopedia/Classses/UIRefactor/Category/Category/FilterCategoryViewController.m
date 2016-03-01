//
//  FilterCategoryViewController.m
//  Tokopedia
//
//  Created by Tokopedia on 2/10/16.
//  Copyright © 2016 TOKOPEDIA. All rights reserved.
//

#import "FilterCategoryViewController.h"
#import "CategoryResponse.h"
#import "FilterCategoryViewCell.h"

#define cellIdentifier @"filterCategoryViewCell"

@interface FilterCategoryViewController () <TokopediaNetworkManagerDelegate>

@property (strong, nonatomic) NSMutableArray *categories;

@end

@implementation FilterCategoryViewController

- (id)initWithStyle:(UITableViewStyle)style {
    self = [super initWithStyle:UITableViewStyleGrouped];
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"Pilih Kategori";
    [self setCancelButton];
    [self setDoneButton];
    [self loadData];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)setCancelButton {
    UIBarButtonItem *cancelButton = [[UIBarButtonItem alloc] initWithTitle:@"Batal" style:UIBarButtonItemStyleBordered target:self action:@selector(didTapCancelButton)];
    self.navigationItem.leftBarButtonItem = cancelButton;
}


- (void)setDoneButton {
    UIBarButtonItem *doneButton = [[UIBarButtonItem alloc] initWithTitle:@"Selesai" style:UIBarButtonItemStyleDone target:self action:@selector(didTapDoneButton)];
    self.navigationItem.rightBarButtonItem = doneButton;
    [self updateDoneButtonAppearance];
}

- (void)updateDoneButtonAppearance {
    UIBarButtonItem *doneButton = self.navigationItem.rightBarButtonItem;
    if (!self.allowAnyCategorySelected) {
        if (self.selectedCategory.hasChildCategories || self.selectedCategory == nil) {
            doneButton.enabled = NO;
            doneButton.tintColor = [[UIColor whiteColor] colorWithAlphaComponent:0.5];
        } else {
            doneButton.enabled = YES;
            doneButton.tintColor = [UIColor whiteColor];
        }
    }
}

- (void)didTapCancelButton {
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
}

- (void)didTapDoneButton {
    if ([self.delegate respondsToSelector:@selector(didSelectCategory:)]) {
        [self.delegate didSelectCategory:self.selectedCategory];
    }
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
}

- (void)loadData {
    TokopediaNetworkManager *networkManager = [TokopediaNetworkManager new];
    networkManager.delegate = self;
    [networkManager doRequest];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.categories.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    FilterCategoryViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
    if (cell == nil) {
        cell = [[FilterCategoryViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    
    CategoryDetail *category = [self.categories objectAtIndex:indexPath.row];
    cell.categoryNameLabel.text = category.name;
    
    NSInteger level = [category.tree integerValue];
    cell.leftPaddingConstraint.constant = level * 18; // 18 -> left padding
    
    if (self.allowAnyCategorySelected) {
        if ([category isEqual:_selectedCategory]) {
            [cell showCheckmark];
        } else {
            [cell hideCheckmark];
        }
    } else {
        // Selected category is last category
        if (!category.hasChildCategories && [category isEqual:_selectedCategory]) {
            [cell showCheckmark];
        } else {
            [cell hideCheckmark];
        }
    }
    
    if (category.child.count > 0) {
        [cell showArrow];
        ArrowDirection direction = category.isExpanded ? ArrowDirectionUp : ArrowDirectionDown;
        [cell setArrowDirection:direction];
    } else {
        [cell hideArrow];
    }
    
    return cell;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    if (self.categories.count > 0) {
        return nil;
    }
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 44)];
    UIActivityIndicatorView *indicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    indicatorView.center = view.center;
    [indicatorView startAnimating];
    [view addSubview:indicatorView];
    return view;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(nonnull NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    CategoryDetail *category = [self.categories objectAtIndex:indexPath.row];
    if (self.allowAnyCategorySelected) {
        if ([category isEqual:_selectedCategory]) {
            [self deselectCategory:category];
        } else {
            [self selectCategory:category];
        }
        self.selectedCategory = category;
    } else {
        if (category.isExpanded) {
            [self deselectCategory:category];
        } else {
            [self selectCategory:category];
        }
        self.selectedCategory = category;
        [self updateDoneButtonAppearance];
    }
    [tableView reloadData];
}

- (void)selectCategory:(CategoryDetail *)category {
    category.isExpanded = YES;
    
    NSInteger index = [self.categories indexOfObject:category];
    NSRange range = NSMakeRange(index + 1, category.child.count);
    NSIndexSet *indexSet = [NSIndexSet indexSetWithIndexesInRange:range];
    [self.categories insertObjects:category.child atIndexes:indexSet];
    
    NSInteger selectedTree = [category.tree integerValue];
    NSInteger selectedParent = [category.parent integerValue];
    NSInteger selectedId = [category.categoryId integerValue];
    
    NSMutableArray *categories = [NSMutableArray new];
    for (CategoryDetail *category in self.categories) {
        if (selectedTree == 1) {
            if ([category.tree integerValue] == 2 && [category.parent integerValue] != selectedId) {
                [categories addObject:category];
            } else if ([category.tree integerValue] == 3) {
                [categories addObject:category];
            }
        } else if (selectedTree == 2) {
            if ([category.tree integerValue] == 2 && [category.parent integerValue] != selectedParent) {
                [categories addObject:category];
            } else if ([category.tree integerValue] == 3 && [category.parent integerValue] != selectedId) {
                [categories addObject:category];
            }
        }
    }
    [self.categories removeObjectsInArray:categories];
}

- (void)deselectCategory:(CategoryDetail *)category {
    category.isExpanded = NO;
    [self.categories removeObjectsInArray:category.child];
}

#pragma mark - Tokopedia network

- (NSString *)getPath:(int)tag {
    return @"v0/categories";
}

- (NSDictionary *)getParameter:(int)tag {
    return @{};
}

- (int)getRequestMethod:(int)tag {
    return RKRequestMethodGET;
}

- (id)getObjectManager:(int)tag {
    RKObjectManager *objectManager = [RKObjectManager sharedClient:@"https://hades-staging.tokopedia.com/"];
    
    RKObjectMapping *responseMapping = [RKObjectMapping mappingForClass:[CategoryResponse class]];
    [responseMapping addAttributeMappingsFromArray:@[@"status"]];
    
    RKObjectMapping *responseDataMapping = [RKObjectMapping mappingForClass:[CategoryData class]];

    NSDictionary *categoryIdMapping = @{@"id" : @"categoryId"};
    NSArray *categoryAttributeMappings = @[@"name", @"weight", @"parent", @"tree", @"has_catalog", @"identifer", @"url"];
    
    RKObjectMapping *categoryMapping = [RKObjectMapping mappingForClass:[CategoryDetail class]];
    [categoryMapping addAttributeMappingsFromDictionary:categoryIdMapping];
    [categoryMapping addAttributeMappingsFromArray:categoryAttributeMappings];
    
    RKObjectMapping *categoryChildMapping = [RKObjectMapping mappingForClass:[CategoryDetail class]];
    [categoryChildMapping addAttributeMappingsFromDictionary:categoryIdMapping];
    [categoryChildMapping addAttributeMappingsFromArray:categoryAttributeMappings];
    
    RKObjectMapping *categoryLastChildMapping = [RKObjectMapping mappingForClass:[CategoryDetail class]];
    [categoryLastChildMapping addAttributeMappingsFromDictionary:categoryIdMapping];
    [categoryLastChildMapping addAttributeMappingsFromArray:categoryAttributeMappings];

    RKRelationshipMapping *reponseDataRelationship = [RKRelationshipMapping relationshipMappingFromKeyPath:@"result" toKeyPath:@"result" withMapping:responseDataMapping];
    [responseMapping addPropertyMapping:reponseDataRelationship];

    RKRelationshipMapping *categoryRelationship = [RKRelationshipMapping relationshipMappingFromKeyPath:@"categories" toKeyPath:@"categories" withMapping:categoryMapping];
    [responseDataMapping addPropertyMapping:categoryRelationship];

    RKRelationshipMapping *categoryChildRelationship = [RKRelationshipMapping relationshipMappingFromKeyPath:@"child" toKeyPath:@"child" withMapping:categoryMapping];
    [categoryMapping addPropertyMapping:categoryChildRelationship];

    RKRelationshipMapping *categoryLastChildRelationship = [RKRelationshipMapping relationshipMappingFromKeyPath:@"child" toKeyPath:@"child" withMapping:categoryMapping];
    [categoryChildMapping addPropertyMapping:categoryLastChildRelationship];
    
    NSString *path = [self getPath:0];
    NSInteger method = [self getRequestMethod:0];
    
    RKResponseDescriptor *responseDescriptor = [RKResponseDescriptor responseDescriptorWithMapping:responseMapping method:method pathPattern:path keyPath:@"" statusCodes:kTkpdIndexSetStatusCodeOK];
    [objectManager addResponseDescriptor:responseDescriptor];
    
    return objectManager;
}

- (NSString *)getRequestStatus:(RKMappingResult *)mappingResult withTag:(int)tag {
    CategoryResponse *response = [mappingResult.dictionary objectForKey:@""];
    return response.status;
}

- (void)actionBeforeRequest:(int)tag {
    
}

- (void)actionAfterRequest:(RKMappingResult *)mappingResult
             withOperation:(RKObjectRequestOperation *)operation withTag:(int)tag {
    CategoryResponse *response = [mappingResult.dictionary objectForKey:@""];
    NSMutableArray *parentCategories = [response.result.categories mutableCopy];
    NSMutableArray *categories = [NSMutableArray arrayWithArray:parentCategories];
    for (CategoryDetail *category in parentCategories) {
        for (CategoryDetail *childCategory in category.child) {
            for (CategoryDetail *lastCategory in childCategory.child) {
                if ([self.selectedCategory isEqual:lastCategory]) {
                    category.isExpanded = YES;
                    childCategory.isExpanded = YES;
                    NSInteger location = [parentCategories indexOfObject:category] + 1;
                    NSIndexSet *indexSet = [NSIndexSet indexSetWithIndexesInRange:NSMakeRange(location, category.child.count)];
                    [categories insertObjects:category.child atIndexes:indexSet];
                    location = [categories indexOfObject:childCategory] + 1;
                    indexSet = [NSIndexSet indexSetWithIndexesInRange:NSMakeRange(location, childCategory.child.count)];
                    [categories insertObjects:childCategory.child atIndexes:indexSet];
                }
            }
        }
    }
    self.categories = categories;
    [self.tableView reloadData];
}

- (void)actionFailAfterRequest:(id)errorResult withTag:(int)tag {
    
}

- (void)actionAfterFailRequestMaxTries:(int)tag {
    
}

@end
