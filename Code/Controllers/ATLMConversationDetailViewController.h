//
//  ATLMConversationDetailViewController.h
//  Atlas Messenger
//
//  Created by Kevin Coleman on 10/2/14.
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

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>
#import "ATLMLayerController.h"

extern NSString *const ATLMConversationDetailViewControllerTitle;
extern NSString *const ATLMConversationMetadataNameKey;

@class ATLMConversationDetailViewController;

/**
 @abstract The `ATLMConversationDetailViewControllerDelegate` notifies its receiver of events that occur within the controller.
 */
@protocol ATLMConversationDetailViewControllerDelegate <NSObject>

/**
 @abstract Informs the delegate that a user has elected to share the application's current location.
 @param conversationDetailViewController The `ATLMConversationDetailViewController` in which the selection occurred.
 */
- (void)conversationDetailViewControllerDidSelectShareLocation:(ATLMConversationDetailViewController *)conversationDetailViewController;

/**
 @abstract Informs the delegate that a user has elected to switch the conversation.
 @param conversationDetailViewController The `ATLMConversationDetailViewController` in which the selection occurred.
 @param conversation The new `LYRConversation` object.
 @discussion The user changes the `LYRConversation` object in response to adding or deleting participants from a conversation.
 */
- (void)conversationDetailViewController:(ATLMConversationDetailViewController *)conversationDetailViewController didChangeConversation:(LYRConversation *)conversation;

@end

/**
 @abstract The `ATLMConversationDetailViewController` presents a user interface that displays information about a given
 conversation. It also provides for adding/removing participants to/from a conversation and sharing the user's location.
 */
@interface ATLMConversationDetailViewController : UITableViewController

///--------------------------------
/// @name Initializing a Controller
///--------------------------------

+ (instancetype)conversationDetailViewControllerWithConversation:(LYRConversation *)conversation withLayerController:(ATLMLayerController *)layerController;

/**
 @abstract The `ATLMConversationDetailViewControllerDelegate` object for the controller.
 */
@property (nonatomic) id<ATLMConversationDetailViewControllerDelegate> detailDelegate;

/**
 @abstract The controller object for the application.
 */
@property (nonatomic) ATLMLayerController *layerController;

@end
