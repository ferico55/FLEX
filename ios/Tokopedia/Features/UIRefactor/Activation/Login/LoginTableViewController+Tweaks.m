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
                   EMAIL_PASSWORD(@"evelyn.greselda+46@tokopedia.com", @"asdf1234"),
                   EMAIL_PASSWORD(@"evelyn.greselda+45@tokopedia.com", @"asdf1234"),
                   EMAIL_PASSWORD(@"deadora.hendra+01@tokopedia.com", @"tokopedia1995"),
                   EMAIL_PASSWORD(@"deadora.hendra+02@tokopedia.com", @"tokopedia1995"),
                   EMAIL_PASSWORD(@"deadora.hendra+03@tokopedia.com", @"tokopedia1995"),
                   EMAIL_PASSWORD(@"deadora.hendra+04@tokopedia.com", @"tokopedia1995"),
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
                   EMAIL_PASSWORD(@"gunadi.qc@tokopedia.com", @"gun123qwerty"),
                   EMAIL_PASSWORD(@"andhika.djaffri+1@tokopedia.com", @"tokopedia789"),
                   EMAIL_PASSWORD(@"andhika.djaffri+2@tokopedia.com", @"tokopedia789"),
                   EMAIL_PASSWORD(@"tri.sujarwo+0@tokopedia.com", @"Tokopedia1"),
                   EMAIL_PASSWORD(@"akunmrmr@gmail.com", @"akunstarwars123"),
                   EMAIL_PASSWORD(@"katherine.oliviani+prod2@tokopedia.com", @"1234567890"),
                   EMAIL_PASSWORD(@"thessa.silviana+17@tokopedia.com", @"tokped1"),
                   })
                );
#endif
}

@end
