//
//  ViewController.swift
//  todolist
//
//  Created by Cao Gia Huy on 1/6/25.
//

import UIKit

struct Task: Codable {
    var title: String
    var isCompleted: Bool
    
    init(title: String, isCompleted: Bool = false) {
        self.title = title
        self.isCompleted = isCompleted
    }
}

class ViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var taskTextField: UITextField!
    @IBOutlet weak var themeControl: UISegmentedControl!
    
    var tasks: [Task] = [] {
        didSet {
            saveTasks()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.dataSource = self
        tableView.delegate = self
        
        // Load saved tasks
        loadTasks()
        
        // Load saved theme
        let savedThemeIndex = UserDefaults.standard.integer(forKey: "Theme")
        themeControl.selectedSegmentIndex = savedThemeIndex
        themeChanged(themeControl)
        
        // Setup keyboard dismissal on background tap
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(tapGesture)
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
    
    // Persistence methods
    func saveTasks() {
        if let encoded = try? JSONEncoder().encode(tasks) {
            UserDefaults.standard.set(encoded, forKey: "SavedTasks")
        }
    }
    
    func loadTasks() {
        if let savedTasks = UserDefaults.standard.data(forKey: "SavedTasks"),
           let decodedTasks = try? JSONDecoder().decode([Task].self, from: savedTasks) {
            tasks = decodedTasks
        }
    }
    
    // Add task button action
    @IBAction func addTaskButtonTapped(_ sender: UIButton) {
        if let taskTitle = taskTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines),
           !taskTitle.isEmpty {
            let newTask = Task(title: taskTitle)
            tasks.append(newTask)
            tableView.reloadData()
            taskTextField.text = ""
            taskTextField.resignFirstResponder()
        }
    }
    
    // UITableViewDataSource methods
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tasks.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "TaskCell", for: indexPath)
        let task = tasks[indexPath.row]
        
        // Configure cell
        cell.textLabel?.text = task.title
        cell.accessoryType = task.isCompleted ? .checkmark : .none
        
        // Apply theme
        if tableView.backgroundColor == .black {
            cell.textLabel?.textColor = .white
            cell.backgroundColor = .black
            cell.tintColor = .white  // For checkmark color
        } else {
            cell.textLabel?.textColor = .black
            cell.backgroundColor = .white
            cell.tintColor = .systemBlue  // Default iOS blue
        }
        
        return cell
    }
    
    // UITableViewDelegate methods
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tasks[indexPath.row].isCompleted.toggle()
        tableView.reloadRows(at: [indexPath], with: .automatic)
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            tasks.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .automatic)
        }
    }
    
    // Theme methods
    @IBAction func themeChanged(_ sender: UISegmentedControl) {
        switch sender.selectedSegmentIndex {
        case 0:
            applyTheme(theme: "light")
        case 1:
            applyTheme(theme: "dark")
        default:
            break
        }
        UserDefaults.standard.set(sender.selectedSegmentIndex, forKey: "Theme")
    }
    
    func applyTheme(theme: String) {
        if theme == "light" {
            view.backgroundColor = .white
            tableView.backgroundColor = .white
            taskTextField.backgroundColor = .white
            taskTextField.textColor = .black
            themeControl.backgroundColor = .white
        } else {
            view.backgroundColor = .black
            tableView.backgroundColor = .black
            taskTextField.backgroundColor = .darkGray
            taskTextField.textColor = .white
            themeControl.backgroundColor = .darkGray
        }
        tableView.reloadData()
    }
}
