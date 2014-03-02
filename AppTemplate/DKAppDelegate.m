//
//  DKAppDelegate.m
//  AppTemplate
//
//  Created by Dmitry Klimkin on 26/2/14.
//  Copyright (c) 2014 Dmitry Klimkin. All rights reserved.
//

#import "DKAppDelegate.h"
#import "DKBaseViewController.h"
#import "DKMenuViewController.h"
#import "DKHomeViewController.h"

#import "KeychainItemWrapper.h"
#import "NSString+MD5Addition.h"
#import "iRate.h"

#define DKAppDelegateDefaultAppNameKey @"DKAppDelegateDefaultAppNameKey"
#define DKAppDelegateDeviceTokenKey @"DeviceTokenKey"

@interface DKAppDelegate ()

@property (nonatomic, strong) NSString *defaultAppName;
@property (nonatomic, strong) NSString *deviceToken;
@property (nonatomic, strong) KeychainItemWrapper *keychainWrapper;

@end

@implementation DKAppDelegate

@synthesize defaultAppName = _defaultAppName;
@synthesize deviceToken = _deviceToken;
@synthesize keychainWrapper = _keychainWrapper;

#if 1
+ (void)initialize
{
    //configure iRate
//    [iRate sharedInstance].appStoreID = APPSTOREID;// App Id
//    [iRate sharedInstance].applicationName = APPLICATION_NAME;
//    [iRate sharedInstance].messageTitle = LIKE_THIS_APP;
//    [iRate sharedInstance].message = PLEASE_RATE_APP;
//    [iRate sharedInstance].rateButtonLabel = RATE_TXT;
//    [iRate sharedInstance].cancelButtonLabel = NO_LATER_TXT;
//    [iRate sharedInstance].remindButtonLabel = DO_LATER_TXT;
    [iRate sharedInstance].daysUntilPrompt = 1;
    [iRate sharedInstance].usesUntilPrompt = 3;
    [iRate sharedInstance].remindPeriod = 3;
}
#endif

- (NSString *)defaultAppName {
    if (_defaultAppName == nil) {
        _defaultAppName = [[[NSBundle mainBundle] infoDictionary] valueForKey:(id)kCFBundleNameKey];

        if (_defaultAppName == nil) {
            
            _defaultAppName = [[NSUserDefaults standardUserDefaults] stringForKey:DKAppDelegateDefaultAppNameKey];
            
            if (_defaultAppName == nil) {
                self.defaultAppName = [NSString uniqueString];
            }
        }
    }
    
    return _defaultAppName;
}

- (void)setDefaultAppName:(NSString *)defaultAppName {
    _defaultAppName = defaultAppName;
    
    if (defaultAppName) {
        [[NSUserDefaults standardUserDefaults] setObject:defaultAppName forKey:DKAppDelegateDefaultAppNameKey];
    } else {
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:DKAppDelegateDefaultAppNameKey];
    }
    
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (NSString *)deviceToken {
    if (_deviceToken == nil) {
        NSString *tokenKey = [NSString stringWithFormat:@"%@%@", self.defaultAppName, DKAppDelegateDeviceTokenKey];
        
        _deviceToken = [[NSUserDefaults standardUserDefaults] stringForKey:tokenKey];
    }
    
    return _deviceToken;
}

- (void)setDeviceToken:(NSString *)deviceToken {
    _deviceToken = deviceToken;
    
    NSString *tokenKey = [NSString stringWithFormat:@"%@%@", self.defaultAppName, DKAppDelegateDeviceTokenKey];

    if (deviceToken) {
        [[NSUserDefaults standardUserDefaults] setObject:deviceToken forKey:tokenKey];
    } else {
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:tokenKey];
    }
    
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    [MagicalRecord setupCoreDataStackWithAutoMigratingSqliteStoreNamed:@"DataModel"];

    NSString *bundleId = [[[NSBundle mainBundle] infoDictionary] valueForKey:(id)kCFBundleIdentifierKey];

    self.keychainWrapper = [[KeychainItemWrapper alloc] initWithIdentifier:self.defaultAppName accessGroup:[NSString stringWithFormat:@"%@.GenericKeychainSuite", bundleId]];

    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    
    UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:[[DKHomeViewController alloc] init]];
    DKMenuViewController *menuViewController = [[DKMenuViewController alloc] init];
    
    RESideMenu *sideMenuViewController = [[RESideMenu alloc] initWithContentViewController:navigationController menuViewController:menuViewController];
    sideMenuViewController.delegate = self;
    self.window.rootViewController = sideMenuViewController;
    
    self.window.backgroundColor = [UIColor whiteColor];
    [self.window makeKeyAndVisible];
    
    // Override point for customization after application launch.
    return YES;
}

- (BOOL)application:(UIApplication *)application
            openURL:(NSURL *)url
  sourceApplication:(NSString *)sourceApplication
         annotation:(id)annotation {
    
    return NO;
}

- (BOOL)application:(UIApplication *)application handleOpenURL:(NSURL *)url {
    return NO;
}
							
- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

- (void) unregisterFromNotifications {

    self.deviceToken = nil;
    
    [[UIApplication sharedApplication] unregisterForRemoteNotifications];
    [[UIApplication sharedApplication] setApplicationIconBadgeNumber:0];
}

- (void)registerForRemoteNotifications:(BOOL)useCachedToken {
    
    if (useCachedToken && self.deviceToken) {
    } else {
        [[UIApplication sharedApplication] registerForRemoteNotificationTypes:(UIRemoteNotificationTypeAlert |
                                                                               UIRemoteNotificationTypeBadge |
                                                                               UIRemoteNotificationTypeSound)];
    }
}

- (void)application:(UIApplication *)app didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
	
    NSString *notificationToken = [NSString stringWithFormat:@"%@", deviceToken];
    
    notificationToken = [notificationToken stringByReplacingOccurrencesOfString:@">" withString:@""];
    notificationToken = [notificationToken stringByReplacingOccurrencesOfString:@"<" withString:@""];
    notificationToken = [notificationToken stringByReplacingOccurrencesOfString:@" " withString:@""];
    
    if (notificationToken.length > 0) {
        self.deviceToken = notificationToken;
    }
}

- (void)application:(UIApplication *)app didFailToRegisterForRemoteNotificationsWithError:(NSError *)error {
	
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo {
}

#pragma mark -
#pragma mark RESideMenu Delegate

- (void)sideMenu:(RESideMenu *)sideMenu willShowMenuViewController:(UIViewController *)menuViewController {
    NSLog(@"willShowMenuViewController");
}

- (void)sideMenu:(RESideMenu *)sideMenu didShowMenuViewController:(UIViewController *)menuViewController {
    NSLog(@"didShowMenuViewController");
}

- (void)sideMenu:(RESideMenu *)sideMenu willHideMenuViewController:(UIViewController *)menuViewController {
    NSLog(@"willHideMenuViewController");
}

- (void)sideMenu:(RESideMenu *)sideMenu didHideMenuViewController:(UIViewController *)menuViewController {
    NSLog(@"didHideMenuViewController");
}

@end
