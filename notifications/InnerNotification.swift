import Foundation
/**
 Stores info about notification item
 */
public class InnerNotification: NSObject {
    public static let titleKey = "_t"
    public static let detailTextKey = "_dt"
    public static let moduleIdKey = "module_id"
    public static let uniqueIdKey = "_uid"
    public static let userInfoKey = "_info"
    public static let timestampKey = "_time"
    /**
     Stores title text
     */
    public var title: String
    /**
     Stores detail text
     */
    public var detailText: String
    /**
     Module id
     */
    public var moduleId: String
    /**
     Unique id in case it was scheduled as local notification
     */
    public var uniqueId: String?
    /**
     Original userInfo
     */
    public var userInfo: [AnyHashable : Any]?
    /**
     Timestamp of create date
     */
    public let timestamp: TimeInterval?//optional because could be nil for notifications from previous version
    
    /**
     Initialisation method
     - Parameters:
     - title: string
     - detailText: string
     */
    init(title: String, detailText: String, moduleId: String, userInfo: [AnyHashable : Any]? = nil, timestamp: TimeInterval = Date().timeIntervalSince1970) {
        self.title = title
        self.detailText = detailText
        self.moduleId = moduleId
        self.userInfo = userInfo
        self.timestamp = timestamp
        super.init()
    }
}

public extension InnerNotification {
    
    /**
     Helper method to convert non-property object to Dictionary
     - Returns: Dictionary representation
     */
    public func convertIntoDictionary() -> [String : String] {
        var dictionary = [String : String]()
        dictionary[InnerNotification.titleKey] = title
        dictionary[InnerNotification.detailTextKey] = detailText
        dictionary[InnerNotification.moduleIdKey] = moduleId
        if let uid = uniqueId {
            dictionary[InnerNotification.uniqueIdKey] = uid
        }
        if let info = userInfo {
            dictionary[InnerNotification.userInfoKey] = convertNotificationUserInfoToString(info)
        }
        dictionary[InnerNotification.timestampKey] = "\(timestamp ?? 0)"
        return dictionary
    }
    
    /**
     Helper method to convert Dictionary object to InnerNotification object
     - Returns: InnerNotification representation object
     - Parameters:
     - dictionary: Dictionary object
     */
    public static func convertIntoInnerNotification(from dictionary: [String : String]) -> InnerNotification {
        let title = dictionary[InnerNotification.titleKey] ?? ""
        let detailText = dictionary[InnerNotification.detailTextKey] ?? ""
        let moduleId = dictionary[InnerNotification.moduleIdKey] ?? ""
        let uniqueId = dictionary[InnerNotification.uniqueIdKey]
        var userInfo: [AnyHashable : Any]?
        if let infoString = dictionary[InnerNotification.userInfoKey] {
            userInfo = convertStringToNotificationUserInfo(infoString)
        }
        var timestamp: TimeInterval = 0
        if let string = dictionary[InnerNotification.timestampKey] {
            timestamp = TimeInterval(string) ?? 0
        }
        let innerNotification = InnerNotification(title: title, detailText: detailText, moduleId: moduleId, userInfo: userInfo, timestamp: timestamp)
        innerNotification.uniqueId = uniqueId
        return innerNotification
    }
    
    /**
     Converts notification user info into string to be stored in kvStorage
     - Returns: String representation object
     - Parameters:
     - userInfo: Dictionary object
     */
    private func convertNotificationUserInfoToString(_ userInfo: [AnyHashable : Any]) -> String {
        var string = ""
        var keyValuePairs: [String] = []
        if let aps = userInfo["aps"] as? [AnyHashable : Any], let alert = aps["alert"] as? String {
            keyValuePairs.append("alert=" + alert)
        }
        for key in userInfo.keys {
            if let value = userInfo[key] {
                if value is String {
                    keyValuePairs.append((key as! String) + "=" + (value as! String))
                }
            }
        }
        string = keyValuePairs.joined(separator: "/")
        return string
    }
    
    /**
     Converts string into notification user info from kvStorage
     - Returns: Dictionary representation object
     - Parameters:
     - string: String object
     */
    static private func convertStringToNotificationUserInfo(_ string: String) -> [AnyHashable : Any] {
        var userInfo: [AnyHashable : Any] = [:]
        let keyValuePairs = string.components(separatedBy: "/")
        for pair in keyValuePairs {
            if pair.range(of:"=") != nil {
                let components = pair.components(separatedBy: "=")
                let key = components.first!
                if key == "alert" {
                    userInfo["aps"] = ["alert":components[1]]
                } else {
                    userInfo[key] = components[1]
                }
            }
        }
        return userInfo
    }
    
}
