import Crashlytics
import Moya
import Result

public class CrashlyticsPlugin: PluginType {
    public func didReceive(_ result: Result<Moya.Response, MoyaError>, target: TargetType) {
        guard case let .success(response) = result else { return }
        Crashlytics.sharedInstance().setObjectValue(try? response.mapJSON(), forKey: "Response API")
        Crashlytics.sharedInstance().setObjectValue(response.request?.url?.absoluteString, forKey: "Request URL")
        Crashlytics.sharedInstance().setObjectValue(target.parameters, forKey: "Request parameter")
        Crashlytics.sharedInstance().setObjectValue(response.request?.allHTTPHeaderFields, forKey: "Request Header")
    }
}
