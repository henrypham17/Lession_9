//
//  EditViewController.swift
//  Lession9
//
//  Created by Quang Phạm on 25/6/24.
//

import UIKit

class EditViewController: UIViewController {
    var sch : Schedule!
    
    @IBOutlet weak var bodyText: UITextField!
    @IBOutlet weak var timePicker: UIDatePicker!
    @IBOutlet weak var actionText: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupData()
        // Do any additional setup after loading the view.
    }
    
    func setupUI(){
        title = "Edit"
        
        let doneBarButton = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(done))
        self.navigationItem.rightBarButtonItem = doneBarButton
    }
    
    func setupData(){
//        if let action = actionText.text, !action.isEmpty,
//           let body = bodyText.text, !body.isEmpty {
//            let dateSchedule = timePicker.date
//
//        }
        
        if let sch = sch {
            actionText.text = sch.action
            bodyText.text = sch.body
            timePicker.date = sch.dateSchedule!
        }
    }
    
    @objc func done(){
        // lay AppDelegate
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return}
        
        // lay managed obj context
        let managedContext = appDelegate.persistentContainer.viewContext
        
        // set gtri cho Obj
        sch.action = actionText.text
        sch.body = bodyText.text
        sch.dateSchedule = timePicker.date
        
        do {
            try managedContext.save()
            NotificationCenter.default.post(name: .didUpdateSchedule, object: nil)
            self.navigationController?.popViewController(animated: true)
        } catch let error as NSError {
            print("Could not save. \(error), \(error.userInfo)")
        }
        
    }
    
}
