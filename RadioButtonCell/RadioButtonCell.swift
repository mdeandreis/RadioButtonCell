//
//  RadioButtonCell.swift
//  RadioButtonCell
//
//  Created by Martin on 9/8/17.
//  Copyright © 2017 Martin. All rights reserved.
//

import UIKit

protocol RadioButtonCellDelegate {
    func shouldReturn()
}

fileprivate extension Int {
    static let textFieldHeight = 40
    static let borderViewHeight = 1
}

class RadioButtonCell: UITableViewCell {
    
    @IBOutlet weak var borderViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var descriptionSymptomTextFieldHeightContraint: NSLayoutConstraint!
    @IBOutlet weak var radioImageView: UIImageView!
    @IBOutlet weak var optionTitleLabel: UILabel!
    @IBOutlet weak var optionDescriptionTextField: UITextField!
    var symptom: Symptom?
    var delegate: RadioButtonCellDelegate?
    
    func setup(symptom: Symptom, isSelected: Bool) {
        optionTitleLabel.text = symptom.description

        radioImageView.backgroundColor = isSelected ? UIColor.blue : UIColor.white
        radioImageView.layer.borderWidth = 2
        radioImageView.layer.cornerRadius = radioImageView.frame.width / 2
        radioImageView.layer.borderColor = UIColor.blue.cgColor
        
        optionDescriptionTextField.text = ""
        optionDescriptionTextField.placeholder = "Enter symptom description"
        optionDescriptionTextField.delegate = self
        
        if symptom.hasInputField && isSelected {
            // "expand" the textField
            descriptionSymptomTextFieldHeightContraint.constant = CGFloat(.textFieldHeight)
            borderViewHeightConstraint.constant = CGFloat(.borderViewHeight)
        }else {
            // "close" the textField
            descriptionSymptomTextFieldHeightContraint.constant = 0.0
            borderViewHeightConstraint.constant = 0.0
        }
    }
}

extension RadioButtonCell: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.delegate?.shouldReturn()
        return true
    }
}
