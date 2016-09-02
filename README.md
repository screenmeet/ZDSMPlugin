# ZDSMPlugin

[![Version](https://img.shields.io/cocoapods/v/ZDSMPlugin.svg?style=flat)](http://cocoapods.org/pods/ZDSMPlugin)
[![License](https://img.shields.io/cocoapods/l/ZDSMPlugin.svg?style=flat)](http://cocoapods.org/pods/ZDSMPlugin)
[![Platform](https://img.shields.io/cocoapods/p/ZDSMPlugin.svg?style=flat)](http://cocoapods.org/pods/ZDSMPlugin)

## Example

To run the example project, clone the repo, and run `pod install` from the Example directory first.

## Requirements

Please add the dependencies in your pod file:

```
pod 'JSQSystemSoundPlayer', '4.4.0'
pod 'MBProgressHUD', '1.0'
pod 'SDWebImage', '3.7'
pod 'ZendeskSDK'
pod 'ZDCChat', '1.2.1.1'
```

## Installation

###ZDSMPlugin is not yet available through [CocoaPods](http://cocoapods.org). 

1. To install it, copy the `ZDSMPlugin` folder to your project and update the framewrok search paths in your build settings if needed.
    1. Be careful with the file referencing and using the "Add files to project" option.
        
    ![alt text](https://github.com/screenmeet/ZDSMPlugin/blob/master/Screenshots/ss01.png)
    2. Make sure the "copy to project if needed" is unchecked if you have the `ZDSMPlugin` folder inside the project folder.
        
   ![alt text](https://github.com/screenmeet/ZDSMPlugin/blob/master/Screenshots/ss02.png)

2. Include the `ScreenMeetSDK.framework` inside the target's Embedded Binaries.
        
    ![alt text](https://github.com/screenmeet/ZDSMPlugin/blob/master/Screenshots/ss04.png)

3. Enable the embedded swift code option.
        
    `Project.xcodeproject -> Target -> Build Settings -> Embedded Content Contains Swift Code -> Yes`
        
    ![alt text](https://github.com/screenmeet/ZDSMPlugin/blob/master/Screenshots/ss03.png)

4. Run `pod init` if you don't have a Podfile yet and add the pod dependencies.

    * Close the .xcproject and open the .xcworkspace if you created a new project and just initiated a new pod.

5. Run `pod install` to add the dependencies.

## Setup

Fill in the keys in the `ZDSMPluginManager.m`

```
SM_API_KEY_SB
SM_API_KEY_PROD

ZENDESK_APP_ID
ZENDESK_URL
ZENDESK_CLIENT_ID
ZENDESK_ACCOUNT_KEY
```

## Usage

Initialize the `[ZDSMPluginManager sharedManager]`.

To show the chat UI:

1. Either present or show the view controller `[[ZDSMPluginManager sharedManager] messagesVC]`

2. Use the method to show the chat window from the Window's RootViewController

    ```
    [[ZDSMPluginManager sharedManager] showChatWindow:^{
        // present from the Window's RootViewController'
    }];
    ```

3. Present/show it from a view Controller

    ```
    [[ZDSMPluginManager sharedManager] showChatWindowFromViewController:self completion:^{
        // present or show from the current view controller
    }];
    ```


## Authors

1. Eugene Abovsky: eugene@projector.is
2. Adrian Cayaco: acayaco@stratpoint.com
3. Mylene Bayan: mbayan@stratpoint.com

## License

ZDSMPlugin is available under the MIT license. See the LICENSE file for more info.
