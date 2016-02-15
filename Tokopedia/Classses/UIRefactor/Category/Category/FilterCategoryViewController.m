//
//  FilterCategoryViewController.m
//  Tokopedia
//
//  Created by Tokopedia on 2/10/16.
//  Copyright © 2016 TOKOPEDIA. All rights reserved.
//

#import "FilterCategoryViewController.h"
#import "CategoryResponse.h"

#define cellIdentifier @"filterCategoryCell"

@interface FilterCategoryViewController () <TokopediaNetworkManagerDelegate>

@property (strong, nonatomic) NSMutableArray *categories;
@property (strong, nonatomic) NSIndexPath *selectedIndexPath;

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
}

- (void)didTapCancelButton {
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
}

- (void)didTapDoneButton {
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
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    CategoryDetail *category = [self.categories objectAtIndex:indexPath.row];
    cell.textLabel.text = category.name;
    cell.textLabel.font = [UIFont fontWithName:@"GothamBook" size:12];
    cell.indentationLevel = [category.tree integerValue];
    if ([self.selectedIndexPath isEqual:indexPath]) {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    } else {
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(nonnull NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];

    CategoryDetail *category = [self.categories objectAtIndex:indexPath.row];
    
    NSInteger row = indexPath.row + 1;
    NSRange range = NSMakeRange(row, category.child.count);
    NSIndexSet *indexSet = [NSIndexSet indexSetWithIndexesInRange:range];
    [self.categories insertObjects:category.child atIndexes:indexSet];
    
    NSMutableArray *categories = [NSMutableArray new];
    
    NSInteger tree = [category.tree integerValue];
    NSInteger parent = [category.parent integerValue];
    NSInteger id = [category.categoryId integerValue];
    
    if (tree == 1) {
        for (CategoryDetail *category in self.categories) {
            if ([category.tree integerValue] > 1 &&
                [category.parent integerValue] != [category.categoryId integerValue]) {
                [categories addObject:category];
            }
        }
    } else if (tree == 2) {
        for (CategoryDetail *category in self.categories) {
            if ([category.tree integerValue]) {
                
            }
        }
    } else if (tree == 3) {

    }
    
    [self.categories removeObjectsInArray:categories];
    
    self.selectedIndexPath = indexPath;
    
    [self.tableView reloadData];
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

    RKObjectMapping *responseStatusMapping = [RKObjectMapping mappingForClass:[CategoryResponseStatus class]];
    [responseStatusMapping addAttributeMappingsFromArray:@[@"error_code", @"message"]];
    
    RKObjectMapping *responseDataMapping = [RKObjectMapping mappingForClass:[CategoryData class]];

    NSDictionary *categoryIdMapping = @{@"categoryId" : @"id"};
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
    
    RKRelationshipMapping *responseStatusRelationship = [RKRelationshipMapping relationshipMappingFromKeyPath:@"status" toKeyPath:@"status" withMapping:responseStatusMapping];
    [responseMapping addPropertyMapping:responseStatusRelationship];

    RKRelationshipMapping *reponseDataRelationship = [RKRelationshipMapping relationshipMappingFromKeyPath:@"data" toKeyPath:@"data" withMapping:responseDataMapping];
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
    return response.status.message;
}

- (void)actionBeforeRequest:(int)tag {
    
}

- (void)actionAfterRequest:(RKMappingResult *)mappingResult
             withOperation:(RKObjectRequestOperation *)operation withTag:(int)tag {
    CategoryResponse *response = [mappingResult.dictionary objectForKey:@""];
    self.categories = [response.data.categories mutableCopy];
    [self.tableView reloadData];
}

- (void)actionFailAfterRequest:(id)errorResult withTag:(int)tag {
    
}

- (void)actionAfterFailRequestMaxTries:(int)tag {
    
}

@end
