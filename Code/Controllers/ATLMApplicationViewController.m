//
//  ATLMApplicationViewController.m
//  Atlas Messenger
//
//  Created by Klemen Verdnik on 6/26/16.
//  Copyright © 2016 Layer, Inc. All rights reserved.
//

#import "ATLMApplicationViewController.h"
#import "ATLMSplashView.h"
#import "ATLMRegistrationViewController.h"
#import "ATLMConversationListViewController.h"
#import "ATLMConversationViewController.h"
#import "ATLMUtilities.h"
#import "ATLMNavigationController.h"
#import "ATLMUserCredentials.h"

///-------------------------
/// @name Application States
///-------------------------

typedef NS_ENUM(NSUInteger, ATLMApplicationState) {
    /**
     @abstract A state where the app has not yet established a state.
     */
    ATLMApplicationStateIndeterminate,
    
    /**
     @abstract A state where the app has the appID, but no user credentials.
     */
    ATLMApplicationStateCredentialsRequired,
    
    /**
     @abstract A state where the app is fully authenticated.
     */
    ATLMApplicationStateAuthenticated
};

static NSString *const ATLMPushNotificationSoundName = @"layerbell.caf";
static void *ATLMApplicationViewControllerObservationContext = &ATLMApplicationViewControllerObservationContext;

@interface ATLMApplicationViewController () <ATLMRegistrationViewControllerDelegate, ATLMConversationListViewControllerPresentationDelegate>

@property (assign, nonatomic, readwrite) ATLMApplicationState state;
@property (nullable, nonatomic) ATLMSplashView *splashView;
@property (nullable, nonatomic) UINavigationController *registrationNavigationController;
@property (nullable, nonatomic) ATLMConversationListViewController *conversationListViewController;

@end

@implementation ATLMApplicationViewController

- (nonnull id)init
{
    self = [super init];
    if (self) {
        _state = ATLMApplicationStateIndeterminate;
        [self addObserver:self forKeyPath:@"state" options:0 context:ATLMApplicationViewControllerObservationContext];
    }
    return self;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (ATLMApplicationState)determineInitialApplicationState
{
    if (self.layerController.layerClient.authenticatedUser == nil) {
        return ATLMApplicationStateCredentialsRequired;
    } else {
        return ATLMApplicationStateAuthenticated;
    }
}

- (void)observeValueForKeyPath:(nullable NSString *)keyPath ofObject:(nullable id)object change:(nullable NSDictionary<NSString*, id> *)change context:(nullable void *)context
{
    if (context == ATLMApplicationViewControllerObservationContext) {
        if ([keyPath isEqualToString:@"state"]) {
            [self presentViewControllerForApplicationState];
        }
    }
}

#pragma mark - UIViewController Overrides

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self makeSplashViewVisible:YES];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    self.state = [self determineInitialApplicationState];
}

#pragma mark - Splash View

- (void)makeSplashViewVisible:(BOOL)visible
{
    if (visible) {
        // Add ATLMSplashView to the self.view
        if (!self.splashView) {
            self.splashView = [[ATLMSplashView alloc] initWithFrame:self.view.bounds];
        }
        [self.view addSubview:self.splashView];
    } else {
        // Fade out self.splashView and remove it from the self.view subviews' stack.
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [UIView animateWithDuration:0.5 animations:^{
                self.splashView.alpha = 0.0;
            } completion:^(BOOL finished) {
                [self.splashView removeFromSuperview];
                self.splashView = nil;
            }];
        });
    }
}

#pragma mark - UI view controller presenting

- (void)presentRegistrationNavigationController
{
    if (!self.registrationNavigationController) {
        self.registrationNavigationController = [[UINavigationController alloc] init];
        self.registrationNavigationController.navigationBarHidden = YES;
        if (!self.childViewControllers.count) {
            // Only if there's no child view controller being presented on top.
            [self presentViewController:self.registrationNavigationController animated:YES completion:nil];
        }
        self.conversationListViewController = nil;
    }
}

- (void)presentRegistrationViewController
{
    if (!self.registrationNavigationController) {
        [self presentRegistrationNavigationController];
    }
    ATLMRegistrationViewController *registrationViewController = [ATLMRegistrationViewController new];
    registrationViewController.delegate = self;
    [self.registrationNavigationController pushViewController:registrationViewController animated:YES];
}

- (void)presentConversationListViewController
{
    [self.registrationNavigationController dismissViewControllerAnimated:YES completion:nil];
    self.registrationNavigationController = nil;
    
    self.conversationListViewController = [ATLMConversationListViewController conversationListViewControllerWithLayerController:self.layerController];
    self.conversationListViewController.presentationDelegate = self;
    UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:self.conversationListViewController];
    [self presentViewController:navigationController animated:YES completion:nil];
}

#pragma mark - Managing UI view transitions

- (void)presentViewControllerForApplicationState
{
    [self makeSplashViewVisible:YES];
    switch (self.state) {
        case ATLMApplicationStateCredentialsRequired: {
            [self presentRegistrationViewController];
            break;
        }
        case ATLMApplicationStateAuthenticated: {
            [self presentConversationListViewController];
            break;
        }
        default:
            [NSException raise:NSInternalInconsistencyException format:@"Unhandled ATLMApplicationState value=%lu", (unsigned long)self.state];
            break;
    }
}

#pragma mark - ATLMConversationListViewControllerPresentationDelegate implementation

