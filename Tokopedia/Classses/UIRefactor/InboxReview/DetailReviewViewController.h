//
//  DetailReviewViewController.h
//
//
//  Created by Tokopedia on 12/11/14.
//
//

#import <UIKit/UIKit.h>
#import "StarsRateView.h"
#import "HPGrowingTextView.h"
#import "Shop.h"

@class TKPDTabInboxReviewNavigationController;

@interface DetailReviewViewController : UIViewController
{
    IBOutlet UIScrollView *scrollContent;
}
@property (strong,nonatomic) NSDictionary *data;
@property (strong,nonatomic) Shop *shop;
@property (strong,nonatomic) NSString *is_owner;
@property (nonatomic) NSString *index;
@property (nonatomic) NSIndexPath *indexPath;

@property (strong, nonatomic) TKPDTabInboxReviewNavigationController *masterViewController;

-(void)replaceDataSelected:(NSDictionary *)data;

@end
