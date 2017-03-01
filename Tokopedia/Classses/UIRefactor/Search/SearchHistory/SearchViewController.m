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
#import "NSString+MD5.h"
#import "SearchAutoCompleteDomains.h"
#import "SearchAutoCompleteObject.h"
#import "SearchAutoCompleteCell.h"
#import "SearchAutoCompleteHeaderView.h"
#import "UIView+HVDLayout.h"
#import "SearchAutoCompleteShopCell.h"
#import "ImagePickerCategoryController.h"

#import "Tokopedia-Swift.h"
@import SwiftOverlays;
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
    NotificationManager *_notifManager;
    UITapGestureRecognizer *imageSearchGestureRecognizer;
    Debouncer *debouncer;
    

}

@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;

@property (strong, nonatomic) NotificationBarButton *notificationButton;
@property (strong, nonatomic) NotificationViewController *notificationController;
@property (strong, nonatomic) IBOutlet UIView *iconCamera;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *searchBarTrailingConstraint;
@property (strong, nonatomic) IBOutlet UIImageView *cameraImageView;
@property (strong, nonatomic) UserAuthentificationManager *authManager;
@property (strong, nonatomic) TokopediaNetworkManager* requestManager;
@property (strong, nonatomic) NSMutableArray *searchSuggestionDataArray;

@end

@implementation SearchViewController

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
    _authManager = [UserAuthentificationManager new];
    debouncer = [[Debouncer alloc] initWithDelay:0.2 callback:nil];
    
    _searchSuggestionDataArray = [NSMutableArray new];
    _searchBar.delegate = self;

    NSNotificationCenter *notification = [NSNotificationCenter defaultCenter];
    [notification addObserver:self selector:@selector(clearAllHistory) name:kTKPD_REMOVE_SEARCH_HISTORY object:nil];
    [notification addObserver:self selector:@selector(goToHotlist:) name:@"redirectSearch" object:nil];
    
    UINib *cellNib = [UINib nibWithNibName:@"SearchAutoCompleteCell" bundle:nil];
    [_collectionView registerNib:cellNib forCellWithReuseIdentifier:@"SearchAutoCompleteCellIdentifier"];
    UINib *cellShopNib = [UINib nibWithNibName:@"SearchAutoCompleteShopCell" bundle:nil];
    [_collectionView registerNib:cellShopNib forCellWithReuseIdentifier:@"SearchAutoCompleteShopCellIdentifier"];
    UINib *cellCategoryNib = [UINib nibWithNibName:@"SearchAutoCompleteCategoryCell" bundle:nil];
    [_collectionView registerNib:cellCategoryNib forCellWithReuseIdentifier:@"SearchAutoCompleteCategoryCellIdentifier"];

    
    [self.collectionView registerClass:[SearchAutoCompleteHeaderView class] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"SearchAutoCompleteCellHeaderViewIdentifier"];
    _requestManager = [TokopediaNetworkManager new];
    _requestManager.isUsingHmac = YES;
    
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
    
    if([self isEnableImageSearch]) {
        _searchBarTrailingConstraint.constant = 44;
    } else {
        _searchBarTrailingConstraint.constant = 0;
    }
    
    [AnalyticsManager trackScreenName:@"Search Page"];
    
    self.hidesBottomBarWhenPushed = NO;
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardDidShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reloadNotification) name:@"reloadNotification" object:nil];
    UIBarButtonItem *backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@" " style:UIBarButtonItemStyleBordered target:self action:nil];
    self.navigationItem.backBarButtonItem = backBarButtonItem;
    
    [Localytics triggerInAppMessage:@"Search Product"];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardDidShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardDidHideNotification object:nil];
    [self.searchBar resignFirstResponder];
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
-(void) autoFillSearchBarWithText: (NSString *) string {
    [_searchBar setText:[string stringByAppendingString:@" "]];
}

