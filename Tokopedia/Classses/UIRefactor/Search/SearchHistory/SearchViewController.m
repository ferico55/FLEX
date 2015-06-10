//
//  SearchViewController.m
//  Tokopedia
//
//  Created by IT Tkpd on 8/21/14.
//  Copyright (c) 2014 TOKOPEDIA. All rights reserved.
//

#import "search.h"
#import "SearchViewController.h"
#import "SearchResultViewController.h"
#import "SearchResultShopViewController.h"
#import "TKPDTabNavigationController.h"
#import "ProductFeedViewController.h"
#import "SearchAutoCompleteViewController.h"

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
>
{
    /** real time search result array **/
    NSMutableArray *_searchresultarray;
    /** variable for segment control **/
    NSString *_filter;
    /** all histories from property list **/
    NSMutableArray *_historysearch;
    
    UITextField *_activeTextField;
    
    //Notification *_notification;
    NotificationManager *_notifManager;
    SearchAutoCompleteViewController *_searchAutoCompleteController;
    
    __weak RKObjectManager *_objectManager;
    __weak RKManagedObjectRequestOperation *_objectRequest;
    NSInteger *_requestCount;
    NSOperationQueue *_operationQueue;
    
    NSMutableArray *_catalogs;
    NSMutableArray *_categories;
}

@property (weak, nonatomic) IBOutlet UITableView *table;
@property (weak, nonatomic) IBOutlet UIButton *buttonclear;
@property (weak, nonatomic) IBOutlet UISearchBar *searchbar;
@property (weak, nonatomic) IBOutlet UIView *searchhistoryview;
@property (weak, nonatomic) IBOutlet UILabel *labelsearchfor;

@property (strong, nonatomic) UIView *notificationView;
@property (strong, nonatomic) NotificationBarButton *notificationButton;
@property (strong, nonatomic) UIImageView *notificationArrowImageView;
@property (strong, nonatomic) NotificationViewController *notificationController;


@end

@implementation SearchViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:@"SearchViewController" bundle:nibBundleOrNil];
    if (self) {
        self.title = kTKPDSEARCH_TITLE;
        UIImageView *logo = [[UIImageView alloc]initWithImage:[UIImage imageNamed:kTKPDIMAGE_TITLEHOMEIMAGE]];
        [self.navigationItem setTitleView:logo];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    _operationQueue = [NSOperationQueue new];
    [self.navigationController.navigationBar setTranslucent:NO];

    if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"7.0.0")) {
        self.edgesForExtendedLayout = UIRectEdgeNone;
    }
    
    _historysearch =[NSMutableArray new];
    _searchresultarray = [NSMutableArray new];
    
    _searchbar.delegate = self;
    
    _table.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];

    _filter = @"search_product";
    
    [self loadHistory];

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(clearHistory)
                                                 name:kTKPD_REMOVE_SEARCH_HISTORY
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(goToHotlist:) name:@"redirectSearch" object:nil];
    
    UINib *cellNib = [UINib nibWithNibName:@"SearchAutoCompleteCell" bundle:nil];
    [_table registerNib:cellNib forCellReuseIdentifier:@"SearchAutoCompleteCellIdentifier"];
    
//    [_searchbar becomeFirstResponder];
}


-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    self.navigationController.title = @"Cari";
    self.screenName = @"Search Page";
    self.hidesBottomBarWhenPushed = NO;
    
    [self initNotificationManager];

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(reloadNotification)
                                                 name:@"reloadNotification"
                                               object:nil];
    
    UIBarButtonItem *backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@" "
                                                                          style:UIBarButtonItemStyleBordered
                                                                         target:self
                                                                         action:nil];
    self.navigationItem.backBarButtonItem = backBarButtonItem;
    
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [_searchbar resignFirstResponder];
}

#pragma mark - Memory Management

