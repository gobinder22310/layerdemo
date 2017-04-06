//
//  ATLMConversationDetailViewController.m
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

#import "ATLMConversationDetailViewController.h"
#import "ATLMUtilities.h"
#import "ATLMCenterTextTableViewCell.h"
#import "ATLMInputTableViewCell.h"
#import <SVProgressHUD/SVProgressHUD.h>
#import "ATLMParticipantTableViewController.h"
#import "LYRIdentity+ATLParticipant.h"

typedef NS_ENUM(NSInteger, ATLMConversationDetailTableSection) {
    ATLMConversationDetailTableSectionMetadata,
    ATLMConversationDetailTableSectionParticipants,
    ATLMConversationDetailTableSectionLocation,
    ATLMConversationDetailTableSectionLeave,
    ATLMConversationDetailTableSectionCount,
};

typedef NS_ENUM(NSInteger, ATLMActionSheetTag) {
    ATLMActionSheetBlockUser,
    ATLMActionSheetLeaveConversation,
};

@interface ATLMConversationDetailViewController () <ATLParticipantTableViewControllerDelegate, UITextFieldDelegate, UIActionSheetDelegate>

@property (nonatomic) LYRConversation *conversation;
@property (nonatomic) NSMutableArray *participants;
@property (nonatomic) NSIndexPath *indexPathToRemove;
@property (nonatomic) CLLocationManager *locationManager;

@end

@implementation ATLMConversationDetailViewController

NSString *const ATLMConversationDetailViewControllerTitle = @"Details";
NSString *const ATLMConversationDetailTableViewAccessibilityLabel = @"Conversation Detail Table View";
NSString *const ATLMAddParticipantsAccessibilityLabel = @"Add Participants";
NSString *const ATLMConversationNamePlaceholderText = @"Enter Conversation Name";
NSString *const ATLMConversationMetadataNameKey = @"conversationName";

NSString *const ATLMShareLocationText = @"Send My Current Location";
NSString *const ATLMDeleteConversationText = @"Delete Conversation";
NSString *const ATLMLeaveConversationText = @"Leave Conversation";

static NSString *const ATLMParticipantCellIdentifier = @"ATLMParticipantCellIdentifier";
static NSString *const ATLMDefaultCellIdentifier = @"ATLMDefaultCellIdentifier";
static NSString *const ATLMInputCellIdentifier = @"ATLMInputCell";
static NSString *const ATLMCenterContentCellIdentifier = @"ATLMCenterContentCellIdentifier";

static NSString *const ATLMPlusIconName = @"AtlasResource.bundle/plus";
static NSString *const ATLMBlockIconName = @"AtlasResource.bundle/block";

+ (instancetype)conversationDetailViewControllerWithConversation:(LYRConversation *)conversation withLayerController:(ATLMLayerController *)layerController
{
    return [[self alloc] initWithConversation:conversation withLayerController:layerController];
}

