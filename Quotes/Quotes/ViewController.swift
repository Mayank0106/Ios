//
//  ViewController.swift
//  Quotes
//
//  Created by Mayank Sharma on 18/02/20.
//  Copyright © 2020 Mayank Sharma. All rights reserved.
//

import UIKit
import CoreData


class ViewController: UIViewController {
    
    private let persistentContainer = NSPersistentContainer(name: "Quotes")
    
    
    
    var quotes = [Quote]()
    {
        didSet{
            updateView()
        }
    }
    
    @IBOutlet var messageLabel: UILabel!
    @IBOutlet var tableView: UITableView!
    @IBOutlet var activityIndicatorView: UIActivityIndicatorView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupView()
        
        persistentContainer.loadPersistentStores { (persistentStoreDescription, error) in
            if let error = error {
                print("Unable to Load Persistent Store")
                print("\(error), \(error.localizedDescription)")
                
            } 
            else
            {
                self.setupView()
                
                do{
                    try self.fetchedResultsController.performFetch()
                } catch{
                    
                    let fetcherror = error as NSError
                    
                    print("unable to perform fetch request")
                    print("\(fetcherror), \(fetcherror.localizedDescription)")
                    
                }
                self.updateView()
            }
            
        }
    }
    
    
    fileprivate lazy  var fetchedResultsController: NSFetchedResultsController<Quote> = {
        // Create Fetch Request
        let fetchRequest: NSFetchRequest<Quote> = Quote.fetchRequest()
        
        // Configure Fetch Request
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "createdAt", ascending: true)]
        
        // Create Fetched Results Controller
        let fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: self.persistentContainer.viewContext, sectionNameKeyPath: nil, cacheName: nil)
        
        // Configure Fetched Results Controller
        fetchedResultsController.delegate = self as! NSFetchedResultsControllerDelegate
        
        return fetchedResultsController
    }()
    

    
    
    private func setupMessageLabel() {
        messageLabel.text = "You don't have any quotes yet."
    }
    
    private func updateView() {
        var hasQuotes = false
        if let Quotes = fetchedResultsController.fetchedObjects {
            
            hasQuotes = quotes.count > 0
        }
        tableView.isHidden = !hasQuotes
        messageLabel.isHidden = hasQuotes
        activityIndicatorView.stopAnimating()
    }
    
    
    
    private func setupView() {
        setupMessageLabel()
        
        updateView()
    }
    
    
    
    
    
    }
          // Do any additional setup after loading the view, typically from a nib.







    

extension ViewController: UITableViewDataSource, NSFetchedResultsControllerDelegate {
        
        func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
            guard let quotes = fetchedResultsController.fetchedObjects else { return 0 }
            return quotes.count
        }
        
        func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: QuoteTableViewCell.reuseIdentifier, for: indexPath) as? QuoteTableViewCell else {
                fatalError("Unexpected Index Path")
            }
            
            // Fetch Quote
            let quote = fetchedResultsController.object(at: indexPath)
            
            
            // Configure Cell
            cell.authorLabel.text = quote.author
            cell.contentsLabel.text = quote.contents
            
            return cell
        }
        
    }



