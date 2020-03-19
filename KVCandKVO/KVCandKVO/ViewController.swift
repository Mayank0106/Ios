//
//  ViewController.swift
//  KVCandKVO
//
//  Created by Mayank Sharma on 06/02/20.
//  Copyright © 2020 Mayank Sharma. All rights reserved.
//

import UIKit

class User: NSObject{
    @objc dynamic  var name = String()
    @objc var age = 0{
        willSet { willChangeValue(forKey: #keyPath(age))   }
        didSet  { didChangeValue(for: \User.age )}
        
        }
}

class ViewController: UIViewController {
    
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var ageLabel: UILabel!
    @IBOutlet weak var textLabel: UILabel!
    @IBOutlet weak var textField: UITextField!
    
    var nameObservationToken: NSKeyValueObservation?
    var ageObservationToken: NSKeyValueObservation?
    var inputTextObservationToken: NSKeyValueObservation?
    
        @objc let user = User()
    
    @objc dynamic var inputText: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        nameObservationToken = observe(\ViewController.user.name, options: [.new]) { (strongSelf, change) in
            
            guard let updatedName = change.newValue else { return }
            strongSelf.nameLabel.text = updatedName
            
        }
        
        ageObservationToken = observe(\.user.age, options: .new, changeHandler: { (vc, change) in
            guard let updatedAge = change.newValue else { return }
            vc.ageLabel.text = String(updatedAge)
    })
        
        inputTextObservationToken = observe(\.inputText, options: .new, changeHandler: { (vc, change) in
            guard let updatedInputText = change.newValue as? String else { return }
            vc.textLabel.text = updatedInputText
    })
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        nameObservationToken?.invalidate()
        ageObservationToken?.invalidate()
        
    }
    
    
    @IBAction func didTapUpdateName()  {
        user.name = "Mayank"
    }
    
    
    @IBAction func didTapUpdateAge() {
        
        user.age = 21
    }
    
    @IBAction func textFieldTextDidChange() {
        
        inputText = textField.text
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
    
    
    }


}

