import Foundation
import Alamofire
import Kanna

let Network = Networking.shared

typealias Success = ((Data) -> Void)
typealias Failure = ((String) -> Void)

enum NetworkStatus {
    case unknown
    case notReachable
    case reachableViaWiFi
    case reachableViaWWAN
}

final class Networking {

    public static let shared = Networking()

    private var reachabilityManager: NetworkReachabilityManager?

    public var isWiFi: Bool {
        return reachabilityManager?.networkReachabilityStatus == .reachable(.ethernetOrWiFi)
    }

    private init() {
        Alamofire.SessionManager.default.session.configuration.timeoutIntervalForRequest = 10
        Alamofire.SessionManager.default.session.configuration.timeoutIntervalForResource = 10
    }

    /// 监听网络
    public func networkListening(_ handle: ((NetworkStatus) -> Void)?) {

        reachabilityManager = NetworkReachabilityManager()
        reachabilityManager?.startListening()

        reachabilityManager?.listener = { status in
            switch status {
            case .notReachable:
                handle?(.notReachable)
            case .unknown :
                handle?(.unknown)
            case .reachable(.ethernetOrWiFi):
                handle?(.reachableViaWiFi)
            case .reachable(.wwan):
                handle?(.reachableViaWWAN)
            }
        }
    }

    func request(
        file: StaticString = #file,
        function: StaticString = #function,
        line: UInt = #line,
        target: API,
        success: Success?,
        failure: Failure?
        ) {

        GCD.runOnMainThread {
            UIApplication.shared.isNetworkActivityIndicatorVisible = true
        }

        guard let url = target.url else { return }

        switch target.task {
        case .request:

            Alamofire.request(url,
                              method: target.route.method,
                              parameters: target.parameters,
                              encoding: target.parameterEncoding,
                              headers: target.httpHeaderFields)
                .responseData(completionHandler: { [weak self] (dataResponse) in
                    self?.responseHandle(target: target, success: success, failure: failure, dataResponse: dataResponse)
                })
            break

        case .upload(.file(let fileUrl)):

            Alamofire.upload(multipartFormData: { multipartFormData in

                multipartFormData.append(fileUrl, withName: "smfile")

                if let params = target.parameters as? [String: String] {
                    for (key, value) in params {
                        multipartFormData.append(value.data(using: .utf8)!, withName: key)
                    }
                }
            }, to: url, encodingCompletion: { (encodingResult: SessionManager.MultipartFormDataEncodingResult) in
                switch encodingResult {
                case let .success(request, _, _):
                    request.uploadProgress(closure: { progress in
                        log.info(progress)
                    })

                    request.responseData(completionHandler: { dataResponse in
                        self.responseHandle(target: target, success: success, failure: failure, dataResponse: dataResponse)
                    })
                case .failure(let error):
                    log.error(error.localizedDescription)
                }
            })
        default:
            break
        }
    }
}

extension Networking {

    fileprivate func responseHandle(file: StaticString = #file,
                                    function: StaticString = #function,
                                    line: UInt = #line,
                                    target: API,
                                    success: Success?,
                                    failure: Failure?,
                                    dataResponse: DataResponse<Data>) {

        let requestString = "\(target.route.method) \(String(describing: target.url)) \(target.parameters ?? [:]))"

        UIApplication.shared.isNetworkActivityIndicatorVisible = false

        let message =  "\(requestString) (\(dataResponse.response?.statusCode ?? -1))"

        switch dataResponse.result {
        case .success(let data):
            log.verbose("✅ SUCCESS: " + message, file: file, function: function, line: line)

            if let statusCode = dataResponse.response?.statusCode {
                if statusCode == 502 {
                    failure?("502 Bad Gateway")
                    return
                } else if statusCode == 404 {
                    failure?("404")
                    return
                }
            }
            success?(data)
        case .failure(let error):
            log.error("❌ FAILURE: \(message) \n \(error)", file: file, function: function, line: line)
            failure?(error.localizedDescription)
        }
    }
}

extension Networking {

    public func htmlRequest(
        file: StaticString = #file,
        function: StaticString = #function,
        line: UInt = #line,
        target: API,
        success: ((HTMLDocument) -> Void)?,
        failure: Failure?
        ) {
        request(target: target, success: { data in
            guard let html = HTML(html: data, encoding: .utf8) else {
                failure?("数据解析失败")
                return
            }

            // 误伤
//            guard let content = html.content,
//                !content.contains("Access Denied") else {
//                failure?("Access Denied")
//                return
//            }

            success?(html)
        }, failure: failure)
    }

    /// 不需要响应结果，  用于 感谢、删除通知评论时， data count = 0
    public func htmlRequestNotResponse(
        file: StaticString = #file,
        function: StaticString = #function,
        line: UInt = #line,
        target: API,
        success: Action?,
        failure: Failure?
        ) {
        request(target: target, success: { data in
            success?()
        }, failure: failure)
    }
}
