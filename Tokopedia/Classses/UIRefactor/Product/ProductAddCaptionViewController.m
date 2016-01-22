//
//  ProductAddCaptionViewController.m
//  Tokopedia
//
//  Created by Kenneth Vincent on 1/19/16.
//  Copyright © 2016 TOKOPEDIA. All rights reserved.
//

#import "ProductAddCaptionViewController.h"
#import "NavigateViewController.h"



@interface ProductAddCaptionViewController () <UITableViewDataSource, UITableViewDelegate> {
    NavigateViewController *_navigate;
    UITextField *_activeTextField;
}

@property (weak, nonatomic) IBOutlet UITableView *table;
@property (weak, nonatomic) IBOutlet UIView *imagesView;
@property (weak, nonatomic) IBOutlet UIImageView *attachedImageView;
@property (weak, nonatomic) IBOutlet UIImageView *deleteIconImageView;
@property (weak, nonatomic) IBOutlet UITextField *imageCaptionTextField;
@property (strong, nonatomic) IBOutletCollection(UIImageView) NSArray *attachedImages;
@property (strong, nonatomic) IBOutletCollection(UITableViewCell) NSArray *addCaptionCells;

@end

@implementation ProductAddCaptionViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _addCaptionCells = [NSArray sortViewsWithTagInArray:_addCaptionCells];
    
    UIBarButtonItem *leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Batal"
                                                                          style:UIBarButtonItemStyleBordered
                                                                         target:self
                                                                         action:@selector(tap:)];
    leftBarButtonItem.tag = 10;
    self.navigationItem.leftBarButtonItem = leftBarButtonItem;
    
    UIBarButtonItem *rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Simpan"
                                                                           style:UIBarButtonItemStyleBordered
                                                                          target:self
                                                                          action:@selector(tap:)];
    rightBarButtonItem.tag = 11;
    self.navigationItem.rightBarButtonItem = rightBarButtonItem;
    
    // Keyboard Notification
    NSNotificationCenter *notification = [NSNotificationCenter defaultCenter];
    [notification addObserver:self
                     selector:@selector(keyboardWillShow:)
                         name:UIKeyboardWillShowNotification
                       object:nil];
    [notification addObserver:self
                     selector:@selector(keyboardWillHide:)
                         name:UIKeyboardWillHideNotification
                       object:nil];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIKeyboardWillShowNotification
                                                  object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIKeyboardWillHideNotification
                                                  object:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)gesture:(UITapGestureRecognizer*)sender {
    
}

#pragma mark - Table View Delegate
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return _addCaptionCells.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = nil;
    
    cell = _addCaptionCells[indexPath.section];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 2) {
        [cell setBackgroundColor:[UIColor clearColor]];
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return [_addCaptionCells[indexPath.section] frame].size.height;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    if (section == 0) {
        return 0;
    }
    return 5;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 0;
}

#pragma mark - Keyboard Notification
- (void)keyboardWillShow:(NSNotification*)notification {
    NSDictionary* userInfo = [notification userInfo];
    CGSize keyboardSize = [[userInfo objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
    
    UIEdgeInsets contentInsets = UIEdgeInsetsMake(0.0, 0.0, keyboardSize.height, 0.0);
    _table.contentInset = contentInsets;
    _table.scrollIndicatorInsets = contentInsets;
    
    if (_activeTextField == _imageCaptionTextField) {
        [_table scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:1] atScrollPosition:UITableViewScrollPositionBottom animated:YES];
    }
}

- (void)keyboardWillHide:(NSNotification*)notification {
    UIEdgeInsets contentInsets = UIEdgeInsetsZero;
    [UIView animateWithDuration:TKPD_FADEANIMATIONDURATION
                          delay:0
                        options: UIViewAnimationOptionCurveEaseInOut
                     animations:^{
                         _table.contentInset = contentInsets;
                         _table.scrollIndicatorInsets = contentInsets;
                     }
                     completion:^(BOOL finished){
                     }];
}

#pragma mark - Action
- (IBAction)tap:(id)sender {
    [_activeTextField resignFirstResponder];
    if ([sender isKindOfClass:[UIButton class]]) {
        UIButton *button = 
    }
}
@end
