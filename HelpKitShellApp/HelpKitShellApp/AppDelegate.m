//
//  AppDelegate.m
//  Smooch
//
//  Created by Mike Spensieri on 2015-10-11.
//  Copyright © 2015 Smooch Technologies. All rights reserved.
//

#import "AppDelegate.h"
#import "SmoochHelpKit.h"
#import "ViewController.h"
#import <Smooch/Smooch.h>

// Enter your Zendesk URL here
NSString* const KnowledgeBaseURL = @"https://support.zendesk.com";

// Other URLs to try:
//
// https://fixmestick.zendesk.com
// https://prezi.zendesk.com
// https://mortgagecoach.zendesk.com
// https://topify.zendesk.com
// https://winshuttle.zendesk.com
// https://dyknow.zendesk.com
// https://picaboo.zendesk.com
// https://shootproof.zendesk.com
// https://huddle.zendesk.com
// https://streamtime.zendesk.com

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    self.window.backgroundColor = [UIColor whiteColor];
    self.window.rootViewController = [[ViewController alloc] init];
    [self.window makeKeyAndVisible];
    
    SHKSettings* settings = [SHKSettings settingsWithAppToken:@""];
    settings.enableZendeskArticleRestyling = NO;
    settings.knowledgeBaseURL = KnowledgeBaseURL;
    [SmoochHelpKit initWithSettings:settings];
    
    [SmoochHelpKit setDefaultRecommendations:@[
                                            @"https://github.com/smooch/smooch-helpkit-ios",
                                            @"https://www.apple.com"
                                            ]];
    
    [SmoochHelpKit setTopRecommendation:@"https://smooch.io"];
    
    return YES;
}

@end
