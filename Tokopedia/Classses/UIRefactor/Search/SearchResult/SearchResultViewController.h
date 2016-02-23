//
//  SearchResultViewController.h
//  Tokopedia
//
//  Created by IT Tkpd on 8/28/14.
//  Copyright (c) 2014 TOKOPEDIA. All rights reserved.
//

#import <UIKit/UIKit.h>


@protocol SearchResultDelegate <NSObject>

- (void)pushViewController:(id)viewController animated:(BOOL)animated;
- (void)updateTabCategory:(NSString *)categoryID;

@end

#pragma mark - Search Result View Controller

@interface SearchResultViewController : GAITrackedViewController

@property (strong,nonatomic) NSDictionary *data;
@property (strong,nonatomic) NSDictionary* imageQueryInfo;
@property (strong,nonatomic) NSString* image_url;
@property (nonatomic) BOOL isFromImageSearch;
@property (nonatomic) BOOL isFromAutoComplete;
@property (weak, nonatomic) id<SearchResultDelegate> delegate;

@end
