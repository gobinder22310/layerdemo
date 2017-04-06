//
//  LYRUIConversation.m
//  LayerSample
//
//  Created by Kevin Coleman on 9/2/14.
//  Copyright (c) 2014 Layer, Inc. All rights reserved.
//

#import "LYRUIConversation.h"

@implementation LYRUIConversation

- (NSSet *)testConversations
{
    LYRUIConversation *conversation1 = [super init];
    conversation1.lastMessage = [[[LYRUIMessage messagesWithConversation:conversation1 number:1] allObjects] firstObject];
    conversation1.createdAt = [NSDate date];
    conversation1.participants = [NSSet setWithObjects:[LYRUIUser testUserWithNumber:5], [LYRUIUser testUserWithNumber:1], nil];
    
    LYRUIConversation *conversation2 = [super init];
    conversation2.lastMessage = [[[LYRUIMessage messagesWithConversation:conversation1 number:1] allObjects] firstObject];
    conversation2.createdAt = [NSDate date];
    conversation2.participants = [NSSet setWithObjects:[LYRUIUser testUserWithNumber:5], [LYRUIUser testUserWithNumber:1], nil];
    
    LYRUIConversation *conversation3 = [super init];
    conversation3.lastMessage = [[[LYRUIMessage messagesWithConversation:conversation1 number:1] allObjects] firstObject];
    conversation3.createdAt = [NSDate date];
    conversation3.participants = [NSSet setWithObjects:[LYRUIUser testUserWithNumber:5], [LYRUIUser testUserWithNumber:1], nil];
    
    LYRUIConversation *conversation4 = [super init];
    conversation4.lastMessage = [[[LYRUIMessage messagesWithConversation:conversation1 number:1] allObjects] firstObject];
    conversation4.createdAt = [NSDate date];
    conversation4.participants = [NSSet setWithObjects:[LYRUIUser testUserWithNumber:5], [LYRUIUser testUserWithNumber:1], nil];
    
    LYRUIConversation *conversation5 = [super init];
    conversation5.lastMessage = [[[LYRUIMessage messagesWithConversation:conversation1 number:1] allObjects] firstObject];
    conversation5.createdAt = [NSDate date];
    conversation5.participants = [NSSet setWithObjects:[LYRUIUser testUserWithNumber:5], [LYRUIUser testUserWithNumber:1], nil];
    
    return  [NSSet setWithObjects:conversation1, conversation2, conversation3, conversation4, conversation5, nil];
}

@end
