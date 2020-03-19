//
//  Alamofire.swift

import Foundation
import Alamofire
import SVProgressHUD
import AwesomeCache

// swiftlint:disable type_name

/// Cache expiry in seconds, default to 1 day
let cacheExpiry = 86400.0

/**
 Enum for cache policy

 - RequestFromURLNoCache:                                       Fetch from URL only not from cache
 - RequestFromCacheFirstThenFromURLAndUpdateInCache:            Fetch from cache first then from url and update in cache
 - RequestFromCacheFirstThenFromURLIfDifferentAndUpdateInCache: Fetch from cache first then from url if data different in cache and update in cache
 - RequestFromCacheIfAvailableOtherwiseFromUrlAndUpdateInCache: Fetch from cache if available other from url and update in cache
 - RequestFromUrlAndUpdateInCache:                              Fetch from url only and update in cache
 - RequestFromCacheOnlyThenCallUrlInBackgroundAndUpdateInCache: Fetch from cache only and then call url in background and update in cache
 */
enum CachePolicy {
    case RequestFromURLNoCache
    case RequestFromCacheFirstThenFromURLAndUpdateInCache
    case RequestFromCacheFirstThenFromURLIfDifferentAndUpdateInCache
    case RequestFromCacheIfAvailableOtherwiseFromUrlAndUpdateInCache
    case RequestFromUrlAndUpdateInCache
    case RequestFromCacheOnlyThenCallUrlInBackgroundAndUpdateInCache
}

// MARK: Requests

/**
 JSON request

 - parameter requestBuilder:            contains url, method and various parameters required for the service call
 - parameter completionHandler:         closure called when request completed
 */
func JSONRequest(requestBuilder: RequestBuilder,
                 completionHandler: @escaping (DataResponse<Any>, Bool) -> Void) {

    request(responseSerializer: Alamofire.DataRequest.jsonResponseSerializer(), requestBuilder: requestBuilder, completionHandler: completionHandler)
}

/**
 Data request

 - parameter requestBuilder:            contains url, method and various parameters required for the service call
 - parameter completionHandler:         closure called when request completed
 */
func DataRequest(requestBuilder: RequestBuilder,
                 completionHandler: @escaping (DataResponse<Data>, Bool) -> Void) {

    request(responseSerializer: Alamofire.DataRequest.dataResponseSerializer(), requestBuilder: requestBuilder, completionHandler: completionHandler)
}

/**
 String request

 - parameter requestBuilder:            contains url, method and various parameters required for the service call
 - parameter completionHandler:         closure called when request completed
 */
func StringRequest(requestBuilder: RequestBuilder,
                   completionHandler: @escaping (DataResponse<String>, Bool) -> Void) {

    request(responseSerializer: Alamofire.DataRequest.stringResponseSerializer(), requestBuilder: requestBuilder, completionHandler: completionHandler)
}

/**
 Property list request

 - parameter requestBuilder:            contains url, method and various parameters required for the service call
 - parameter completionHandler:         closure called when request completed
 */
func PropertyListRequest(requestBuilder: RequestBuilder,
                         completionHandler: @escaping (DataResponse<Any>, Bool) -> Void) {

    request(responseSerializer: Alamofire.DataRequest.propertyListResponseSerializer(), requestBuilder: requestBuilder, completionHandler: completionHandler)
}

// MARK: Generic request

/**
 Generic request called by other request methods

 - parameter responseSerializer:        type of serializer: json, data etc
 - parameter requestBuilder:            contains url, method and various parameters required for the service call
 - parameter completionHandler:         closure called when request completed
 */
private func request<T: DataResponseSerializerProtocol>(responseSerializer: T, requestBuilder: RequestBuilder, completionHandler: @escaping (DataResponse<T.SerializedObject>, Bool) -> Void) {

    let cacheKey = getKeyForCacheAccordingToUrl(url: requestBuilder.URLString, parameters: requestBuilder.parameters, headers: requestBuilder.headers)
    var cachedData: Data?
    var isDataReturnedFromCache = false

    if shouldRequestFromCache(cache: requestBuilder.cache) {
        isDataReturnedFromCache = cachedRequest(responseSerializer: responseSerializer, cacheKey: cacheKey, completionHandler: { (response, isLoadedFromCache) in
            cachedData = response.data
            completionHandler(response, isLoadedFromCache)
        })
    }

    if shouldRequestFromURL(cache: requestBuilder.cache, isDataReturnedFromCache: isDataReturnedFromCache) {

        manageUIInteractionAndLoader(isServiceStart: true, requestBuilder: requestBuilder, isDataReturnedFromCache: isDataReturnedFromCache)

        Alamofire.request(requestBuilder.URLString, method: requestBuilder.method, parameters: requestBuilder.parameters, encoding: requestBuilder.encoding, headers: requestBuilder.headers)
            .validate()
            .response(responseSerializer: responseSerializer, completionHandler: { (response) in

                manageUIInteractionAndLoader(isServiceStart: false, requestBuilder: requestBuilder, isDataReturnedFromCache: isDataReturnedFromCache)
                _ = saveResponseInCache(responseSerializer: responseSerializer, response: response, cacheKey: cacheKey, cache: requestBuilder.cache)

                guard requestBuilder.cache != .RequestFromCacheOnlyThenCallUrlInBackgroundAndUpdateInCache else {
                    return
                }

                if requestBuilder.cache == .RequestFromCacheFirstThenFromURLIfDifferentAndUpdateInCache && cachedData != nil && response.data != nil && cachedData! == response.data! {
                    return                                   // Don't call completion closure if cachedData & url responseData is same
                }
                completionHandler(response, false)
            })
    }
}

