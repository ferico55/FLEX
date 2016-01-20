//
//  ProductAddCaptionViewController.m
//  Tokopedia
//
//  Created by Kenneth Vincent on 1/19/16.
//  Copyright © 2016 TOKOPEDIA. All rights reserved.
//

#import "ProductAddCaptionViewController.h"

@interface ProductAddCaptionViewController ()

@property (weak, nonatomic) IBOutlet UITableView *table;
@property (weak, nonatomic) IBOutlet UIImageView *attachedImageView;
@property (weak, nonatomic) IBOutlet UIImageView *deleteIconImageView;
@property (weak, nonatomic) IBOutlet UITextField *imageCaptionTextField;
@property (strong, nonatomic) IBOutletCollection(UIImageView) NSArray *attachedImages;



@end

@implementation ProductAddCaptionViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