- (void)conversationListViewControllerWillBeDismissed:(nonnull ATLConversationListViewController *)conversationListViewController
{
    // Prepare the current view controller for dismissal of the
    [self makeSplashViewVisible:YES];
}

- (void)conversationListViewControllerWasDismissed:(nonnull ATLConversationListViewController *)conversationListViewController
{
    [self presentViewController:self.registrationNavigationController animated:YES completion:nil];
}

#pragma mark - ATLMLayerControllerDelegate implementation

- (void)applicationController:(ATLMLayerController *)applicationController didFinishHandlingRemoteNotificationForConversation:(LYRConversation *)conversation message:(LYRMessage *)message responseText:(nullable NSString *)responseText
{
    if (responseText.length) {
        // Handle the inline message reply.
        if (!conversation) {
            NSLog(@"Failed to complete inline reply: unable to find Conversation referenced by remote notification.");
            return;
        }
        LYRMessagePart *messagePart = [LYRMessagePart messagePartWithText:responseText];
        NSString *fullName = self.layerController.layerClient.authenticatedUser.displayName;
        NSString *pushText = [NSString stringWithFormat:@"%@: %@", fullName, responseText];
        LYRMessage *message = ATLMessageForParts(self.layerController.layerClient, @[ messagePart ], pushText, ATLMPushNotificationSoundName);
        if (message) {
            NSError *error = nil;
            BOOL success = [conversation sendMessage:message error:&error];
            if (!success) {
                NSLog(@"Failed to send inline reply: %@", [error localizedDescription]);
            }
        }
        return;
    }
    
    // Navigate to the conversation, after the remote notification's been handled.
    BOOL userTappedRemoteNotification = [UIApplication sharedApplication].applicationState == UIApplicationStateInactive;
    if (userTappedRemoteNotification && conversation) {
        [self.conversationListViewController selectConversation:conversation];
    } else if (userTappedRemoteNotification) {
        [SVProgressHUD showWithStatus:@"Loading Conversation"];
    }
}

- (void)setLayerController:(ATLMLayerController *)layerController
{
    if (_layerController == layerController) {
        return;
    }
    
    _layerController = layerController;
    if (layerController) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleLayerClientWillAttemptToConnectNotification:) name:LYRClientWillAttemptToConnectNotification object:layerController.layerClient];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleLayerClientDidConnectNotification:) name:LYRClientDidConnectNotification object:layerController.layerClient];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleLayerClientDidDisconnectNotification:) name:LYRClientDidDisconnectNotification object:layerController.layerClient];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleLayerClientDidLoseConnectionNotification:) name:LYRClientDidLoseConnectionNotification object:layerController.layerClient];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleLayerClientDidAuthenticateNotification:) name:LYRClientDidAuthenticateNotification object:layerController.layerClient];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleLayerClientDidDeauthenticateNotification:) name:LYRClientDidDeauthenticateNotification object:layerController.layerClient];
        
        // Connect the client
        [layerController.layerClient connectWithCompletion:^(BOOL success, NSError * _Nullable error) {
            if (success) {
                NSLog(@"Connected to Layer");
            } else {
                NSLog(@"Failed connection to Layer: %@", error);
            }
        }];
        
        if (self.state != ATLMApplicationStateIndeterminate) {
            self.state = [self determineInitialApplicationState];
        }
    }
}

- (void)handleLayerClientWillAttemptToConnectNotification:(NSNotification *)notification
{
    unsigned long attemptNumber = [notification.userInfo[@"attemptNumber"] unsignedLongValue];
    unsigned long attemptLimit = [notification.userInfo[@"attemptLimit"] unsignedLongValue];
    NSTimeInterval delayInterval = [notification.userInfo[@"delayInterval"] floatValue];
    // Show HUD with message
    if (attemptNumber == 1) {
        [SVProgressHUD showWithStatus:@"Connecting to Layer"];
    } else {
        [SVProgressHUD showWithStatus:[NSString stringWithFormat:@"Connecting to Layer in %lus (%lu of %lu)", (unsigned long)ceil(delayInterval), attemptNumber, attemptLimit]];
    }
}

- (void)handleLayerClientDidConnectNotification:(NSNotification *)notification
{
    // Show HUD with message
    [SVProgressHUD showSuccessWithStatus:@"Connected to Layer"];
}

- (void)handleLayerClientDidDisconnectNotification:(NSNotification *)notification
{
    // Show HUD with message
    [SVProgressHUD showWithStatus:@"Disconnected from Layer"];
}

- (void)handleLayerClientDidLoseConnectionNotification:(NSNotification *)notification
{
    // Show HUD with message
    [SVProgressHUD showErrorWithStatus:@"Lost connection from Layer"];
}

- (void)handleLayerClientDidAuthenticateNotification:(NSNotification *)notification
{
    self.state = ATLMApplicationStateAuthenticated;
}

- (void)handleLayerClientDidDeauthenticateNotification:(NSNotification *)notification
{
    self.state = ATLMApplicationStateCredentialsRequired;
}

#pragma mark - ATLMRegistrationViewControllerDelegate implementation

- (void)registrationViewController:(ATLMRegistrationViewController *)registrationViewController didSubmitCredentials:(ATLMUserCredentials *)credentials
{
    [self.layerController authenticateWithCredentials:credentials completion:^(LYRSession *_Nonnull session, NSError *_Nullable error) {
        if (session) {
            self.state = ATLMApplicationStateAuthenticated;
        } else {
            NSLog(@"Failed to authenticate with credentials=%@. errors=%@", credentials, error);
            ATLMAlertWithError(error);
        }
    }];
}

@end