-(void) clearHistory:(UIButton *) button {
    CGPoint buttonPoint = [button convertPoint:CGPointZero toView:_collectionView];
    
    NSIndexPath *buttonIndexPath = [_collectionView indexPathForItemAtPoint:buttonPoint];
    
    
    SearchAutoCompleteCell *searchAutoCompleteCell = (SearchAutoCompleteCell *)[_collectionView cellForItemAtIndexPath:buttonIndexPath];
    
    [_requestManager requestWithBaseUrl:[NSString aceUrl]
                                   path:@"/recent_search/v1"
                                 method:RKRequestMethodDELETE
                              parameter:@{@"unique_id": [self getUniqueId], @"q": searchAutoCompleteCell.searchTitle.text}
                                mapping:[SearchSuggestionItem mapping]
                              onSuccess:^(RKMappingResult *successResult, RKObjectRequestOperation *operation) {
        
            for (SearchSuggestionData *searchSuggestionData in _searchSuggestionDataArray) {
                if ([searchSuggestionData.id isEqual: RECENT_SEARCH]){
                    NSMutableArray *searchSuggestionItems = [NSMutableArray  arrayWithArray:searchSuggestionData.items];
                    [searchSuggestionItems removeObjectAtIndex:buttonIndexPath.item];
                    searchSuggestionData.items = searchSuggestionItems;
                    if ([searchSuggestionItems count] == 0) {
                        [_searchSuggestionDataArray removeObject:searchSuggestionData];
                    }
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
    
    [_requestManager requestWithBaseUrl:[NSString aceUrl]
                                   path:@"/recent_search/v1"
                                 method:RKRequestMethodDELETE
                              parameter:@{@"clear_all":@"true", @"unique_id": [self getUniqueId]}
                                mapping:[SearchSuggestionItem mapping]
                              onSuccess:^(RKMappingResult *successResult, RKObjectRequestOperation *operation) {
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
    
    [_collectionView reloadData];
}

-(NSString*) getUniqueId {
    NSString *userId = [_authManager getUserId];
    
    if ([userId  isEqual: @"0"]) {
        userId = [_authManager getMyDeviceToken];
    }
    
    return [userId encryptWithMD5];
}

#pragma mark - API

-(void) getUserSearchSuggestionDataWithQuery: (NSString*) query {
     __weak typeof(self) weakSelf = self;
    [debouncer setCallback:^{
        [weakSelf.requestManager requestWithBaseUrl:[NSString aceUrl]
                                               path:@"/universe/v3"
                                             method:RKRequestMethodGET
                                          parameter:@{@"unique_id": [weakSelf getUniqueId], @"q" : query}
                                            mapping:[GetSearchSuggestionGeneralResponse mapping]
                                          onSuccess:^(RKMappingResult *successResult, RKObjectRequestOperation *operation) {
                                              NSDictionary *result = [successResult dictionary];
                                              weakSelf.searchSuggestionDataArray = [[NSMutableArray alloc] init];
                                              GetSearchSuggestionGeneralResponse *searchResponse = (GetSearchSuggestionGeneralResponse*)[result objectForKey:@""];
                                              NSMutableArray *searchSuggestionDatas = [NSMutableArray arrayWithArray: searchResponse.data];
                                              weakSelf.searchSuggestionDataArray = [[searchSuggestionDatas bk_select:^BOOL(SearchSuggestionData *suggestion) {
                                                  return suggestion.items.count > 0;
                                              }] copy];
                                              [weakSelf.collectionView reloadData];
                                          } onFailure:^(NSError *errorResult) {
                                              StickyAlertView *alertView = [[StickyAlertView alloc] initWithErrorMessages:@[errorResult.localizedDescription] delegate:weakSelf];
                                              [alertView show];
                                          }];
    }];
    
    [debouncer call];
    
}

#pragma mark - Collection Delegate
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return [_searchSuggestionDataArray count];
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    SearchSuggestionData *searchSuggestionData = [_searchSuggestionDataArray objectAtIndex:section];
    return searchSuggestionData.items.count;
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath {
    UICollectionReusableView *view = nil;
    
    if ([kind isEqualToString:UICollectionElementKindSectionHeader]) {
        SearchAutoCompleteHeaderView *header = [collectionView dequeueReusableSupplementaryViewOfKind:kind withReuseIdentifier:@"SearchAutoCompleteCellHeaderViewIdentifier" forIndexPath:indexPath];
        if (_searchSuggestionDataArray.count > 0) {
            SearchSuggestionData *searchSuggestionData = [_searchSuggestionDataArray objectAtIndex:indexPath.section];
            
            header.titleLabel.text = searchSuggestionData.name;
            
            if ([header.titleLabel.text isEqual: [[RECENT_SEARCH uppercaseString] stringByReplacingOccurrencesOfString:@"_" withString:@" "]] ) {
                header.deleteButton.hidden = NO;
                [header.deleteButton setTitle:@"Clear All" forState:UIControlStateNormal];
                [header.deleteButton addTarget:self action:@selector(clearAllHistory) forControlEvents:UIControlEventTouchUpInside];
            } else {
                [header.deleteButton setTitle:@"" forState:UIControlStateNormal];
                header.deleteButton.hidden = YES;
            }
        }
        view = header;
    }
    
    return view;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    UICollectionViewCell *cell = nil;

    if (_searchSuggestionDataArray.count > 0){
        SearchSuggestionData *searchSuggestionData = [_searchSuggestionDataArray objectAtIndex:indexPath.section];
        SearchSuggestionItem *searchSuggestionItem = [searchSuggestionData.items objectAtIndex:indexPath.item];
        __weak typeof(self) weakSelf = self;
        if ([searchSuggestionData.id isEqual: @"shop"]) {
            SearchAutoCompleteShopCell *shopCell = [collectionView dequeueReusableCellWithReuseIdentifier:@"SearchAutoCompleteShopCellIdentifier" forIndexPath:indexPath];
            [shopCell setSearchItem:searchSuggestionItem];
            
            cell = shopCell;
        } else if ([searchSuggestionData.id isEqual: kTKPDSEARCH_IN_CATEGORY]) {
            SearchAutoCompleteCategoryCell *categoryCell = [collectionView dequeueReusableCellWithReuseIdentifier:@"SearchAutoCompleteCategoryCellIdentifier" forIndexPath:indexPath];
            
            [categoryCell setSearchItemWithItem:searchSuggestionItem];
            categoryCell.didTapAutoFillButton = ^(NSString *searchText) {
                [weakSelf autoFillSearchBarWithText:searchText];
            };
            [categoryCell setGreenSearchTextWithSearchText: _searchBar.text];
            cell = categoryCell;
            
        } else {
            SearchAutoCompleteCell *searchCell = [collectionView dequeueReusableCellWithReuseIdentifier:@"SearchAutoCompleteCellIdentifier" forIndexPath:indexPath];

            [searchCell setSearchCell:searchSuggestionItem section:searchSuggestionData];
            searchCell.didTapAutoFillButton = ^(NSString *suggestionText) {
                [weakSelf autoFillSearchBarWithText: suggestionText ];
            };
            [searchCell.closeButton addTarget:self action:@selector(clearHistory:) forControlEvents:UIControlEventTouchUpInside];
            [searchCell setGreenSearchText:_searchBar.text];
            cell = searchCell;
        }
        cell.hidden = NO;
      }
    
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
    if (_searchSuggestionDataArray.count > 0){
        SearchSuggestionData *searchSuggestionData = [_searchSuggestionDataArray objectAtIndex:section];
        if (![searchSuggestionData.id isEqual: @"autocomplete"] && ![searchSuggestionData.id isEqual: kTKPDSEARCH_IN_CATEGORY]) {
            size = CGSizeMake(collectionView.bounds.size.width, 50);
        }
    }
    return size;
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section {
    return 1.0;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    SearchSuggestionData *searchSuggestionData = [_searchSuggestionDataArray objectAtIndex:indexPath.section];
    
    SearchSuggestionItem *searchSuggestionItem = [searchSuggestionData.items objectAtIndex:indexPath.item];
    
    NSString *trackKeyword = [searchSuggestionData.id  isEqual: kTKPDSEARCH_IN_CATEGORY] ? [NSString stringWithFormat:@"%@ | %@", searchSuggestionItem.sc, searchSuggestionItem.keyword] : searchSuggestionItem.keyword;
    [AnalyticsManager trackSearch:searchSuggestionData.id keyword:trackKeyword];

    NSString *url = searchSuggestionItem.redirectUrl;
    if (url == nil || [[url stringByTrimmingCharactersInSet: [NSCharacterSet whitespaceCharacterSet]] length] == 0) {
        url = searchSuggestionItem.url;
    }
    
    [TPRoutes routeURL:[NSURL URLWithString:url]];
    
}


#pragma mark - UISearchBar Delegate
- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
        _requestManager = [TokopediaNetworkManager new];
        _requestManager.isUsingHmac = YES;
        [self getUserSearchSuggestionDataWithQuery:searchText];
        [_collectionView scrollToTop];
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    NSString *searchString = [searchBar.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    if ([searchString length]) {
        [AnalyticsManager trackSearch:@"search" keyword:searchString];
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
    if ([self isEnableImageSearch]) {
        _searchBarTrailingConstraint.constant = 44;
    } else {
        _searchBarTrailingConstraint.constant = 0;
    }
    return YES;
}

- (BOOL)searchBarShouldBeginEditing:(UISearchBar *)searchBar {
    [searchBar setShowsCancelButton:YES animated:YES];
    _searchBarTrailingConstraint.constant = 0;
    
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
    [self.presentingViewController.navigationController pushViewController:[userInfo objectForKey:@"vc"] animated:YES];
}

- (void)keyboardWillShow:(NSNotification *)notification {
    NSDictionary* keyboardInfo = [notification userInfo];
    NSValue* keyboardFrameBegin = [keyboardInfo valueForKey:UIKeyboardFrameBeginUserInfoKey];
    CGRect keyboardFrameBeginRect = [keyboardFrameBegin CGRectValue];
    
    _collectionView.contentInset = UIEdgeInsetsMake(0, 0, keyboardFrameBeginRect.size.height, 0);
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


-(void) hideKeyboard {
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
    vc1.isFromAutoComplete = autocomplete;
    vc1.delegate = self;
    vc1.data =@{kTKPDSEARCH_DATASEARCHKEY : searchText?:@"" ,
                kTKPDSEARCH_DATATYPE:kTKPDSEARCH_DATASEARCHCATALOGKEY};
    SearchResultShopViewController *vc2 = [SearchResultShopViewController new];
    vc2.data =@{kTKPDSEARCH_DATASEARCHKEY : searchText?:@"" ,
                kTKPDSEARCH_DATATYPE:kTKPDSEARCH_DATASEARCHSHOPKEY};
    NSArray *viewcontrollers = @[vc,vc1,vc2];
    
    TKPDTabNavigationController *viewController = [TKPDTabNavigationController new];
    vc.tkpdTabNavigationController = viewController;
    [viewController setSelectedIndex:0];
    [viewController setViewControllers:viewcontrollers];
    [viewController setNavigationTitle:searchText];
    
    viewController.hidesBottomBarWhenPushed = YES;
    [self.presentingViewController.navigationController pushViewController:viewController animated:YES];
}

- (void)orientationChanged:(NSNotification*)note {
    [_collectionView reloadData];
}

#pragma mark - Image search

- (void)takePhoto:(UIButton *)sender {
    [AnalyticsManager trackScreenName:@"Snap Search Camera"];
    
    UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
    imagePicker.delegate = self;
    imagePicker.allowsEditing = YES;
    imagePicker.sourceType = UIImagePickerControllerSourceTypeCamera;
    imagePicker.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    [self.presentController.navigationController presentViewController:imagePicker animated:YES completion:NULL];
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    [picker dismissViewControllerAnimated:YES completion:^{
        ImagePickerCategoryController *controller = [[ImagePickerCategoryController alloc] init];
        controller.imageQuery = info;
        controller.hidesBottomBarWhenPushed = YES;
        [self.presentController.navigationController pushViewController:controller animated:YES];
    }];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [picker dismissViewControllerAnimated:YES completion:NULL];
}

-(void)searchBarBookmarkButtonClicked:(UISearchBar *)searchBar{
    [self takePhoto:nil];
}

- (void)navigateToIntermediaryPage {
    UIViewController *viewController = [UIViewController new];
    viewController.view.frame = self.presentingViewController.navigationController.viewControllers.lastObject.view.frame;
    viewController.view.backgroundColor = [UIColor whiteColor];
    viewController.hidesBottomBarWhenPushed = YES;
    
    [self.presentingViewController.navigationController pushViewController:viewController animated:YES];
}

- (NSString *)shopDomainForUrl:(NSString *)urlString {
    NSURL *url = [NSURL URLWithString:urlString];
    
    NSString *path = [[url.pathComponents
                       bk_reject:^BOOL(NSString *path) {
                           return [path isEqualToString:@"/"];
                       }]
                      componentsJoinedByString:@"/"];
    return path;
}

@end
