typealias FeedbackList = Model.FeedbackReport.FeedbackList
typealias FeedbackReport = Model.FeedbackReport.FeedbackReport
typealias Feedback = Model.FeedbackReport.

enum FeedbackType: String {
    case custom
    case manual
}

extension Model {
    struct FeedbackReport {
        struct Item: Codable {
            var id : String
            var name : String
            var localName: String?
            var rawType : String?
            var algorithmType : Int
            var type : String?
            var category : String?
            var comment : String?
            
            enum CodingKeys : String, CodingKey {
                case id = "ID"
                case name = "Name"
                case localName = "LocalName"
                case algorithmType = "AlgorithmType"
                case type = "Type"
                case rawType = "RawType"
                case comment = "comment"
                case category = "Category"
            }
            
            init() {
                self.id = "0"
                self.name = ""
                self.rawType = ""
                self.algorithmType = 0
                self.type = ""
            }
        }
        
        // MARK: - Reports
        
        struct FeedbackReport: Codable {
            var visitId: Int = 0
            var isVisit: Bool = true
            var isCorrectLocation: Bool = true
            var isCorrect: Bool = false
            var original: ?
            var labeleds: [] = []
            
            enum CodingKeys : String, CodingKey {
                case visitId = "VisitId"
                case isVisit = "isVisit"
                case isCorrectLocation = "isCorrectLocation"
                case isCorrect = "isCorrect"
                case original = "Original"
                case labeleds = "Labeleds"
            }
            
            init() {
            }
            
            func find(type: String) -> Feedback? {
                return self.labeleds.first {
                    $0.rawType == FeedbackType.manual.rawValue
                }
            }
        }
        
        struct FeedbackList: Codable {
            private var reports: [FeedbackReport]
            
            init() {
                self.reports = []
            }
            
            func find(by visit: Visit) -> FeedbackReport? {
                return self.reports.first {
                    $0.visitId == visit.id
                }
            }
            
            @discardableResult
            mutating func confirm(for visit: Visit) -> FeedbackReport {
                let report = FeedbackReport(visit: visit)
                save(report: report, for: visit)
                return report
            }
            
            mutating func save(report: FeedbackReport, for visit: Visit) {
                if let index = indexOf(visitId: visit.id) {
                    self.reports.insert(report, at: index)
                } else {
                    self.reports.append(report)
                }
                self.cache()
            }
            
            private func indexOf(visitId: Int) -> Int? {
                return self.reports.firstIndex {
                    $0.visitId == visitId
                }
            }
        }
    }
}

extension FeedbackList {
    var directoryURL: URL {
        return App.FilePaths.documents
            .appendingPathComponent("demo")
            .appendingPathComponent("Report")
    }
    
    var fileURL: URL {
        return self.directoryURL
            .appendingPathComponent("items")
            .appendingPathExtension("json")
    }
    
    private var fileManager: FileManager {
        return FileManager.default
    }
    
    func cache() {
        do {
            try self.fileManager.createDirectory(at: self.directoryURL, withIntermediateDirectories: true, attributes: nil)
        } catch {
            debugPrint(error)
        }
        do {
            try self.data?.write(to: self.fileURL)
        } catch {
            debugPrint(error)
        }
    }
    
    func retrieve() -> FeedbackList {
        var LabelList = FeedbackList()
        let fileManager = FileManager.default
        if let data = fileManager.contents(atPath: self.fileURL.path),
            let decoded:FeedbackList = self.decode(from: data) {
            LabelList = decoded
        }
        return LabelList
    }
    
    mutating func load() {
        self = self.retrieve()
    }
}
