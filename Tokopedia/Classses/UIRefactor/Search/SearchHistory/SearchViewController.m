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
#import "HotlistResultViewController.h"

#import "SearchAutoCompleteDomains.h"
#import "SearchAutoCompleteObject.h"
#import "SearchAutoCompleteCell.h"
#import "SearchAutoCompleteHeaderView.h"
#import "UIView+HVDLayout.h"

#import "Localytics.h"

#import "ImagePickerCategoryController.h"

#import "Tokopedia-Swift.h"

NSString *const searchPath = @"/search/%@";

@interface SearchViewController ()
<
UISearchBarDelegate,
UISearchDisplayDelegate,
UICollectionViewDataSource,
UICollectionViewDelegate,
UIImagePickerControllerDelegate,
UINavigationControllerDelegate,
SearchResultDelegate,
NotificationDelegate,
NotificationManagerDelegate
>
{
    
    NSString *_filter;
    UITextField *_activeTextField;
    
    NotificationManager *_notifManager;
    SearchAutoCompleteViewController *_searchAutoCompleteController;
    
    NSMutableArray *_domains;
    NSMutableArray *_general;
    NSMutableArray *_hotlist;
    NSMutableArray *_historyResult;
    NSMutableArray *_typedHistoryResult;
    NSURL *_deeplinkUrl;
    
    NSMutableArray *_searchSuggestionDataArray;
    
    UITapGestureRecognizer *imageSearchGestureRecognizer;
    
    TokopediaNetworkManager* _requestManager;
}

@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;

@property (strong, nonatomic) NotificationBarButton *notificationButton;
@property (strong, nonatomic) NotificationViewController *notificationController;
@property (strong, nonatomic) IBOutlet UIView *iconCamera;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *searchBarTrailingConstraint;
@property (strong, nonatomic) IBOutlet UIImageView *cameraImageView;
@property (strong, nonatomic) UserAuthentificationManager *authManager;


@end

@implementation SearchViewController

NSString *const SearchDomainHistory = @"History";
NSString *const SearchDomainGeneral = @"Keyword";
NSString *const SearchDomainHotlist = @"Hotlist";
NSString *const SEARCH_AUTOCOMPLETE = @"autocomplete";
NSString *const RECENT_SEARCH = @"recent_search";

