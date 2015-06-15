//
//  SearchViewController.m
//  Tokopedia
//
//  Created by IT Tkpd on 8/21/14.
//  Copyright (c) 2014 TOKOPEDIA. All rights reserved.
//

#import "search.h"
#import "category.h"
#import "SearchViewController.h"
#import "SearchResultViewController.h"
#import "SearchResultShopViewController.h"
#import "TKPDTabNavigationController.h"
#import "ProductFeedViewController.h"
#import "SearchAutoCompleteViewController.h"
#import "CatalogViewController.h"
#import "NotificationManager.h"

#import "SearchAutoCompleteDomains.h"
#import "SearchAutoCompleteObject.h"
#import "SearchAutoCompleteCell.h"

@interface SearchViewController ()
<
    UISearchBarDelegate,
    UISearchDisplayDelegate,
    UITableViewDelegate,
    UITableViewDataSource,
    SearchResultDelegate,
    NotificationDelegate,
    NotificationManagerDelegate
> {
    NSMutableArray *_typedHistoryResult;
    NSString *_filter;
    NSMutableArray *_historyResult;
    
    UITextField *_activeTextField;
    
    NotificationManager *_notifManager;
    SearchAutoCompleteViewController *_searchAutoCompleteController;
    
    __weak RKObjectManager *_objectManager;
    __weak RKManagedObjectRequestOperation *_objectRequest;
    NSInteger *_requestCount;
    NSOperationQueue *_operationQueue;
    
    NSMutableArray *_catalogs;
    NSMutableArray *_categories;
    NSMutableArray *_domains;
}

@property (weak, nonatomic) IBOutlet UITableView *table;
@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;

@property (strong, nonatomic) NotificationBarButton *notificationButton;
@property (strong, nonatomic) NotificationViewController *notificationController;


@end

@implementation SearchViewController

NSString *const SearchDomainHistory = @"History";
NSString *const SearchDomainCatalog = @"Katalog";
NSString *const SearchDomainCategory = @"Kategori";

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:@"SearchViewController" bundle:nibBundleOrNil];
    if (self) {
        self.title = kTKPDSEARCH_TITLE;
        UIImageView *logo = [[UIImageView alloc]initWithImage:[UIImage imageNamed:kTKPDIMAGE_TITLEHOMEIMAGE]];
        [self.navigationItem setTitleView:logo];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _operationQueue = [NSOperationQueue new];
    [self.navigationController.navigationBar setTranslucent:NO];

    if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"7.0.0")) {
        self.edgesForExtendedLayout = UIRectEdgeNone;
    }
    
    _historyResult =[NSMutableArray new];
    _typedHistoryResult = [NSMutableArray new];
    _domains = [NSMutableArray new];
    _catalogs = [NSMutableArray new];
    _categories = [NSMutableArray new];
    

    UISearchBar *searchBar = [[UISearchBar alloc] initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, 44)];
    [searchBar setPlaceholder:@"Sudah cek tokopedia belum ?"];
    [searchBar setOpaque:YES];
    [searchBar setBackgroundImage:[UIImage imageNamed:@"NavBar"]];
    [searchBar setTintColor:[UIColor whiteColor]];
    [[UITextField appearance] setTintColor:[UIColor blueColor]];
    _searchBar = searchBar;
    [self.view addSubview:_searchBar];

    _searchBar.delegate = self;
    
    _table.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    _table.tableHeaderView = [[UIView alloc] initWithFrame:CGRectZero];


    _filter = @"search_product";
    
    [self loadHistory];

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(clearHistory)
                                                 name:kTKPD_REMOVE_SEARCH_HISTORY
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(goToHotlist:) name:@"redirectSearch" object:nil];
    NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
    [nc addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [nc addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
    
    UINib *cellNib = [UINib nibWithNibName:@"SearchAutoCompleteCell" bundle:nil];
    [_table registerNib:cellNib forCellReuseIdentifier:@"SearchAutoCompleteCellIdentifier"];
}


-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self initNotificationManager];
    
    self.navigationController.title = @"Cari";
    self.screenName = @"Search Page";
    self.hidesBottomBarWhenPushed = NO;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reloadNotification) name:@"reloadNotification" object:nil];
    UIBarButtonItem *backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@" " style:UIBarButtonItemStyleBordered target:self action:nil];
    self.navigationItem.backBarButtonItem = backBarButtonItem;
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [_searchBar resignFirstResponder];
}

