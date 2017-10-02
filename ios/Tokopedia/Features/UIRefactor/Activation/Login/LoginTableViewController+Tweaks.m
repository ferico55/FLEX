//
//  LoginTableViewController+Tweaks.m
//  Tokopedia
//
//  Created by Vishun Dayal on 09/09/17.
//  Copyright © 2017 TOKOPEDIA. All rights reserved.
//

#import "LoginTableViewController+Tweaks.h"

@implementation LoginTableViewController (Tweaks)
#define EMAIL_PASSWORD(email, password) (@{ @"email":email, @"password":password }): email
@dynamic loginData;

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupDefaultUsersForTesting];
}
- (void)setLoginData:(NSDictionary *)loginData {
    [self setFieldWithEmail: loginData[@"email"]];
    [self setFieldWithPassword: loginData[@"password"]];
}

- (void)setupDefaultUsersForTesting {
#ifdef DEBUG
    FBTweakBind(self, loginData, @"Login", @"Test Accounts", @"Account", (@{}),
                (@{
                   (@{}): @"-Blank-",
                   EMAIL_PASSWORD(@"elly.susilowati+007@tokopedia.com", @"tokopedia2015"),
                   EMAIL_PASSWORD(@"elly.susilowati+089@tokopedia.com", @"tokopedia2015"),
                   EMAIL_PASSWORD(@"elly.susilowati+090@tokopedia.com", @"tokopedia2015"),
                   EMAIL_PASSWORD(@"alwan.ubaidillah+101@tokopedia.com", @"tokopedia2016"),
                   EMAIL_PASSWORD(@"alwan.ubaidillah+103@tokopedia.com", @"tokopedia2016"),
                   EMAIL_PASSWORD(@"alwan.ubaidillah+003@tokopedia.com", @"tokopedia2016"),
                   EMAIL_PASSWORD(@"julius.gonawan+buyer@tokopedia.com", @"tokopedia2016"),
                   EMAIL_PASSWORD(@"julius.gonawan+seller@tokopedia.com", @"tokopedia2016"),
                   EMAIL_PASSWORD(@"julius.gonawan@tokopedia.com", @"tokopedia2016"),
                   EMAIL_PASSWORD(@"felicia.amanda+buyer@tokopedia.com", @"tokopedia2017"),
                   EMAIL_PASSWORD(@"felicia.amanda+seller@tokopedia.com", @"tokopedia2017"),
                   EMAIL_PASSWORD(@"feni.manurung+123@tokopedia.com", @"123tokopedia"),
                   EMAIL_PASSWORD(@"feni.manurung+456@tokopedia.com", @"123toped"),
                   EMAIL_PASSWORD(@"chrysanthia.novelia@tokopedia.com", @"Chrysan33"),
                   EMAIL_PASSWORD(@"dylan.anggasta@tokopedia.com", @"admintokopedia"),
                   EMAIL_PASSWORD(@"gunadi.qc@tokopedia.com", @"gun123qwerty")
                   })
                );
#endif
}

@end
