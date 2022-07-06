enum NotificationCategory: String {
    case feedback
}

enum NotificationIdentifier: String {
    case prediction = "prediction"
    case visit = "visit"
}

enum NotificationActionIdentifier: String {
    case visit_confirm = "visit.confirm"
    case visit_reject = "isit.reject"
}

struct NotificationAction: Hashable {
    typealias ActionCompletion = (_ userInfo: [AnyHashable:Any]) -> Void
    
    var identifier: NotificationActionIdentifier
    var title: String
    var openApp: Bool
    var action: ActionCompletion
    
    static func == (lhs: NotificationAction, rhs: NotificationAction) -> Bool {
        return lhs.hashValue == rhs.hashValue && lhs.identifier == rhs.identifier
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(identifier)
        hasher.combine(title)
    }
} 

class NotificationsService: NSObject {
    static let shared = NotificationsService()
    
    private var actions: Set<NotificationAction> = []
    
    private override init() {
        super.init()
        UNUserNotificationCenter.current().delegate = self
    }
    
    func hasLocalNotificationPermissions(completion: @escaping (Bool, UNAuthorizationStatus) -> Void) {
        UNUserNotificationCenter.current().getNotificationSettings() { (settings) in
            Async.main { () -> Void in
                completion(settings.authorizationStatus == .authorized, settings.authorizationStatus)
            }
        }
    }
    
    func requestForLocalNotificationsPermissions(_ onAllowed:@escaping () -> Void, onDenied:@escaping () -> Void) {
        UNUserNotificationCenter.current().requestAuthorization(options: .alert) { (granted, error) in
            Async.main { () -> Void in
                if granted {
                    onAllowed()
                } else {
                    onDenied()
                }
            }
        }
    }
    
    func registerNotificationCategory(identifier: NotificationCategory, actions: [NotificationAction]) {
        self.actions.insert(actions)
        let unActions = actions.map {
            UNNotificationAction(identifier: $0.identifier.rawValue, title: $0.title, options: $0.openApp ? [.foreground] : [])
        }
        let category = UNNotificationCategory(identifier: identifier.rawValue, actions: unActions, intentIdentifiers: [], options: [])
        UNUserNotificationCenter.current().setNotificationCategories([category])
    }
    
    func fireLocalNotification(identifier: NotificationIdentifier, text: String, categoryIdentifier: NotificationCategory? = nil, title: String? = nil, userInfo: [AnyHashable:Any] = [:]) {
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1.0, repeats: false)
        let content = UNMutableNotificationContent()
        content.title = title ?? ""
        content.body = text
        content.userInfo = userInfo
        if let category = categoryIdentifier {
            content.categoryIdentifier = category.rawValue
        }
        let request = UNNotificationRequest(identifier: identifier.rawValue, content: content, trigger: trigger)
        UNUserNotificationCenter.current().add(request, withCompletionHandler: nil)
    }
}

extension NotificationsService: UNUserNotificationCenterDelegate {
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler([.alert, .badge, .sound])
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        let notificationAction = self.actions.first { $0.identifier.rawValue == response.actionIdentifier }
        let userInfo = response.notification.request.content.userInfo
        notificationAction?.action(userInfo)
    }
}
