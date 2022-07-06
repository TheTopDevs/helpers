import Foundation

let inAppNotificationManagerDidUpdate = Notification.Name("NotificationManagerDidUpdateNotification")

class InAppNotificationsManager {
    private let storageKey = "notifications"
    /**
     Stores the notifications list
     */
    fileprivate var notifications: [InnerNotification] = [] {
        didSet {
            notifications = notifications.sorted { (first, second) -> Bool in
                if let timestamp1 = first.timestamp, let timestamp2 = second.timestamp {
                    return timestamp1 > timestamp2
                }
                return false
            }
        }
    }
    /**
     Stores KVStorage object
     */
    fileprivate var kvStorage: KVStorage!
        
    init(kvStorage: KVStorage) {
        self.kvStorage = kvStorage
        readNotifications()
    }
    
    func getNotifications() -> [InnerNotification] {
        return notifications
    }
    
    func addNotification(_ notification: InnerNotification, scheduledInterval: TimeInterval = -1) {
        notifications.append(notification)
        saveNotifications()
    }
    
    func removeNotification(_ notification: InnerNotification) {
        notifications = notifications.filter({ (notif) -> Bool in
            return !(notif.title == notification.title && notif.detailText == notification.detailText && notif.moduleId == notification.moduleId)
        })
        saveNotifications()
    }
    
    private func readNotifications() {
        if let kvNotifications = kvStorage.array(forKey: storageKey) as? [Dictionary<String,String>] {
            notifications = kvNotifications.map({ (notification) -> InnerNotification in
                return InnerNotification.convertIntoInnerNotification(from: notification)
            })
        }
    }
    
    private func saveNotifications() {
        let convertedNotifications = notifications.map { (notification) -> Dictionary<String,String> in
            return notification.convertIntoDictionary()
        }
        kvStorage.set(array: convertedNotifications, forKey: storageKey)
        notifyUpdates()
    }
    
    private func notifyUpdates() {
        NotificationCenter.default.post(name: inAppNotificationManagerDidUpdate, object: nil)
    }
    
}
