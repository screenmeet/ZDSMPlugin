//
//  ScreenMeet.swift
//  ScreenMeet
//
//  Created by IMakhnyk on 5/23/16.
//  Copyright © 2016 Projector. All rights reserved.
//

import Foundation
import UIKit

/// Main ScreenMeet class to work with ScreenMeet SDK
public class ScreenMeet: NSObject {

    let apiKey: String
    let environment: EnvironmentType
    
    private static var instance: ScreenMeet! = nil
    
    /**
     Initialize shared instance of ScreenMeet
     - Parameter apiKey: A string idetifier of application that uses ScreenMeet
     - Parameter environment: Enum [SANDBOX or PRODUCTION]. Defualt is SANDBOX
     */
    public static func initSharedInstance(apiKey: String, environment: EnvironmentType = .SANDBOX) {
        if (instance != nil) {
            instance.logoutUser()
        }
        instance = ScreenMeet(apiKey: apiKey, environment: environment)
    }
    
    /**
     - Returns: Shared instance of ScreenMeet
     */
    public static func sharedInstance() -> ScreenMeet! {
        if (instance == nil) {
            print("ScreenMeet sharedInstance is not initialized. Use ScreenMeet.initSharedInstance method to init sharedInstance")
        }
        return instance
    }
    
    public let socketService = SocketService()

    /**
     Initializes a new ScreenMeet with the provided apiKey and environment.
     
     - Parameters:
        - apiKey: A string idetifier of application that uses ScreenMeet
        - environment: Enum [SANDBOX or PRODUCTION]. Defualt is SANDBOX
     
     - Returns: New ScreenMeet instance
     */
    public init(apiKey: String, environment: EnvironmentType = .SANDBOX) {
        self.apiKey = apiKey
        self.environment = environment
        super.init()
        socketService.root = self
        BackendClient.root = self
        BackendClient.getWebsiteConfig()
        BackendClient.initAnalyticSender()
    }
    
    
    /**
     Authenticate the user with either a username/password. It returns a success or failure state to the callback.
     - Parameters:
        - username: Username
        - password: Password
        - callback: Is called when operation is finished with result in status variable
     */
    public func authenticate(username: String, password: String, callback: (status: CallStatus) -> Void) {
        BackendClient.loginUser(username, password: password, bearer: nil, callback: {status in
            if (status == .SUCCESS) {
                //use default stream config
                self.socketService.setConfig(MeetingConfig(), callback: {s in
                    dispatch_async(dispatch_get_main_queue()) {
                        callback(status: s)
                    }
                })
            } else {
                dispatch_async(dispatch_get_main_queue()) {
                callback(status: status)
                }
            }
        })
    }
    
    /**
     Authenticate the user with a bearer token. It will return a success or failure state to the callback.
     - Parameters:
        - bearerToken: Bearer token
        - callback: Is called when operation is finished with result in status variable
     */
    public func authenticate(bearerToken: String, callback: (status: CallStatus) -> Void) {
        BackendClient.loginUser(nil, password: nil, bearer: bearerToken, callback: {status in
            if (status == .SUCCESS) {
                //use default stream config
                self.socketService.setConfig(MeetingConfig(), callback: {s in
                    dispatch_async(dispatch_get_main_queue()) {
                        callback(status: s)
                    }
                })
            } else {
                dispatch_async(dispatch_get_main_queue()) {
                    callback(status: status)
                }
            }
        })
    }
    
    /**
     - Returns: Bearer token of authenticated user or nil is user is not authenticated
     */
    public func getBearerToken() -> String! {
        if (BackendClient.user == nil) || (BackendClient.user["bearer"] == nil) {
            return nil
        }
        return BackendClient.user["bearer"] as! String!
    }
    
    /**
     Create user with specified username and password
     - Parameters:
        - username: Username of user
        - password: Password of user
        - callback: Is called when operation is finished with result in status variable
     */
    public func createUser(email: String, username: String, password: String, callback: (status: CallStatus) -> Void) {
        BackendClient.registerUser(username, email: email, password: password, callback: {status in
            if (status == .SUCCESS) {
                //use default stream config
                self.socketService.setConfig(MeetingConfig(), callback: {s in
                    dispatch_async(dispatch_get_main_queue()) {
                        callback(status: s)
                    }
                })
            } else {
                dispatch_async(dispatch_get_main_queue()) {
                    callback(status: status)
                }
            }
        })
    }
    