-(void)dealloc{
    NSLog(@"%@ : %@",[self class], NSStringFromSelector(_cmd));
    [[NSNotificationCenter defaultCenter] removeObserver:self];    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Methods
-(void)SaveHistory:(id)history{
    NSString *destPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
    destPath = [destPath stringByAppendingPathComponent:kTKPDSEARCH_SEARCHHISTORYPATHKEY];
    
    [_historysearch insertObject:history atIndex:0];
    [_historysearch writeToFile:destPath atomically:YES];
    
    [_table reloadData];
    
    if (_historysearch.count == 0) {
        _searchhistoryview.hidden = YES;
    }else {
        _searchhistoryview.hidden = NO;
    }
}

-(void)loadHistory
{
    NSString *destPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
    destPath = [destPath stringByAppendingPathComponent:kTKPDSEARCH_SEARCHHISTORYPATHKEY];
        
    // Load the Property List
    [_historysearch addObjectsFromArray:[[NSArray alloc] initWithContentsOfFile:destPath]];
    
    if (_historysearch.count == 0) {
        _searchhistoryview.hidden = YES;
    }else {
        _searchhistoryview.hidden = NO;
    }
}

-(void)clearHistory
{
    [_historysearch removeAllObjects];
    
    NSString *destPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
    destPath = [destPath stringByAppendingPathComponent:kTKPDSEARCH_SEARCHHISTORYPATHKEY];
    
    // If the file doesn't exist in the Documents Folder, copy it.
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    if (![fileManager fileExistsAtPath:destPath]) {
        NSString *sourcePath = [[NSBundle mainBundle] pathForResource:@"history_search" ofType:@"plist"];
        [fileManager copyItemAtPath:sourcePath toPath:destPath error:nil];
    }
    
    [_historysearch writeToFile:destPath atomically:YES];
    
    [_table reloadData];
    
    if (_historysearch.count == 0) {
        _searchhistoryview.hidden = YES;
    }else {
        _searchhistoryview.hidden = NO;
    }
}


#pragma mark - View Gesture
- (IBAction)tap:(id)sender {
    [_searchbar resignFirstResponder];
    [self clearHistory];
}
- (IBAction)gesture:(id)sender {
    [_searchbar resignFirstResponder];
}

#pragma mark - Table View Data Source

//-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
//    
//    if (_searchresultarray == nil || _searchresultarray.count == 0) {
//        return [_historysearch count];
//    } else {
//        return [_searchresultarray count];
//    }
//}
//
//-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
//    
//    UITableViewCell* cell = nil;
//    NSString *CellIdentifier = kTKPDSEARCH_STANDARDTABLEVIEWCELLIDENTIFIER;
//    
//    NSString *searchresult;
//    if (_searchresultarray == nil || _searchresultarray.count == 0) {
//        searchresult = [_historysearch objectAtIndex:indexPath.row];
//    } else {
//        searchresult = [_searchresultarray objectAtIndex:indexPath.row];
//    }
//    
//    if (cell == nil) {
//        
//        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
//        cell.selectionStyle = UITableViewCellSelectionStyleDefault;
//    }
//    if (_historysearch.count > indexPath.row) {
//        cell.textLabel.text = searchresult;
//        cell.textLabel.font = [UIFont fontWithName:@"GothamMedium" size:14.0f];
//    }
//	
//	return cell;
//}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 2;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    if(section == 0) {
        return @"Catalog";
    } else {
        return @"Kategori";
    }
    
    return nil;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    if(section == 0) {
        return _catalogs.count;
    } else if(section == 1) {
        return _categories.count;
    }
    
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    SearchAutoCompleteCell *cell = [tableView dequeueReusableCellWithIdentifier:@"SearchAutoCompleteCellIdentifier"];
    
    if(indexPath.section == 0) {
        SearchAutoCompleteCatalog *catalog = _catalogs[indexPath.row];
        [cell setViewModel:catalog.viewModel];
    } else if(indexPath.section == 1) {
        SearchAutoCompleteCategory *category = _categories[indexPath.row];
        [cell setViewModel:category.viewModel];
    }


    return cell;
}

