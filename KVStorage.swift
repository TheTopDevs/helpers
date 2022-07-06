import Foundation

/**
 Component provides simple key-value storage solution based on UserDefaults
 */
public class KVStorage: NSObject {
    
    let storageId = "storageId"
    
    /**
     KV storage
     */
    var kvStorage: Dictionary<String, AnyObject>
    /**
     IOS user defaulsts singleton
     */
    let userDefaults = UserDefaults.standard
    
    /**
     Initilization method
     - Parameters:
        - moduleId: module Id
     */
    init(moduleId: String) {
        let key = moduleId
        if userDefaults.object(forKey: key) == nil {
            userDefaults.set(Dictionary<String, AnyObject>(), forKey: key)
        }
        kvStorage = userDefaults.object(forKey: key) as! Dictionary<String, AnyObject>
    }
    
    /**
     Sets array value for key
     - Parameters:
        - array: value to set
        - key: name of key
     */
    public func set(array: [Any], forKey key: String) {
        insert(value: array as AnyObject, forKey: key)
    }
    
    /**
     Returns array value of key
     - Parameters:
        - key: name of key
     */
    public func array(forKey key: String) -> [Any]? {
        return kvStorage[key] as? [Any]
    }
    
    /**
     Sets dictionary value for key
     - Parameters:
        - dictionary: value to set
        - key: name of key
     */
    public func set(dictionary: [String:Any], forKey key: String) {
        insert(value: dictionary as AnyObject, forKey: key)
    }
    
    /**
     Returns dictionary value of key
     - Parameters:
        - key: name of key
     */
    public func dictionary(forKey key: String) -> [String:Any]? {
        return kvStorage[key] as? [String:Any]
    }
    
    /**
     Sets data value for key
     - Parameters:
     - data: value to set
     - key: name of key
     */
    public func set(data: Data, forKey key:String) {
        insert(value: data as AnyObject, forKey: key)
    }
    
    /**
     Returns data value of key
     - Parameters:
     - key: name of key
     */
    public func data(forKey key:String) -> Data? {
        return kvStorage[key] as? Data
    }

    /**
     Removes value with specified key
     - Parameters:
        - key: name of key
     */
    public func removeValue(forKey key: String) {
        kvStorage.removeValue(forKey: key)
        save()
    }
    
    /**
     Removes all keys
     */
    public func cleanup() {
        kvStorage.removeAll()
        save()
    }
    
    // MARK: - Helpers
    
    /**
     Insert helper method
     - Parameters:
        - value: value object
        - key: key object
     */
    fileprivate func insert(value: AnyObject, forKey key: String) {
        kvStorage[key] = value
        save()
    }

    /**
     Save helper method, saves to IOS defaults storage
     */
    fileprivate func save() {
        userDefaults.set(kvStorage, forKey: storageId)
        userDefaults.synchronize()
    }
    
}
