// APIHelper.swift
//
// Generated by swagger-codegen
// https://github.com/swagger-api/swagger-codegen
//

class APIHelper {
    static func rejectNil(source: [String: Any?]) -> [String: Any]? {
        var destination = [String: Any]()
        for (key, nillableValue) in source {
            if let value: Any = nillableValue {
                destination[key] = value
            }
        }
        if destination.isEmpty {
            return nil
        }
        return destination
    }

    static func convertBoolToString(source: [String: Any]?) -> [String: Any]? {
        guard let source = source else {
            return nil
        }
        var destination = [String: Any]()
        for (key, value) in source {
            if value is Bool {
                destination[key] = "\(value)"
            } else {
                destination[key] = value
            }
        }
        return destination
    }
}