// MARK: Caching

/**
 Get cached data

 - parameter responseSerializer: type of serializer json, data etc
 - parameter cacheKey:           unique key of cached data
 - parameter completionHandler:  handler to return cached data

 - returns: bool to represent whether the cached data is returned or not
 */
private func cachedRequest<T: DataResponseSerializerProtocol>(responseSerializer: T, cacheKey: String, completionHandler: @escaping (DataResponse<T.SerializedObject>, Bool) -> Void) -> Bool {

    let startTime = CFAbsoluteTimeGetCurrent()

    guard let wrapperResponse = getResponseFromCache(cacheKey: cacheKey) else {
        return false
    }

    let result = responseSerializer.serializeResponse(wrapperResponse.request, wrapperResponse.response, wrapperResponse.data, nil)

    let timeline = getTimeline(startTime: startTime)

    let response = DataResponse<T.SerializedObject>(request: wrapperResponse.request, response: wrapperResponse.response, data: wrapperResponse.data, result: result, timeline: timeline)

    completionHandler(response, true)

    return true
}

/**
 Get response wrapper object from cache

 - parameter cacheKey: unique key of cached data

 - returns: Object of AlamofireResponseWrapper
 */
private func getResponseFromCache(cacheKey: String) -> AlamofireResponseWrapper? {

    do {
        let cache = try Cache<AlamofireResponseWrapper>(name: "awesomeCache")
        let responseData = cache[cacheKey]
        return responseData
    } catch _ {
        print("Something went wrong :(")
        return nil
    }
}

/**
 Save response in cache

 - parameter responseSerializer: type of serializer json, data etc
 - parameter response:           struct of response
 - parameter cacheKey:           unique key of cached data
 - parameter cache:              cache policy

 - returns: bool to represent whether value is saved in cache or not
 */
private func saveResponseInCache<T: DataResponseSerializerProtocol>(responseSerializer: T, response: DataResponse<T.SerializedObject>, cacheKey: String, cache: CachePolicy) -> Bool {

    if cache == .RequestFromURLNoCache || response.result.isFailure {
        return false
    }

    do {
        let cache = try Cache<AlamofireResponseWrapper>(name: "awesomeCache")

        let wrapperResponse = AlamofireResponseWrapper(request: response.request, response: response.response, data: response.data)
        cache.setObject(wrapperResponse, forKey: cacheKey, expires: .seconds(cacheExpiry))
        return true

    } catch _ {
        print("Something went wrong :(")
        return false
    }}

/**
 Should request from url or not

 - parameter cache:                   cache policy
 - parameter isDataReturnedFromCache: bool to represent whether the data is returned from cache or not

 - returns: bool to represent whether request from url or not
 */
private func shouldRequestFromURL(cache: CachePolicy, isDataReturnedFromCache: Bool) -> Bool {

    switch cache {
    case .RequestFromURLNoCache,
         .RequestFromCacheFirstThenFromURLAndUpdateInCache,
         .RequestFromUrlAndUpdateInCache,
         .RequestFromCacheOnlyThenCallUrlInBackgroundAndUpdateInCache,
         .RequestFromCacheFirstThenFromURLIfDifferentAndUpdateInCache:
        return true
    case .RequestFromCacheIfAvailableOtherwiseFromUrlAndUpdateInCache:
        return !isDataReturnedFromCache
    }
}

/**
 Should request from cache or not

 - parameter cache: cache policy

 - returns: bool to represent whether request from cache or not
 */
