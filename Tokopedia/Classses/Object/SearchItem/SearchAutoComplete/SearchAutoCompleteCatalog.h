//
//  SearchAutoCompleteCatalog.h
//  Tokopedia
//
//  Created by Tonito Acen on 6/10/15.
//  Copyright (c) 2015 TOKOPEDIA. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SearchAutoCompleteViewModel.h"

@interface SearchAutoCompleteCatalog : NSObject

@property (nonatomic, strong) NSString *title;
@property (nonatomic, strong) NSString *url;
@property (nonatomic, strong) NSString *rating;
@property (nonatomic, strong) NSString *image;
@property (nonatomic, strong) NSString *catalogID;

@property (strong, nonatomic) SearchAutoCompleteViewModel *viewModel;

@end