#pragma mark - Lifecycle
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
    
    [self.navigationController.navigationBar setTranslucent:NO];
    
    _historyResult =[NSMutableArray new];
    _typedHistoryResult = [NSMutableArray new];
    _domains = [NSMutableArray new];
    
    _general = [NSMutableArray new];
    _hotlist = [NSMutableArray new];
    
    [_searchBar setPlaceholder:@"Cari produk, katalog dan toko"];
    [self.view addSubview:_searchBar];
    
    _searchBar.delegate = self;
    _searchBar.showsCancelButton = NO;
    
    [self generateSearchBarAccessoryView];
    
    [_searchBar setImage:[UIImage imageNamed:@"camera-grey.png"] forSearchBarIcon:UISearchBarIconBookmark state:UIControlStateNormal];
    
    imageSearchGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(takePhoto:)];
    [_iconCamera addGestureRecognizer:imageSearchGestureRecognizer];
    
    _filter = @"search_product";
    
    NSNotificationCenter *notification = [NSNotificationCenter defaultCenter];
    [notification addObserver:self selector:@selector(clearAllHistory) name:kTKPD_REMOVE_SEARCH_HISTORY object:nil];
    [notification addObserver:self selector:@selector(goToHotlist:) name:@"redirectSearch" object:nil];
    [notification addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [notification addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
    
    UINib *cellNib = [UINib nibWithNibName:@"SearchAutoCompleteCell" bundle:nil];
    [_collectionView registerNib:cellNib forCellWithReuseIdentifier:@"SearchAutoCompleteCellIdentifier"];
    
    [self.collectionView registerClass:[SearchAutoCompleteHeaderView class] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"SearchAutoCompleteCellHeaderViewIdentifier"];
    
    [_domains removeAllObjects];
    [_domains addObject:@{@"title" : SearchDomainHistory, @"data" : _historyResult}];

    _authManager = [UserAuthentificationManager new];
    _requestManager = [TokopediaNetworkManager new];
}

-(BOOL)isEnableImageSearch{
    if (!_authManager.isLogin) {
        return NO;
    }
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    TAGContainer *gtmContainer = appDelegate.container;
    
    NSString *enableImageSearchString = [gtmContainer stringForKey:@"enable_image_search"]?:@"0";
    
    return [enableImageSearchString isEqualToString:@"1"];
}

- (UITextField*)searchSubviewsForTextFieldIn:(UIView*)view
{
    if ([view isKindOfClass:[UITextField class]]) {
        return (UITextField*)view;
    }
    UITextField *searchedTextField;
    for (UIView *subview in view.subviews) {
        searchedTextField = [self searchSubviewsForTextFieldIn:subview];
        if (searchedTextField) {
            break;
        }
    }
    return searchedTextField;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self getUserSearchSuggestionDataWithQuery:@""];
    [self initNotificationManager];
    
    [self.searchBar becomeFirstResponder];
    [self.searchBar setText:nil];
    [self searchBar:_searchBar textDidChange:@""];
    [self.searchBar setShowsBookmarkButton:NO];
    
    if([self isEnableImageSearch]) {
        _searchBarTrailingConstraint.constant = 44;
    } else {
        _searchBarTrailingConstraint.constant = 0;
    }
    
    [TPAnalytics trackScreenName:@"Search Page"];
    self.screenName = @"Search Page";
    
    self.hidesBottomBarWhenPushed = NO;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reloadNotification) name:@"reloadNotification" object:nil];
    UIBarButtonItem *backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@" " style:UIBarButtonItemStyleBordered target:self action:nil];
    self.navigationItem.backBarButtonItem = backBarButtonItem;
    
    [Localytics triggerInAppMessage:@"Search Product"];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [_searchBar resignFirstResponder];
}