#pragma mark - TableView Delegate
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    NSString *searchresult;
    if (_searchresultarray == nil || _searchresultarray.count == 0) {
        searchresult = [_historysearch objectAtIndex:indexPath.row];
    } else {
        searchresult = [_searchresultarray objectAtIndex:indexPath.row];
    }
    
    SearchResultViewController *vc = [SearchResultViewController new];
    vc.delegate = self;
    vc.data =@{kTKPDSEARCH_DATASEARCHKEY : searchresult?:@"" ,
               kTKPDSEARCH_DATATYPE:kTKPDSEARCH_DATASEARCHPRODUCTKEY,
               kTKPD_AUTHKEY:[_data objectForKey:kTKPD_AUTHKEY]?:@{}};
    SearchResultViewController *vc1 = [SearchResultViewController new];
    vc1.delegate = self;
    vc1.data =@{kTKPDSEARCH_DATASEARCHKEY : searchresult?:@"" ,
                kTKPDSEARCH_DATATYPE:kTKPDSEARCH_DATASEARCHCATALOGKEY,
                kTKPD_AUTHKEY:[_data objectForKey:kTKPD_AUTHKEY]?:@{}};
    SearchResultShopViewController *vc2 = [SearchResultShopViewController new];
    vc2.data =@{kTKPDSEARCH_DATASEARCHKEY : searchresult?:@"" ,
                kTKPDSEARCH_DATATYPE:kTKPDSEARCH_DATASEARCHSHOPKEY,
                kTKPD_AUTHKEY:[_data objectForKey:kTKPD_AUTHKEY]?:@{}};
    NSArray *viewcontrollers = @[vc,vc1,vc2];
    
    TKPDTabNavigationController *viewController = [TKPDTabNavigationController new];
    [viewController setSelectedIndex:0];
    [viewController setViewControllers:viewcontrollers];
    [viewController setNavigationTitle:searchresult];
    
    viewController.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:viewController animated:YES];
    self.hidesBottomBarWhenPushed = NO;
}

-(void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    [_searchbar resignFirstResponder];
}

