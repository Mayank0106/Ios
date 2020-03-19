/*import UIKit
class Meal {

    //Mark : Properties
    var name: String = ""
    var photo: UIImage?
    var rating: Int = 0
    
    //Mark : Initialization
    init?(name: String, photo: UIImage?, rating: Int) {
        
        //Initialization should fail if there is no name or if the rating in negative
        if name.isEmpty || rating < 0 {
            return nil
        }
        
        //Initialize Stored Properties
        self.name = name
        self.photo = photo
        self.rating = rating
    }
    
}
 
 Closures*******
var  additionOfTwoNumbers:(Int, Int) ->Int = {
    (number1, number2) in
    return number1 + number2
}

let result = additionOfTwoNumbers(10, 30)
print(result)
 */


/* Understanding UIKit and Foundation Kit*********
import Foundation
import Swift

var str = "Hello, playground"
let str2: NSString = "hello"
let str3: String = "hello"
 


//
//  ViewController.swift
//  AdvanceOfClasses
//
//  Created by Mayank Sharma on 13/03/20.
//  Copyright © 2020 Mayank Sharma. All rights reserved.
//




import UIKit
class Pizza {
    
    //MARK: Properties
    var diameter:Double = 0.0
    var crust:String = ""
    var toppings:[String] = []
    

    
    //MARK: Class Methods -- Constructors
    
    init(){}
    init(diameter:Double, crust:String, toppings:[String]){
        self.diameter = diameter
        self.crust = crust
        self.toppings = toppings
    
    }
    //MARK: Methods
    func toppingsString()->String {
        var myString = ""
        for topping in toppings {
            myString = myString + topping + ""
        }
        return myString
    }
    func area() -> Double {
        return diameter * diameter * M_PI
    }
    func price(costPerSquareUnit:Double) -> Double {
        return self.area() * costPerSquareUnit
    }

}

//******************************
// The subclass DeepDishPizza
//*****************************

class DeepDishPizza:Pizza{
    // A subclass of Pizza with a pan depth.
    //price is computed by volume
    //MARK: Properties
    var panDepth:Double = 4.0
    //MARK: Class Methods -- Constructors
    override init(){
        super.init()
    }
    
    init(panDepth:Double){
        super.init()
        self.panDepth = panDepth
    }

    init(diameter: Double, crust: String, toppings: [String], panDepth:Double) {
        super.init(diameter: diameter, crust: crust, toppings: toppings)
        self.panDepth = panDepth
    }
    
    //MARK: Instance Methods
    func volume() -> Double{
        return area() * panDepth
    }
    
    override func price(costPerSquareUnit: Double) -> Double {
        return volume() * costPerSquareUnit
    }
    
    func price(costPerSquareUnit:Double, panDepth:Double) -> Double{
        self.panDepth = panDepth
        return volume() * costPerSquareUnit
    }
}
*/
*/*/
protocol classa {
    var marks: Int { get set }
    var result: Bool { get }
    
    func attendance() -> String
    func markssecured() -> String
}
protocol classb: classa {
    var present: Bool { get set }
    var subject: String { get set }
    var stname: String { get set }
}

class classc: classb {
    var marks = 96
    let result = true
    var present = false
    var subject = "Swift 4 Protocols"
    var stname = "Protocols"
    
    func attendance() -> String {
        return "The \(stname) has secured 99% attendance"
    }
    func markssecured() -> String {
        return "\(stname) has scored \(marks)"
    }
}
let studdet = classc()
studdet.stname = "Swift 4"
studdet.marks = 98
studdet.markssecured()

print(studdet.marks)
print(studdet.result)
print(studdet.present)
print(studdet.subject)
print(studdet.stname)



