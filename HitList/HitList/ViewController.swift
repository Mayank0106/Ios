//
//  ViewController.swift
//  HitList
//
//  Created by Mayank Sharma on 18/02/20.
//  Copyright © 2020 Mayank Sharma. All rights reserved.
//

import UIKit
import CoreData



class ViewController: UIViewController, UITableViewDelegate {
    @IBOutlet weak var tblPersonList: UITableView!
    var people: [NSManagedObject] = []
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        self.fetchPersonObjects()
    }
    
    func fetchPersonObjects() {
        guard let appDelegate =
            UIApplication.shared.delegate as? AppDelegate else {
                return
        }
        //fetch Request
        let managedContext = appDelegate.persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "Person")
        
        do {
            people = try managedContext.fetch(fetchRequest)
            print("arr People are", people)
            tblPersonList.reloadData()
        } catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        title = "The List"
        //TableView.register(UITableViewCell.self, forCellReuseIdentifier: "Cell")
    }
    // Do any additional setup after loading the view, typically from a nib.
    
    
    @IBAction func addName(_ sender: UIBarButtonItem) {
        
        let alert = UIAlertController(title: "New Name",message: "Add a new name",preferredStyle: .alert)
        let saveAction = UIAlertAction(title: "Save",style: .default) {[unowned self] action in
            guard let textField = alert.textFields?.first, let nameToSave = textField.text else {
                return
            }
            self.save(name: nameToSave)
            self.tblPersonList.reloadData()
        }
        
        let cancelAction = UIAlertAction(title: "Cancel",
                                         style: .cancel)
        alert.addTextField()
        alert.addAction(saveAction)
        alert.addAction(cancelAction)
        present(alert, animated: true)
        
    }
    
    
    func save(name: String) {
        
        guard let appDelegate =
            UIApplication.shared.delegate as? AppDelegate else {
                return
        }
        
        let managedContext =
            appDelegate.persistentContainer.viewContext
        
        let entity =
            NSEntityDescription.entity(forEntityName: "Person",
                                       in: managedContext)!
        
        let person = NSManagedObject(entity: entity,
                                     insertInto: managedContext)
        
        
        person.setValue(name, forKeyPath: "name")
        
        
        do {
            try managedContext.save()
            people.append(person)
        } catch let error as NSError {
            print("Could not save. \(error), \(error.userInfo)")
        }
    }
    
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}



// MARK: - UITableViewDataSource
extension ViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView,
                   numberOfRowsInSection section: Int) -> Int {
        return people.count
    }
    
    func tableView(_ tableView: UITableView,
                   cellForRowAt indexPath: IndexPath)
        -> UITableViewCell {
            guard  let cell = tableView.dequeueReusableCell(withIdentifier: "UserTableVIewCellIdentifier", for: indexPath) as? UserTableVIewCell else {
                return UITableViewCell()
            }
            let people = self.people[indexPath.row]
            if let name = people.value(forKeyPath: "name") as? String {
                cell.lblPersonName.text = name
            }
            cell.subscribeButtonAction = {[unowned self] in
                let selectedPerson = self.people[indexPath.row]
                let alert = UIAlertController(title: "Alert!", message: "Are you sure you want to delete \(String(describing: selectedPerson.value(forKeyPath: "name")!)))", preferredStyle: .alert)
                
                let yesAction = UIAlertAction(title: "YES", style: .cancel) { (action:UIAlertAction) in
                    print("You've pressed cancel");
                    self.deletePerson(people: selectedPerson)
                }
                
                let noAction = UIAlertAction(title: "No" , style: .default, handler: nil)
                alert.addAction(yesAction)
                alert.addAction(noAction)
                self.present(alert, animated: true, completion: nil)
            }
    
            cell.updateButtonAction = {[unowned self] in
                let person = self.people[indexPath.row]
                let alert = UIAlertController(title: "New Name",message: "Update a new name \(String(describing: person.value(forKeyPath: "name")!)))",preferredStyle: .alert)
                let UpdateAction = UIAlertAction(title: "Save",style: .default) {[unowned self] action in
                    guard let textField = alert.textFields?.first, let updateToSave = textField.text else {
                        return
                    }
                    self.updateRecord(people: person, changedName: updateToSave)
                    self.tblPersonList.reloadData()
                }
            
                let noAction = UIAlertAction(title: "No" , style: .default, handler: nil)
                alert.addTextField()
                alert.addAction(UpdateAction)
                alert.addAction(noAction)
                self.present(alert, animated: true, completion: nil)
                guard let textField = alert.textFields?.first else {
                    return
                }
                textField.text = person.value(forKeyPath: "name") as? String
            }
            return cell
    }
   
    //For Delete Button
    
    func deletePerson(people: NSManagedObject) {
        guard let appDelegate =
            UIApplication.shared.delegate as? AppDelegate else {
                return
        }
        let managedContext =
            appDelegate.persistentContainer.viewContext
        managedContext.delete(people)//For delete
        
        do {
            try managedContext.save()
            self.fetchPersonObjects()
        }
        catch {
            print(error.localizedDescription)
        }
    }
    
     //For Update Button
    func updateRecord(people: NSManagedObject, changedName: String){
        guard let appDelegate =
            UIApplication.shared.delegate as? AppDelegate else {
                return
        }
        let managedContext =
             appDelegate.persistentContainer.viewContext
             people.setValue(changedName, forKey: "name")//ForUpdate
        do {
            try managedContext.save()
            self.fetchPersonObjects()
        }
        catch {
            print(error.localizedDescription)
        }
    }
}





