- (id)initWithConversation:(LYRConversation *)conversation withLayerController:(ATLMLayerController *)layerController
{
    self = [super initWithStyle:UITableViewStyleGrouped];
    if (self) {
        _conversation = conversation;
        _layerController = layerController;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title = ATLMConversationDetailViewControllerTitle;
    self.tableView.sectionHeaderHeight = 48.0f;
    self.tableView.sectionFooterHeight = 0.0f;
    self.tableView.rowHeight = 48.0f;
    self.tableView.accessibilityLabel = ATLMConversationDetailTableViewAccessibilityLabel;
    [self.tableView registerClass:[ATLMCenterTextTableViewCell class] forCellReuseIdentifier:ATLMCenterContentCellIdentifier];
    [self.tableView registerClass:[ATLParticipantTableViewCell class] forCellReuseIdentifier:ATLMParticipantCellIdentifier];
    [self.tableView registerClass:[ATLMInputTableViewCell class] forCellReuseIdentifier:ATLMInputCellIdentifier];
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:ATLMDefaultCellIdentifier];
    
    self.participants = [self filteredParticipants];
    
    [self configureAppearance];
    [self registerNotificationObservers];
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return ATLMConversationDetailTableSectionCount;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    switch (section) {
        case ATLMConversationDetailTableSectionMetadata:
            return 1;
            
        case ATLMConversationDetailTableSectionParticipants:
            return self.participants.count + 1; // Add a row for the `Add Participant` cell.
            
        case ATLMConversationDetailTableSectionLocation:
            return 1;
            
        case ATLMConversationDetailTableSectionLeave:
            return 1;
            
        default:
            return 0;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    switch (indexPath.section) {
        case ATLMConversationDetailTableSectionMetadata: {
            ATLMInputTableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:ATLMInputCellIdentifier forIndexPath:indexPath];
            [self configureConversationNameCell:cell];
            return cell;
        }
            
        case ATLMConversationDetailTableSectionParticipants:
            if (indexPath.row < self.participants.count) {
                ATLParticipantTableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:ATLMParticipantCellIdentifier forIndexPath:indexPath];
                [self configureParticipantCell:cell atIndexPath:indexPath];
                return cell;
            } else {
                UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:ATLMDefaultCellIdentifier forIndexPath:indexPath];
                cell.textLabel.attributedText = [self addParticipantAttributedString];
                cell.accessibilityLabel = ATLMAddParticipantsAccessibilityLabel;
                cell.imageView.image = [UIImage imageNamed:ATLMPlusIconName];
                return cell;
            }
            
        case ATLMConversationDetailTableSectionLocation: {
            UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:ATLMDefaultCellIdentifier forIndexPath:indexPath];
            cell.textLabel.text = ATLMShareLocationText;
            cell.textLabel.textColor = ATLBlueColor();
            cell.textLabel.font = [UIFont systemFontOfSize:17];
            return cell;
        }
            
        case ATLMConversationDetailTableSectionLeave: {
            ATLMCenterTextTableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:ATLMCenterContentCellIdentifier];
            cell.centerTextLabel.textColor = ATLRedColor();
            cell.centerTextLabel.text = self.conversation.participants.count > 2 ? ATLMLeaveConversationText : ATLMDeleteConversationText;
            return cell;
        }
            
        default:
            return nil;
    }
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    switch ((ATLMConversationDetailTableSection)section) {
        case ATLMConversationDetailTableSectionMetadata:
            return @"Conversation Name";
            
        case ATLMConversationDetailTableSectionParticipants:
            return @"Participants";
            
        case ATLMConversationDetailTableSectionLocation:
            return @"Location";
            
        default:
            return nil;
    }
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == ATLMConversationDetailTableSectionParticipants) {
        // Prevent removal in 1 to 1 conversations.
        if (self.conversation.participants.count < 3) {
            return NO;
        }
        BOOL canEdit = indexPath.row < self.participants.count;
        return canEdit;
    }
    return NO;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    self.indexPathToRemove = indexPath;
    NSString *blockString = [self blockedParticipantAtIndexPath:indexPath] ? @"Unblock" : @"Block";
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:@"Remove" otherButtonTitles:blockString, nil];
    actionSheet.tag = ATLMActionSheetBlockUser;
    [actionSheet showInView:self.view];
}


#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    switch ((ATLMConversationDetailTableSection)indexPath.section) {
        case ATLMConversationDetailTableSectionParticipants:
            if (indexPath.row == self.participants.count) {
                [self presentParticipantPicker];
            }
            break;
            
        case ATLMConversationDetailTableSectionLocation:
            [self shareLocation];
            break;
            
        case ATLMConversationDetailTableSectionLeave:
            [self confirmLeaveConversation];
            break;
            
        default:
            break;
    }
}

- (NSArray *)tableView:(UITableView *)tableView editActionsForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewRowAction *removeAction = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleDefault title:@"Remove" handler:^(UITableViewRowAction *action, NSIndexPath *indexPath) {
        [self removeParticipantAtIndexPath:indexPath];
    }];
    removeAction.backgroundColor = ATLGrayColor();
    
    NSString *blockString = [self blockedParticipantAtIndexPath:indexPath] ? @"Unblock" : @"Block";
    UITableViewRowAction *blockAction = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleDefault title:blockString handler:^(UITableViewRowAction *action, NSIndexPath *indexPath) {
        [self blockParticipantAtIndexPath:indexPath];
    }];
    blockAction.backgroundColor = ATLRedColor();
    return @[removeAction, blockAction];
}

