//
//  ATLMLayerController.m
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

#import "ATLMLayerController.h"
#import <SVProgressHUD/SVProgressHUD.h>
#import "ATLMErrors.h"
#import "ATLMConstants.h"
#import "ATLMessagingUtilities.h"
#import "ATLMUserCredentials.h"

NSString *const ATLMConversationMetadataDidChangeNotification = @"LSConversationMetadataDidChangeNotification";
NSString *const ATLMConversationParticipantsDidChangeNotification = @"LSConversationParticipantsDidChangeNotification";
NSString *const ATLMConversationDeletedNotification = @"LSConversationDeletedNotification";
NSString *const ATLMLayerControllerErrorDomain = @"ATLMLayerControllerErrorDomain";

@interface ATLMLayerController ()

@property (nonnull, nonatomic, readwrite) id<ATLMAuthenticating> authenticationProvider;
@property (nullable, nonatomic, readwrite) LYRClient *layerClient;
@property (nonatomic, readwrite, copy) LYRClientOptions *layerClientOptions;

@end

@implementation ATLMLayerController

+ (nonnull instancetype)applicationControllerWithLayerAppID:(nonnull NSURL *)layerAppID clientOptions:(nullable LYRClientOptions *)clientOptions authenticationProvider:(nonnull id<ATLMAuthenticating>)authenticationProvider
{
    return [[self alloc] initWithLayerAppID:layerAppID clientOptions:clientOptions authenticationProvider:authenticationProvider];
}

- (id)initWithLayerAppID:(nonnull NSURL *)layerAppID clientOptions:(nullable LYRClientOptions *)clientOptions authenticationProvider:(nonnull id<ATLMAuthenticating>)authenticationProvider
{
    self = [super init];
    if (self) {
        _layerClient = [LYRClient clientWithAppID:layerAppID delegate:self options:clientOptions];
        _layerClient.autodownloadMIMETypes = [NSSet setWithObjects:ATLMIMETypeImageJPEGPreview, ATLMIMETypeTextPlain, nil];
        _authenticationProvider = authenticationProvider;
    }
    return self;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)authenticateWithCredentials:(ATLMUserCredentials *)credentials completion:(void (^)(LYRSession *session, NSError *error))completion
{
    [self.layerClient requestAuthenticationNonceWithCompletion:^(NSString * _Nullable nonce, NSError * _Nullable error) {
        if (!nonce) {
            completion(nil, error);
            return;
        }
        [self.authenticationProvider authenticateWithCredentials:[credentials asDictionary] nonce:nonce completion:^(NSString * _Nonnull identityToken, NSError * _Nonnull error) {
            if (!identityToken) {
                completion(nil, error);
                return;
            }
            [self.layerClient authenticateWithIdentityToken:identityToken completion:^(LYRIdentity * _Nullable authenticatedUser, NSError * _Nullable error) {
                if (authenticatedUser) {
                    completion(self.layerClient.currentSession, nil);
                } else {
                    completion(nil, error);
                }
            }];
        }];
    }];
}

- (void)updateRemoteNotificationDeviceToken:(NSData *)deviceToken
{
    NSError *error;
    BOOL success = [self.layerClient updateRemoteNotificationDeviceToken:deviceToken error:&error];
    if (!success) {
        [self notifyDelegateOfError:error];
    }
}

#pragma mark - Remote notification handling

- (void)handleRemoteNotification:(NSDictionary *)userInfo responseInfo:(nullable NSDictionary *)responseInfo completion:(void (^)(BOOL success, NSError *_Nullable error))completionHandler
{
    __weak typeof(self) weakSelf = self;
    BOOL success = [self.layerClient synchronizeWithRemoteNotification:userInfo completion:^(LYRConversation * _Nullable conversation, LYRMessage * _Nullable message, NSError * _Nullable error) {
        if (conversation || message) {
            // Notify the delegate the remote notification has been handled.
            if ([weakSelf.delegate respondsToSelector:@selector(layerController:didFinishHandlingRemoteNotificationForConversation:message:responseText:)]) {
                // Extract the response text from the responseInfo dictionary (if available).
                NSString *responseText = responseInfo[UIUserNotificationActionResponseTypedTextKey];
                [weakSelf.delegate layerController:weakSelf didFinishHandlingRemoteNotificationForConversation:conversation message:message responseText:responseText];
            }
            completionHandler(YES, nil);
        } else {
            if (error) {
                // In case the client hit an error during the synchronization process.
                completionHandler(NO, error);
            } else {
                // In case the client didn't receive any conversations or messages.
                completionHandler(YES, nil);
            }
        }
    }];
    if (!success) {
        completionHandler(YES, nil);
    }
}

#pragma mark - LYRClientDelegate implementation

