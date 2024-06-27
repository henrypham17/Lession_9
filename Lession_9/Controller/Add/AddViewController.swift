//
//  AddViewController.swift
//  Lession9
//
//  Created by Quang Phạm on 25/6/24.
//

import UIKit
import CoreData

class AddViewController: UIViewController {
    
    @IBOutlet weak var actionText: UITextField!
    @IBOutlet weak var timePicker: UIDatePicker!
    @IBOutlet weak var bodyText: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    func setupUI() {
        title = "New Schedule"
        
        let doneBarButton = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(done))
        self.navigationItem.rightBarButtonItem = doneBarButton
    }
    
    @objc func done(){
        guard let appDelagate = UIApplication.shared.delegate as? AppDelegate else { return }
        
        let managedContext = appDelagate.persistentContainer.viewContext
        
        let entity = NSEntityDescription.entity(forEntityName: "Schedule", in: managedContext)!
        
        let sch = Schedule(entity: entity, insertInto: managedContext)
        
        sch.action = actionText.text
        sch.body = bodyText.text
        sch.dateSchedule = timePicker.date
        
        //save context
        do {
            try managedContext.save()
            self.navigationController?.popViewController(animated: true)
        } catch let error as NSError {
            print("Could not save. \(error), \(error.userInfo)")
        }
    }
}
