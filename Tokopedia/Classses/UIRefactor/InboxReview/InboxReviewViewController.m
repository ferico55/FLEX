//
//  InboxReviewViewController.m
//  
//
//  Created by Tokopedia on 12/11/14.
//
//

#import "InboxReviewViewController.h"

@interface InboxReviewViewController () <UITableViewDataSource, UITableViewDelegate>

- (void)configureRestkit;
- (void)cancelCurrentAction;
- (void)loadData;
- (void)requestSuccess;
- (void)requestFail;
- (void)requestTimeout;

@end

@implementation InboxReviewViewController

#pragma mark - ViewController Life
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
}

#pragma mark - DataSource Delegate
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = nil;
    
    return cell;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    return 0;
}

#pragma mark - Tableview Delegate
- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    
}

#pragma mark - Request + Restkit Init
- (void)configureRestkit {
    
}

- (void)loadData {
    
}

- (void)requestSuccess {
    
}

- (void)requestFail {
    
}

- (void)requestTimeout {
    
}

- (void)cancelCurrentAction {
    
}

#pragma mark - IBAction
-(IBAction)tap:(id)sender {
    if ([sender isKindOfClass:[UIBarButtonItem class]]) {
        UIBarButtonItem *barButton = (UIBarButtonItem *)sender;
        switch (barButton.tag) {
            case 10:
            {
                [self.navigationController popViewControllerAnimated:YES];
                break;
            }
                
            default:
                break;
        }
    }
}

#pragma mark - Memory Manage
- (void)dealloc {
    
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
