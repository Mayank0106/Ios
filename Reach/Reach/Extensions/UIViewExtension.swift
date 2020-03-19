//
//  UIViewExtension.swift
//  Feed Me
//
/// Copyright (c) 2017 Razeware LLC
///
/// Permission is hereby granted, free of charge, to any person obtaining a copy
/// of this software and associated documentation files (the "Software"), to deal
/// in the Software without restriction, including without limitation the rights
/// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
/// copies of the Software, and to permit persons to whom the Software is
/// furnished to do so, subject to the following conditions:
///
/// The above copyright notice and this permission notice shall be included in
/// all copies or substantial portions of the Software.
///
/// Notwithstanding the foregoing, you may not use, copy, modify, merge, publish,
/// distribute, sublicense, create a derivative work, and/or sell copies of the
/// Software in any work that is designed, intended, or marketed for pedagogical or
/// instructional purposes related to programming, coding, application development,
/// or information technology.  Permission for such use, copying, modification,
/// merger, publication, distribution, sublicensing, creation of derivative works,
/// or sale is expressly withheld.
///
/// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
/// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
/// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
/// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
/// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
/// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
/// THE SOFTWARE.

import UIKit
let navigationBarHeight: CGFloat = 64
let tabBarHeight: CGFloat = 44
extension UIView {

  func lock() {
    if let _ = viewWithTag(10) {
      //View is already locked
    } else {
      let lockView = UIView(frame: bounds)
        lockView.cornerRadiusView = self.cornerRadiusView
      lockView.backgroundColor = UIColor(white: 0.0, alpha: 0.75)
      lockView.tag = 10
      lockView.alpha = 0.0
      let activity = UIActivityIndicatorView(activityIndicatorStyle: .white)
      activity.hidesWhenStopped = true
      activity.center = lockView.center
      lockView.addSubview(activity)
      activity.startAnimating()
      addSubview(lockView)

      UIView.animate(withDuration: 0.2, animations: {
        lockView.alpha = 1.0
      })
    }
  }

  func unlock() {
    if let lockView = viewWithTag(10) {
      UIView.animate(withDuration: 0.2, animations: {
        lockView.alpha = 0.0
      }, completion: { _ in
        lockView.removeFromSuperview()
      })
    }
  }

  func fadeOut(_ duration: TimeInterval) {
    UIView.animate(withDuration: duration, animations: {
      self.alpha = 0.0
    })
  }

  func fadeIn(_ duration: TimeInterval) {
    UIView.animate(withDuration: duration, animations: {
      self.alpha = 1.0
    })
  }
    /// Add view on another view
    ///
    /// - parameter onView: view on which add popup
    func addView(onView: UIView) {
        self.frame = CGRect(x: 0, y: 0, width: (AppUtility.getAppDelegate()?.window?.frame.width)!, height: (AppUtility.getAppDelegate()?.window?.frame.height)! - (44 + navigationBarHeight + tabBarHeight))// 44 height of top view Bar
        onView.addSubview(self)
        onView.layoutIfNeeded()
    }
  class func viewFromNibName(_ name: String) -> UIView? {
    let views = Bundle.main.loadNibNamed(name, owner: nil, options: nil)
    return views?.first as? UIView
  }
  class func viewFromNibName(name: String) -> UIView? {

        let views = Bundle.main.loadNibNamed(name, owner: nil, options: nil)
        guard let viewsArr = views else { return UIView() }
        return viewsArr.first as? UIView
    }
}
@IBDesignable extension UIView {
    @IBInspectable var borderColorView: UIColor? {
        set {
            layer.borderColor = newValue?.cgColor
        }
        get {
            guard let color = layer.borderColor else {
                return nil
            }
            return UIColor(cgColor: color)
        }
    }
    @IBInspectable var borderWidthView: CGFloat {
        set {
            layer.borderWidth = newValue
        }
        get {
            return layer.borderWidth
        }
    }
    @IBInspectable var cornerRadiusView: CGFloat {
        set {
            layer.cornerRadius = newValue
            clipsToBounds = newValue > 0
        }
        get {
            return layer.cornerRadius
        }
    }
}