    /**
     Update user profile: email, username, password. User must be authenticated, otherwise an error will be produced. Please note that if the password is changed, the bearer token will be updated.
     - Parameters:
        - email: New email value. Use nil in case you dont need to update email value.
        - username: New username value. Use nil in case you dont need to update username value.
        - password: New password value. Use nil in case you dont need to update password value.
        - callback: Is called when operation is finished with result in status variable
     */
    public func updateUser(email: String! = nil, username: String! = nil, password: String! = nil, callback: (status: CallStatus) -> Void) {
        if (!isUserLoggedIn()) { print("Error: User must be authenticated"); callback(status: .AUTH_ERROR) }
        
        BackendClient.updateProfile(email, name: username, password: password, callback: {status in
            dispatch_async(dispatch_get_main_queue()) {
                callback(status: status)
            }
        })
    }
    
    /**
     - Returns: Is user authenticated
     */
    public func isUserLoggedIn() -> Bool {
        return getBearerToken() != nil
    }
    
    
    /**
     Logout user. If current stream is in progress stops stream.
     */
    public func logoutUser() {
        if (!isUserLoggedIn()) { print("Error: User must be authenticated"); return }
        
        if (getStreamState() != .STOPPED) {
            stopStream()
        }
        BackendClient.logout()
    }
    
    /**
     Return ScreenMeet URL to reset password of user by email
     - Parameter email: Email to reset password
     - Returns: Url to reset password of user
     */
    public func getResetPasswordURL(email: String) -> String {
        let baseUrl: String = (BackendClient.webConfig["default_brand"]!["url_prefix"] as? String)!
        let url = "\(baseUrl)/#/reset_password?email=\(email)"
        return url
    }
    
    /**
     - Returns: ScreenMeet room name of the user. User must be authenticated.
     */
    public func getRoomName() -> String! {
        if (!isUserLoggedIn()) { print("Error: User must be authenticated"); return nil }

        return BackendClient.room["room_id"] as! String!
    }
    
    /**
     - Returns: Unique User identifier
     */
    public func getUserId() -> String! {
        if (!isUserLoggedIn()) { print("Error: User must be authenticated"); return nil }

        return String(BackendClient.user["id"])
    }
    
    /**
     - Returns: Username of authenticated user
     */
    public func getUserName() -> String! {
        if (!isUserLoggedIn()) { print("Error: User must be authenticated"); return nil }
        
        return BackendClient.user["name"] as! String!
    }
    
    /**
     - Returns: Email of authenticated user
     */
    public func getUserEmail() -> String! {
        if (!isUserLoggedIn()) { print("Error: User must be authenticated"); return nil }
        
        return BackendClient.user["email"] as! String!
    }
    
    /**
     Update the user’s Room name. Alpha-numeric only.
     - Parameters:
        - roomName: New root name
        - callback: Is called when operation is finished with result in status variable
     */
    public func setRoomName(roomName: String, callback: (status: CallStatus) -> Void) {
        if (!isUserLoggedIn()) { print("Error: User must be authenticated"); callback(status: .AUTH_ERROR) }
        
        BackendClient.setRoomName(roomName, callback: {status in
            if (status == .SUCCESS) {
                BackendClient.getInviteText(self.socketService.streamConfig, callback: {s in
                    dispatch_async(dispatch_get_main_queue()) {
                        callback(status: s)
                    }
                })
            } else {
                dispatch_async(dispatch_get_main_queue()) {
                    callback(status: status)
                }
            }
        })
    }

    /**
     Returns the fully qualified ScreenMeet room URL for the user’s meetings. User must be authenticated
     - Parameters:
        - config: Screen share config
        - callback: Is called when operation is finished with result in roomUrl and status variables
     */
    public func getRoomUrl() -> String! {
        if (!isUserLoggedIn()) { print("Error: User must be authenticated"); return nil}
        return BackendClient.inviteText["url"] as! String!
    }
    
    /**
     Shows share invite link dialog.
     Allows you to present a popover from a rect in a particular view.
     `arrowDirections` is a bitfield which specifies what arrow directions are allowed when laying out the popover; for most uses, `UIPopoverArrowDirectionAny` is sufficient.
     */
    public func showInviteMeetingLinkDialog(rect: CGRect, inView: UIView, arrowDirections:UIPopoverArrowDirection,  animated:Bool) {
        ShareTextActivityProvider.showInviteMeetingLinkDialog(rect, inView: inView, arrowDirections: arrowDirections, animated: animated)
    }
        
    public func setMeetingConfig(password: String!, askForName: Bool, callback: (status: CallStatus) -> Void) {
        setMeetingConfig(MeetingConfig(password: password, askForName: askForName), callback: callback)
    }
    
    public func setMeetingConfig(config: MeetingConfig, callback: (status: CallStatus) -> Void) {
        socketService.setConfig(config, callback: callback)
    }
    
    public func getMeetingConfig() -> MeetingConfig {
        return socketService.streamConfig
    }
    