#pragma mark - Cell Configuration

- (void)configureConversationNameCell:(ATLMInputTableViewCell *)cell
{
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.textField.delegate = self;
    cell.textField.clearButtonMode = UITextFieldViewModeWhileEditing;
    cell.guideText = @"Name:";
    cell.placeHolderText = @"Enter Conversation Name";
    NSString *conversationName = [self.conversation.metadata valueForKey:ATLMConversationMetadataNameKey];
    cell.textField.text = conversationName;
}

- (void)configureParticipantCell:(ATLParticipantTableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath
{
     id<ATLParticipant> participant = [self.participants objectAtIndex:indexPath.row];
    if ([self blockedParticipantAtIndexPath:indexPath]) {
        cell.accessoryView.accessibilityLabel = @"Blocked";
        cell.accessoryView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:ATLMBlockIconName]];
    }
    [cell presentParticipant:participant withSortType:ATLParticipantPickerSortTypeFirstName shouldShowAvatarItem:YES];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
}

- (NSAttributedString *)addParticipantAttributedString
{
    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:@"Add Participant"];
    NSRange range = NSMakeRange(0, attributedString.length);
    [attributedString addAttribute:NSForegroundColorAttributeName value:ATLBlueColor() range:range];
    [attributedString addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:17]  range:range];
    return attributedString;
}

#pragma mark - UIActionSheetDelegate

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (actionSheet.tag == ATLMActionSheetBlockUser) {
        if (buttonIndex == actionSheet.destructiveButtonIndex) {
            [self removeParticipantAtIndexPath:self.indexPathToRemove];
        } else if (buttonIndex == actionSheet.firstOtherButtonIndex) {
            [self blockParticipantAtIndexPath:self.indexPathToRemove];
        } else if (buttonIndex == actionSheet.cancelButtonIndex) {
            [self setEditing:NO animated:YES];
        }
        self.indexPathToRemove = nil;
    } else if (actionSheet.tag == ATLMActionSheetLeaveConversation) {
        if (buttonIndex == actionSheet.destructiveButtonIndex) {
            self.conversation.participants.count > 2 ? [self leaveConversation] : [self deleteConversation];
        }
    }
}
 
#pragma mark - Actions

- (void)presentParticipantPicker
{
    LYRQuery *query = [LYRQuery queryWithQueryableClass:[LYRIdentity class]];
    query.predicate = [LYRPredicate predicateWithProperty:@"userID" predicateOperator:LYRPredicateOperatorIsNotIn value:[self.conversation.participants valueForKey:@"userID"]];
    NSError *error;
    NSOrderedSet *identities = [self.layerController.layerClient executeQuery:query error:&error];
    
    ATLMParticipantTableViewController  *controller = [ATLMParticipantTableViewController participantTableViewControllerWithParticipants:identities.set sortType:ATLParticipantPickerSortTypeFirstName];
    controller.delegate = self;
    controller.allowsMultipleSelection = NO;
    
    UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:controller];
    [self.navigationController presentViewController:navigationController animated:YES completion:nil];
}

- (void)removeParticipantAtIndexPath:(NSIndexPath *)indexPath
{
    id<ATLParticipant>participant = self.participants[indexPath.row];
    NSError *error;
    BOOL success = [self.conversation removeParticipants:[NSSet setWithObject:[participant userID]] error:&error];
    if (!success) {
        ATLMAlertWithError(error);
        return;
    }
    [self.participants removeObjectAtIndex:indexPath.row];
    [self.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationLeft];
}

