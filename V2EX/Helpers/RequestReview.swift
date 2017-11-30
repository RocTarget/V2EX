import Foundation
import StoreKit

struct RequestReview {

    private struct Keys {
        static let runIncrementerSetting = "numberOfRuns"  // 用于存储运行次数的 UserDefauls 字典键
        static let minimumRunCount = 10 // 询问评分的最少运行次数
    }

    // app 运行次数计数器。可以在 App Delegate 中调用此方法
    func incrementAppRuns() {
        let runs = getRunCounts() + 1
        UserDefaults.save(at: runs, forKey: Keys.runIncrementerSetting)
    }

    // 从 UserDefaults 里读取运行次数并返回。
    private func getRunCounts () -> Int {
        let savedRuns = (UserDefaults.get(forKey: Keys.runIncrementerSetting) as? Int) ?? 0
        log.info("已运行\(savedRuns)次")
        return savedRuns
    }

    public func showReview() {
        let runs = getRunCounts()

        log.info("请求显示评分")
        // 运行次数 大于 10， 并且 运行次数 % 20 == 0
        // 第一次请求时机是第十次运行
        // 之后每运行 20 次请求一次
        // 但不一定触发
        if (runs > Keys.minimumRunCount && runs % 20 == 0) {
            if #available(iOS 10.3, *) {
//                 #if !DEBUG
                    log.info("已请求评分")
                    SKStoreReviewController.requestReview()
//                #endif
            } else {
                log.info("版本低于 10.3， 不处理")
//                UIApplication.appReviewPage(with: Constants.Config.AppID)
            }
        } else {
            print("请求评分所需的运行次数不足！")
        }
    }
}
