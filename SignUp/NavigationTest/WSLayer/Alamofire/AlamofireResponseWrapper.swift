//
//  AlamofireResponseWrapper.swift
//  Uplift

import Foundation

class AlamofireResponseWrapper: NSObject, NSCoding {

    var request: URLRequest?

    /// The server's response to the URL request.
    var response: HTTPURLResponse?

    /// The data returned by the server.
    var data: Data?

    init(request: URLRequest?, response: HTTPURLResponse?, data: Data?) {
        self.request = request
        self.response = response
        self.data = data
    }

    required init?(coder aDecoder: NSCoder) {
        request = aDecoder.decodeObject(forKey: "request") as? URLRequest
        response = aDecoder.decodeObject(forKey: "response") as? HTTPURLResponse
        data = aDecoder.decodeObject(forKey: "data") as? Data
    }

    func encode(with aCoder: NSCoder) {
        aCoder.encode(request, forKey: "request")
        aCoder.encode(response, forKey: "response")
        aCoder.encode(data, forKey: "data")
    }
}