#pragma mark - Memory Management
- (void)dealloc{
    NSLog(@"%@ : %@",[self class], NSStringFromSelector(_cmd));
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark - Methods
-(void)saveHistory:(NSString*)history {
    NSString *destPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
    destPath = [destPath stringByAppendingPathComponent:kTKPDSEARCH_SEARCHHISTORYPATHKEY];
    
    if(![_historyResult containsObject:[history lowercaseString]]) {
        [_historyResult insertObject:[history lowercaseString] atIndex:0];
        [_historyResult writeToFile:destPath atomically:YES];
        
        [_collectionView reloadData];
    }
    
}

//-(void)loadHistory {
//    NSString *destPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
//    destPath = [destPath stringByAppendingPathComponent:kTKPDSEARCH_SEARCHHISTORYPATHKEY];
//    
//    [_historyResult addObjectsFromArray:[[NSArray alloc] initWithContentsOfFile:destPath]];
//    [_typedHistoryResult addObjectsFromArray:_historyResult];
//}

-(void) clearHistory:(UIButton *) button {
    CGPoint buttonPoint = [button convertPoint:CGPointZero toView:_collectionView];
    
    NSIndexPath *buttonIndexPath = [_collectionView indexPathForItemAtPoint:buttonPoint];
    
    
    SearchAutoCompleteCell *searchAutoCompleteCell = (SearchAutoCompleteCell *)[_collectionView cellForItemAtIndexPath:buttonIndexPath];
    
    [_requestManager requestWithBaseUrl:[NSString aceUrl] path:@"/recent_search/v1?" method:RKRequestMethodDELETE parameter:@{@"unique_id": [self getUniqueId], @"q": searchAutoCompleteCell.searchTitle.text} mapping:[SearchSuggestionItem mapping] onSuccess:^(RKMappingResult *successResult, RKObjectRequestOperation *operation) {
        
            for (SearchSuggestionData *searchSuggestionData in _searchSuggestionDataArray) {
                if ([searchSuggestionData.id isEqual: RECENT_SEARCH]){
                    NSMutableArray *searchSuggestionItems = [NSMutableArray  arrayWithArray:searchSuggestionData.items];
                    [searchSuggestionItems removeObjectAtIndex:buttonIndexPath.item];
                    searchSuggestionData.items = searchSuggestionItems ;
                    break; 
                }
            }
            [_collectionView reloadData];
        
    } onFailure:^(NSError *errorResult) {
        StickyAlertView *stickyAlert = [[StickyAlertView alloc] initWithErrorMessages:@[errorResult.localizedDescription] delegate:self];
        [stickyAlert show];
    }];
}

-(void)clearAllHistory {
    
    [_requestManager requestWithBaseUrl:[NSString aceUrl] path:@"/recent_search/v1?" method:RKRequestMethodDELETE parameter:@{@"clear_all":@"true", @"unique_id": [self getUniqueId]} mapping:[SearchSuggestionItem mapping] onSuccess:^(RKMappingResult *successResult, RKObjectRequestOperation *operation) {
        dispatch_async(dispatch_get_main_queue(), ^{
            for (SearchSuggestionData *searchSuggestionData in _searchSuggestionDataArray) {
                if ([searchSuggestionData.id isEqual: RECENT_SEARCH]){
                    [_searchSuggestionDataArray removeObject:searchSuggestionData];
                    [_collectionView reloadData];
                    break;
                }
            }
        });
    } onFailure:^(NSError *errorResult) {
        StickyAlertView *stickyAlert = [[StickyAlertView alloc] initWithErrorMessages:@[errorResult.localizedDescription] delegate:self];
        [stickyAlert show];
    }];
//    [_historyResult removeAllObjects];
//    [_typedHistoryResult removeAllObjects];
//    
//    NSString *destPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
//    destPath = [destPath stringByAppendingPathComponent:kTKPDSEARCH_SEARCHHISTORYPATHKEY];
    
//    NSFileManager *fileManager = [NSFileManager defaultManager];
//    if (![fileManager fileExistsAtPath:destPath]) {
//        NSString *sourcePath = [[NSBundle mainBundle] pathForResource:@"history_search" ofType:@"plist"];
//        [fileManager copyItemAtPath:sourcePath toPath:destPath error:nil];
//    }
    
//    [_historyResult writeToFile:destPath atomically:YES];
    
    [_collectionView reloadData];
}

-(NSString*) getUniqueId {
    NSString *userId = [_authManager getUserId];
    
    if (userId == nil) {
        userId = [_authManager getMyDeviceIdToken];
    }
    
    return userId;
}

#pragma mark - API

-(void) getUserSearchSuggestionDataWithQuery: (NSString*) query {
    NSString *uniqueId = [self getUniqueId];
    
    //__weak typeof(self) weakSelf = self;
    _requestManager.isUsingHmac = YES;
    [_requestManager requestWithBaseUrl:[NSString aceUrl] path:@"/universe/v1" method:RKRequestMethodGET parameter:@{@"unique_id": uniqueId, @"q" : query} mapping:[GetSearchSuggestionGeneralResponse mapping] onSuccess:^(RKMappingResult *successResult, RKObjectRequestOperation *operation) {
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            NSDictionary *result = [successResult dictionary];
            _searchSuggestionDataArray = [[NSMutableArray alloc] init];
            GetSearchSuggestionGeneralResponse *searchResponse = (GetSearchSuggestionGeneralResponse*)[result objectForKey:@""];
            
            NSMutableArray *searchSuggestionDatas = [NSMutableArray arrayWithArray: searchResponse.data];
            for (SearchSuggestionData* data in searchSuggestionDatas) {
                if (data.items.count > 0) {
                    [_searchSuggestionDataArray addObject:data];
                }
            }
            
            [_collectionView reloadData];
        });

    } onFailure:^(NSError *errorResult) {
        StickyAlertView *alertView = [[StickyAlertView alloc] initWithErrorMessages:@[errorResult.localizedDescription] delegate:self];
        [alertView show];
    }];
}

