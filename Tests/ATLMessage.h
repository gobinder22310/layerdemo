//
//  LYRUIMessage.h
//  LayerSample
//
//  Created by Kevin Coleman on 9/2/14.
//  Copyright (c) 2014 Layer, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LYRUIConversation.h"

@interface LYRUIMessage : NSObject

@property (nonatomic, strong) LYRUIConversation *conversation;

@property (nonatomic, strong) NSArray *parts;

@property (nonatomic, strong) NSDate *sentAt;

@property (nonatomic, strong) NSString *sentByUserID;

+ (NSSet *)messagesWithConversation:(LYRUIConversation *)conversation number:(NSUInteger)number;

@end
