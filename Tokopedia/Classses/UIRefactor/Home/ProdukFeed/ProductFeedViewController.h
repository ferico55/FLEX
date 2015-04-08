//
//  ProdukFeedViewController.h
//  Tokopedia
//
//  Created by IT Tkpd on 8/27/14.
//  Copyright (c) 2014 TOKOPEDIA. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TKPDTabHomeViewController.h"

@interface ProductFeedViewController : UIViewController
{
    IBOutlet UIView *viewNoData;
}
@property NSInteger index;
@property (weak, nonatomic) id<TKPDTabHomeDelegate> delegate;
@end
