import UIKit
import CoreData

class HomeViewController: UIViewController {
    
    var fetch: NSFetchedResultsController<Schedule>!
    
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
        setupData()
        
        NotificationCenter.default.addObserver(self, selector: #selector(handleAddSchedule), name: .didAddSchedule, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(handleUpdateSchedule), name: .didUpdateSchedule, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(handleDeleteSchedule), name: .didDeleteSchedule, object: nil)
    }

    @objc func handleAddSchedule() {
        print("Add Schedule Notification received")
        tableView.reloadData()
    }

    @objc func handleUpdateSchedule() {
        print("Update Schedule Notification received")
        tableView.reloadData()
    }

    @objc func handleDeleteSchedule() {
        print("Delete Schedule Notification received")
        tableView.reloadData()
    }

    func setupData() {
        initFetch()
    }
    
    func setupUI() {
        title = "List Schedule"
        
        tableView.delegate = self
        tableView.dataSource = self
        
        let nib = UINib(nibName: "HomeCell", bundle: .main)
        tableView.register(nib, forCellReuseIdentifier: "HomeCell")
        
        let addNew = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(gotoAdd))
        self.navigationItem.rightBarButtonItem = addNew
    }
    
    @objc func gotoAdd() {
        let vc = AddViewController()
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    func save(action: String, body: String, dateSchedule: String) {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
        
        let managedContext = appDelegate.persistentContainer.viewContext
        
        guard let entity = NSEntityDescription.entity(forEntityName: "Schedule", in: managedContext) else {
            fatalError("Could not find entity descriptions!")
        }
        
        let sch = NSManagedObject(entity: entity, insertInto: managedContext)
        
        sch.setValue(action, forKeyPath: "action")
        sch.setValue(body, forKeyPath: "body")
        sch.setValue(dateSchedule, forKeyPath: "dateSchedule")
        
        do {
            try managedContext.save()
            NotificationCenter.default.post(name: .didAddSchedule, object: nil)
        } catch let error as NSError {
            print("Could not save. \(error), \(error.userInfo)")
        }
    }
    
    func formatDate(_ date: Date?) -> String {
        guard let date = date else { return ""}
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
}


extension HomeViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return fetch?.fetchedObjects?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "HomeCell", for: indexPath) as! HomeCell
        
        let schedule = fetch.object(at: indexPath)
        
        cell.actionLabel.text = schedule.action
        cell.bodyLabel.text = schedule.body
        cell.dateLabel.text = formatDate(schedule.dateSchedule)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        
        let editAction = UIContextualAction(style: .normal, title: "Edit") { (action, view, handler) in
            let vc = EditViewController()
            vc.sch = self.fetch.object(at: indexPath)
            self.navigationController?.pushViewController(vc, animated: true)
            handler(true)
        }
        editAction.backgroundColor = .blue
        
        let deleteAction = UIContextualAction(style: .destructive, title: "Delete") { (action, view, handler) in
            guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
            
            let managedContext = appDelegate.persistentContainer.viewContext
            let sch = self.fetch.object(at: indexPath)
            
            managedContext.delete(sch)
            
            do {
                try managedContext.save()
                NotificationCenter.default.post(name: .didDeleteSchedule, object: nil)
                handler(true)
            } catch let error as NSError {
                print("Could not save. \(error), \(error.userInfo)")
                handler(false)
            }
        }
        
        let configuration = UISwipeActionsConfiguration(actions: [editAction, deleteAction])
        configuration.performsFirstActionWithFullSwipe = false
        return configuration
    }
}

extension HomeViewController: NSFetchedResultsControllerDelegate {
    func initFetch() {
        let fetchRequest: NSFetchRequest<Schedule> = Schedule.fetchRequest()
        
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "action", ascending: true)]
        
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
        
        let managedContext = appDelegate.persistentContainer.viewContext
        fetch = NSFetchedResultsController(fetchRequest: fetchRequest,
                                           managedObjectContext: managedContext,
                                           sectionNameKeyPath: nil,
                                           cacheName: nil)
        fetch.delegate = self
        
        do {
            try fetch.performFetch()
        } catch {
            fatalError("Failed to initialize FetchedResultsController: \(error)")
        }
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        switch type {
        case .insert:
            if let indexPath = newIndexPath {
                tableView.insertRows(at: [indexPath], with: .fade)
            }
        case .delete:
            if let indexPath = indexPath {
                tableView.deleteRows(at: [indexPath], with: .fade)
            }
        case .update:
            if let indexPath = indexPath {
                tableView.reloadRows(at: [indexPath], with: .automatic)
                if let cell = tableView.cellForRow(at: indexPath) as? HomeCell {
                    let schedule = fetch.object(at: indexPath)
                    cell.actionLabel.text = schedule.action
                    cell.bodyLabel.text = schedule.body
                    cell.dateLabel.text = formatDate(schedule.dateSchedule)
                }
            }
        case .move:
            if let indexPath = indexPath {
                tableView.deleteRows(at: [indexPath], with: .fade)
            }
            if let newIndexPath = newIndexPath {
                tableView.insertRows(at: [newIndexPath], with: .fade)
            }
        default:
            break
        }
    }
}

extension Notification.Name {
    static let didAddSchedule = Notification.Name("didAddSchedule")
    static let didUpdateSchedule = Notification.Name("didUpdateSchedule")
    static let didDeleteSchedule = Notification.Name("didDeleteSchedule")
}