#pragma mark - Memory Management

-(void)dealloc{
    NSLog(@"%@ : %@",[self class], NSStringFromSelector(_cmd));
    [[NSNotificationCenter defaultCenter] removeObserver:self];    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark - Methods
-(void)saveHistory:(id)history {
    NSString *destPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
    destPath = [destPath stringByAppendingPathComponent:kTKPDSEARCH_SEARCHHISTORYPATHKEY];
    
    [_historyResult insertObject:history atIndex:0];
    [_historyResult writeToFile:destPath atomically:YES];
    
    [_table reloadData];
}

-(void)loadHistory {
    NSString *destPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
    destPath = [destPath stringByAppendingPathComponent:kTKPDSEARCH_SEARCHHISTORYPATHKEY];

    [_historyResult addObjectsFromArray:[[NSArray alloc] initWithContentsOfFile:destPath]];
}

-(void)clearHistory {
    [_historyResult removeAllObjects];
    
    NSString *destPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
    destPath = [destPath stringByAppendingPathComponent:kTKPDSEARCH_SEARCHHISTORYPATHKEY];
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if (![fileManager fileExistsAtPath:destPath]) {
        NSString *sourcePath = [[NSBundle mainBundle] pathForResource:@"history_search" ofType:@"plist"];
        [fileManager copyItemAtPath:sourcePath toPath:destPath error:nil];
    }
    
    [_historyResult writeToFile:destPath atomically:YES];
    
    [_table reloadData];
}


#pragma mark - View Gesture
- (IBAction)tap:(id)sender {
    [_searchBar resignFirstResponder];
    [self clearHistory];
}

#pragma mark - Table View Data Source
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return [_domains count];
}


- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    NSDictionary *domain = [_domains objectAtIndex:section];
    return [domain objectForKey:@"title"];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSDictionary *domain = [_domains objectAtIndex:section];
    NSArray *domainData = [domain objectForKey:@"data"];
    return [domainData count];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    SearchAutoCompleteCell *cell = [tableView dequeueReusableCellWithIdentifier:@"SearchAutoCompleteCellIdentifier"];
    NSDictionary *domain = [_domains objectAtIndex:indexPath.section];
    NSString *domainName = [domain objectForKey:@"title"];
    if([domainName isEqualToString:SearchDomainHistory]) {
        NSString *searchResult;
        if(_typedHistoryResult.count > 0) {
            searchResult = [_typedHistoryResult objectAtIndex:indexPath.row];
        } else {
            searchResult = [_historyResult objectAtIndex:indexPath.row];
        }
        NSRange range = [searchResult rangeOfString:_searchBar.text options:NSCaseInsensitiveSearch];

        NSMutableAttributedString *attributedText = [[NSMutableAttributedString alloc] initWithString:searchResult];
        [attributedText setAttributes:@{NSFontAttributeName:[UIFont boldSystemFontOfSize:13.0f]} range:range];
        cell.searchTitle.attributedText = attributedText;
        [cell.searchImage setHidden:YES];
    } else if([domainName isEqualToString:SearchDomainCatalog]) {
        SearchAutoCompleteCatalog *catalog = _catalogs[indexPath.row];
        [cell setViewModel:catalog.viewModel];
        [cell setBoldSearchText:_searchBar.text];
    } else if([domainName isEqualToString:SearchDomainCategory]) {
        SearchAutoCompleteCategory *category = _categories[indexPath.row];
        [cell setViewModel:category.viewModel];
        [cell setBoldSearchText:_searchBar.text];
    }

    return cell;
}

