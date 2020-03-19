//
//  RequestBuilder.swift
//  Uplift
//
//  Copyright © 2016 Net Solutions. All rights reserved.
//

import Foundation
import Alamofire

struct RequestBuilder {

    var URLString: String
    var method: Alamofire.HTTPMethod
    var parameters: [String: Any]?
    var encoding: ParameterEncoding
    var headers: [String: String]?
    var cache: CachePolicy
    var shouldShowLoader: Bool
    var shouldDisableInteraction: Bool

    init(urlString: String, requestMethod: String = "POST", requestParameters: [String: Any]? = nil, requestEncoding: ParameterEncoding = JSONEncoding.default, requestHeaders: [String: String]? = nil, showLoader: Bool = false, requestCache: CachePolicy = .RequestFromURLNoCache, requestShouldDisableInteraction: Bool = false) {
        URLString = urlString
        method = Alamofire.HTTPMethod.init(rawValue: requestMethod) ?? .post
        parameters = requestParameters
        encoding = requestEncoding
        headers = requestHeaders
        cache = requestCache
        shouldShowLoader = showLoader
        shouldDisableInteraction = showLoader
    }
}
