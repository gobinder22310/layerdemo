//
//  ATLMInputTableViewCell.m
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

#import "ATLMInputTableViewCell.h"
#import <Atlas/Atlas.h>

@interface ATLMInputTableViewCell ()

@property (nonatomic) UILabel *guideLabel;
@property (nonatomic) NSLayoutConstraint *guideLabelLeftConstraint;

@end

@implementation ATLMInputTableViewCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        
        _textField = [[UITextField alloc] init];
        _textField.translatesAutoresizingMaskIntoConstraints = NO;
        _textField.returnKeyType = UIReturnKeyDone;
        _textField.font = [UIFont systemFontOfSize:17];
        _textField.textColor = [UIColor darkGrayColor];
        [self.contentView addSubview:_textField];
        
        _guideLabel = [[UILabel alloc] init];
        _guideLabel.translatesAutoresizingMaskIntoConstraints = NO;
        _guideLabel.font = [UIFont systemFontOfSize:17];
        _guideLabel.textColor = [UIColor darkGrayColor];
        [self.contentView addSubview:_guideLabel];
        
        [self configureLayoutConstraints];
    }
    return self;
}

- (void)updateConstraints
{
    self.guideLabelLeftConstraint.constant = self.separatorInset.left;
    [super updateConstraints];
}

- (void)configureLayoutConstraints
{
    [self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:self.guideLabel attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:self.contentView attribute:NSLayoutAttributeCenterY multiplier:1.0 constant:0]];
    self.guideLabelLeftConstraint = [NSLayoutConstraint constraintWithItem:self.guideLabel attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:self.contentView attribute:NSLayoutAttributeLeft multiplier:1.0 constant:self.separatorInset.left];
    [self.contentView addConstraint:self.guideLabelLeftConstraint];
    
    [self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:self.textField attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual toItem:self.contentView attribute:NSLayoutAttributeRight multiplier:1.0 constant:-10]];
    [self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:self.textField attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:self.guideLabel attribute:NSLayoutAttributeRight multiplier:1.0 constant:10]];
    [self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:self.textField attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.contentView attribute:NSLayoutAttributeTop multiplier:1.0 constant:0]];
    [self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:self.textField attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:self.contentView attribute:NSLayoutAttributeHeight multiplier:1.0 constant:0]];
}

- (void)setSeparatorInset:(UIEdgeInsets)separatorInset
{
    [super setSeparatorInset:separatorInset];
    [self setNeedsUpdateConstraints];
}

- (void)setGuideText:(NSString *)guideText
{
    self.guideLabel.text = guideText;
    self.guideLabel.accessibilityLabel = guideText;
}

- (void)setPlaceHolderText:(NSString *)placeHolderText
{
    self.textField.accessibilityLabel = placeHolderText;
    self.textField.placeholder = placeHolderText;
}

@end
