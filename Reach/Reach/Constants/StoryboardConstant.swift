// Generated using SwiftGen, by O.Halligon — https://github.com/AliSoftware/SwiftGen

import Foundation
import UIKit
import Reach

// swiftlint:disable file_length
// swiftlint:disable line_length
// swiftlint:disable type_body_length

protocol StoryboardSceneType {
  static var storyboardName: String { get }
}

extension StoryboardSceneType {
  static func storyboard() -> UIStoryboard {
    return UIStoryboard(name: self.storyboardName, bundle: nil)
  }

  static func initialViewController() -> UIViewController {
    guard let vc = storyboard().instantiateInitialViewController() else {
      fatalError("Failed to instantiate initialViewController for \(self.storyboardName)")
    }
    return vc
  }
}

extension StoryboardSceneType where Self: RawRepresentable, Self.RawValue == String {
  func viewController() -> UIViewController {
    return Self.storyboard().instantiateViewController(withIdentifier: self.rawValue)
  }
  static func viewController(identifier: Self) -> UIViewController {
    return identifier.viewController()
  }
}

protocol StoryboardSegueType: RawRepresentable { }

extension UIViewController {
  func perform<S: StoryboardSegueType>(segue: S, sender: Any? = nil) where S.RawValue == String {
    performSegue(withIdentifier: segue.rawValue, sender: sender)
  }
}

struct StoryboardScene {
  enum LaunchScreen: StoryboardSceneType {
    static let storyboardName = "LaunchScreen"
  }
  enum Main: String, StoryboardSceneType {
    static let storyboardName = "Main"

    static func initialViewController() -> UINavigationController {
      guard let vc = storyboard().instantiateInitialViewController() as? UINavigationController else {
        fatalError("Failed to instantiate initialViewController for \(self.storyboardName)")
      }
      return vc
    }

    case homeVCScene = "HomeVC"
    static func instantiateHomeVC() -> Reach.HomeVC {
      guard let vc = StoryboardScene.Main.homeVCScene.viewController() as? Reach.HomeVC
      else {
        fatalError("ViewController 'HomeVC' is not of the expected class Reach.HomeVC.")
      }
      return vc
    }

    case otpvcScene = "OTPVC"
    static func instantiateOtpvc() -> Reach.OTPVC {
      guard let vc = StoryboardScene.Main.otpvcScene.viewController() as? Reach.OTPVC
      else {
        fatalError("ViewController 'OTPVC' is not of the expected class Reach.OTPVC.")
      }
      return vc
    }

    case signInVCScene = "SignInVC"
    static func instantiateSignInVC() -> Reach.SignInVC {
      guard let vc = StoryboardScene.Main.signInVCScene.viewController() as? Reach.SignInVC
      else {
        fatalError("ViewController 'SignInVC' is not of the expected class Reach.SignInVC.")
      }
      return vc
    }

    case signUpVCScene = "SignUpVC"
    static func instantiateSignUpVC() -> Reach.SignUpVC {
      guard let vc = StoryboardScene.Main.signUpVCScene.viewController() as? Reach.SignUpVC
      else {
        fatalError("ViewController 'SignUpVC' is not of the expected class Reach.SignUpVC.")
      }
      return vc
    }

    case verifyMobileNumberVCScene = "VerifyMobileNumberVC"
    static func instantiateVerifyMobileNumberVC() -> Reach.VerifyMobileNumberVC {
        guard let vc = StoryboardScene.Main.verifyMobileNumberVCScene.viewController() as? Reach.VerifyMobileNumberVC
            else {
                fatalError("ViewController 'VerifyMobileNumberVC' is not of the expected class Reach.VerifyMobileNumberVC.")
        }
        return vc
    }
  }
}

struct StoryboardSegue {
  enum Main: String, StoryboardSegueType {
    case toSignUpVC = "ToSignUpVC"
    case toSignInVC = "ToSignInVC"
    case toForgotPasswordVC = "ToForgotPasswordVC"
    case toInputMobileNumberVC = "ToInputMobileNumberVC"
    case toEnterOTPVC = "ToEnterOTPVC"
    case toEnterOTPFromForgotPasswordVC = "ToEnterOTPFromForgotPasswordVC"
    case toResetPasswordVC = "ToResetPasswordVC"
  }
}
