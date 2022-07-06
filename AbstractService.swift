import Foundation

protocol Service {
    
    func start();
    func stop();
    func refresh();

    var name:String {
        get
    }
}

class AbstractService : NSObject, Service {
  
    var name: String {
        return String(describing: self)
    }
    
    var started:Bool = false

    func start() {
        if !started {
            do {
                try onStart()
                started = true
                debugPrint("Service %@ - started.", self.name)
            } catch {
                debugPrint("Service (%@) - starting failed. (%@)", type:.error, self.name, error.fullLocalizedDescription)
            }
        }
    }

    func stop() {
        if started {
            do {
                try onStop()
                started = false
                debugPrint("Service (%@) - stopped.", "\(self.name)")
            } catch {
                debugPrint("Service (%@) - stopping failed. (%@)", type:.error, "\(self.name)", error.fullLocalizedDescription)
            }
        }
    }

    func restart() {
        if started {
            self.stop()
        }
        if !started {
            self.start()
        }
    }

    func onStart() throws {
    }

    func onStop() throws {
    }

    func refresh() {
        if started {
            do {
                try onRefresh()
                debugPrint("Service (%@) - refreshed.", "\(self.name)")
            } catch {
                debugPrint("Service (%@) - refreshing failed. (%@)", type:.error, "\(self.name)", error.fullLocalizedDescription)
            }
        }
    }

    func onRefresh() throws {
    }
}

// Example
class SimpleService : AbstractService {}
