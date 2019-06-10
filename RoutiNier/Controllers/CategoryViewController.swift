//
//  CategoryViewController.swift
//  RoutiNier
//
//  Created by Nazar Petruk on 10/06/2019.
//  Copyright © 2019 Nazar Petruk. All rights reserved.
//

import UIKit
import CoreData

class CategoryViewController: UITableViewController {
    var categoryArray = [Category]()
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadCategory()
    }
     //MARK: - TableView Datasource Methods
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return categoryArray.count
    }
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CategoryCell", for: indexPath)
        
        cell.textLabel?.text = categoryArray[indexPath.row].name
        return cell
    }
    

    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
        var textField = UITextField()
        //creating alert for new item creation
        let alert = UIAlertController(title: "Add new Routine Category", message: "", preferredStyle: .alert)
        let action = UIAlertAction(title: "Add", style: .default){
            (action) in
            //geting context out of appDelegate
            
            let newCategory = Category(context: self.context)
            newCategory.name = textField.text!
            
            self.categoryArray.append(newCategory)//setting new item into array
            self.saveCategory()
    }
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
    func saveCategory(){
        
        do {
            try context.save()
        }catch{
            print("Error saving context \(error)")
        }
        
        self.tableView.reloadData()//refresh data to show new element in tableView
        
    }
    func loadCategory(with request: NSFetchRequest<Category> = Category.fetchRequest()){
        do{
            categoryArray = try context.fetch(request)
        }catch{
            print("Error fetching data from context \(error)")
        }
        
    }
    //MARK: - TableView Delegate Methods
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "goToItems", sender: self)
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let destinationVC = segue.destination as! TodolistViewController
        if let indexPath = tableView.indexPathForSelectedRow{
            destinationVC.selectedCategory = categoryArray[indexPath.row]
        }
    }
    //MARK: - TableView Datasource Methods
    
}