- (void)layerClient:(LYRClient *)client didReceiveAuthenticationChallengeWithNonce:(NSString *)nonce
{
    NSLog(@"Layer Client did receive an authentication challenge with nonce=%@", nonce);
    [self.authenticationProvider refreshAuthenticationWithNonce:nonce completion:^(NSString * _Nonnull identityToken, NSError * _Nonnull error) {
        if (!identityToken) {
            [self notifyDelegateOfError:error];
            return;
        }
        // Pass the new identity token to the client to reestablish the session.
        [self.layerClient authenticateWithIdentityToken:identityToken completion:^(LYRIdentity * _Nullable authenticatedUser, NSError * _Nullable error) {
            if (!authenticatedUser) {
                [self notifyDelegateOfError:error];
            }
        }];
    }];
}

- (void)layerClient:(LYRClient *)client didAuthenticateAsUserID:(NSString *)userID
{
    NSLog(@"Layer Client did authenticate as userID=%@", userID);
}

- (void)layerClientDidDeauthenticate:(LYRClient *)client
{
    NSLog(@"Layer Client did deauthenticate");
}

- (void)layerClient:(LYRClient *)client objectsDidChange:(NSArray *)changes
{
    for (LYRObjectChange *change in changes) {
        if (![change.object isKindOfClass:[LYRConversation class]]) {
            continue;
        }
        if (change.type == LYRObjectChangeTypeUpdate && [change.property isEqualToString:@"metadata"]) {
            [[NSNotificationCenter defaultCenter] postNotificationName:ATLMConversationMetadataDidChangeNotification object:change.object];
        }
        if (change.type == LYRObjectChangeTypeUpdate && [change.property isEqualToString:@"participants"]) {
            [[NSNotificationCenter defaultCenter] postNotificationName:ATLMConversationParticipantsDidChangeNotification object:change.object];
        }
        if (change.type == LYRObjectChangeTypeDelete) {
            [[NSNotificationCenter defaultCenter] postNotificationName:ATLMConversationDeletedNotification object:change.object];
        }
    }
}

- (void)layerClient:(LYRClient *)client didFailOperationWithError:(NSError *)error
{
    NSLog(@"Layer Client did fail operation with error: %@", error);
    [self notifyDelegateOfError:error];
}

#pragma mark - Helpers

- (void)notifyDelegateOfError:(NSError *)error
{
    if (error) {
        if ([self.delegate respondsToSelector:@selector(layerController:didFailWithError:)]) {
            [self.delegate layerController:self didFailWithError:error];
        }
    }
}

- (NSUInteger)countOfUnreadMessages
{
    LYRQuery *query = [LYRQuery queryWithQueryableClass:[LYRMessage class]];
    LYRPredicate *unreadPred =[LYRPredicate predicateWithProperty:@"isUnread" predicateOperator:LYRPredicateOperatorIsEqualTo value:@(YES)];
    LYRPredicate *userPred = [LYRPredicate predicateWithProperty:@"sender.userID" predicateOperator:LYRPredicateOperatorIsNotEqualTo value:self.layerClient.authenticatedUser.userID];
    query.predicate = [LYRCompoundPredicate compoundPredicateWithType:LYRCompoundPredicateTypeAnd subpredicates:@[unreadPred, userPred]];
    return [self.layerClient countForQuery:query error:nil];
}

- (NSUInteger)countOfMessages
{
    LYRQuery *query = [LYRQuery queryWithQueryableClass:[LYRMessage class]];
    return [self.layerClient countForQuery:query error:nil];
}

- (NSUInteger)countOfConversations
{
    LYRQuery *query = [LYRQuery queryWithQueryableClass:[LYRConversation class]];
    return [self.layerClient countForQuery:query error:nil];
}

- (LYRMessage *)messageForIdentifier:(NSURL *)identifier
{
    LYRQuery *query = [LYRQuery queryWithQueryableClass:[LYRMessage class]];
    query.predicate = [LYRPredicate predicateWithProperty:@"identifier" predicateOperator:LYRPredicateOperatorIsEqualTo value:identifier];
    query.limit = 1;
    return [self.layerClient executeQuery:query error:nil].firstObject;
}

- (LYRConversation *)existingConversationForIdentifier:(NSURL *)identifier
{
    LYRQuery *query = [LYRQuery queryWithQueryableClass:[LYRConversation class]];
    query.predicate = [LYRPredicate predicateWithProperty:@"identifier" predicateOperator:LYRPredicateOperatorIsEqualTo value:identifier];
    query.limit = 1;
    return [self.layerClient executeQuery:query error:nil].firstObject;
}

- (LYRConversation *)existingConversationForParticipants:(NSSet *)participants
{
    LYRQuery *query = [LYRQuery queryWithQueryableClass:[LYRConversation class]];
    query.predicate = [LYRPredicate predicateWithProperty:@"participants" predicateOperator:LYRPredicateOperatorIsEqualTo value:participants];
    query.limit = 1;
    return [self.layerClient executeQuery:query error:nil].firstObject;
}

#pragma mark - Notification Handlers

- (void)didReceiveLayerClientWillBeginSynchronizationNotification:(NSNotification *)notification
{
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
}

- (void)didReceiveLayerClientDidFinishSynchronizationNotification:(NSNotification *)notification
{
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
}

@end
