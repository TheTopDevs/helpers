extension UIViewController {
    func showAlert(title: String?, message: String? = nil, seconds: Int, completion: (() -> Void)?) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        self.present(alert, animated: true) {
            let deadlineTime = DispatchTime.now() + .seconds(seconds)
            DispatchQueue.main.asyncAfter(deadline: deadlineTime) {
                alert.dismiss(animated: true, completion: completion)
            }
        }
    }
    
    func showAlert(title: String?, message: String? = nil, cancelTitle: String? = nil, cancelCompletionHandler: (() -> Void)? = nil, actionTitle: String? = nil, actionCompletionHandler: (() -> Void)? = nil) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        let cancelButtonTitle = cancelTitle ?? "OK"
        alert.addAction(UIAlertAction(title: cancelButtonTitle, style: .cancel, handler: { (_) in
            cancelCompletionHandler?()
        }))
        if let actionButtonTitle = actionTitle {
            alert.addAction(UIAlertAction(title: actionButtonTitle, style: .default, handler: { (_) in
                actionCompletionHandler?()
            }))
        }
        self.present(alert, animated: true, completion: nil)
    }
    
    func showAlert(title: String, message: String? = nil) {
        let controller = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let action = UIAlertAction(title: "OK", style: .default, handler: nil)
        controller.addAction(action)
        self.present(controller, animated: true, completion: nil)
    }
}
