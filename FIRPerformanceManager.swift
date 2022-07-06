import Foundation
import FirebasePerformance

/**
 Helper class for performance calls
 */
class PerformanceManager {
    
    // A custom trace is a report of performance data associated with some of the code in your app
    
    /**
     Shared instance singleton
     */
    static let sharedManager = PerformanceManager()
    /**
     Stores the list of traces
     */
    private var traceArray = [Trace]() {
        didSet(newValue) {
            if newValue.count > 100 {
                clearAllTraces()
            }
        }
    }
    /**
     Private initialisation method
     */
    private init() {}
    
    // MARK: - Private
    
    /**
     Clears all traces
     */
    private func clearAllTraces() {
        traceArray.forEach { $0.stop() }
        traceArray.removeAll()
    }
    
    // MARK: - Public
    
    /**
     Starts performance measuremnt
     - Parameters:
         - name: String
     */
    func startMeasurement(name: String) {
        if let trace = Performance.startTrace(name: name) {
            traceArray.append(trace)
        }
    }
    /**
     Increments performance measuremnt (to count performance-related events that occur in your app (such as cache hits or retries))
     - Parameters:
         - name: String
         - message: String
     */
    func incrementMeasurement(name: String, with message: String) {
        if let trace = traceArray.first(where: { $0.name == name }) {
            trace.incrementCounter(named: message)
        }
    }
    /**
     Stops performance measuremnt
     - Parameters:
         - name: String
     */
    func stopMeasurement(name: String) {
        if let index = traceArray.index(where: { $0.name == name }) {
            let trace = traceArray.remove(at: index)
            trace.stop()
        }
    }
    
}
