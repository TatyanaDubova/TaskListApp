//
//  ViewController.swift
//  TaskListApp
//
//  Created by brubru on 23.11.2023.
//

import UIKit

final class TaskListViewController: UITableViewController {
    private let storageManager = StorageManager.shared
    private let cellID = "task"
    private var taskList: [TaskStruct] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: cellID)
        view.backgroundColor = .white
        setupNavigationBar()
        fetchData()
    }
    
    @objc
    private func addNewTask() {
        showSeveAlert(with: "New Task", and: "What do you want to do?")
    }
}

// MARK: - Private Methods
private extension TaskListViewController {
    func setupNavigationBar() {
        title = "Task List"
        navigationController?.navigationBar.prefersLargeTitles = true
        
        let navBarAppearance = UINavigationBarAppearance()
        navBarAppearance.configureWithOpaqueBackground()
        
        navBarAppearance.backgroundColor = UIColor(named: "MilkBlue")
        
        navBarAppearance.titleTextAttributes = [.foregroundColor: UIColor.white]
        navBarAppearance.largeTitleTextAttributes = [.foregroundColor: UIColor.white]
        
        navigationController?.navigationBar.standardAppearance = navBarAppearance
        navigationController?.navigationBar.scrollEdgeAppearance = navBarAppearance
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            barButtonSystemItem: .add,
            target: self,
            action: #selector(addNewTask)
        )
        
        navigationController?.navigationBar.tintColor = .white
    }
    
    private func fetchData() {
        taskList = storageManager.fetchData()
        tableView.reloadData()
    }
    
    func showSeveAlert(with title: String, and message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        let saveAction = UIAlertAction(title: "Save Task", style: .default) { [unowned self] _ in
            guard let title = alert.textFields?.first?.text, !title.isEmpty else { return }
            let task = TaskStruct(title: title)
            storageManager.addTask(task)
            taskList.append(task)
            tableView.reloadData()
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .destructive)
        alert.addAction(saveAction)
        alert.addAction(cancelAction)
        alert.addTextField { textField in
            textField.placeholder = "NewTask"
        }
        
        present(alert, animated: true)
    }
}

extension TaskListViewController {
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        taskList.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellID, for: indexPath)
        let task = taskList[indexPath.row]
        
        var content = cell.defaultContentConfiguration()
        content.text = task.title
        cell.contentConfiguration = content
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let editAction = UIContextualAction(style: .normal, title: "Edit", handler: { (action, view, completionHandler) in
            
            func showEditAlert(with title: String, and message: String) {
                let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
                
                let editAction = UIAlertAction(title: "Edit Task", style: .default) { [unowned self] _ in
                    guard let title = alert.textFields?.first?.text, !title.isEmpty else { return }
                    taskList[indexPath.row].title = title
                    let task = taskList[indexPath.row]
                    storageManager.updateTask(task)
                    tableView.reloadRows(at: [indexPath], with: .automatic)
                }
                
                let cancelAction = UIAlertAction(title: "Cancel", style: .destructive)
                alert.addAction(editAction)
                alert.addAction(cancelAction)
                alert.addTextField { textField in
                    textField.placeholder = "NewTask"
                }
                
                self.present(alert, animated: true)
            }
            
            showEditAlert(with: "Edit Task", and: "What do you want to change?")
            
        })
        editAction.backgroundColor = .blue
        
        let swipeConfiguration = UISwipeActionsConfiguration(actions: [editAction])
        return swipeConfiguration
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        let task = taskList[indexPath.row]
        if editingStyle == .delete {
            StorageManager.shared.deleteTask(task.id)
            taskList.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .automatic)
        }
    }
}

