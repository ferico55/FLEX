//
//  SearchAutoCompleteViewController.h
//  Tokopedia
//
//  Created by Tonito Acen on 6/10/15.
//  Copyright (c) 2015 TOKOPEDIA. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SearchAutoCompleteViewController : UIViewController

@property (strong, nonatomic) NSArray *categories;
@property (strong, nonatomic) NSArray *catalogs;
@property (strong, nonatomic) UISearchBar *searchBar;

@end