#pragma mark - TableView Delegate
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    NSDictionary *domain = [_domains objectAtIndex:indexPath.section];
    NSString *domainName = [domain objectForKey:@"title"];
    if([domainName isEqualToString:SearchDomainHistory]) {
        [self goToResultPage:[_typedHistoryResult objectAtIndex:indexPath.row]];
    } else if([domainName isEqualToString:SearchDomainCatalog]) {
        NSArray *catalogs = [domain objectForKey:@"data"];
        SearchAutoCompleteCatalog *catalog = [catalogs objectAtIndex:indexPath.row];

        CatalogViewController *vc = [CatalogViewController new];
        vc.catalogID = catalog.id;
        vc.catalogName = catalog.title;
        vc.hidesBottomBarWhenPushed = YES;
        
        [self.navigationController pushViewController:vc animated:YES];
    } else if([domainName isEqualToString:SearchDomainCategory]) {
        NSArray *categories = [domain objectForKey:@"data"];
        SearchAutoCompleteCategory *category = [categories objectAtIndex:indexPath.row];
        
        SearchResultViewController *vc = [SearchResultViewController new];
        vc.data =@{kTKPDSEARCH_APIDEPARTMENTIDKEY : category.id?:@"",
                   kTKPDSEARCH_APIDEPARTEMENTTITLEKEY : category.title?:@"",
                   kTKPDSEARCH_DATATYPE:kTKPDSEARCH_DATASEARCHPRODUCTKEY};
        
        SearchResultViewController *vc1 = [SearchResultViewController new];
        vc1.data =@{kTKPDSEARCH_APIDEPARTMENTIDKEY : category.id?:@"",
                    kTKPDSEARCH_APIDEPARTEMENTTITLEKEY : category.title?:@"",
                    kTKPDSEARCH_DATATYPE:kTKPDSEARCH_DATASEARCHCATALOGKEY};
        
        SearchResultShopViewController *vc2 = [SearchResultShopViewController new];
        vc2.data =@{kTKPDSEARCH_APIDEPARTMENTIDKEY : category.id?:@"",
                    kTKPDSEARCH_APIDEPARTEMENTTITLEKEY : category.title?:@"",
                    kTKPDSEARCH_DATATYPE:kTKPDSEARCH_DATASEARCHSHOPKEY};
        
        NSArray *viewcontrollers = @[vc,vc1,vc2];
        
        TKPDTabNavigationController *viewController = [TKPDTabNavigationController new];
        [viewController setData:@{kTKPDCATEGORY_DATATYPEKEY: @(kTKPDCATEGORY_DATATYPECATEGORYKEY), kTKPDSEARCH_APIDEPARTMENTIDKEY : category.id?:@"" }];
        [viewController setNavigationTitle:category.title];
        [viewController setSelectedIndex:0];
        [viewController setViewControllers:viewcontrollers];
        [viewController setNavigationTitle:category.title?:@""];
        
        viewController.hidesBottomBarWhenPushed = YES;
        [self.navigationController pushViewController:viewController animated:YES];
    }
}


#pragma mark - UISearchBar Delegate
-(void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
    [_typedHistoryResult removeAllObjects];
    
    if([searchText isEqualToString:@""]) {
        [_domains removeAllObjects];
        [_domains addObject:@{@"title" : SearchDomainHistory, @"data" : _historyResult}];
        [_table reloadData];
    } else {
        NSPredicate *resultPredicate = [NSPredicate predicateWithFormat:@"SELF contains[c] %@", searchText];
        NSArray *historiesresult;
        historiesresult = [_historyResult filteredArrayUsingPredicate:resultPredicate];
        NSInteger limit = 3;

        if(historiesresult.count > limit) {
            NSRange endRange = NSMakeRange((historiesresult.count-limit), limit);
            NSArray *lastThree= [historiesresult subarrayWithRange:endRange];
            [_typedHistoryResult addObjectsFromArray:lastThree];
        } else {
            [_typedHistoryResult addObjectsFromArray:historiesresult];
        }
        
        [self configureRestkit];
        [self doRequest];
    }

}


