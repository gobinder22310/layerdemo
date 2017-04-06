//
//  ATLTestInterface.m
//  Atlas Messenger
//
//  Created by Kevin Coleman on 9/3/14.
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

#import "ATLMTestInterface.h"
#import "ATLMTestUser.h"
#import "ATLMErrors.h"
#import "ATLMUtilities.h"

@interface ATLMTestInterface ();

@end

@implementation ATLMTestInterface

+ (instancetype)testInterfaceWithApplicationController:(ATLMLayerController *)applicationController
{
    NSParameterAssert(applicationController);
    return [[self alloc] initWithApplicationController:applicationController];
}

- (id)initWithApplicationController:(ATLMLayerController *)applicationController
{
    self = [super init];
    if (self) {
        _applicationController = applicationController;
       
        NSURL*appID = [NSURL URLWithString:@"0cbf780a-ba39-11e4-b645-4382000002fe"];
        ATLMLayerClient *client = [ATLMLayerClient clientWithAppID:appID];
        _applicationController.layerClient = client;
        
        NSURL *fileURL = [[NSBundle mainBundle] URLForResource:@"LayerConfiguration.json" withExtension:nil];
        ATLMConfiguration *configuration = [[ATLMConfiguration alloc] initWithFileURL:fileURL];
        
        ATLMAPIManager *manager = [ATLMAPIManager managerWithBaseURL:(configuration.identityProviderURL ?: ATLMRailsBaseURL(ATLMEnvironmentProduction)) layerClient:client];
        _applicationController.APIManager = manager;
        
        _contentFactory = [ATLMLayerContentFactory layerContentFactoryWithLayerClient:applicationController.layerClient];
    }
    return self;
}

- (void)connectLayerClient
{
    LYRCountDownLatch *latch = [LYRCountDownLatch latchWithCount:1 timeoutInterval:10];
    [self.applicationController.layerClient connectWithCompletion:^(BOOL success, NSError *error) {
        [latch decrementCount];
    }];
     [latch waitTilCount:0];
}

- (void)registerTestUserWithIdentifier:(NSString *)identifier
{
    // Hello
    LYRCountDownLatch *latch = [LYRCountDownLatch latchWithCount:3 timeoutInterval:10];
    [self.applicationController.layerClient requestAuthenticationNonceWithCompletion:^(NSString *nonce, NSError *error) {
        NSAssert(!error, @"Error requesting authentication nonce: %@", error);
        [latch decrementCount];
        [self.applicationController.APIManager registerUserWithName:identifier nonce:nonce completion:^(NSString *identityToken, NSError *error) {
            NSAssert(!error, @"Error requesting identity token: %@", error);
            [latch decrementCount];
            [self.applicationController.layerClient authenticateWithIdentityToken:identityToken completion:^(NSString *authenticatedUserID, NSError *error) {
                NSAssert(!error, @"Error authenticating with layer:%@", error);
                [latch decrementCount];
            }];
        }];
    }];
    [latch waitTilCount:0];
}

- (void)deauthenticateIfNeeded
{
    if (self.applicationController.layerClient.authenticatedUserID) {
        LYRCountDownLatch *latch = [LYRCountDownLatch latchWithCount:1 timeoutInterval:10];
        [self.applicationController.layerClient deauthenticateWithCompletion:^(BOOL success, NSError *error) {
            NSAssert(!error, @"Error deauthenticating");
            [self.applicationController.APIManager deauthenticate];
            [latch decrementCount];
        }];
        [latch waitTilCount:0];
    }
}

- (void)clearLayerContent
{
    NSOrderedSet *conversations = [self allLayerConversations];
    for (LYRConversation *conversation in conversations) {
        NSError *error;
        [conversation delete:LYRDeletionModeAllParticipants error:&error];
        NSAssert(!error, @"Failed to delete conversation with error: %@", error);
    }
}

- (NSOrderedSet *)allLayerConversations
{
    LYRQuery *query = [LYRQuery queryWithQueryableClass:[LYRConversation class]];
    NSError *error;
    NSOrderedSet *conversations = [self.applicationController.layerClient executeQuery:query error:&error];
    NSAssert(!error, @"Failed querying for conversations with error: %@", error);
    return conversations;
}

