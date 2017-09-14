//
//  ViewController.swift
//  RadioButtonCell
//
//  Created by Martin on 9/8/17.
//  Copyright © 2017 Martin. All rights reserved.
//

import UIKit

fileprivate extension Int {
    static let rowHeight = 65
}

enum Symptom: String {
    case abdominalPain, bloodInStool, cough, diarrhea, headaches, other
    
    var description: String { return NSLocalizedString(self.rawValue.capitalized, comment: "") }
    static let allSymptoms: [Symptom] = [.abdominalPain, .bloodInStool, .cough, .diarrhea, .headaches, .other]
}

extension Symptom {
   
    var hasInputField: Bool {
        switch self {
        case .other:
            return false
        default:
            return true
        }
    }
}

class ViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    var allSymptoms: [Symptom] = Symptom.allSymptoms
    var selectedOptions: [(symptom: Symptom?, index: Int)] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = NSLocalizedString("Symptoms", comment: "")
        
        tableView.separatorStyle = .none
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = CGFloat(.rowHeight)
        tableView.tableFooterView = UIView()
        
        subscribeForKeyboardNotifications()
    }
    
    deinit {
        unsubscribeFromKeyboardNotifications()
    }
    
    func subscribeForKeyboardNotifications() {
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardNotificationHandler(notification:)), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardNotificationHandler(notification:)), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
    }
    
    func unsubscribeFromKeyboardNotifications() {
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardWillHide, object: nil)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardWillShow, object: nil)
    }
    
    func keyboardNotificationHandler(notification: NSNotification) {
        if notification.name == NSNotification.Name.UIKeyboardWillShow {
            guard let
                userInfo = notification.userInfo,
                let rectValue = userInfo[UIKeyboardFrameBeginUserInfoKey] as? NSValue
                else { return }
            let keyboardFrame = rectValue.cgRectValue
            keyboardWillShowHandler(keyboardFrame: keyboardFrame)
        } else if notification.name == NSNotification.Name.UIKeyboardWillHide {
            keyboardWillHideHandler()
        }
    }
    
    func keyboardWillShowHandler(keyboardFrame: CGRect) {
        tableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: keyboardFrame.height, right: 0)
    }
    
    func keyboardWillHideHandler() {
        tableView.contentInset = UIEdgeInsets()
    }
}

extension ViewController: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return allSymptoms.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let reuseIdentifier = "RadioButtonCell"
        let radioButtonCell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier, for: indexPath) as! RadioButtonCell
        //get the current symptom
        let symptom = allSymptoms[indexPath.row]
        if selectedOptions.count == 0 {
            radioButtonCell.setup(symptom: symptom, isSelected: false)
        }else {
            let symptoms = selectedOptions.filter { (option: (symptom: Symptom?, index: Int)) -> Bool in
                option.symptom == symptom
            }
            
            if symptoms.count == 0 {
                radioButtonCell.setup(symptom: symptom, isSelected: false)
            }else {
                radioButtonCell.setup(symptom: symptom, isSelected: indexPath.row == symptoms[0].index)
            }
        }
        
        radioButtonCell.delegate = self
        radioButtonCell.selectionStyle = .none
        
        return radioButtonCell
    }
    
}

extension ViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedSymptom = allSymptoms[indexPath.row]
        //get the selected symptom and update the selected options
        let symptoms = selectedOptions.filter { (option: (symptom: Symptom?, index: Int)) -> Bool in
            option.symptom == selectedSymptom
        }
        
        if symptoms.count == 0 {
            selectedOptions.append((selectedSymptom, indexPath.row))
        }else {
            //check if the selected symptom was already selected. If so, remove from selected options
            if selectedSymptom == symptoms[0].symptom {
                selectedOptions = selectedOptions.filter({ (option:(symptom: Symptom?, index: Int)) -> Bool in
                    option.symptom != selectedSymptom
                })
            }else {
                selectedOptions.append((selectedSymptom, indexPath.row))
            }
        }
        tableView.reloadData()
    }
}

extension ViewController: RadioButtonCellDelegate {
    
    func shouldReturn() {
        view.endEditing(true)
    }
}
