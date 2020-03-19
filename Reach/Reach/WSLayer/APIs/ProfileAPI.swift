//
//  ProfileAPI.swift
//  Reach
//
//  Copyright © 2019 Netsolutions. All rights reserved.
//

import Alamofire

// swiftlint:disable function_parameter_count
protocol ProfileAPI {

}
extension ProfileAPI {

    /**
     Profile Details
     - parameter userID: User ID
     - parameter handler: completion handler to receive the data
     - parameter failureHandler: failure handler to receive the error objects
     */
    func profileData(userID: Int, withHandler handler: @escaping (_ response: NSIResponse<ProfileModel>?, _ isResponseFromCache: Bool?) -> Void, failureHandler: @escaping (_ error: NSIError) -> Void) {
        let path = "/api/accounts/users/\(userID)/detail/"
        let URLString = Configuration.BaseURL() + path
        let headers = Configuration.customHeadersUserToken
        let nillableParameters: [String: Any?] = [:]
        let parameters = APIHelper.rejectNil(source: nillableParameters)
        let convertedParameters = APIHelper.convertBoolToString(source: parameters)
        let requestBuilder = RequestBuilder(urlString: URLString, requestMethod: Alamofire.HTTPMethod.init(rawValue: "GET")!.rawValue, requestParameters: convertedParameters, requestEncoding: JSONEncoding.default, requestHeaders: headers, showLoader: false, requestCache: .RequestFromURLNoCache, requestShouldDisableInteraction: true)
        JSONRequest(requestBuilder: requestBuilder) { (response, isLoadedFromCache) in
            if response.result.isSuccess {
                guard let jsonResponse = response.result.value as? [String: AnyObject] else {
                    failureHandler(NSIError(error: response.result.error, response: response.result.value))
                    return
                }
                let nsiResponse = NSIResponse<ProfileModel>(JSON: jsonResponse)
                handler(nsiResponse, isLoadedFromCache)
            } else {
                var error = NSIError()
                error.error = response.result.error
                do {
                    let jsonResponse = try JSONSerialization.jsonObject(with: response.data!, options: .allowFragments)
                    error.response = jsonResponse
                } catch {}
                failureHandler(error)
            }
        }
    }

    /**
     Profile Events
     - parameter showLoader: show Loader
     - parameter userID: User ID
     - parameter handler: completion handler to receive the data
     - parameter failureHandler: failure handler to receive the error objects
     */
    func profileEvents(showLoader: Bool, userID: Int, withHandler handler: @escaping (_ response: NSIResponse<PaginationFeedsModel>?, _ isResponseFromCache: Bool?) -> Void, failureHandler: @escaping (_ error: NSIError) -> Void) {
        let path = "/api/event/list_profile_events/\(userID)/"
        let URLString = Configuration.BaseURL() + path
        let headers = Configuration.customHeadersUserToken
        let nillableParameters: [String: Any?] = [:]
        let parameters = APIHelper.rejectNil(source: nillableParameters)
        let convertedParameters = APIHelper.convertBoolToString(source: parameters)

        let requestBuilder = RequestBuilder(urlString: URLString, requestMethod: Alamofire.HTTPMethod.init(rawValue: "GET")!.rawValue, requestParameters: convertedParameters, requestEncoding: JSONEncoding.default, requestHeaders: headers, showLoader: false, requestCache: .RequestFromURLNoCache, requestShouldDisableInteraction: true)
        JSONRequest(requestBuilder: requestBuilder) { (response, isLoadedFromCache) in
            if response.result.isSuccess {
                guard let jsonResponse = response.result.value as? [String: AnyObject] else {
                    failureHandler(NSIError(error: response.result.error, response: response.result.value))
                    return
                }
                let nsiResponse = NSIResponse<PaginationFeedsModel>(JSON: jsonResponse)
                handler(nsiResponse, isLoadedFromCache)
            } else {
                var error = NSIError()
                error.error = response.result.error
                do {
                    let jsonResponse = try JSONSerialization.jsonObject(with: response.data!, options: .allowFragments)
                    error.response = jsonResponse
                } catch {}
                failureHandler(error)
            }
        }
    }

    /**
     Edit Profile
     - parameter userID: User ID
     - parameter body: User Model
     - parameter handler: completion handler to receive the data
     - parameter failureHandler: failure handler to receive the error objects
     */
    func editProfile(userID: Int, body: UserModel, withHandler handler: @escaping (_ response: NSIResponse<UserModel>?, _ isResponseFromCache: Bool?) -> Void, failureHandler: @escaping (_ error: NSIError) -> Void) {
        let path = "/api/accounts/update_profile/\(userID)/"
        let URLString = Configuration.BaseURL() + path
        let headers = Configuration.customHeadersUserToken

        let parameters = body.encodeToJSON()
        let convertedParameters = APIHelper.convertBoolToString(source: parameters)

        let requestBuilder = RequestBuilder(urlString: URLString, requestMethod: Alamofire.HTTPMethod.init(rawValue: "PUT")!.rawValue, requestParameters: convertedParameters, requestEncoding: JSONEncoding.default, requestHeaders: headers, showLoader: true, requestCache: .RequestFromURLNoCache, requestShouldDisableInteraction: true)
        JSONRequest(requestBuilder: requestBuilder) { (response, isLoadedFromCache) in
            if response.result.isSuccess {
                guard let jsonResponse = response.result.value as? [String: AnyObject] else {
                    failureHandler(NSIError(error: response.result.error, response: response.result.value))
                    return
                }
                let nsiResponse = NSIResponse<UserModel>(JSON: jsonResponse)
                handler(nsiResponse, isLoadedFromCache)
            } else {
                var error = NSIError()
                error.error = response.result.error
                do {
                    let jsonResponse = try JSONSerialization.jsonObject(with: response.data!, options: .allowFragments)
                    error.response = jsonResponse
                } catch {}
                failureHandler(error)
            }
        }
    }
}