#pragma mark - Collection Delegate
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
   // return [_domains count];
    return [_searchSuggestionDataArray count];
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
//    NSDictionary *domain = [_domains objectAtIndex:section];
//    NSArray *domainData = [domain objectForKey:@"data"];
//    return [domainData count];
    SearchSuggestionData *searchSuggestionData = [_searchSuggestionDataArray objectAtIndex:section];
    return searchSuggestionData.items.count;
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath {
    UICollectionReusableView *view = nil;
    
    if ([kind isEqualToString:UICollectionElementKindSectionHeader]) {
        SearchAutoCompleteHeaderView *header = [collectionView dequeueReusableSupplementaryViewOfKind:kind withReuseIdentifier:@"SearchAutoCompleteCellHeaderViewIdentifier" forIndexPath:indexPath];
        
        SearchSuggestionData *searchSuggestionData = [_searchSuggestionDataArray objectAtIndex:indexPath.section];
        
        header.titleLabel.text = searchSuggestionData.name;
        
        if ([header.titleLabel.text isEqual: [[RECENT_SEARCH uppercaseString] stringByReplacingOccurrencesOfString:@"_" withString:@" "]] ) {
            [header.deleteButton setTitle:@"Clear All" forState:UIControlStateNormal];
            [header.deleteButton addTarget:self action:@selector(clearAllHistory) forControlEvents:UIControlEventTouchUpInside];
        } else {
            [header.deleteButton setTitle:@"" forState:UIControlStateNormal];
        }
        
        
        view = header;
        
//        SearchAutoCompleteHeaderView *header = [collectionView dequeueReusableSupplementaryViewOfKind:kind withReuseIdentifier:@"SearchAutoCompleteCellHeaderViewIdentifier" forIndexPath:indexPath];
//        NSDictionary *domain = [_domains objectAtIndex:[indexPath section]];
//        
//        [header.titleLabel setText:[[domain objectForKey:@"title"] uppercaseString]];
//        if([[domain objectForKey:@"title"] isEqualToString:SearchDomainHistory]) {
//            if(_historyResult.count > 0 || _typedHistoryResult.count > 0) {
//                [header.deleteButton setTitle:@"Hapus" forState:UIControlStateNormal];
//                [header.deleteButton addTarget:self action:@selector(clearAllHistory) forControlEvents:UIControlEventTouchUpInside];
//            } else {
//                [header.titleLabel setText:@""];
//                [header.deleteButton setTitle:@"" forState:UIControlStateNormal];
//            }
//        } else {
//            [header.deleteButton setTitle:@"" forState:UIControlStateNormal];
//        }
//        view = header;
    }
    
    return view;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    UICollectionViewCell *cell = nil;
    
    SearchAutoCompleteCell *searchCell = [collectionView dequeueReusableCellWithReuseIdentifier:@"SearchAutoCompleteCellIdentifier" forIndexPath:indexPath];
    
    SearchSuggestionData *searchSuggestionData = [_searchSuggestionDataArray objectAtIndex:indexPath.section];
    
    SearchSuggestionItem *searchSuggestionItem = [searchSuggestionData.items objectAtIndex:indexPath.item];
    searchCell.searchTitle.text = searchSuggestionItem.keyword;
    
    searchCell.closeButton.hidden = YES;
    searchCell.searchLoopImageView.hidden = YES;
    [searchCell addConstraint: searchCell.searchTitleLeadingToSuperViewConstraint];
    if([searchSuggestionData.id isEqual: RECENT_SEARCH]) {
        searchCell.closeButton.hidden = NO;
        [searchCell.closeButton addTarget:self action:@selector(clearHistory:) forControlEvents:UIControlEventTouchUpInside];
    } else if ([searchSuggestionData.id isEqual: SEARCH_AUTOCOMPLETE]){
        searchCell.searchLoopImageView.hidden = NO;
        [searchCell removeConstraint: searchCell.searchTitleLeadingToSuperViewConstraint];
    }
    
    [searchCell setGreenSearchText:_searchBar.text];
//    NSDictionary *domain = [_domains objectAtIndex:indexPath.section];
//    NSString *domainName = [domain objectForKey:@"title"];
//    if([domainName isEqualToString:SearchDomainHistory]) {
//        NSString *searchResult;
//        if(_typedHistoryResult.count > 0) {
//            searchResult = [_typedHistoryResult objectAtIndex:indexPath.row];
//        } else {
//            searchResult = [_historyResult objectAtIndex:indexPath.row];
//        }
//        NSRange range = [searchResult rangeOfString:_searchBar.text options:NSCaseInsensitiveSearch];
//        
//        NSMutableAttributedString *attributedText = [[NSMutableAttributedString alloc] initWithString:searchResult];
//        [attributedText setAttributes:@{NSFontAttributeName:[UIFont boldSystemFontOfSize:13.0f]} range:range];
//        searchCell.searchTitle.attributedText = attributedText;
//        [searchCell.searchImage setHidden:YES];
//        [searchCell setBackgroundColor:[UIColor colorWithWhite:0.9 alpha:1.0]];
//    } else if([domainName isEqualToString:SearchDomainGeneral]) {
//        SearchAutoCompleteGeneral *general = _general[indexPath.row];
//        [searchCell setViewModel:general.viewModel];
//        [searchCell setBoldSearchText:_searchBar.text];
//    } else if([domainName isEqualToString:SearchDomainHotlist]) {
//        SearchAutoCompleteHotlist *hotlist = _hotlist[indexPath.row];
//        [searchCell setViewModel:hotlist.viewModel];
//        [searchCell setBoldSearchText:_searchBar.text];
//    }
    

    
    cell = searchCell;
    cell.hidden = NO;
    
    return cell;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    CGSize size = CGSizeZero;
    CGFloat maxWidth = collectionView.bounds.size.width;
    
    size = CGSizeMake(maxWidth, 44.0);
    
    return size;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout referenceSizeForHeaderInSection:(NSInteger)section {
    CGSize size = CGSizeZero;
    
//    NSDictionary *domain = [_domains objectAtIndex:section];
//    if(![[domain objectForKey:@"title"] isEqualToString:SearchDomainGeneral]) {
//        size = CGSizeMake(collectionView.bounds.size.width, 25);
//    }
    SearchSuggestionData *searchSuggestionData = [_searchSuggestionDataArray objectAtIndex:section];
    if (![searchSuggestionData.id isEqual: @"autocomplete"]) {
        size = CGSizeMake(collectionView.bounds.size.width, 45);
    }
    return size;
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section {
    return 1.0;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    UICollectionViewCell  *cell = [collectionView cellForItemAtIndexPath:indexPath];
    [UIView animateWithDuration:0.10 delay:0 options:(UIViewAnimationOptionCurveEaseInOut)
                     animations:^{
                         [cell setBackgroundColor: collectionView.backgroundColor];
                     }
                     completion:^(BOOL finished){
                         SearchSuggestionData *searchSuggestionData = [_searchSuggestionDataArray objectAtIndex:indexPath.section];
                         
                         SearchSuggestionItem *searchSuggestionItem = [searchSuggestionData.items objectAtIndex:indexPath.item];
                         
                         if ([searchSuggestionData.id  isEqual: @"hotlist"]){
                             NSArray *keys = [searchSuggestionItem.url componentsSeparatedByString:@"/"];
                             
                             HotlistResultViewController *controller = [HotlistResultViewController new];
                             NSString *hotListUrl = [keys lastObject]; // hotListValue example: iphone-5s?source=jahe . But we only need 'iphone-5s' value, so we need to cut ?source=jahe
                             
                             NSString *hotListName = [[hotListUrl componentsSeparatedByString:@"?"] objectAtIndex: 0];
                             controller.data = @{@"title" : searchSuggestionItem.keyword, @"key" : hotListName};
                             controller.isFromAutoComplete = YES;
                             controller.hidesBottomBarWhenPushed = YES;
                             [TPAnalytics trackSearchWithAction:@"Search Hotlist" keyword:searchSuggestionItem.keyword];
                             
                             [self.navigationController pushViewController:controller animated:YES];
                         } else {
                             [self goToResultPage:searchSuggestionItem.keyword withAutoComplete:YES];
                         }
                         
//                         [cell setBackgroundColor:[UIColor colorWithRed:(231.0/255) green:(231.0/255) blue:(231.0/255) alpha:1.0]];
                         
//                         NSDictionary *domain = [_domains objectAtIndex:indexPath.section];
//                         NSString *domainName = [domain objectForKey:@"title"];
//                         if([domainName isEqualToString:SearchDomainHistory]) {
//                             if (_searchBar.text.length > 0) {
//                                 NSString *searchText = [_typedHistoryResult objectAtIndex:indexPath.row];
//                                 [self goToResultPage:searchText withAutoComplete:YES];
//                                 [TPAnalytics trackSearchWithAction:@"Search History" keyword:searchText];
//                             } else {
//                                 NSString *searchText = [_historyResult objectAtIndex:indexPath.row];
//                                 [self goToResultPage:searchText withAutoComplete:YES];
//                                 [TPAnalytics trackSearchWithAction:@"Search History" keyword:searchText];
//                             }
//                         }
//                         
//                         else if ([domainName isEqualToString:SearchDomainGeneral]) {
//                             NSArray *generals = [domain objectForKey:@"data"];
//                             SearchAutoCompleteGeneral *general = [generals objectAtIndex:indexPath.row];
//                             [self saveHistory:general.title];
//                             [TPAnalytics trackSearchWithAction:@"Search Autocomplete" keyword:general.title];
//                             [self goToResultPage:general.title withAutoComplete:YES];
//                         }
//                         else if ([domainName isEqualToString:SearchDomainHotlist]) {
//                             NSArray *hotlists = [domain objectForKey:@"data"];
//                             SearchAutoCompleteHotlist *hotlist = [hotlists objectAtIndex:indexPath.row];
//                             NSArray *keys = [hotlist.url componentsSeparatedByString:@"/"];
//                             
//                             HotlistResultViewController *controller = [HotlistResultViewController new];
//                             controller.data = @{@"title" : hotlist.title, @"key" : [keys lastObject]};
//                             controller.isFromAutoComplete = YES;
//                             controller.hidesBottomBarWhenPushed = YES;
//                             [TPAnalytics trackSearchWithAction:@"Search Hotlist" keyword:hotlist.title];
//                             
//                             [self.navigationController pushViewController:controller animated:YES];
//                         }
//                         
                     }
     ];
}


#pragma mark - UISearchBar Delegate
- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
    
    if([searchText isEqualToString:@""]) {
        NSMutableArray *willBeDeletedIndexes = [[NSMutableArray alloc] init];
        
        for (SearchSuggestionData* searchSuggestionData in _searchSuggestionDataArray) {
            if ([searchSuggestionData.name  isEqual: SEARCH_AUTOCOMPLETE] || [searchSuggestionData.name  isEqual: @"hotlist"]) {
                [willBeDeletedIndexes addObject:searchSuggestionData];
            }
        }
        
        for (SearchSuggestionData* searchSuggestionData in willBeDeletedIndexes) {
            [_searchSuggestionDataArray removeObject:searchSuggestionData];
        }
        
        [_collectionView reloadData];
    } else {
        
        [self getUserSearchSuggestionDataWithQuery:searchText];
//        NSPredicate *resultPredicate = [NSPredicate predicateWithFormat:@"SELF contains[c] %@", searchText];
//        NSArray *historiesresult;
//        historiesresult = [_historyResult filteredArrayUsingPredicate:resultPredicate];
//        NSInteger limit = 5;
//        
//        if(historiesresult.count > limit) {
//            NSRange endRange = NSMakeRange((historiesresult.count-limit), limit);
//            NSArray *lastThree= [historiesresult subarrayWithRange:endRange];
//            [_typedHistoryResult addObjectsFromArray:lastThree];
//        } else {
//            [_typedHistoryResult addObjectsFromArray:historiesresult];
//        }
//        
//        [_requestManager requestWithBaseUrl:@"http://jahe.tokopedia.com"
//                                       path:[NSString stringWithFormat:searchPath, _searchBar.text]
//                                     method:RKRequestMethodGET
//                                  parameter:nil
//                                    mapping:[self mapping]
//                                  onSuccess:^(RKMappingResult *successResult, RKObjectRequestOperation *operation) {
//                                      NSDictionary *result = successResult.dictionary;
//                                      SearchAutoCompleteObject *search = [result objectForKey:@""];
//                                      
//                                      [_domains removeAllObjects];
//                                      [_general removeAllObjects];
//                                      [_hotlist removeAllObjects];
//                                      
//                                      [_general addObjectsFromArray:search.domains.general];
//                                      [_hotlist addObjectsFromArray:search.domains.hotlist];
//                                      
//                                      if(_general.count > 0) {
//                                          [_domains addObject:@{@"title" : SearchDomainGeneral, @"data" : _general}];
//                                      }
//                                      
//                                      if(_hotlist.count > 0) {
//                                          [_domains addObject:@{@"title" : SearchDomainHotlist, @"data" : _hotlist}];
//                                      }
//                                      
//                                      if(_typedHistoryResult.count > 0) {
//                                          [_domains addObject:@{@"title" : SearchDomainHistory, @"data" : _typedHistoryResult}];
//                                      }
//                                      
//                                      [_collectionView reloadData];
//                                      [_collectionView setHidden:NO];
//                                  } onFailure:^(NSError *errorResult) {
//                                      
//                                  }];
//        
        
    }
    
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    NSString *searchString = [searchBar.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    if ([searchString length]) {
        [TPAnalytics trackSearchWithAction:@"Search" keyword:searchString];
        [self goToResultPage:_searchBar.text withAutoComplete:NO];
    }
    else {
        [_collectionView reloadData];
    }
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar {
    [_searchBar setText:@""];
    [_searchBar resignFirstResponder];
    [self searchBar:_searchBar textDidChange:@""];
    self.navigationController.tabBarController.tabBar.hidden = NO;
}

- (BOOL)searchBarShouldEndEditing:(UISearchBar *)searchBar {
    [searchBar setShowsCancelButton:NO animated:YES];
    [searchBar setShowsBookmarkButton:NO];
    if ([self isEnableImageSearch]) {
        _searchBarTrailingConstraint.constant = 44;
    } else {
        _searchBarTrailingConstraint.constant = 0;
    }
    [self deActivateSearchBar];
    return YES;
}

- (BOOL)searchBarShouldBeginEditing:(UISearchBar *)searchBar {
    [searchBar setShowsCancelButton:YES animated:YES];
    _searchBar.showsBookmarkButton = ([self isEnableImageSearch]);
    _searchBarTrailingConstraint.constant = 0;
    [self activateSearchBar];
    return YES;
}

#pragma mark - properties
- (void)setData:(NSDictionary *)data {
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
    
    _collectionView.contentInset = UIEdgeInsetsMake(0, 0, keyboardFrameBeginRect.size.height+25, 0);
}

- (void)keyboardWillHide:(NSNotification *)info {
    _collectionView.contentInset = UIEdgeInsetsZero;
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


- (RKObjectMapping*)mapping {
    RKObjectMapping *searchMapping = [RKObjectMapping mappingForClass:[SearchAutoCompleteObject class]];;
    RKObjectMapping *domainsMapping = [RKObjectMapping mappingForClass:[SearchAutoCompleteDomains class]];
    
    RKObjectMapping *generalMapping = [RKObjectMapping mappingForClass:[SearchAutoCompleteGeneral class]];
    [generalMapping addAttributeMappingsFromArray:@[@"title", @"url", @"rating", @"id"]];
    
    RKObjectMapping *hotlistMapping = [RKObjectMapping mappingForClass:[SearchAutoCompleteHotlist class]];
    [hotlistMapping addAttributeMappingsFromArray:@[@"title", @"url", @"rating", @"id"]];
    
    RKRelationshipMapping *generalRel = [RKRelationshipMapping relationshipMappingFromKeyPath:@"general" toKeyPath:@"general" withMapping:generalMapping];
    RKRelationshipMapping *hotlistRel = [RKRelationshipMapping relationshipMappingFromKeyPath:@"hotlist" toKeyPath:@"hotlist" withMapping:hotlistMapping];
    
    RKRelationshipMapping *domainsRel = [RKRelationshipMapping relationshipMappingFromKeyPath:@"domains" toKeyPath:@"domains" withMapping:domainsMapping];
    
    
    [domainsMapping addPropertyMapping:generalRel];
    [domainsMapping addPropertyMapping:hotlistRel];
    [searchMapping addPropertyMapping:domainsRel];

    return searchMapping;
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

-(void) generateSearchBarAccessoryView {
    UIToolbar* keyboardToolbar = [[UIToolbar alloc] init];
    [keyboardToolbar sizeToFit];
    UIBarButtonItem *flexBarButton = [[UIBarButtonItem alloc]
                                      initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace
                                      target:nil action:nil];
    UIBarButtonItem *doneBarButton = [[UIBarButtonItem alloc]
                                      initWithBarButtonSystemItem:UIBarButtonSystemItemDone
                                      target:self action:@selector(hideKeyboard:)];
    keyboardToolbar.items = @[flexBarButton, doneBarButton];
    self.searchBar.inputAccessoryView = keyboardToolbar;
}

-(void) hideKeyboard: (UIBarButtonItem*) barButtonItem {
    [self.searchBar resignFirstResponder];
}

#pragma mark - Method
- (void)goToResultPage:(NSString*)searchText withAutoComplete:(BOOL) autocomplete{
    searchText = [searchText lowercaseString];
    SearchResultViewController *vc = [SearchResultViewController new];
    vc.delegate = self;
    vc.isFromAutoComplete = autocomplete;
    vc.data =@{kTKPDSEARCH_DATASEARCHKEY : searchText?:@"" ,
               kTKPDSEARCH_DATATYPE:kTKPDSEARCH_DATASEARCHPRODUCTKEY};
    SearchResultViewController *vc1 = [SearchResultViewController new];
    vc.isFromAutoComplete = autocomplete;
    vc.delegate = self;
    vc1.data =@{kTKPDSEARCH_DATASEARCHKEY : searchText?:@"" ,
                kTKPDSEARCH_DATATYPE:kTKPDSEARCH_DATASEARCHCATALOGKEY};
    SearchResultShopViewController *vc2 = [SearchResultShopViewController new];
    vc.isFromAutoComplete = autocomplete;
    vc2.data =@{kTKPDSEARCH_DATASEARCHKEY : searchText?:@"" ,
                kTKPDSEARCH_DATATYPE:kTKPDSEARCH_DATASEARCHSHOPKEY};
    NSArray *viewcontrollers = @[vc,vc1,vc2];
    
    TKPDTabNavigationController *viewController = [TKPDTabNavigationController new];
    
    [viewController setSelectedIndex:0];
    [viewController setViewControllers:viewcontrollers];
    [viewController setNavigationTitle:searchText];
    
    viewController.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:viewController animated:YES];
}

- (void)orientationChanged:(NSNotification*)note {
    [_collectionView reloadData];
}

#pragma mark - Image search

- (void)takePhoto:(UIButton *)sender {
    [TPAnalytics trackScreenName:@"Snap Search Camera"];
    
    UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
    imagePicker.delegate = self;
    imagePicker.allowsEditing = YES;
    imagePicker.sourceType = UIImagePickerControllerSourceTypeCamera;
    imagePicker.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    [self.navigationController presentViewController:imagePicker animated:YES completion:NULL];
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    [picker dismissViewControllerAnimated:YES completion:^{
        ImagePickerCategoryController *controller = [[ImagePickerCategoryController alloc] init];
        controller.imageQuery = info;
        controller.hidesBottomBarWhenPushed = YES;
        [self.navigationController pushViewController:controller animated:YES];
    }];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [picker dismissViewControllerAnimated:YES completion:NULL];
}

-(void)searchBarBookmarkButtonClicked:(UISearchBar *)searchBar{
    [self takePhoto:nil];
}

@end
