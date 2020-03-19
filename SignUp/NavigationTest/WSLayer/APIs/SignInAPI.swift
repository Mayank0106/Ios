//
//  SignInAPI.swift
//  Zepplin
//
//  Created by Mayank Sharma on 06/03/20.
//  Copyright © 2020 Mayank Sharma. All rights reserved.
//

import Foundation
import Alamofire
// swiftlint:disable function_parameter_count
protocol SignInAPI {
    
}
extension SignInAPI {
    /**
     sign in
     - parameter body: (body) User device model
     - parameter handler: completion handler to receive the data
     - parameter failureHandler: failure handler to receive the error objects
     */
    func signIn(_ body: UserDeviceModel, withHandler handler: @escaping (_ response: NSIResponse<UserModel>?, _ isResponseFromCache: Bool?) -> Void, failureHandler: @escaping (_ error: NSIError) -> Void) {
        let path = "/api/accounts/signin/"
        let URLString = "https://reachtheparty.info" + path
        let headers = Configuration.customHeaders
        
        print("headers \(headers)")
        let parameters = body.encodeToJSON()
        let convertedParameters = APIHelper.convertBoolToString(source: parameters)
        print("convertedParameters \(convertedParameters)")
        let requestBuilder = RequestBuilder(urlString: URLString, requestMethod: Alamofire.HTTPMethod.init(rawValue: "POST")!.rawValue, requestParameters: convertedParameters, requestEncoding: JSONEncoding.default, requestHeaders: headers, showLoader: false, requestCache: .RequestFromURLNoCache, requestShouldDisableInteraction: true)
        JSONRequest(requestBuilder: requestBuilder) { (response, isLoadedFromCache) in
            print("response \(response)")
            if response.result.isSuccess {
                guard let jsonResponse = response.result.value as? [String: AnyObject] else {
                    failureHandler(NSIError(error: response.result.error, response: response.result.value))
                    return
                }
                print("jsonResponse \(jsonResponse)")
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