-(void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    NSArray *histories = _historyResult;
    NSString *searchString = [searchBar.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    if ([searchString length]) {
        [_typedHistoryResult removeAllObjects];
        [_searchBar resignFirstResponder];
        
        if (histories.count == 0 || [histories isEqualToArray: @[]]) {
            [self saveHistory:searchBar.text];
        }
        else {
            if (![histories containsObject:searchBar.text]) {
                [self saveHistory:searchBar.text];
            }
        }
        [self goToResultPage:_searchBar.text];
    }
    else {
        [_typedHistoryResult removeAllObjects];
        [_table reloadData];
    }
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar {
    [_searchBar setText:@""];
    [_searchBar resignFirstResponder];
}


- (BOOL)searchBarShouldEndEditing:(UISearchBar *)searchBar {
    [searchBar setShowsCancelButton:NO animated:YES];
    [self deActivateSearchBar];
    
    return YES;
}

- (BOOL)searchBarShouldBeginEditing:(UISearchBar *)searchBar {
    [searchBar setShowsCancelButton:YES animated:YES];
    [self activateSearchBar];

    return YES;
}

#pragma mark - properties
-(void)setData:(NSDictionary *)data {
    _data = data;
}

#pragma mark - Notification Manager

- (void)initNotificationManager {
    _notifManager = [NotificationManager new];
    [_notifManager setViewController:self];
    _notifManager.delegate = self;
    self.navigationItem.rightBarButtonItem = _notifManager.notificationButton;
}

- (void)tapNotificationBar {
    [_searchBar resignFirstResponder];
    [_notifManager tapNotificationBar];
}

- (void)tapWindowBar {
    [_notifManager tapWindowBar];
}

#pragma mark - Notification delegate
- (void)goToHotlist:(NSNotification*)notification {
    NSDictionary *userInfo = notification.userInfo;
    [self.navigationController pushViewController:[userInfo objectForKey:@"vc"] animated:YES];
}


- (void)keyboardWillShow:(NSNotification *)notification {
    NSDictionary* keyboardInfo = [notification userInfo];
    NSValue* keyboardFrameBegin = [keyboardInfo valueForKey:UIKeyboardFrameBeginUserInfoKey];
    CGRect keyboardFrameBeginRect = [keyboardFrameBegin CGRectValue];
    
    _table.contentInset = UIEdgeInsetsMake(0, 0, keyboardFrameBeginRect.size.height+25, 0);
}

- (void)keyboardWillHide:(NSNotification *)info {
    _table.contentInset = UIEdgeInsetsZero;
}


- (void)reloadNotification {
    [self initNotificationManager];
}

- (void)notificationManager:(id)notificationManager pushViewController:(id)viewController {
    [notificationManager tapWindowBar];
    [self performSelector:@selector(pushViewController:) withObject:viewController afterDelay:0.3];
}

- (void)pushViewController:(id)viewController {
    self.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:viewController animated:YES];
    self.hidesBottomBarWhenPushed = NO;
}

- (void)pushViewController:(id)viewController animated:(BOOL)animated {
    self.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:viewController animated:animated];
}

#pragma mark - Network
- (void)configureRestkit {
    NSString *urlString = [NSString stringWithFormat:@"http://ec2-52-74-246-185.ap-southeast-1.compute.amazonaws.com/"];
    _objectManager = [RKObjectManager sharedClientUploadImage:urlString];
    
    RKObjectMapping *searchMapping = [RKObjectMapping mappingForClass:[SearchAutoCompleteObject class]];;
    RKObjectMapping *domainsMapping = [RKObjectMapping mappingForClass:[SearchAutoCompleteDomains class]];
    
    RKObjectMapping *catalogMapping = [RKObjectMapping mappingForClass:[SearchAutoCompleteCatalog class]];
    [catalogMapping addAttributeMappingsFromArray:@[@"title", @"url", @"rating", @"image", @"id"]];
    
    RKObjectMapping *categoryMapping = [RKObjectMapping mappingForClass:[SearchAutoCompleteCategory class]];
    [categoryMapping addAttributeMappingsFromArray:@[@"title", @"url", @"rating", @"id"]];
    
    RKRelationshipMapping *catalogRel = [RKRelationshipMapping relationshipMappingFromKeyPath:@"catalog" toKeyPath:@"catalog" withMapping:catalogMapping];
    RKRelationshipMapping *categoryRel = [RKRelationshipMapping relationshipMappingFromKeyPath:@"category" toKeyPath:@"category" withMapping:categoryMapping];
    RKRelationshipMapping *domainsRel = [RKRelationshipMapping relationshipMappingFromKeyPath:@"domains" toKeyPath:@"domains" withMapping:domainsMapping];
    
    
    [domainsMapping addPropertyMapping:catalogRel];
    [domainsMapping addPropertyMapping:categoryRel];
    [searchMapping addPropertyMapping:domainsRel];
    
    RKResponseDescriptor *responseDescriptorStatus = [RKResponseDescriptor responseDescriptorWithMapping:searchMapping
                                                                                                  method:RKRequestMethodGET
                                                                                             pathPattern:[NSString stringWithFormat:@"search/%@", _searchBar.text]
                                                                                                 keyPath:@""
                                                                                             statusCodes:kTkpdIndexSetStatusCodeOK];
    
    [_objectManager addResponseDescriptor:responseDescriptorStatus];
}

