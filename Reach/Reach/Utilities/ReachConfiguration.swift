//
//  ReachConfiguration.swift

import UIKit

struct Configuration {

    static var config: String?
    static var variables: NSDictionary?
    static var customHeaders: [String: String] = ["Content-Type": "application/json"]
    static var customHeadersUserToken: [String: String] = ["Content-Type": "application/json"]
    static var customHeadersToken: [String: String] = ["Content-Type": "application/x-www-form-urlencoded"]

    /**
     Set the configuartion variables from plist
     */

    static func setConfiguaration() {
        if let configuration = Bundle.main.object(forInfoDictionaryKey: "Configuration") as? String {
            let configValue = configuration.replacingOccurrences(of: " ", with: "", options: .literal, range: nil)
            self.config = configValue.replacingOccurrences(of: ".", with: "", options: .literal, range: nil)
            if let path = Bundle.main.path(forResource: "Configuration", ofType: "plist") {
                // use swift dictionary as normal
                let dict = NSDictionary(contentsOfFile: path)
                self.variables = dict!.object(forKey: self.config!) as? NSDictionary
            }
        }
    }

    /**
     Get the base Url according to  configuration

     - returns: base url in string
     */

    static func BaseURL() -> String! {
        self.setConfiguaration()
        if (self.variables) != nil {
            if let url = self.variables!.object(forKey: "BaseURL") as? String {
                return url
            }
        }
        return ""
    }
    /**
     Get the clientSecret according to  configuration
     - returns: clientSecret for App in string
     */

    static func clientSecret() -> String! {
        self.setConfiguaration()
        if (self.variables) != nil {
            if let url = self.variables!.object(forKey: "clientSecret") as? String {
                return url
            }
        }
        return ""
    }
    /**
     Get the clientId according to  configuration
     - returns: clientId for App in string
     */

    static func clientId() -> String! {
        self.setConfiguaration()
        if (self.variables) != nil {
            if let url = self.variables!.object(forKey: "clientId") as? String {
                return url
            }
        }
        return ""
    }
    /**
     Get the userPassword according to  configuration
     - returns: clientId for App in string
     */

    static func userPassowrd() -> String! {
        self.setConfiguaration()
        if (self.variables) != nil {
            if let url = self.variables!.object(forKey: "userPassword") as? String {
                return url
            }
        }
        return ""
    }
    /**
     Get the userName according to  configuration
     - returns: clientId for App in string
     */

    static func userName() -> String! {
        self.setConfiguaration()
        if (self.variables) != nil {
            if let url = self.variables!.object(forKey: "userName") as? String {
                return url
            }
        }
        return ""
    }

    /**
     Get the grantType according to  configuration
     - returns: grantType for App in string
     */

    static func grantType() -> String! {
        self.setConfiguaration()
        if (self.variables) != nil {
            if let url = self.variables!.object(forKey: "grantType") as? String {
                return url
            }
        }
        return ""
    }

    /**
     Get the s3PoolId according to  configuration
     - returns: s3PoolId
     */
    
    static func s3PoolId() -> String! {
        self.setConfiguaration()
        if (self.variables) != nil {
            if let url = self.variables!.object(forKey: "s3PoolId") as? String {
                return url
            }
        }
        return ""
    }
    /**
     Get the s3BucketName according to  configuration
     - returns: s3BucketName
     */
    static func s3BucketName() -> String! {
        self.setConfiguaration()
        if (self.variables) != nil {
            if let url = self.variables!.object(forKey: "s3BucketName") as? String {
                return url
            }
        }
        return ""
    }
    /**
     Get the s3Path according to  configuration
     - returns: s3Path
     */
    static func s3Path() -> String! {
        self.setConfiguaration()
        if (self.variables) != nil {
            if let url = self.variables!.object(forKey: "s3Path") as? String {
                return url
            }
        }
        return ""
    }

    /**
     Get the nexmoAPIKey according to  configuration
     - returns: nexmoAPIKey for App in string
     */

    static func nexmoApiKey() -> String! {
        self.setConfiguaration()
        if (self.variables) != nil {
            if let url = self.variables!.object(forKey: "nexmoApiKey") as? String {
                return url
            }
        }
        return ""
    }

    /**
     Get the nexmoSecretKey according to  configuration
     - returns: nexmoAPIKey for App in string
     */

    static func nexmoSecretKey() -> String! {
        self.setConfiguaration()
        if (self.variables) != nil {
            if let url = self.variables!.object(forKey: "nexmoSecretKey") as? String {
                return url
            }
        }
        return ""
    }

    /**
     Get the Terms And Conditions URL according to  configuration
     - returns: Terms And Conditions URL for App in string
     */

    static func termsAndConditionsURL() -> String! {
        self.setConfiguaration()
        if (self.variables) != nil {
            if let url = self.variables!.object(forKey: "termsAndConditions") as? String {
                return url
            }
        }
        return ""
    }
    /**
     Get the Privacy Policy URL according to  configuration
     - returns: Privacy Policy URL for App in string
     */

    static func privacyPolicyURL() -> String! {
        self.setConfiguaration()
        if (self.variables) != nil {
            if let url = self.variables!.object(forKey: "privacyPolicy") as? String {
                return url
            }
        }
        return ""
    }
    /**
     Get the About Us according to  configuration
     - returns: About Us for App in string
     */

    static func aboutUsURL() -> String! {
        self.setConfiguaration()
        if (self.variables) != nil {
            if let url = self.variables!.object(forKey: "aboutUs") as? String {
                return url
            }
        }
        return ""
    }

}
