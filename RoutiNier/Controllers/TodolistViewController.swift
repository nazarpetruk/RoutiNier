//
//  ViewController.swift
//  RoutiNier
//
//  Created by Nazar Petruk on 02/06/2019.
//  Copyright © 2019 Nazar Petruk. All rights reserved.
//

import UIKit
import RealmSwift
import ChameleonFramework

class TodolistViewController: SwipeTableViewController {
    let realm = try!  Realm()
    var todoItems: Results<Item>?
  
    @IBOutlet weak var searchBar: UISearchBar!
    // if selected category is set will load data from dataBase
    var selectedCategory : Category?{
        didSet{
            loadItem()
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.separatorStyle = .none
        
    }
    override func viewWillAppear(_ animated: Bool) {
        title = selectedCategory?.name
        guard let colourHex = selectedCategory?.colour else {fatalError()}
        updateNavBar(withHexCode: colourHex)
        }
    
    override func viewWillDisappear(_ animated: Bool) {
        updateNavBar(withHexCode: "1D9BF6")
    }
    
    //MARK : New Bar Setup Methods
    func updateNavBar (withHexCode colourHexCode: String){
        guard let navBar = navigationController?.navigationBar else {fatalError("Navigation controller doesn't exist.")}
        guard let colourHex = selectedCategory?.colour else {fatalError()}
        title = selectedCategory!.name
        guard let navBarColour = UIColor(hexString: colourHexCode) else {fatalError()}
        navBar.barTintColor = navBarColour
        navBar.tintColor = ContrastColorOf(navBarColour, returnFlat: true)
        navBar.largeTitleTextAttributes = [NSAttributedString.Key.foregroundColor: ContrastColorOf(navBarColour, returnFlat: true)]
        
        searchBar.barTintColor =  UIColor(hexString: colourHex)
    }
    
    //Mark : TableView Datasource Methods
    
    //amount of rows
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return todoItems?.count ?? 1
    }
    //tableview cell creation + seting text from items in array
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = super.tableView(tableView, cellForRowAt: indexPath)
        if let item = todoItems?[indexPath.row] {
            
            cell.textLabel?.text = item.title
//if UIColour is not nill the darken is trigered
            if let colour = UIColor(hexString: selectedCategory!.colour)?.darken(byPercentage: CGFloat(indexPath.row) / CGFloat(todoItems!.count)){
                cell.backgroundColor = colour
                cell.textLabel?.textColor = ContrastColorOf(colour, returnFlat: true)
            }
            
            cell.accessoryType = item.done ? .checkmark : .none
        }else{
            cell.textLabel?.text = "No Items Added"
        }
        return cell
    }
    
    
    // MARK - TableView Delegate methods
        //creating delegate to check which row is selected
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //adding checkmark if the row is tapped
        if let item = todoItems?[indexPath.row]{
            do{
                try realm.write {
                   item.done = !item.done
                }
            }catch{
                print("ERROR saving done status \(error)")
            }
        }
        tableView.reloadData()
        tableView.deselectRow(at: indexPath, animated: true)
    }
    // MARK: Add new Item to the TableView
    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
        var textField = UITextField()
        //creating alert for new item creation
        let alert = UIAlertController(title: "Add new ToDo Item", message: "", preferredStyle: .alert)
    let action = UIAlertAction(title: "Add item", style: .default){
            (action) in
        
        if let currentCategory = self.selectedCategory{
             do{
                try self.realm.write {
                  let newItem = Item()
                  newItem.title = textField.text!
                  currentCategory.item.append(newItem)
                  }
            }catch{
                print("Error saving new items, \(error)")
            }
        }
        self.tableView.reloadData()
        
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
    
    func loadItem(){
       todoItems = selectedCategory?.item.sorted(byKeyPath: "title", ascending: true)
       tableView.reloadData()
    }
    override func updateModel(at indexPath: IndexPath) {
        if let itemForDeletion = self.todoItems?[indexPath.row]{
            do{
                try self.realm.write {
                    self.realm.delete(itemForDeletion)
                }
            }catch{
                print("Error in item deleting \(error)")
            }
        }
    }
    
}
// MARK: - Search Bar Methods
extension TodolistViewController: UISearchBarDelegate{
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        todoItems = todoItems?.filter("title CONTAINS[cd] %@", searchBar.text!).sorted(byKeyPath: "title", ascending: true)
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


