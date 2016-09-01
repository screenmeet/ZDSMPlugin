# JSQMessagesViewController

## Date Cloned: August 22, 2016
## Cloned Version: [7.3.4](https://github.com/jessesquires/JSQMessagesViewController/releases/tag/7.3.4)

## Modified Files:

**JSQMessagesCollectionViewDataSource.h**
- added new data source:

`- (NSURL *)collectionView:(JSQMessagesCollectionView *)collectionView avatarImageUrlForItemAtIndexPath:(NSIndexPath *)indexPath;`

**JSQMessagesViewController.m**

- in the UICollectionViewDataSource implementation `collectionView:cellForItemAtIndexPath:`:
	- used the added data source `collectionView:avatarImageUrlForItemAtIndexPath` to support asynchronous image loading for avatars.
	- changed check for `bubbleTopLabelInset` to be `needsAvatar` instead of `avatarImageDataSource` to identify the it's value. A value of 40.0f instead of 60.0f will be used if `needsAvatar` is `true`.

**JSQMessagesCollectionViewCellIncoming.xib**
**JSQMessagesCollectionViewCellOutgoing.xib**
- modified `avatarContainerView` autolayout to always stick it's top to `messageBubbleTopLabel` bottom.
- made `avatarImageView` a subclass of `SMCircularImageView` to automatically make imageView circular.

**JSQMessagesBubblesSizeCalculator.m**
- set `_minimumBubbleWidth` to be a fixed value of 20.0f.

**JSQSystemSoundPlayer+JSQMessages.m**
- updated method call to play sound from `playAlertSoundWithFilename:fileExtension` to `playAlertSoundWithFilename:fileExtension:completion` and `playSoundWithFilename:fileExtension` to `playSoundWithFilename:fileExtension:completion`.