- (void)blockParticipantAtIndexPath:(NSIndexPath *)indexPath
{
    id<ATLParticipant>participant = [self.participants objectAtIndex:indexPath.row];
    LYRPolicy *policy =  [self blockedParticipantAtIndexPath:indexPath];
    if (policy) {
        NSError *error;
        [self.layerController.layerClient removePolicies:[NSSet setWithObject:policy] error:&error];
        if (error) {
            ATLMAlertWithError(error);
            return;
        }
    } else {
        [self blockParticipantWithIdentifier:[participant userID]];
    }
    [self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
}

- (void)blockParticipantWithIdentifier:(NSString *)identitifer
{
    LYRPolicy *blockPolicy = [LYRPolicy policyWithType:LYRPolicyTypeBlock];
    blockPolicy.sentByUserID = identitifer;
    
    NSError *error;
    [self.layerController.layerClient addPolicies:[NSSet setWithObject:blockPolicy] error:&error];
    if (error) {
        ATLMAlertWithError(error);
        return;
    }
    [SVProgressHUD showSuccessWithStatus:@"Participant Blocked"];
}

- (void)shareLocation
{
    [self.detailDelegate conversationDetailViewControllerDidSelectShareLocation:self];
}

- (void)confirmLeaveConversation
{
    NSString *destructiveButtonTitle = self.conversation.participants.count > 2 ? ATLMLeaveConversationText : ATLMDeleteConversationText;
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:destructiveButtonTitle otherButtonTitles:nil];
    actionSheet.tag = ATLMActionSheetLeaveConversation;
    [actionSheet showInView:self.view];
}

- (void)leaveConversation
{
    NSError *error;
    BOOL success = [self.conversation leave:&error];
    if (!success) {
        ATLMAlertWithError(error);
        return;
    } else {
        [self.navigationController popToRootViewControllerAnimated:YES];
    }
}

- (void)deleteConversation
{
    NSError *error;
    BOOL success = [self.conversation delete:LYRDeletionModeAllParticipants error:&error];
    if (!success) {
        ATLMAlertWithError(error);
        return;
    } else {
        [self.navigationController popToRootViewControllerAnimated:YES];
    }
}

#pragma mark - ATLParticipantTableViewControllerDelegate

- (void)participantTableViewController:(ATLParticipantTableViewController *)participantTableViewController didSelectParticipant:(id<ATLParticipant>)participant
{
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
    
    [self.participants addObject:participant];
    NSError *error;
    BOOL success = [self.conversation addParticipants:[NSSet setWithObject:participant.userID] error:&error];
    if (!success) {
        ATLMAlertWithError(error);
        return;
    }
    [self.tableView reloadData];
}

- (void)participantTableViewController:(ATLParticipantTableViewController *)participantTableViewController didSearchWithString:(NSString *)searchText completion:(void (^)(NSSet *))completion
{
    LYRQuery *query = [LYRQuery queryWithQueryableClass:[LYRIdentity class]];
    query.predicate = [LYRPredicate predicateWithProperty:@"displayName" predicateOperator:LYRPredicateOperatorLike value:[NSString stringWithFormat:@"%%%@%%", searchText]];
    [self.layerController.layerClient executeQuery:query completion:^(NSOrderedSet<id<LYRQueryable>> * _Nullable resultSet, NSError * _Nullable error) {
        if (resultSet) {
            completion(resultSet.set);
        } else {
            completion([NSSet set]);
        }
    }];
}

#pragma mark - Conversation Configuration

- (void)switchToConversationForParticipants
{
    NSSet *participantIdentifiers = [self.participants valueForKey:@"userID"];
    LYRConversation *conversation = [self.layerController existingConversationForParticipants:participantIdentifiers];
    if (!conversation) {
        conversation = [self.layerController.layerClient newConversationWithParticipants:participantIdentifiers options:nil error:nil];
    }
    [self.detailDelegate conversationDetailViewController:self didChangeConversation:conversation];
    self.conversation = conversation;
}

- (LYRPolicy *)blockedParticipantAtIndexPath:(NSIndexPath *)indexPath
{
    NSOrderedSet *policies = self.layerController.layerClient.policies;
    id<ATLParticipant>participant = self.participants[indexPath.row];
    NSPredicate *policyPredicate = [NSPredicate predicateWithFormat:@"SELF.sentByUserID = %@", [participant userID]];
    NSOrderedSet *filteredPolicies = [policies filteredOrderedSetUsingPredicate:policyPredicate];
    if (filteredPolicies.count) {
        return filteredPolicies.firstObject;
    } else {
        return nil;
    }
}

