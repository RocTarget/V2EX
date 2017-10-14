import SQLite
import Foundation

class DB {
    private static let dir = FileManager.document + "/data"

    lazy var db: Connection? = {
        do {
            let messageDB = try Connection(self.path)
            messageDB.busyTimeout = 3
            messageDB.busyHandler {  $0 < 3 }
            return messageDB
        } catch {
            log.error(error)
            return try? Connection()
        }
    }()

    /// 数据库路径
    lazy var path: String = {
        return DB.dir + "/db.sqlite3"
    }()

    init() {
        FileManager.create(at: DB.dir)

        setupTable()
    }

    func setupTable() {

    }
}
