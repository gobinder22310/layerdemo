//
//  ATLMConversationListViewController.h
//  Atlas Messenger
//
//  Created by Kevin Coleman on 8/29/14.
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

#import "ATLMLayerController.h"
#import <Atlas/Atlas.h>
#import <SVProgressHUD/SVProgressHUD.h>

NS_ASSUME_NONNULL_BEGIN
@class ATLConversationListViewController;

/**
 @abstract The delegate is notified when the `ATLMConversationListViewController`
   will begin the dismissal transition and when it ends. This is useful when
   the parent view controller needs to present one view controller after another.
 */
@protocol ATLMConversationListViewControllerPresentationDelegate <NSObject>

/**
 @abstract The delegate method is called when the `ATLMConversationListViewController`
   will begin the dismissal transition of its child view controllers.
 @param conversationListViewController The `ATLConversationListViewController`
   making the invocation.
 */
- (void)conversationListViewControllerWillBeDismissed:(nonnull ATLConversationListViewController *)conversationListViewController;

/**
 @abstract The delegate method is called when the `ATLMConversationListViewController`
   completed its child view controller were dismissed.
 @param conversationListViewController The `ATLConversationListViewController`
   making the invocation.
 */
- (void)conversationListViewControllerWasDismissed:(nonnull ATLConversationListViewController *)conversationListViewController;

@end

/**
 @abstract Subclass of the `ATLMConversationListViewController`. Presents a list of conversations.
 */
@interface ATLMConversationListViewController : ATLConversationListViewController

/**
 @abstract The controller object for the application.
 */
@property (nonatomic) ATLMLayerController *layerController;

/**
 @abstract Determines if the view controller should display an `Info` item as
   the left bar button item of the navigation controller.
 */
@property (nonatomic) BOOL displaysInfoItem;

/**
 @abstract The presentation delegate receiver, which is usually the parent
   view controller.
 */
@property (nullable, nonatomic, weak) id<ATLMConversationListViewControllerPresentationDelegate> presentationDelegate;

+ (instancetype)conversationListViewControllerWithLayerController:(nonnull ATLMLayerController *)layerController;

/**
 @abstract Programmatically simulates the selection of an `LYRConversation`
   object in the conversations table view.
 @discussion This method is used when opening the application in response to
   a push notification. When invoked, it will display the appropriate conversation on screen.
 */
- (void)selectConversation:(nonnull LYRConversation *)conversation;

@end
NS_ASSUME_NONNULL_END
