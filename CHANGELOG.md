# Atlas Messenger Changelog

## 0.9.6

### Enhancements
* Tapping on the location bubble now opens a full screen Map view.

## 0.9.5

### Enhancements

* Searching within a conversation list has been updated to integrate with the latest Atlas changes for `ATLConversationListViewController`.
* Added search capabilities within the participants list when adding participants from the conversation details view.

### Bug Fixes

* Fixed an issue where the keyboard would disappear when navigating from the conversation details view back to the conversation view.

## 0.9.4

### Bug Fixes

* Fixes an issue where the app would crash when modifying the participants of a conversation.

## 0.9.3

### Bug Fixes

* Fixed Atlas version string to reflect current installed version.
* Added permissions key for allowing access to Photo Library.

## 0.9.2-pre1

### Enchancements

* Added support for inliner replies to push notifications.

## 0.9.1

### Enchancements

* Added support for video attachments.
* Added support for video playback (renamed `ATLImageViewController` to `ATLMediaViewController`).

## 0.9.0

### Enhancements

1. Added support for new Layer App ID URL format. 

## 0.8.8

### Enhancements

1. Updated code to support the new change notifications in LayerKit v0.13.3.

### Bug Fixes

1. Fixed declared but undefined boolean values in ATLMConversationViewController.m which caused the messages' state to be stuck at 'pending' on random occasions.

## 0.8.7

### New Features 

1. iMessage style address bar with type ahead results
2. iMessage style pariticipant picker
3. Adding or removing a participant from a conversation now switches conversations or creates a new one. 

### Deprecated Features

1. Layer particpant picker with selection indicator
2. Ability to add a user to an existing conversation. 

## 0.8.5

### New Features 

1. Settings View with enhanced controls
2. Conversation Detail View with the ability to add / remove participants and share location
3. Deletion Modes, both local and global…swipe cell to see options
4. Enhanced Connection State…sample app relies entirely on LayerKit’s transport manager
5. Local Notification and Notification removal (turn on in settings)

### Deprecated Features

1. Version View – All info has been moved to settings

### Known Issues

1. Message send issue persist due to stream contention bugs with our service
2. UI Locks…there is a long running process related to the SDK which is locking the UI from time to time. This issue has not yet been resolved. If you run into it, please let me Kevin know. 
3. Conversations with 0 participants bug. The case can occur where conversations have 0 participants. If you attempt to view the detail view for this conversation, the app will crash.
