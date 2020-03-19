//
//  NexmoAPI.swift
//  DITY

import Foundation
import Alamofire
// swiftlint:disable function_parameter_count
/* Now added on configuration file
let nexmoApiKey =  "69b6b0a6" //client 69b6b0a6 //shikha:  4b3324d4 // vivek  bd88927c
let nexmoSecretKey = "ad7142edeb933067" //Client ad7142edeb933067 // shikha : 8965888000604b4c // vivek: 735e2bf135218990

*/
let nexmoBrandKey = "Reach"
let nexmoApiKeyServer = "api_key"
let nexmoSecretKeyServer = "api_secret"
let nexmoRequestedIdKeyServer = "request_id"
let nexmoNumberKeyServer = "number"
let nexmoBrandKeyServer = "brand"
let nexmoCodeKeyServer = "code"
let eventIdKeyServer = "event_id"
let errorTextKeyServer = "error_text"
let nexmoErrorText = "error_text"
//let countryCode = "1" // 91
//status code
let successStatus = "0"
let CodeAlreadySentStatus = "10"
let errorOtpCode = "3"
let invalidOtp = "16"
let tooManyAttempts = "17"
let blockedUser = "6"

protocol NexmoAPI {

}
extension NexmoAPI {
    /// Send Otp API
    ///
    /// - parameter phoneNumber:    phone number
    /// - parameter handler:        success handler
    /// - parameter failureHandler: failture handler
    func sendOTP(_ phoneNumber: String, countryCode: String, withHandler handler: @escaping (_ requestId: String?, _ status: String?, _ message: String?) -> Void, failureHandler: @escaping (_ error: NSIError) -> Void) {
        let URLString =  "https://api.nexmo.com/verify/json"
        let nillableParameters: [String: Any?] = [
            nexmoSecretKeyServer: Configuration.nexmoSecretKey(),
            nexmoApiKeyServer: Configuration.nexmoApiKey(),
            nexmoNumberKeyServer: countryCode + phoneNumber,
            nexmoBrandKeyServer: nexmoBrandKey
        ]
        let parameters = APIHelper.rejectNil(source: nillableParameters)
        let convertedParameters = APIHelper.convertBoolToString(source: parameters)
        let requestBuilder = RequestBuilder(urlString: URLString, requestMethod: "POST", requestParameters: convertedParameters, requestEncoding: JSONEncoding.default, showLoader: true, requestCache: .RequestFromURLNoCache, requestShouldDisableInteraction: true)
        JSONRequest(requestBuilder: requestBuilder) { (response, _) in
            if response.result.isSuccess {
                guard let jsonResponse = response.result.value as? [String: AnyObject] else {
                    failureHandler(NSIError(error: response.result.error, response: response.result.value))
                    return
                }
                if let statusObj = jsonResponse[AppConstants.statusKey], let requestedId = jsonResponse[nexmoRequestedIdKeyServer]as? String, "\(statusObj)" == successStatus {
                    handler(requestedId, "\(statusObj)", nil)
                } else if let statusObj = jsonResponse[AppConstants.statusKey], let requestedId = jsonResponse[nexmoRequestedIdKeyServer] as? String, "\(statusObj)" == CodeAlreadySentStatus {
                   //  AppUtility.showAlert("", message: "OtpSentAlready".localized, delegate: nil)
                    handler(requestedId, "\(statusObj)", jsonResponse[nexmoErrorText]as? String ?? "OtpSentAlready".localized)
                } else if let statusObj = jsonResponse[AppConstants.statusKey], "\(statusObj)" == errorOtpCode {
                    let numberText =  AppConstants.plusText + AppConstants.countryCode + AppConstants.whiteSpace + phoneNumber + AppConstants.whiteSpace
                    AppUtility.showAlert("", message: numberText + "NoValidMobileNo".localized, delegate: nil)
                } else {
                    DispatchQueue.main.async(execute: {() -> Void in
                        AppUtility.showAlert("", message: jsonResponse[errorTextKeyServer] as? String ?? "", delegate: nil)
                    })
                }
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

    /// Verify OTP message
    ///
    /// - parameter requestedId:    requested ID which is request Key
    /// - parameter pin:            verify pin
    /// - parameter handler:        success handler
    /// - parameter failureHandler: failure handler
    func verifyOTP(requestedId: String, pin: String, withHandler handler: @escaping (_ eventId: String?) -> Void, failureHandler: @escaping (_ error: NSIError) -> Void) {

        let URLString = AppConstants.NexmoAPIURL
        let nillableParameters: [String: Any?] = [
            nexmoSecretKeyServer: Configuration.nexmoSecretKey(),
            nexmoApiKeyServer: Configuration.nexmoApiKey(),
            nexmoRequestedIdKeyServer: requestedId,
            nexmoCodeKeyServer: pin
        ]
        let parameters = APIHelper.rejectNil(source: nillableParameters)
        let convertedParameters = APIHelper.convertBoolToString(source: parameters)
        let requestBuilder = RequestBuilder(urlString: URLString, requestMethod: "POST", requestParameters: convertedParameters, requestEncoding: JSONEncoding.default, showLoader: true, requestCache: .RequestFromURLNoCache, requestShouldDisableInteraction: true)
        JSONRequest(requestBuilder: requestBuilder) { (response, _) in
            if response.result.isSuccess {
                guard let jsonResponse = response.result.value as? [String: AnyObject] else {
                    failureHandler(NSIError(error: response.result.error, response: response.result.value))
                    return
                }
                if let _ = jsonResponse[eventIdKeyServer] as? String, let requestedId = jsonResponse[nexmoRequestedIdKeyServer]as? String {
                        handler(requestedId)

                } else if let statusObj = jsonResponse[AppConstants.statusKey], "\(statusObj)" == invalidOtp {
                    AppUtility.showAlert("", message: "IncorrectOtpMsg".localized, delegate: nil)
                    return
                } else if let statusObj = jsonResponse[AppConstants.statusKey], "\(statusObj)" == tooManyAttempts {
                    AppUtility.showAlert("", message: "TooManyAttempts".localized, delegate: nil)
                    return
                } else if let statusObj = jsonResponse[AppConstants.statusKey], "\(statusObj)" == blockedUser {
                    AppUtility.showAlert("", message: "BlockedUser".localized, delegate: nil)
                    return
                }
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
