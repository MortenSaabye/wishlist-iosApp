//
//  CategoryViewController.swift
//  birthday-wishes
//
//  Created by Morten Saabye Kristensen on 18/09/2017.
//  Copyright © 2017 Morten Saabye Kristensen. All rights reserved.
//

import UIKit

class CategoryViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate {
//    MARK: Properties
    var category = ""
    var newCategoryCreated = false
    @IBOutlet weak var newCategoryTextField: UITextField!
    @IBOutlet weak var categoryTableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        categoryTableView.delegate = self
        categoryTableView.dataSource = self
        newCategoryTextField.delegate = self
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
//    MARK: UITableViewDatasource
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return Wish.categories.count
    }
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "CategoryCell", for: indexPath) as? CategoryTableViewCell else {
            fatalError("Could not cast tableViewCell as CategorytableViewCell")
        }
        cell.categoryLabel.text = Wish.categories[indexPath.row]
        return cell
    }
    
//    MARK: Navigation 
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let cell = sender as? CategoryTableViewCell else {
            fatalError("Could not cast to CategoryTableViewCell")
        }
        if let category = cell.categoryLabel.text {
            self.category = category
        }
    }

//    MARK: UITextFieldDelegate
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    func textFieldDidEndEditing(_ textField: UITextField) {
        guard let category = textField.text, category.isEmpty == false else {
            print("Nothing was added")
            return
        }
        if Wish.categories.contains(category) == true {
            let alert = UIAlertController(title: "Category already exists", message: "Select the existing category instead", preferredStyle: .alert)
            let alertAction = UIAlertAction(title: "OK", style: .default, handler: nil)
            alert.addAction(alertAction)
            present(alert, animated: true, completion: nil)
        } else {
            Wish.categories.append(category)
            self.newCategoryCreated = true
            categoryTableView.reloadData()
            textField.text = ""
        }
    }
}














