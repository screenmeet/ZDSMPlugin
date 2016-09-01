# ZDSMPlugin

[![Version](https://img.shields.io/cocoapods/v/ZDSMPlugin.svg?style=flat)](http://cocoapods.org/pods/ZDSMPlugin)
[![License](https://img.shields.io/cocoapods/l/ZDSMPlugin.svg?style=flat)](http://cocoapods.org/pods/ZDSMPlugin)
[![Platform](https://img.shields.io/cocoapods/p/ZDSMPlugin.svg?style=flat)](http://cocoapods.org/pods/ZDSMPlugin)

## Example

To run the example project, clone the repo, and run `pod install` from the Example directory first.

## Requirements

Please add the dependencies in your pod file:

```ruby
pod 'JSQSystemSoundPlayer', '4.4.0'
pod 'MBProgressHUD', '1.0'
pod 'SDWebImage', '3.7'
pod 'ZendeskSDK'
pod 'ZDCChat', '1.2.1.1'
```

## Installation

ZDSMPlugin is note yet available through [CocoaPods](http://cocoapods.org). 

To install it, copy the "ZDSMPlugin" folder to your project and update the framewrok search paths in your build settings if needed.

Include the `ScreenMeetSDK.framework` inside the target's Embedded Binaries.

Enable the embedded swift code option.

`Project.xcodeproject -> Target -> Build Settings -> Embedded Content Contains Swift Code -> Yes`

## Usage

Initialize the `[ZDSMPluginManager sharedManager]`.

To show show the chat UI:

Either present or show the view controller
`
[[ZDSMPluginManager sharedManager] messagesVC]
`

The `ZDSMPluginManager` contains the object of the SMMessagesViewController

`@property (strong, nonatomic) SMMessagesViewController *messagesVC;`

## Authors

Eugene Abovsky: eugene@projector.is

Adrian Cayaco: acayaco@stratpoint.com

Mylene Bayan: mbayan@stratpoint.com

## License

ZDSMPlugin is available under the MIT license. See the LICENSE file for more info.