#pragma mark - UISearchBar Delegate
-(void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText
{
//    [_searchresultarray removeAllObjects];
//    if (![searchBar.text isEqualToString: @""]&&![searchBar.text isEqualToString:@" "]) {
//        _labelsearchfor.hidden = NO;
//        //_labelsearchfor.text = [NSString stringWithFormat:@"Search for '%@'", searchBar.text];
//        NSPredicate *resultPredicate = [NSPredicate predicateWithFormat:@"SELF contains[c] %@", searchText];
//        NSArray *historiesresult;
//        historiesresult = [_historysearch filteredArrayUsingPredicate:resultPredicate];
//        [_searchresultarray addObjectsFromArray:historiesresult];
//        [_table reloadData];
//    }
//    else
//    {
//        [_searchresultarray removeAllObjects];
//        [_table reloadData];
//        _labelsearchfor.hidden = YES;
//    }
    
    if([searchText isEqualToString:@""]) {
        [_table setHidden:YES];
    } else {
        [self configureRestkit];
        [self doRequest];
    }

}

-(void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    NSArray *histories = _historysearch;
    NSString *searchString = [searchBar.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    if ([searchString length]) {
    
        [_searchresultarray removeAllObjects];
        [_searchbar resignFirstResponder];
        
        if (histories.count == 0 || [histories isEqualToArray: @[]]) {
            [self SaveHistory:searchBar.text];
        }
        else{
            if (![histories containsObject:searchBar.text]) {
                [self SaveHistory:searchBar.text];
            }
        }
        
        /** Goto result page **/
        SearchResultViewController *vc = [SearchResultViewController new];
        vc.delegate = self;
        vc.data =@{kTKPDSEARCH_DATASEARCHKEY : _searchbar.text?:@"" ,
                   kTKPDSEARCH_DATATYPE:kTKPDSEARCH_DATASEARCHPRODUCTKEY,
                   kTKPD_AUTHKEY:[_data objectForKey:kTKPD_AUTHKEY]?:@{}};
        SearchResultViewController *vc1 = [SearchResultViewController new];
        vc.delegate = self;
        vc1.data =@{kTKPDSEARCH_DATASEARCHKEY : _searchbar.text?:@"" ,
                    kTKPDSEARCH_DATATYPE:kTKPDSEARCH_DATASEARCHCATALOGKEY,
                    kTKPD_AUTHKEY:[_data objectForKey:kTKPD_AUTHKEY]?:@{}};
        SearchResultShopViewController *vc2 = [SearchResultShopViewController new];
        vc2.data =@{kTKPDSEARCH_DATASEARCHKEY : _searchbar.text?:@"" ,
                    kTKPDSEARCH_DATATYPE:kTKPDSEARCH_DATASEARCHSHOPKEY,
                    kTKPD_AUTHKEY:[_data objectForKey:kTKPD_AUTHKEY]?:@{}};
        NSArray *viewcontrollers = @[vc,vc1,vc2];
        
        TKPDTabNavigationController *viewController = [TKPDTabNavigationController new];
        
        [viewController setSelectedIndex:0];
        [viewController setViewControllers:viewcontrollers];
        [viewController setNavigationTitle:_searchbar.text];

        viewController.hidesBottomBarWhenPushed = YES;
        [self.navigationController pushViewController:viewController animated:YES];
    }
    else
    {
        [_searchresultarray removeAllObjects];
        [_table reloadData];
    }
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar
{
    [_searchbar setText:@""];
    [_searchbar resignFirstResponder];

}


- (BOOL)searchBarShouldEndEditing:(UISearchBar *)searchBar
{
    [searchBar setShowsCancelButton:NO animated:YES];
    [searchBar resignFirstResponder];
    [self deActivateSearchBar];
    
    return YES;
}

- (BOOL)searchBarShouldBeginEditing:(UISearchBar *)searchBar
{
    [searchBar setShowsCancelButton:YES animated:YES];
    [self activateSearchBar];

    return YES;
}

#pragma mark - properties
-(void)setData:(NSDictionary *)data
{
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
    [_searchbar resignFirstResponder];
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

- (void)reloadNotification
{
    [self initNotificationManager];
}

- (void)notificationManager:(id)notificationManager pushViewController:(id)viewController
{
    [notificationManager tapWindowBar];
    [self performSelector:@selector(pushViewController:) withObject:viewController afterDelay:0.3];
}

- (void)pushViewController:(id)viewController
{
    self.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:viewController animated:YES];
    self.hidesBottomBarWhenPushed = NO;
}

- (void)pushViewController:(id)viewController animated:(BOOL)animated
{
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
    [catalogMapping addAttributeMappingsFromArray:@[@"title", @"url", @"rating", @"image", @"catalogID"]];
    
    RKObjectMapping *categoryMapping = [RKObjectMapping mappingForClass:[SearchAutoCompleteCategory class]];
    [categoryMapping addAttributeMappingsFromArray:@[@"title", @"url", @"rating", @"categoryID"]];
    
    RKRelationshipMapping *catalogRel = [RKRelationshipMapping relationshipMappingFromKeyPath:@"catalog" toKeyPath:@"catalog" withMapping:catalogMapping];
    RKRelationshipMapping *categoryRel = [RKRelationshipMapping relationshipMappingFromKeyPath:@"category" toKeyPath:@"category" withMapping:categoryMapping];
    RKRelationshipMapping *domainsRel = [RKRelationshipMapping relationshipMappingFromKeyPath:@"domains" toKeyPath:@"domains" withMapping:domainsMapping];
    
    
    [domainsMapping addPropertyMapping:catalogRel];
    [domainsMapping addPropertyMapping:categoryRel];
    [searchMapping addPropertyMapping:domainsRel];
    
    RKResponseDescriptor *responseDescriptorStatus = [RKResponseDescriptor responseDescriptorWithMapping:searchMapping
                                                                                                  method:RKRequestMethodGET
                                                                                             pathPattern:[NSString stringWithFormat:@"search/product/%@", _searchbar.text]
                                                                                                 keyPath:@""
                                                                                             statusCodes:kTkpdIndexSetStatusCodeOK];
    
    [_objectManager addResponseDescriptor:responseDescriptorStatus];
}

- (void)doRequest {
    _objectRequest = [_objectManager appropriateObjectRequestOperationWithObject:self
                                                                          method:RKRequestMethodGET
                                                                            path:[NSString stringWithFormat:@"search/product/%@", _searchbar.text]
                                                                      parameters:nil];
    
    [_objectRequest setCompletionBlockWithSuccess:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
        NSDictionary *result = ((RKMappingResult*)mappingResult).dictionary;
        SearchAutoCompleteObject *search = [result objectForKey:@""];
        
        _catalogs = search.domains.catalog;
        _categories = search.domains.category;
        
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
        _searchbar.frame = (CGRect){.origin = {0, 0}, .size = _searchbar.frame.size};
    } completion:^(BOOL finished) {
        
    }];
}

- (void)deActivateSearchBar {
    [self.navigationController setNavigationBarHidden:NO animated:YES];
    [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationSlide];
    
    [UIView animateWithDuration:0.25f delay:0.0f options:UIViewAnimationOptionCurveLinear animations:^{
        _searchbar.frame = (CGRect){.origin = {0, 0}, .size = _searchbar.frame.size};
    } completion:^(BOOL finished) {
        
    }];
}


@end
