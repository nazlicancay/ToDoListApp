//
//  ViewController.swift
//  ToDoApp
//
//  Created by Nazlıcan Çay on 8.03.2023.
//

import UIKit

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
   
    private var Models = [ToDoListItem]()

    let context = (UIApplication.shared.delegate as!AppDelegate).persistentContainer.viewContext
    
    let tableView : UITableView = {
        let table = UITableView()
        table.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        
        return table
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
       
        
        title = " Core Data To Do List "
        view.addSubview(tableView)
        GetAllItems()
        tableView.delegate = self
        tableView.dataSource = self
        tableView.frame = view.bounds
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(didTapAdd))
    }
    
    @objc func didTapAdd(){
        let alert = UIAlertController(title: "New Item", message: "Enter New Item", preferredStyle: .alert)
        alert.addTextField(configurationHandler: nil)
        alert.addAction(UIAlertAction(title: "Submit", style: .cancel, handler:{[weak self] _ in
            guard let field = alert.textFields?.first, let text = field.text, !text.isEmpty else{
                return
            }
            self?.CreateItem(name: text)
        }))
        present(alert , animated: true)
        
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let model = Models[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.textLabel?.text = model.name
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let item = Models[indexPath.row]
        let sheet = UIAlertController(title: "Edit", message: nil, preferredStyle: .actionSheet)
        
        sheet.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler:{ _ in
        }))
        sheet.addAction(UIAlertAction(title: "Edit", style: .default, handler:{ _ in
            
            let alert = UIAlertController(title: "Edit Item", message: "Edit Your Item", preferredStyle: .alert)
            alert.addTextField(configurationHandler: nil)
            alert.textFields?.first?.text = item.name
            alert.addAction(UIAlertAction(title: "Save", style: .cancel, handler:{[weak self] _ in
                guard let field = alert.textFields?.first, let NewName = field.text, !NewName.isEmpty else{
                    return
                }
                self?.UpdateItem(item: item, newName: NewName)
            }))
            self.present(alert , animated: true)

            
        }))
        
        
        sheet.addAction(UIAlertAction(title: "Delete", style: .destructive, handler:{[weak self] _ in
            
            self?.delete(item: item)
        }))
        
        present(sheet , animated: true)
        
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return Models.count
    }
    
   
    
    // MARK: - Core Data
    func GetAllItems(){
        do {
            Models = try context.fetch(ToDoListItem.fetchRequest())
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }catch{
            //error
        }
        
        
        
    }
    
    func CreateItem(name: String){
        let newItem = ToDoListItem(context: context)
        newItem.name = name
        newItem.createdAt = Date()
        
        do{
            try context.save()
            GetAllItems()
        }
        catch{
            // errror
        }
    }
    
    func delete (item : ToDoListItem){
        context.delete(item)
        
        do{
            try context.save()
            GetAllItems()
        }
        catch{
            // errror
        }
    }
    
    func UpdateItem(item : ToDoListItem, newName : String){
        
        item.name = newName
        
        do{
            try context.save()
            GetAllItems()
        }
        catch{
            // errror
        }
    }

}