#pragma mark - UITextFieldDelegate

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    NSString *title = [self.conversation.metadata valueForKey:ATLMConversationMetadataNameKey];
    if (![textField.text isEqualToString:title]) {
        [self.conversation setValue:textField.text forMetadataAtKeyPath:ATLMConversationMetadataNameKey];
    }
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if (textField.text.length > 0) {
        [self.conversation setValue:textField.text forMetadataAtKeyPath:ATLMConversationMetadataNameKey];
    } else {
        [self.conversation deleteValueForMetadataAtKeyPath:ATLMConversationMetadataNameKey];
    }
    [textField resignFirstResponder];
    return YES;
}

#pragma mark - Notification Handlers

- (void)conversationMetadataDidChange:(NSNotification *)notification
{
    if (!self.conversation) return;
    if (!notification.object) return;
    if (![notification.object isEqual:self.conversation]) return;
    
    NSIndexPath *nameIndexPath = [NSIndexPath indexPathForRow:0 inSection:ATLMConversationDetailTableSectionMetadata];
    ATLMInputTableViewCell *nameCell = (ATLMInputTableViewCell *)[self.tableView cellForRowAtIndexPath:nameIndexPath];
    if (!nameCell) return;
    if ([nameCell.textField isFirstResponder]) return;
    
    [self configureConversationNameCell:nameCell];
}

- (void)conversationParticipantsDidChange:(NSNotification *)notification
{
    if (!self.conversation) return;
    if (!notification.object) return;
    if (![notification.object isEqual:self.conversation]) return;
    
    [self.tableView beginUpdates];
    
    NSSet *existingParticipants = [NSSet setWithArray:self.participants];
    
    NSMutableArray *deletedIndexPaths = [NSMutableArray new];
    NSMutableIndexSet *deletedIndexSet = [NSMutableIndexSet new];
    NSMutableSet *deletedParticipants = [existingParticipants mutableCopy];
    [deletedParticipants minusSet:self.conversation.participants];
    for (LYRIdentity *deletedIdentity in deletedParticipants) {
        NSUInteger row = [self.participants indexOfObject:deletedIdentity];
        [deletedIndexSet addIndex:row];
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:row inSection:ATLMConversationDetailTableSectionParticipants];
        [deletedIndexPaths addObject:indexPath];
    }
    [self.participants removeObjectsAtIndexes:deletedIndexSet];
    [self.tableView deleteRowsAtIndexPaths:deletedIndexPaths withRowAnimation:UITableViewRowAnimationAutomatic];
    
    NSMutableArray *insertedIndexPaths = [NSMutableArray new];
    NSMutableSet *insertedParticipants = [self.conversation.participants mutableCopy];
    [insertedParticipants removeObject:self.layerController.layerClient.authenticatedUser];
    [insertedParticipants minusSet:existingParticipants];
    for (LYRIdentity *identity in insertedParticipants) {
        [self.participants addObject:identity];
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:self.participants.count - 1 inSection:ATLMConversationDetailTableSectionParticipants];
        [insertedIndexPaths addObject:indexPath];
    }
    [self.tableView insertRowsAtIndexPaths:insertedIndexPaths withRowAnimation:UITableViewRowAnimationAutomatic];
    [self.tableView endUpdates];
}

#pragma mark - Helpers

- (NSMutableArray *)filteredParticipants
{
    NSMutableArray *participants = [[self.conversation.participants allObjects] mutableCopy];
    [participants removeObject:self.layerController.layerClient.authenticatedUser];
    return participants;
}

- (void)configureAppearance
{
    [[ATLParticipantTableViewCell appearanceWhenContainedIn:[self class], nil] setTitleColor:[UIColor blackColor]];
    [[ATLParticipantTableViewCell appearanceWhenContainedIn:[self class], nil] setTitleFont:[UIFont systemFontOfSize:17]];
    [[ATLParticipantTableViewCell appearanceWhenContainedIn:[self class], nil] setBoldTitleFont:[UIFont systemFontOfSize:17]];
    [[ATLAvatarImageView appearanceWhenContainedIn:[ATLParticipantTableViewCell class], nil] setAvatarImageViewDiameter:32];
}

- (void)registerNotificationObservers
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(conversationMetadataDidChange:) name:ATLMConversationMetadataDidChangeNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(conversationParticipantsDidChange:) name:ATLMConversationParticipantsDidChangeNotification object:nil];
}

@end
