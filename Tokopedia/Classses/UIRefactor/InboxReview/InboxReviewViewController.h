//
//  InboxReviewViewController.h
//
//
//  Created by Tokopedia on 12/11/14.
//
//

#import <UIKit/UIKit.h>
@class DetailReviewViewController;

@interface InboxReviewViewController : UIViewController

@property (strong,nonatomic) NSDictionary *data;

@property (strong, nonatomic) DetailReviewViewController *detailViewController;

@end