- (ATLMUser *)randomUser
{
    NSError *error;
    NSSet *users = [self.applicationController.persistenceManager persistedUsersWithError:&error];
    expect(users).toNot.beNil;
    expect(error).to.beNil;
    
    NSMutableSet *mutableUsers = [users mutableCopy];
    [mutableUsers removeObject:self.applicationController.APIManager.authenticatedSession.user];
    
    int randomNumber = arc4random_uniform((int)users.count);
    ATLMUser *user = [[users allObjects] objectAtIndex:randomNumber];
    
    return user;
}

- (ATLMUser *)userForIdentifier:(NSString *)identifier
{
    ATLMUser *user = [self.applicationController.persistenceManager userForIdentifier:identifier];
    expect(user).to.beNil;
    return  user;
}

- (NSString *)conversationLabelForParticipants:(NSSet *)participantIDs
{
    NSMutableSet *participantIdentifiers = [NSMutableSet setWithSet:participantIDs];
    
    if ([participantIdentifiers containsObject:self.applicationController.layerClient.authenticatedUserID]) {
        [participantIdentifiers removeObject:self.applicationController.layerClient.authenticatedUserID];
    }
    
    if (!participantIdentifiers.count > 0) return @"Personal Conversation";
    
    NSSet *participants = [self.applicationController.persistenceManager usersForIdentifiers:participantIdentifiers];
    
    if (!participants.count > 0) return @"No Matching Participants";
    
    ATLMUser *firstUser = [[participants allObjects] objectAtIndex:0];
    NSString *conversationLabel = firstUser.fullName;
    if (participants.count == 1) {
        return conversationLabel;
    }
    conversationLabel = firstUser.firstName;
    for (int i = 1; i < [[participants allObjects] count]; i++) {
        ATLMUser *user = [[participants allObjects] objectAtIndex:i];
        conversationLabel = [NSString stringWithFormat:@"%@, %@", conversationLabel, user.firstName];
    }
    return conversationLabel;
}

- (NSString *)selectionIndicatorAccessibilityLabelForUser:(ATLMUser *)testUser;
{
    return [NSString stringWithFormat:@"%@ selected", testUser.fullName];
}

- (void)requestIdentityTokenForUserID:(NSString *)userID appID:(NSString *)appID nonce:(NSString *)nonce completion:(void(^)(NSString *identityToken, NSError *error))completion
{
    NSParameterAssert(userID);
    NSParameterAssert(appID);
    NSParameterAssert(nonce);
    NSParameterAssert(completion);
    
    NSURL *identityTokenURL = [NSURL URLWithString:@"https://layer-identity-provider.herokuapp.com/identity_tokens"];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:identityTokenURL];
    request.HTTPMethod = @"POST";
    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [request setValue:@"application/json" forHTTPHeaderField:@"Accept"];
    
    NSDictionary *parameters = @{ @"app_id": appID, @"user_id": userID, @"nonce": nonce };
    NSData *requestBody = [NSJSONSerialization dataWithJSONObject:parameters options:0 error:nil];
    request.HTTPBody = requestBody;
    
    NSURLSessionConfiguration *sessionConfiguration = [NSURLSessionConfiguration ephemeralSessionConfiguration];
    NSURLSession *session = [NSURLSession sessionWithConfiguration:sessionConfiguration];
    [[session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        if (error) {
            completion(nil, error);
            return;
        }
        
        // Deserialize the response
        NSDictionary *responseObject = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
        if(![responseObject valueForKey:@"error"])
        {
            NSString *identityToken = responseObject[@"identity_token"];
            completion(identityToken, nil);
        }
        else
        {
            NSString *domain = @"layer-identity-provider.herokuapp.com";
            NSInteger code = [responseObject[@"status"] integerValue];
            NSDictionary *userInfo =
            @{
              NSLocalizedDescriptionKey: @"Layer Identity Provider Returned an Error.",
              NSLocalizedRecoverySuggestionErrorKey: @"There may be a problem with your APPID."
              };
            
            NSError *error = [[NSError alloc] initWithDomain:domain code:code userInfo:userInfo];
            completion(nil, error);
        }
        
    }] resume];
}


@end