- (void)doRequest {
    _objectRequest = [_objectManager appropriateObjectRequestOperationWithObject:self
                                                                          method:RKRequestMethodGET
                                                                            path:[NSString stringWithFormat:@"search/%@", _searchBar.text]
                                                                      parameters:nil];
    
    [_objectRequest setCompletionBlockWithSuccess:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
        NSDictionary *result = ((RKMappingResult*)mappingResult).dictionary;
        SearchAutoCompleteObject *search = [result objectForKey:@""];
        
        [_domains removeAllObjects];
        [_catalogs removeAllObjects];
        [_categories removeAllObjects];
        
        [_catalogs addObjectsFromArray:search.domains.catalog];
        [_categories addObjectsFromArray:search.domains.category];

        
        if(_typedHistoryResult.count > 0) {
            [_domains addObject:@{@"title" : SearchDomainHistory, @"data" : _typedHistoryResult}];
        }
        
        if(_catalogs.count > 0) {
            [_domains addObject:@{@"title" : SearchDomainCatalog, @"data" : _catalogs}];
        }
            
        if(_categories.count > 0) {
            [_domains addObject:@{@"title" : SearchDomainCategory, @"data" : _categories}];
        }
        
        [_table reloadData];
        [_table setHidden:NO];
    } failure:^(RKObjectRequestOperation *operation, NSError *error) {

    }];
    
    [_operationQueue addOperation:_objectRequest];
    
}


#pragma mark - SearchBar Method
- (void)activateSearchBar {
    [self.navigationController setNavigationBarHidden:YES animated:YES];
    [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationSlide];
    
    [UIView animateWithDuration:0.25f delay:0.0f options:UIViewAnimationOptionCurveLinear animations:^{
        _searchBar.frame = (CGRect){.origin = {0, 0}, .size = _searchBar.frame.size};
    } completion:^(BOOL finished) {
        
    }];
}

- (void)deActivateSearchBar {
    [self.navigationController setNavigationBarHidden:NO animated:YES];
    [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationSlide];
    
    [UIView animateWithDuration:0.25f delay:0.0f options:UIViewAnimationOptionCurveLinear animations:^{
        _searchBar.frame = (CGRect){.origin = {0, 0}, .size = _searchBar.frame.size};
    } completion:^(BOOL finished) {
        
    }];
}

#pragma mark - Method
- (void)goToResultPage:(NSString*)searchText {
    SearchResultViewController *vc = [SearchResultViewController new];
    vc.delegate = self;
    vc.data =@{kTKPDSEARCH_DATASEARCHKEY : _searchBar.text?:@"" ,
               kTKPDSEARCH_DATATYPE:kTKPDSEARCH_DATASEARCHPRODUCTKEY,
               kTKPD_AUTHKEY:[_data objectForKey:kTKPD_AUTHKEY]?:@{}};
    SearchResultViewController *vc1 = [SearchResultViewController new];
    vc.delegate = self;
    vc1.data =@{kTKPDSEARCH_DATASEARCHKEY : _searchBar.text?:@"" ,
                kTKPDSEARCH_DATATYPE:kTKPDSEARCH_DATASEARCHCATALOGKEY,
                kTKPD_AUTHKEY:[_data objectForKey:kTKPD_AUTHKEY]?:@{}};
    SearchResultShopViewController *vc2 = [SearchResultShopViewController new];
    vc2.data =@{kTKPDSEARCH_DATASEARCHKEY : _searchBar.text?:@"" ,
                kTKPDSEARCH_DATATYPE:kTKPDSEARCH_DATASEARCHSHOPKEY,
                kTKPD_AUTHKEY:[_data objectForKey:kTKPD_AUTHKEY]?:@{}};
    NSArray *viewcontrollers = @[vc,vc1,vc2];
    
    TKPDTabNavigationController *viewController = [TKPDTabNavigationController new];
    
    [viewController setSelectedIndex:0];
    [viewController setViewControllers:viewcontrollers];
    [viewController setNavigationTitle:searchText];
    
    viewController.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:viewController animated:YES];
}



@end
