//
//  ATLMAppDelegate.m
//  Atlas Messenger
//
//  Created by Kevin Coleman on 6/10/14.
//  Copyright (c) 2014 Layer, Inc. All rights reserved.
//
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//  http://www.apache.org/licenses/LICENSE-2.0
//
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.
//

#import <LayerKit/LayerKit.h>
#import <Atlas/Atlas.h>
#import <SVProgressHUD/SVProgressHUD.h>

#import "ATLMAppDelegate.h"
#import "ATLMNavigationController.h"
#import "ATLMConversationListViewController.h"
#import "ATLMSplashView.h"
#import "ATLMUtilities.h"
#import "ATLMConstants.h"
#import "ATLMAuthenticationProvider.h"
#import "ATLMApplicationViewController.h"
#import "ATLMConfiguration.h"


@interface ATLMAppDelegate () <ATLMLayerControllerDelegate>

@property (nonnull, nonatomic) ATLMLayerController *layerController;
@property (nonnull, nonatomic) ATLMApplicationViewController *applicationViewController;

@end

@implementation ATLMAppDelegate

#pragma mark UIApplicationDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    [SVProgressHUD setMinimumDismissTimeInterval:3.0f];
    
    // Create the view controller that will also be the root view controller of the app.
    self.applicationViewController = [ATLMApplicationViewController new];
    
    [self initializeLayer];
    
    // Push Notifications follow authentication state
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(registerForRemoteNotifications) name:LYRClientDidAuthenticateNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(unregisterForRemoteNotifications) name:LYRClientDidDeauthenticateNotification object:nil];

    // Put the view controller on screen.
    self.window = [UIWindow new];
    self.window.frame = [[UIScreen mainScreen] bounds];
    self.window.rootViewController = self.applicationViewController;
    [self.window makeKeyAndVisible];
    return YES;
}


- (void)initializeLayer
{
    NSURL *fileURL = [[NSBundle mainBundle] URLForResource:@"LayerConfiguration.json" withExtension:nil];
    ATLMConfiguration *configuration = [[ATLMConfiguration alloc] initWithFileURL:fileURL];
    
    ATLMAuthenticationProvider *authenticationProvider = [[ATLMAuthenticationProvider alloc] initWithConfiguration:configuration];
    
    NSURL *appID = authenticationProvider.layerAppID;
    
    // Configure the Layer Client options.
    LYRClientOptions *clientOptions = [LYRClientOptions new];
    clientOptions.synchronizationPolicy = LYRClientSynchronizationPolicyPartialHistory;
    clientOptions.partialHistoryMessageCount = 20;
    
    // Create the application controller.
    self.layerController = [ATLMLayerController applicationControllerWithLayerAppID:appID clientOptions:clientOptions authenticationProvider:authenticationProvider];
    self.layerController.delegate = self;
    
    self.applicationViewController.layerController = self.layerController;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    NSUInteger countOfUnreadMessages = [self.layerController countOfUnreadMessages];
    [application setApplicationIconBadgeNumber:countOfUnreadMessages];
}

- (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error
{
    NSLog(@"Application failed to register for remote notifications with error %@", error);
}

- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken
{
    [self.layerController updateRemoteNotificationDeviceToken:deviceToken];
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo fetchCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler
{
    [self.layerController handleRemoteNotification:userInfo responseInfo:nil completion:^(BOOL success, NSError * _Nullable error) {
        if (success) {
            completionHandler(UIBackgroundFetchResultNewData);
        } else {
            NSLog(@"Failed to handle remote notification with error %@", error);
            completionHandler(UIBackgroundFetchResultFailed);
        }
    }];
}

- (void)application:(UIApplication *)application handleActionWithIdentifier:(nullable NSString *)identifier forRemoteNotification:(nonnull NSDictionary *)userInfo withResponseInfo:(nonnull NSDictionary *)responseInfo completionHandler:(nonnull void (^)())completionHandler
{
    if (![identifier isEqualToString:ATLUserNotificationInlineReplyActionIdentifier]) {
        // Bail out, if the action identifier is not meant for us.
        return;
    }
    [self.layerController handleRemoteNotification:userInfo responseInfo:responseInfo completion:^(BOOL success, NSError * _Nullable error) {
        if (success) {
            completionHandler(UIBackgroundFetchResultNewData);
        } else {
            NSLog(@"Failed to handle remote notification with response with error %@", error);
            completionHandler(UIBackgroundFetchResultFailed);
        }
    }];
}

- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation
{
    return YES;
}

#pragma mark - Remote Notifications

- (void)registerForRemoteNotifications
{
    NSSet *categories = [NSSet setWithObject:ATLDefaultUserNotificationCategory()];
    UIUserNotificationType types = (UIUserNotificationTypeAlert | UIUserNotificationTypeBadge | UIUserNotificationTypeSound);
    UIUserNotificationSettings *notificationSettings = [UIUserNotificationSettings settingsForTypes:types
                                                                                         categories:categories];
    [[UIApplication sharedApplication] registerUserNotificationSettings:notificationSettings];
    [[UIApplication sharedApplication] registerForRemoteNotifications];
}

- (void)unregisterForRemoteNotifications
{
    [[UIApplication sharedApplication] unregisterForRemoteNotifications];
}

#pragma mark - ATLMLayerControllerDelegate

- (void)layerController:(ATLMLayerController *)applicationController didFailWithError:(NSError *)error
{
    NSLog(@"Application controller=%@ has hit an error=%@", applicationController, error);
}

@end