private func shouldRequestFromCache(cache: CachePolicy) -> Bool {
    switch cache {
    case .RequestFromURLNoCache, .RequestFromUrlAndUpdateInCache:
        return false
    case .RequestFromCacheFirstThenFromURLAndUpdateInCache,
         .RequestFromCacheIfAvailableOtherwiseFromUrlAndUpdateInCache,
         .RequestFromCacheOnlyThenCallUrlInBackgroundAndUpdateInCache,
         .RequestFromCacheFirstThenFromURLIfDifferentAndUpdateInCache:
        return true
    }
}

// MARK: Helper methods

/**
 Get timeline object based on start time

 - parameter startTime: start time

 - returns: timeline object
 */
private func getTimeline(startTime: CFAbsoluteTime) -> Timeline {

    let requestCompletedTime = CFAbsoluteTimeGetCurrent()

    return Timeline(requestStartTime: startTime, initialResponseTime: requestCompletedTime, requestCompletedTime: requestCompletedTime, serializationCompletedTime: CFAbsoluteTimeGetCurrent())
}

/**
 Get the unique key for caching

 - parameter url:        url of the request
 - parameter parameters: parameters of the request
 - parameter headers:    headers of the request

 - returns: cache key
 */
private func getKeyForCacheAccordingToUrl(url: String, parameters: [String: Any]?, headers: [String: String]?) -> String {
    var cacheKey = url

    if parameters != nil {
        let allKeys = (parameters?.keys)!

        for key in allKeys {
            cacheKey = cacheKey.appending("\(key):\(parameters![key])")
        }
    }
    if headers != nil {
        let allKeys = (headers?.keys)!

        for key in allKeys {
            cacheKey = cacheKey.appending("\(key):\(headers![key])")
        }
    }
    return cacheKey
}

// MARK: UIInteraction & Loaders

/**
 Manages user interaction and loading indicator based on parameters

 - parameter isServiceStart:          bool to state whether service will start or is ended
 - parameter requestBuilder:          contains url, method and various parameters required for the service call
 - parameter isDataReturnedFromCache: bool to represent whether the data is returned from cache or not
 */
private func manageUIInteractionAndLoader(isServiceStart: Bool, requestBuilder: RequestBuilder, isDataReturnedFromCache: Bool) {

    UIApplication.shared.isNetworkActivityIndicatorVisible = isServiceStart

    let cache = requestBuilder.cache

    switch cache {
    case .RequestFromURLNoCache,
         .RequestFromCacheFirstThenFromURLAndUpdateInCache,
         .RequestFromCacheIfAvailableOtherwiseFromUrlAndUpdateInCache,
         .RequestFromUrlAndUpdateInCache:
        if isServiceStart {
            showLoader(requestBuilder: requestBuilder)
            userInteractionEnabled(requestBuilder: requestBuilder, interactionEnable: false)
        } else {
            hideLoader(requestBuilder: requestBuilder)
            userInteractionEnabled(requestBuilder: requestBuilder, interactionEnable: true)
        }
    case .RequestFromCacheFirstThenFromURLIfDifferentAndUpdateInCache:
        if !isDataReturnedFromCache {
            if isServiceStart {
                showLoader(requestBuilder: requestBuilder)
                userInteractionEnabled(requestBuilder: requestBuilder, interactionEnable: false)
            } else {
                hideLoader(requestBuilder: requestBuilder)
                userInteractionEnabled(requestBuilder: requestBuilder, interactionEnable: true)
            }
        }
    case .RequestFromCacheOnlyThenCallUrlInBackgroundAndUpdateInCache:
        // do nothing
        break
    }
}

/**
 Show loading indicator according to requestBuilder variable

 - parameter requestBuilder: contains url, method and various parameters required for the service call
 */
private func showLoader(requestBuilder: RequestBuilder) {
    if requestBuilder.shouldShowLoader {
        // show loader
        SVProgressHUD.setDefaultStyle(.custom)
        SVProgressHUD.setBackgroundColor(UIColor(red: 0, green: 0, blue: 0, alpha: 0.5))
        SVProgressHUD.setForegroundColor(UIColor.white)
        SVProgressHUD.show()
    }
}

/**
 Hide loading indicator

 - parameter requestBuilder: contains url, method and various parameters required for the service call
 */
private func hideLoader(requestBuilder: RequestBuilder) {
    if requestBuilder.shouldShowLoader {
        SVProgressHUD.dismiss()
    }
}

/**
 Enable or disable user interaction

 - parameter requestBuilder:    contains url, method and various parameters required for the service call
 - parameter interactionEnable: bool to represent whether to enable/disable user interaction
 */
private func userInteractionEnabled(requestBuilder: RequestBuilder, interactionEnable: Bool) {
    if requestBuilder.shouldDisableInteraction {
        UIApplication.shared.delegate?.window??.isUserInteractionEnabled = interactionEnable
    }
}
