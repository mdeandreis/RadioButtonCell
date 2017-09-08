//
//  ViewController.swift
//  RadioButtonCell
//
//  Created by Martin on 9/8/17.
//  Copyright © 2017 Martin. All rights reserved.
//

import UIKit

fileprivate extension Int {
    static let rowHeight = 55
}

enum Symptom: String {
    case abdominalPain, bloodInStool, cough, diarrhea, headaches, other
    
    var description: String { return NSLocalizedString(self.rawValue.capitalized, comment: "") }
    static let allSymptoms: [Symptom] = [.abdominalPain, .bloodInStool, .cough, .diarrhea, .headaches, .other]
}

extension Symptom {
    
    var image: UIImage {
        guard let image = UIImage(named: "deselected") else {
            return UIImage()
        }
        return image
    }
    
    var selectedImage: UIImage {
        guard let selectedImage = UIImage(named: "selected") else {
            return UIImage()
        }
        return selectedImage
    }
    
    var hasInputField: Bool {
        switch self {
        case .other:
            return true
        default:
            return false
        }
    }
}

class ViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    var allSymptoms: [Symptom] = Symptom.allSymptoms
    var selectedOption: (symptom: Symptom?, index: Int) = (nil, -1)
    
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
        if selectedOption.symptom == nil {
            radioButtonCell.setup(symptom: symptom, isSelected: false)
        }else {
            radioButtonCell.setup(symptom: symptom, isSelected: indexPath.row == selectedOption.index)
        }
        radioButtonCell.delegate = self
        radioButtonCell.selectionStyle = .none
        
        return radioButtonCell
    }
    
}

extension ViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let symptom = allSymptoms[indexPath.row]
        //get the current symptom and update the selected option
        if let lastSelectedSymptom = selectedOption.symptom {
            selectedOption = symptom == lastSelectedSymptom ? (nil, -1) : (symptom, indexPath.row)
        }else {
            selectedOption = (symptom, indexPath.row)
        }
        tableView.reloadData()
    }
}

extension ViewController: RadioButtonCellDelegate {
    
    func shouldReturn() {
        view.endEditing(true)
    }
}