    /**
     Initiate a stream to the user’s room. If successfully started, content of view is now being streamed.
     
     - Parameters:
     - callback: Is called when operation is finished with result in status variables
     */
    public func startStream(callback: (status: CallStatus) -> Void) {
        if (!isUserLoggedIn()) { print("Error: User must be authenticated"); callback(status: .AUTH_ERROR) }
        if (getStreamState() == .STOPPED) {
            socketService.startScreenSharing(callback)
        } else {
            callback(status: .STREAM_ALREADY_STARTED)
        }
    }
    
    /**
     Set UIView source object. Use 'nil' to do full screen capturing
     
     - Parameters:
     - source: UIView that will be used to share
     */
    public func setStreamSource(newSource: UIView!) {
        socketService.setStreamSource(newSource)
    }
    
    /**
     Set UIImage source object. Use 'nil' to do screen capturing
     
     - Parameters:
     - source: UIImage that will be used to share
     */
    public func setStreamImage(image: UIImage!) {
        socketService.screenshoter.setImageToStream(image)
    }
    
    /**
     Pause the active stream. Keeps the meeting open but stops the capturing/streaming.
     */
    public func pauseStream() {
        if (getStreamState() == .ACTIVE) {
            socketService.isPaused = true
            self.notifyAboutStreamStateChange(.PAUSED)
        } else {
            print("Warning: Stream is \(getStreamState()) and cannot be paused")
        }
    }
    
    /**
     Resume a paused stream
     */
    public func resumeStream() {
        if (getStreamState() == .PAUSED) {
            socketService.isPaused = false
            self.notifyAboutStreamStateChange(.ACTIVE)
        } else {
            print("Warning: Stream is \(getStreamState()) and cannot be resumed")
        }
    }

    /**
     Ends the current screen sharing session
     */
    public func stopStream() {
        if (getStreamState() != .STOPPED) {
            socketService.stopScreenSharing()
            self.notifyAboutStreamStateChange(.STOPPED)
        } else {
            print("Warning: Stream is aready stopped (do not need to stop it again)")
        }
    }

    /**
     - Returns: Current stream state [ACTIVE, PAUSED, STOPPED]
     */
    public func getStreamState() -> StreamStateType {
        if (!isUserLoggedIn()) { return .STOPPED}

        if (socketService.screenSharingEnabled){
            if (socketService.isPaused){
                return .PAUSED
            } else {
                return .ACTIVE
            }
        }
        return .STOPPED
    }
    
    /**
     - Returns: count of viewers in the user’s room
     */
    public func getViewerCount() -> Int {
        if (socketService.screenSharingEnabled){
            return socketService.attendeeList.count
        }
        return 0
    }
    
    /**
     - Returns: Array of joined viewers
     */
    public func getViewers() -> [ScreenMeetViewer] {
        var vs: [ScreenMeetViewer] = []
        if (socketService.screenSharingEnabled){
            for a in socketService.attendeeList {
                vs.append(ScreenMeetViewer(data: a))
            }
        }
        return vs
    }
    
    /**
     Kick viewer from stream
     - Parameters:
        - id: ID of viewer to kick
     */
    public func kickViewer(id: String) {
        socketService.kickAttendee(id)
    }
    
    /**
     Set image quality of stream. An integer from 1-100. This sets the compression quality level of the stream, where 1 will use the highest compression possible and result in lower quality and lower bandwidth consumption, while 100 will result in higher quality but more bandwidth consumption. Default is 50. 
     - Parameter
        - quality: Image quality
     */
    public func setQuality(quality: Int = 50) {
        socketService.screenshoter.imageQuality = quality
    }
    
    /**
     - Returns: Image quality of stream
     */
    public func getQuality() -> Int {
        return socketService.screenshoter.imageQuality
    }
    
    var viewerJoinedHandler: ((viewer: ScreenMeetViewer) -> Void)! = nil
    
    /**
     Set on viewer joins handler. Use nil to remove handler
     - Parameters:
        - callback: Is called when new viewer joins stream
     */
    public func onViewerJoined(callback: ((viewer: ScreenMeetViewer) -> Void)!) {
        viewerJoinedHandler = callback
    }

    var viewerLeftHandler: ((viewer: ScreenMeetViewer) -> Void)! = nil

    /**
     Set on viewer lefts handler. Use nil to remove handler
     - Parameters:
        - callback: Is called when new viewer lefts stream
     */
    public func onViewerLeft(callback: ((viewer: ScreenMeetViewer) -> Void)!) {
        viewerLeftHandler = callback
    }

    var streamStateChangeHandler: ((newState: StreamStateType, reason: StreamStateChangedReason) -> Void)! = nil
    
    /**
     Set on stream state changed handler. Use nil to remove handler
     - Parameters:
        - callback: Is called when stream status is changed with reason
     */
    public func onStreamStateChanged(callback: ((newState: StreamStateType, reason: StreamStateChangedReason) -> Void)!) {
        streamStateChangeHandler = callback
    }
    
