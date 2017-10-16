import Foundation
import SQLite

class NodeCategoryStore: DB {

    public static let shared = NodeCategoryStore()

    public let table = Table("nodeCategory")

    private let id = Expression<Int>("id")
    private let name = Expression<String>("name")

    override func setupTable() {
        do {
            let createTable = table.create(ifNotExists: true) { t in
                t.column(id, primaryKey: true)
                t.column(name)
            }

            try db?.run(createTable)
        } catch {
            log.error("DB Error ", error)
        }
    }

    func insert(_ nodeCate: NodeCategoryModel) {
        log.info(nodeCate.name)
        let insert = table.insert(
            name <- nodeCate.name,
            id <- nodeCate.id
        )
        log.verbose(insert.asSQL())
        do {
            try db?.run(insert)
            nodeCate.nodes.forEach { NodeStore.shared.insert($0, ncid: nodeCate.id) }
        } catch {
            log.error(error)
        }
    }
    
    func deleteAll() {
        do {
            try db?.run(table.delete())
        } catch {
            log.error(error)
        }
    }

    func cates() -> [NodeCategoryModel] {
        var cates: [NodeCategoryModel] = []
        
        do {
            guard let result = try db?.prepare(table.select(id)) else { return [] }
            for row in result {
                let nodes = NodeStore.shared.nodes(by: row[id])
                let model = NodeCategoryModel(id: row[id], name: row[name], nodes: nodes)
                cates.append(model)
            }
        } catch {
            log.error(error)
        }
        
        return cates
    }
}

class NodeStore: DB {

    public static let shared = NodeStore()

    private let table = Table("node")

    private let id = Expression<Int>("id")
    private let name = Expression<String>("name")
    private let href = Expression<String>("href")
    private let isCurrent = Expression<Bool>("isCurrent")
    private let icon = Expression<String?>("icon")
    private let comments = Expression<String?>("comments")
    private let ncid = Expression<Int>("ncid")

    override func setupTable() {
        do {
            let createTable = table.create(ifNotExists: true) { t in
                t.column(id, primaryKey: .autoincrement)
//                t.column(id, primaryKey: true)
                t.column(name)
                t.column(href)
                t.column(isCurrent, defaultValue: false)
                t.column(icon)
                t.column(comments)
                t.column(ncid)
            }

            try db?.run(createTable)
        } catch {
            log.error("DB Error ", error)
        }
    }

    func insert(_ node: NodeModel, ncid: Int) {
        let insert = table.insert(
            name <- node.name,
            href <- node.href,
            isCurrent <- node.isCurrent,
            icon <- node.icon,
            comments <- node.comments,
            self.ncid <- ncid
        )

        log.verbose(insert.asSQL())

        do {
            try db?.run(insert)
        } catch {
            log.error(error)
        }
    }
    
    
    func deleteAll() {
        do {
            try db?.run(table.delete())
        } catch {
            log.error(error)
        }
    }
    
    func nodes(by ncid: Int) -> [NodeModel] {
        var nodes: [NodeModel] = []
        
        let filter = table.filter(self.ncid == ncid)
        do {
            guard let result = try db?.prepare(filter) else { return [] }
            for row in result {
                let model = NodeModel(name: row[name], href: row[href], isCurrent: row[isCurrent], icon: row[icon], comments: row[comments])
                nodes.append(model)
            }
        } catch {
            log.error(error)
        }
        
        return nodes
    }
}
