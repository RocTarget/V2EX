import Foundation

enum SearchSortType: String {
    case created = "created"
    case sumup = "sumup"
}

public struct SearchResponeModel: Codable {
    
    private enum CodingKeys: String, CodingKey {
        case total = "total"
        case timedOut = "timed_out"
        case took = "took"
        case result = "hits"
    }
    
    // MARK: Properties
    public var total: Int?
    public var timedOut: Bool? = false
    public var took: Int?
    public var result: [SearchResultModel]?
}

public struct SearchResultModel: Codable {

    private enum CodingKeys: String, CodingKey {
        case topic = "_source"
        case id = "_id"
        case index = "_index"
        case type = "_type"
    }
    
    // MARK: Properties
    public var topic: SearchTopicModel?
    public var id: String?
    public var index: String?
    public var type: String?
}

public struct SearchTopicModel: Codable {
    
    // MARK: Properties
    public var member: String?
    public var content: String?
    public var replies: Int?
    public var node: Int?
    public var id: Int?
    public var created: String?
    public var title: String?
}