    func notifyAboutStreamStateChange(newState: StreamStateType, reason: StreamStateChangedReason = .API_CALL){
        if (self.streamStateChangeHandler != nil) {
            dispatch_async(dispatch_get_main_queue()) {
                self.streamStateChangeHandler(newState: newState, reason: reason)
            }
        }
    }

    var imageProc: ((sourceImage: UIImage) -> UIImage)! = nil
    
    /**
     Set image processor to change image before send it stream. Use nil to remove handler. 
     Processor should return new image that will be sent to stream
     - Parameters:
        - callback: Is called when new frame image appears before send it to stream.
     */
    public func setImageProcessor(processor: ((sourceImage: UIImage) -> UIImage)!) {
        imageProc = processor
    }
}

/// ScreenMeet stream configuration
public class MeetingConfig: NSObject {

    /// Password to join stream. Nil is no rassword required
    public let password: String!

    /// Ask for viewer name before join the stream
    public let askForName: Bool
 
    public init(password: String! = nil, askForName: Bool = false) {
        self.password = password
        self.askForName = askForName
    }

}

/// ScreenMeet viewer model
public class ScreenMeetViewer: NSObject {
    
    /// identifier of the viewer
    public let id: String
    
    /// name of the viewer
    public let name: String
    
    /// The delay, in seconds, of how long it’s taking the user’s stream to reach the viewer
    public let latency: Double

    public init(id: String, name: String, latency: Double) {
        self.id = id
        self.name = name
        self.latency = latency
    }
    
    init(data: NSDictionary){
        self.id = data["id"]! as! String
        self.name = data["name"]! as! String
        if let l = data["latency"] as? Double {
            self.latency = l
        } else {
            self.latency = 0
        }
    }
}

/**
    Environment used for streaming.
 
    - SANDBOX: Used for testing applicaton.
    - PRODUCTION: Used for final applicaton.
 */
@objc public enum EnvironmentType: Int {
    ///Used for testing applicaton.
    case SANDBOX
    ///Used for final applicaton
    case PRODUCTION
}

/**
    Stream state
 
    - ACTIVE: Stream is active
    - PAUSED: Stream is paused
    - STOPPED: Stream is stopped
 */
@objc public enum StreamStateType: Int {
    ///Stream is active
    case ACTIVE
    ///Stream is paused
    case PAUSED
    ///Stream is stopped
    case STOPPED
}

/**
    Disconnection reason
 
    - API_CALL: Direct API call
    - SERVER_ERROR: Unexpected server error
    - NETWORK_ERROR: Network connection lost
    - STARTED_ON_OTHER_DEVICE: Stream started from another device
 */
@objc public enum StreamStateChangedReason: Int {
    ///API call
    case API_CALL
    ///Unexpected server error
    case SERVER_ERROR
    ///Network connection lost
    case NETWORK_ERROR
    ///Stream started from another device
    case STARTED_ON_OTHER_DEVICE
}

/**
    Background operation status
 
    - SUCCESS: Operation finished with success
    - ALREADY_HAS_ACCOUNT: User already has account
    - INVALID_EMAIL: Invalid e-mail address
    - DUPLICATE_EMAIL: Duplicate e-mail address
    - INVALID_ROOM_NAME: Invalid room name (eg, illegal characters)
    - DUPLICATE_ROOM_NAME: Duplicate room name (name is already taken)
    - STREAM_ALREADY_STARTED: Stream is already started
    - INVALID_API_KEY: Invalid API key
    - AUTH_ERROR: Authentication error (invalid user auth)
    - NETWORK_ERROR: Unexpected server communication error (network issues, API server issue, etc)
    - INVALID_SUBSCRIPTION: Invalid subscription (user needs to purchase ScreenMeet subscription)
*/
@objc public enum CallStatus: Int {
    ///Operation finished with success
    case SUCCESS
    ///User already has account
    case ALREADY_HAS_ACCOUNT
    ///Invalid e-mail address
    case INVALID_EMAIL
    ///Duplicate e-mail address
    case DUPLICATE_EMAIL
    ///Invalid room name (eg, illegal characters)
    case INVALID_ROOM_NAME
    ///Duplicate room name (name is already taken)
    case DUPLICATE_ROOM_NAME
    ///Stream is already started
    case STREAM_ALREADY_STARTED
    ///Invalid API key
    case INVALID_API_KEY
    ///Authentication error (invalid user auth)
    case AUTH_ERROR
    ///Unexpected server communication error (network issues, API server issue, etc)
    case NETWORK_ERROR
    ///Invalid subscription (user needs to purchase ScreenMeet subscription)
    case INVALID_SUBSCRIPTION
}


