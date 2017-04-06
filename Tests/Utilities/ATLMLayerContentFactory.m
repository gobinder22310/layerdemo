//
//  ATLLayerContentFactory.m
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

#import "ATLMLayerContentFactory.h"
#import "ATLMUser.h"


@interface ATLMLayerContentFactory ()

@property (nonatomic) LYRClient *layerClient;

@end

@implementation ATLMLayerContentFactory

NSString *const ATLTestMessageText = @"Hi, this is a test!";

+ (instancetype)layerContentFactoryWithLayerClient:(LYRClient *)layerClient;
{
    return [[self alloc] initWithLayerClient:layerClient];
}

- (id)initWithLayerClient:(LYRClient *)layerClient
{
    self = [super init];
    if (self) {
        _layerClient = layerClient;
    }
    return self;
}

- (LYRConversation *)newConversationsWithParticipants:(NSSet *)participants
{
    LYRConversation *conversation = [self.layerClient newConversationWithParticipants:participants options:nil error:nil];
    [self sendMessagesToConversation:conversation number:10];
    return conversation;
}

- (void)sendMessagesToConversation:(LYRConversation *)conversation number:(NSUInteger)number
{
    for (int i = 0; i < number; i++) {
        LYRMessagePart *part = [LYRMessagePart messagePartWithText:ATLTestMessageText];
        NSError *error;
        LYRMessage *message = [self.layerClient newMessageWithParts:@[part] options:@{LYRMessageOptionsPushNotificationAlertKey: @"Test Push"} error:nil];
        [conversation sendMessage:message error:&error];
        if (error) {
            NSLog(@"Error sending messages");
        }
    }
}

@end