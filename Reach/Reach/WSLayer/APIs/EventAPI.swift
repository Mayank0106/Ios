//
//  EventAPI.swift
//  Reach
//
//  Copyright © 2019 Netsolutions. All rights reserved.
//

import Alamofire

// swiftlint:disable function_parameter_count
protocol EventAPI {

}
extension EventAPI {

    /**
     List Events
     - parameter handler: completion handler to receive the data
     - parameter failureHandler: failure handler to receive the error objects
     */
    func listAllEvents(withHandler handler: @escaping (_ response: NSIResponse<PaginationFeedsModel>?, _ isResponseFromCache: Bool?) -> Void, failureHandler: @escaping (_ error: NSIError) -> Void) {
        let path = "/api/event/list_my_events/"
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
     Create Event
     - parameter body: (body) Event model
     - parameter handler: completion handler to receive the data
     - parameter failureHandler: failure handler to receive the error objects
     */
    func createEvent(_ body: MyEventModel, withHandler handler: @escaping (_ response: NSIResponse<Any>?, _ isResponseFromCache: Bool?) -> Void, failureHandler: @escaping (_ error: NSIError) -> Void) {
        let path = "/api/event/create_event/"
        let URLString = Configuration.BaseURL() + path
        let headers = Configuration.customHeadersUserToken
        let parameters = body.encodeToJSON()
        let convertedParameters = APIHelper.convertBoolToString(source: parameters)
        let requestBuilder = RequestBuilder(urlString: URLString, requestMethod: Alamofire.HTTPMethod.init(rawValue: "POST")!.rawValue, requestParameters: convertedParameters, requestEncoding: JSONEncoding.default, requestHeaders: headers, showLoader: true, requestCache: .RequestFromURLNoCache, requestShouldDisableInteraction: true)
        JSONRequest(requestBuilder: requestBuilder) { (response, isLoadedFromCache) in
            if response.result.isSuccess {
                guard let jsonResponse = response.result.value as? [String: AnyObject] else {
                    failureHandler(NSIError(error: response.result.error, response: response.result.value))
                    return
                }
                let nsiResponse = NSIResponse<Any>(JSON: jsonResponse)
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
     Edit Event
     - parameter body: (body) Event model
     - parameter handler: completion handler to receive the data
     - parameter failureHandler: failure handler to receive the error objects
     */
    func editEvent(eventID: Int, _ body: MyEventModel, withHandler handler: @escaping (_ response: NSIResponse<Any>?, _ isResponseFromCache: Bool?) -> Void, failureHandler: @escaping (_ error: NSIError) -> Void) {
        let path = "/api/event/update_event/\(eventID)/"
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
                let nsiResponse = NSIResponse<Any>(JSON: jsonResponse)
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
     List Feeds
     - parameter handler: completion handler to receive the data
     - parameter failureHandler: failure handler to receive the error objects
     */
    func listAllFeeds(page: Int, withHandler handler: @escaping (_ response: NSIResponse<PaginationFeedsModel>?, _ isResponseFromCache: Bool?) -> Void, failureHandler: @escaping (_ error: NSIError) -> Void) {
        let path = "/api/event/list_feeds/"
        let URLString = Configuration.BaseURL() + path
        let headers = Configuration.customHeadersUserToken

        let nillableParameters: [String: Any?] = [
            "page": page
        ]
        let parameters = APIHelper.rejectNil(source: nillableParameters)
        let convertedParameters = APIHelper.convertBoolToString(source: parameters)

        let requestBuilder = RequestBuilder(urlString: URLString, requestMethod: Alamofire.HTTPMethod.init(rawValue: "GET")!.rawValue, requestParameters: convertedParameters, requestEncoding: URLEncoding.default, requestHeaders: headers, showLoader: false, requestCache: .RequestFromURLNoCache, requestShouldDisableInteraction: true)
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
     Event Detail
     - parameter eventID: Event ID
     - parameter handler: completion handler to receive the data
     - parameter failureHandler: failure handler to receive the error objects
     */
    func eventDetail(eventID: Int, withHandler handler: @escaping (_ response: NSIResponse<MyEventModel>?, _ isResponseFromCache: Bool?) -> Void, failureHandler: @escaping (_ error: NSIError) -> Void) {
        let path = "/api/event/event_detail/\(eventID)/"
        let URLString = Configuration.BaseURL() + path
        let headers = Configuration.customHeadersUserToken
        let nillableParameters: [String: Any?] = [:]
        let parameters = APIHelper.rejectNil(source: nillableParameters)
        let convertedParameters = APIHelper.convertBoolToString(source: parameters)
        let requestBuilder = RequestBuilder(urlString: URLString, requestMethod: Alamofire.HTTPMethod.init(rawValue: "GET")!.rawValue, requestParameters: convertedParameters, requestEncoding: URLEncoding.default, requestHeaders: headers, showLoader: false, requestCache: .RequestFromURLNoCache, requestShouldDisableInteraction: true)
        JSONRequest(requestBuilder: requestBuilder) { (response, isLoadedFromCache) in
            if response.result.isSuccess {
                guard let jsonResponse = response.result.value as? [String: AnyObject] else {
                    failureHandler(NSIError(error: response.result.error, response: response.result.value))
                    return
                }
                let nsiResponse = NSIResponse<MyEventModel>(JSON: jsonResponse)
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
     Event Deletion
     - parameter eventID: Event ID
     - parameter handler: completion handler to receive the data
     - parameter failureHandler: failure handler to receive the error objects
     */
    func deleteEvent(eventID: Int, withHandler handler: @escaping (_ response: NSIResponse<Any>?, _ isResponseFromCache: Bool?) -> Void, failureHandler: @escaping (_ error: NSIError) -> Void) {
        let path = "/api/event/delete-event/\(eventID)/"
        let URLString = Configuration.BaseURL() + path
        let headers = Configuration.customHeadersUserToken
        let nillableParameters: [String: Any?] = [:]
        let parameters = APIHelper.rejectNil(source: nillableParameters)
        let convertedParameters = APIHelper.convertBoolToString(source: parameters)
        let requestBuilder = RequestBuilder(urlString: URLString, requestMethod: Alamofire.HTTPMethod.init(rawValue: "PUT")!.rawValue, requestParameters: convertedParameters, requestEncoding: URLEncoding.default, requestHeaders: headers, showLoader: false, requestCache: .RequestFromURLNoCache, requestShouldDisableInteraction: true)
        JSONRequest(requestBuilder: requestBuilder) { (response, isLoadedFromCache) in
            if response.result.isSuccess {
                guard let jsonResponse = response.result.value as? [String: AnyObject] else {
                    failureHandler(NSIError(error: response.result.error, response: response.result.value))
                    return
                }
                let nsiResponse = NSIResponse<Any>(JSON: jsonResponse)
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
     Report Event
     - parameter body: Request Model
     - parameter handler: completion handler to receive the data
     - parameter failureHandler: failure handler to receive the error objects
     */
    func reportEvent(body: RequestModel, withHandler handler: @escaping (_ response: NSIResponse<Any>?, _ isResponseFromCache: Bool?) -> Void, failureHandler: @escaping (_ error: NSIError) -> Void) {
        let path = "/api/event/report-event/"
        let URLString = Configuration.BaseURL() + path
        let headers = Configuration.customHeadersUserToken
        let parameters = body.encodeToJSON()
        let convertedParameters = APIHelper.convertBoolToString(source: parameters)
        let requestBuilder = RequestBuilder(urlString: URLString, requestMethod: Alamofire.HTTPMethod.init(rawValue: "POST")!.rawValue, requestParameters: convertedParameters, requestEncoding: JSONEncoding.default, requestHeaders: headers, showLoader: false, requestCache: .RequestFromURLNoCache, requestShouldDisableInteraction: true)
        JSONRequest(requestBuilder: requestBuilder) { (response, isLoadedFromCache) in
            if response.result.isSuccess {
                guard let jsonResponse = response.result.value as? [String: AnyObject] else {
                    failureHandler(NSIError(error: response.result.error, response: response.result.value))
                    return
                }
                let nsiResponse = NSIResponse<Any>(JSON: jsonResponse)
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
     Going for an Event
     - parameter eventID: Event ID
     - parameter handler: completion handler to receive the data
     - parameter failureHandler: failure handler to receive the error objects
     */
    func goingForEvent(eventID: Int, withHandler handler: @escaping (_ response: NSIResponse<Any>?, _ isResponseFromCache: Bool?) -> Void, failureHandler: @escaping (_ error: NSIError) -> Void) {
        let path = "/api/event/mark_going/\(eventID)/"
        let URLString = Configuration.BaseURL() + path
        let headers = Configuration.customHeadersUserToken
        let nillableParameters: [String: Any?] = [:]
        let parameters = APIHelper.rejectNil(source: nillableParameters)
        let convertedParameters = APIHelper.convertBoolToString(source: parameters)
        let requestBuilder = RequestBuilder(urlString: URLString, requestMethod: Alamofire.HTTPMethod.init(rawValue: "PUT")!.rawValue, requestParameters: convertedParameters, requestEncoding: URLEncoding.default, requestHeaders: headers, showLoader: false, requestCache: .RequestFromURLNoCache, requestShouldDisableInteraction: true)
        JSONRequest(requestBuilder: requestBuilder) { (response, isLoadedFromCache) in
            if response.result.isSuccess {
                guard let jsonResponse = response.result.value as? [String: AnyObject] else {
                    failureHandler(NSIError(error: response.result.error, response: response.result.value))
                    return
                }
                let nsiResponse = NSIResponse<Any>(JSON: jsonResponse)
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
     Report Event
     - parameter body: Request friends for event
     - parameter handler: completion handler to receive the data
     - parameter failureHandler: failure handler to receive the error objects
     */
    func requestFriendsForAnEvent(body: RequestModel, withHandler handler: @escaping (_ response: NSIResponse<Any>?, _ isResponseFromCache: Bool?) -> Void, failureHandler: @escaping (_ error: NSIError) -> Void) {
        let path = "/api/event/recommendfriend/"
        let URLString = Configuration.BaseURL() + path
        let headers = Configuration.customHeadersUserToken
        let parameters = body.encodeToJSON()
        let convertedParameters = APIHelper.convertBoolToString(source: parameters)
        let requestBuilder = RequestBuilder(urlString: URLString, requestMethod: Alamofire.HTTPMethod.init(rawValue: "POST")!.rawValue, requestParameters: convertedParameters, requestEncoding: JSONEncoding.default, requestHeaders: headers, showLoader: false, requestCache: .RequestFromURLNoCache, requestShouldDisableInteraction: true)
        JSONRequest(requestBuilder: requestBuilder) { (response, isLoadedFromCache) in
            if response.result.isSuccess {
                guard let jsonResponse = response.result.value as? [String: AnyObject] else {
                    failureHandler(NSIError(error: response.result.error, response: response.result.value))
                    return
                }
                let nsiResponse = NSIResponse<Any>(JSON: jsonResponse)
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
     Accept/Reject Invitation
     - parameter eventID: Event ID
     - parameter handler: completion handler to receive the data
     - parameter failureHandler: failure handler to receive the error objects
     */
    func acceptRejectInvitation(body: RequestModel, withHandler handler: @escaping (_ response: NSIResponse<Any>?, _ isResponseFromCache: Bool?) -> Void, failureHandler: @escaping (_ error: NSIError) -> Void) {
        let path = "/api/event/accept-reject-invitation/"
        let URLString = Configuration.BaseURL() + path
        let headers = Configuration.customHeadersUserToken
        let parameters = body.encodeToJSON()
        let convertedParameters = APIHelper.convertBoolToString(source: parameters)
        let requestBuilder = RequestBuilder(urlString: URLString, requestMethod: Alamofire.HTTPMethod.init(rawValue: "PUT")!.rawValue, requestParameters: convertedParameters, requestEncoding: JSONEncoding.default, requestHeaders: headers, showLoader: false, requestCache: .RequestFromURLNoCache, requestShouldDisableInteraction: true)
        JSONRequest(requestBuilder: requestBuilder) { (response, isLoadedFromCache) in
            if response.result.isSuccess {
                guard let jsonResponse = response.result.value as? [String: AnyObject] else {
                    failureHandler(NSIError(error: response.result.error, response: response.result.value))
                    return
                }
                let nsiResponse = NSIResponse<Any>(JSON: jsonResponse)
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
     Delete Invitation
     - parameter eventID: Event ID
     - parameter handler: completion handler to receive the data
     - parameter failureHandler: failure handler to receive the error objects
     */
    func deleteInvitation(eventID: Int, withHandler handler: @escaping (_ response: NSIResponse<Any>?, _ isResponseFromCache: Bool?) -> Void, failureHandler: @escaping (_ error: NSIError) -> Void) {
        let path = "/api/event/delete-invitation/\(eventID)/"
        let URLString = Configuration.BaseURL() + path
        let headers = Configuration.customHeadersUserToken
        let nillableParameters: [String: Any?] = [:]
        let parameters = APIHelper.rejectNil(source: nillableParameters)
        let convertedParameters = APIHelper.convertBoolToString(source: parameters)
        let requestBuilder = RequestBuilder(urlString: URLString, requestMethod: Alamofire.HTTPMethod.init(rawValue: "PUT")!.rawValue, requestParameters: convertedParameters, requestEncoding: JSONEncoding.default, requestHeaders: headers, showLoader: false, requestCache: .RequestFromURLNoCache, requestShouldDisableInteraction: true)
        JSONRequest(requestBuilder: requestBuilder) { (response, isLoadedFromCache) in
            if response.result.isSuccess {
                guard let jsonResponse = response.result.value as? [String: AnyObject] else {
                    failureHandler(NSIError(error: response.result.error, response: response.result.value))
                    return
                }
                let nsiResponse = NSIResponse<Any>(JSON: jsonResponse)
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
