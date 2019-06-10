//
//  ViewController.swift
//  RoutiNier
//
//  Created by Nazar Petruk on 02/06/2019.
//  Copyright © 2019 Nazar Petruk. All rights reserved.
//

import UIKit
import CoreData

class TodolistViewController: UITableViewController {
    var itemArray = [Item]()
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    // if selected category is set will load data from dataBase
    var selectedCategory : Category?{
        didSet{
            loadItem()
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

    }
    //Mark : TableView Datasource Methods
    
    //amount of rows
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return itemArray.count
    }
    //tableview cell creation + seting text from items in array
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ToDoItemCell", for: indexPath)
        let item = itemArray[indexPath.row]
        cell.textLabel?.text = item.title
        
        cell.accessoryType = item.done ? .checkmark : .none

        return cell
    }
    
    
    // MARK - TableView Delegate methods
        //creating delegate to check which row is selected
       //adding checkmark if the row is tapped
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//        context.delete(itemArray[indexPath.row])
//        itemArray.remove(at: indexPath.row)
        itemArray[indexPath.row].done = !itemArray[indexPath.row].done
        
        saveItems()
        
        tableView.deselectRow(at: indexPath, animated: true)
    }
    // MARK: Add new Item to the TableView
    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
        var textField = UITextField()
        //creating alert for new item creation
        let alert = UIAlertController(title: "Add new ToDo Item", message: "", preferredStyle: .alert)
    let action = UIAlertAction(title: "Add item", style: .default){
            (action) in
        //geting context out of appDelegate
        
        let newItem = Item(context: self.context)
        newItem.title = textField.text!
        newItem.done = false
        newItem.parentCategory = self.selectedCategory
        self.itemArray.append(newItem)//setting new item into array
        self.saveItems()
       
        }
        //adding text field into the alert message
        alert.addTextField { (alertTextField) in
            alertTextField.placeholder = "Create new item!"
            textField = alertTextField
        }
        //set on the alert
        alert.addAction(action)
        present(alert, animated: true, completion: nil)
    }
    func saveItems(){
        
        do {
           try context.save()
        }catch{
           print("Error saving context \(error)")
        }
        
        self.tableView.reloadData()//refresh data to show new element in tableView
        
    }
    func loadItem(with request: NSFetchRequest<Item> = Item.fetchRequest(), predicate: NSPredicate? = nil){
        let categoryPredicate = NSPredicate(format: "parentCategory.name MATCHES %@", selectedCategory!.name!)
        
        if let additionalPredicate = predicate{
            request.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [categoryPredicate,additionalPredicate])
        }else{
            request.predicate = categoryPredicate
        }

        
        do{
        itemArray = try context.fetch(request)
        }catch{
            print("Error fetching data from context \(error)")
        }
    }
    
}
// MARK: - Search Bar Methods
extension TodolistViewController: UISearchBarDelegate{
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        let request : NSFetchRequest<Item> = Item.fetchRequest()
        
       let predicate = NSPredicate(format: "title CONTAINS[cd] %@", searchBar.text!)
        
        request.sortDescriptors = [NSSortDescriptor(key: "title", ascending: true)]
        
        loadItem(with: request, predicate: predicate )
        
        tableView.reloadData()
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchBar.text?.count == 0 {
            loadItem()
            DispatchQueue.main.async{
                searchBar.resignFirstResponder()
            }
            
        }
    }
}


