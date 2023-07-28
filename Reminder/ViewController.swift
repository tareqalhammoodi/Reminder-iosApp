//
//  ViewController.swift
//  Reminder
//
//  Created by Tareq Alhammoodi on 28.07.2023.
//

import UIKit
import UserNotifications

struct Reminder: Codable {
    let title: String
    let date: Date
    let identifier: String
}

class ViewController: UIViewController {
    
    var models = [Reminder]()
    
    @IBOutlet var tableView: UITableView!

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        tableView.delegate = self
        tableView.dataSource = self
        // add button
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addTapped))
        // access notifications
        accessNotification()
        // load saved data
        let defaults = UserDefaults.standard
        if let savedData = defaults.object(forKey: "data") as? Data {
            let jsonDecoder = JSONDecoder()
            do {
                models = try jsonDecoder.decode([Reminder].self, from: savedData)
            } catch {
                print("Failed to load data.")
            }
        }
        // sort data
        models = models.sorted(by: { $0.date > $1.date })
    }
    
    func accessNotification() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound], completionHandler: { success, error in
            if success {
                print("working.")
            } else if error != nil {
                print("error occurred.")
            }
        })
    }
    
    func saveData() {
        let jsonEncoder = JSONEncoder()
        if let savedData = try? jsonEncoder.encode(models) {
            let defaults = UserDefaults.standard
            defaults.set(savedData, forKey: "data")
        } else {
            print("Failed to save data.")
        }
    }
    
    @objc func addTapped() {
        guard let vc = storyboard?.instantiateViewController(identifier: "add") as? AddViewController else {
            return
        }
        vc.completion = { title, body, date in
            DispatchQueue.main.async { [weak self] in
                self?.navigationController?.popToRootViewController(animated: true)
                let new = Reminder(title: title, date: date, identifier: "id_\(title)")
                self?.models.append(new)
                self?.saveData()
                self?.models = (self?.models.sorted(by: { $0.date > $1.date }))!
                self?.tableView.reloadData()
                
                let content = UNMutableNotificationContent()
                content.title = title
                content.sound = .default
                content.body = body
                let targetDate = date
                let trigger = UNCalendarNotificationTrigger(dateMatching: Calendar.current.dateComponents([.year, .month, .day, .hour, .minute, .second], from: targetDate), repeats: false)
                let request = UNNotificationRequest(identifier: "id", content: content, trigger: trigger)
                UNUserNotificationCenter.current().add(request, withCompletionHandler: { error in
                    if error != nil {
                        print("something went wrong.")
                    }
                })
            }
        }
        present(UINavigationController(rootViewController: vc), animated: true)
    }

}

extension ViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return models.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.textLabel?.text = models[indexPath.row].title
        let date = models[indexPath.row].date
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE, MMM d, yyyy, h:mm a"
        cell.detailTextLabel?.text = formatter.string(from: date)
        cell.detailTextLabel?.textColor = .link
        cell.separatorInset = UIEdgeInsets.zero
        cell.selectionStyle = .none
        if date < Date() {
            cell.textLabel?.textColor = .gray
            cell.detailTextLabel?.textColor = .gray
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80
    }
    
    func tableView(_ tableView: UITableView, contextMenuConfigurationForRowAt indexPath: IndexPath, point: CGPoint) -> UIContextMenuConfiguration? {
        return UIContextMenuConfiguration(identifier: nil, previewProvider: nil, actionProvider: { suggestedActions in
            return self.makeContextMenu(for: indexPath)
        })
    }
    
    func makeContextMenu(for indexPath: IndexPath) -> UIMenu {
        let action = UIAction(title: "Delete") { [weak self] _ in
            guard let self = self else { return }
            tableView.beginUpdates()
            self.models.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .left)
            tableView.endUpdates()
            saveData()
        }
        return UIMenu(title: "", children: [action])
    }
    
}
