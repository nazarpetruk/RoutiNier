//
//  CategoryViewController.swift
//  RoutiNier
//
//  Created by Nazar Petruk on 10/06/2019.
//  Copyright © 2019 Nazar Petruk. All rights reserved.
//

import UIKit
import RealmSwift
import ChameleonFramework

class CategoryViewController: SwipeTableViewController {
    let realm = try! Realm()
    var categoryArray: Results<Category>?
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadCategory()
        tableView.separatorStyle = .none
    }
     //MARK: - TableView Datasource Methods
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return categoryArray?.count ?? 1
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = super.tableView(tableView, cellForRowAt: indexPath)
        if let category = categoryArray?[indexPath.row]{
            cell.textLabel?.text = category.name
            guard let categoryColour = UIColor(hexString: category.colour) else {fatalError()}
            cell.backgroundColor = UIColor(hexString: category.colour)
            cell.textLabel?.textColor = ContrastColorOf(categoryColour, returnFlat: true)
        }
        return cell
    }
    

    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
        var textField = UITextField()
        //creating alert for new item creation
        let alert = UIAlertController(title: "Add new Routine Category", message: "", preferredStyle: .alert)
        let action = UIAlertAction(title: "Add", style: .default){
            (action) in
            let newCategory = Category()
            newCategory.name = textField.text!
            newCategory.colour = UIColor.randomFlat.hexValue()
            self.saveCategory(category: newCategory)
    }
        alert.addAction(action)
        //adding text field into the alert message
        alert.addTextField { (alertTextField) in
            alertTextField.placeholder = "Create new Routine!"
            textField = alertTextField
        }
        //set on the alert
        alert.addAction(action)
        present(alert, animated: true, completion: nil)
    }
    
    //MARK: - Data Manipulation Methods
    func saveCategory(category: Category){
        
        do {
            try realm.write {
                realm.add(category)
            }
        }catch{
            print("Error saving into realm \(error)")
        }
        
        self.tableView.reloadData()//refresh data to show new element in tableView
        
    }
    func loadCategory(){
        categoryArray = realm.objects(Category.self)
        tableView.reloadData()
    }
    //MARK: - Delete Data from Swipe
    override func updateModel(at indexPath: IndexPath) {
        if let categoryForDeletion = self.categoryArray?[indexPath.row]{
            do{
                try self.realm.write {
                    self.realm.delete(categoryForDeletion)
                }
            }catch{
                print("Error in item deleting \(error)")
            }
        }
    }
    //MARK: - TableView Delegate Methods
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "goToItems", sender: self)
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let destinationVC = segue.destination as! TodolistViewController
        if let indexPath = tableView.indexPathForSelectedRow{
            destinationVC.selectedCategory = categoryArray?[indexPath.row] 
        }
    }
    
    
}
