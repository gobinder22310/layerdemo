//
//  ATLMLayerController.h
//  Atlas Messenger
//
//  Created by Kevin Coleman on 6/12/14.
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


#import <Foundation/Foundation.h>
#import <LayerKit/LYRClient.h>
#import "ATLMAuthenticationProvider.h"

@class ATLMUserCredentials;

extern NSString * _Nonnull const ATLMConversationMetadataDidChangeNotification;
extern NSString * _Nonnull const ATLMConversationParticipantsDidChangeNotification;
extern NSString * _Nonnull const ATLMConversationDeletedNotification;

extern NSString *_Nonnull const ATLMLayerControllerErrorDomain;

typedef NS_ENUM(NSUInteger, ATLMLayerControllerError) {
    ATLMLayerControllerErrorAppIDAlreadySet                  = 1, // Layer appID already set on the application controller.
    ATLMLayerControllerErrorFailedHandlingRemoteNotification = 2, // Underlying Layer client failed to handle the remote notification.
};

@class ATLMLayerController;

/**
 @abstract The `ATLMLayerControllerDelegate` notifies the receiver about
   the application state changes so that the receiver can navigate the UI accordingly.
 */
@protocol ATLMLayerControllerDelegate <NSObject>

@optional

/**
 @abstract Notifies the receiver the application controller has finished handling
   the remote notification and hands all the objects associated with the remote
   notification.
 @param applicationController The `ATLMLayerController` instance performing the invocation.
 @param conversation The `LYRConversation` instance associated with the remote notification.
 @param conversation The `LYRMessage` instance associated with the remote notification.
 */
- (void)layerController:(nonnull ATLMLayerController *)applicationController didFinishHandlingRemoteNotificationForConversation:(nullable LYRConversation *)conversation message:(nullable LYRMessage *)message responseText:(nullable NSString *)responseText;

/**
 @abstract Notifies the receiver the application controller has hit an error.
 @param applicationController The `ATLMLayerController` instance performing the invocation.
 @param error The error instance the application controller has hit.
 */
- (void)layerController:(nonnull ATLMLayerController *)applicationController didFailWithError:(nonnull NSError *)error;

@end

/**
 @abstract The `ATLMLayerController` manages global resources needed by
   multiple view controller classes in the Atlas Messenger App. It also
   implements the `LYRClientDelegate` protocol. Only one instance should be
   instantiated and it should be passed to controllers that require it.
 */
@interface ATLMLayerController : NSObject <LYRClientDelegate>

///--------------------------------
/// @name Initializing a Controller
///--------------------------------

/**
 @abstract Creates the `ATLMLayerController` instance with the supplied provider.
 @param layerAppID The application identifier for the Layer client.
 @param provider An object conforming to the `ATLMAuthenticating protocol.
 @param layerClientOptions The Layer client's options instance, which will be passed
   to the `LYRClient` during its initialization.
 @return Returns an instance of the `ATLMLayerController` ready for use.
 @discussion The application controller creates an instance of the `LYRClient` once the
   appID is known.
 */
+ (nonnull instancetype)applicationControllerWithLayerAppID:(nonnull NSURL *)layerAppID clientOptions:(nullable LYRClientOptions *)clientOptions authenticationProvider:(nonnull id<ATLMAuthenticating>)authenticationProvider;

/**
 @abstract Authenticates the application by performing the Layer authentication handshake.
 @param credentials An `NSDictionary` containing authetication credentials. 
 @param completions A block to be called upon completion of the operation.
 */
- (void)authenticateWithCredentials:(nonnull ATLMUserCredentials *)credentials completion:(nonnull void (^)(LYRSession * _Nonnull session, NSError *_Nullable error))completion;

/**
 @abstract Updates the remote notification device token on the underlying `LYRClient` insance.
 @param deviceToken The remote notification device token passed by the app delegate
   upon receiving a device token.
 */
- (void)updateRemoteNotificationDeviceToken:(nullable NSData *)deviceToken;

/**
 @abstract Passes the remote notification to the client to handle it, which
   will cause a short synchronization process and call the completion handler
   once the synchronization completes.
 @param userInfo The remote notification dictionary passed by the app
   delegate upon receiving a remote notification or user responding to it.
 @param responseInfo The response info containing the message reply entered
   by the user from the notification center.
 @param completionHandler A block to be called upon completion of the
   synchronization process. The `completionHandler` will always be executed,
   no matter if the underlying client handled the remote notification
   successfully, hit an error, or if the remote notification was not meant
   for the underlying `layerClient`.
 */
- (void)handleRemoteNotification:(nonnull NSDictionary *)userInfo responseInfo:(nullable NSDictionary *)responseInfo completion:(nonnull void (^)(BOOL success, NSError *_Nullable error))completionHandler;

///-----------------------
/// @name Global Resources
///-----------------------

/**
 @abstract The receiver in charge of handling application state changes and errors.
 */
@property (nullable, nonatomic, weak) id<ATLMLayerControllerDelegate> delegate;

/**
 @abstract The `LSAPIManager` object for the application.
 */
@property (nonnull, nonatomic, readonly) id<ATLMAuthenticating> authenticationProvider;

/**
 @abstract The `LYRClient` object for the application.
 */
@property (nullable, nonatomic, readonly) LYRClient *layerClient;

/**
 @abstract Queries the underlying LayerKit client for the total count of `LYRMessage` objects whose `isUnread` property is true.
 */
@property (assign, nonatomic, readonly) NSUInteger countOfUnreadMessages;

/**
 @abstract Queries the underlying LayerKit client for the total count of `LYRMessage` objects.
 */
@property (assign, nonatomic, readonly) NSUInteger countOfMessages;

/**
 @abstract Queries the underlying LayerKit client for the total count of `LYRConversation` objects.
 */
@property (assign, nonatomic, readonly) NSUInteger countOfConversations;

/**
 @abstract Queries LayerKit for an existing message whose `identifier` property matches the supplied identifier.
 @param identifier An NSURL representing the `identifier` property of an `LYRMessage` object for which the query will be performed.
 @retrun An `LYRMessage` object or `nil` if none is found.
 */
- (nullable LYRMessage *)messageForIdentifier:(nonnull NSURL *)identifier;

/**
 @abstract Queries LayerKit for an existing conversation whose `identifier` property matches the supplied identifier.
 @param identifier An NSURL representing the `identifier` property of an `LYRConversation` object for which the query will be performed.
 @retrun An `LYRConversation` object or `nil` if none is found.
 */
- (nullable LYRConversation *)existingConversationForIdentifier:(nonnull NSURL *)identifier;

/**
 @abstract Queries LayerKit for an existing conversation whose `participants` property matches the supplied set.
 @param participants An `NSSet` of participant identifier strings for which the query will be performed.
 @retrun An `LYRConversation` object or `nil` if none is found.
 */
- (nullable LYRConversation *)existingConversationForParticipants:(nonnull NSSet *)participants;

@end
