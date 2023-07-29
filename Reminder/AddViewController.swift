//
//  AddViewController.swift
//  Reminder
//
//  Created by Tareq Alhammoodi on 28.07.2023.
//

import UIKit

class AddViewController: UIViewController, UITextFieldDelegate {

    public var completion: ((String, String, Date) -> Void)?
    
    private let scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.clipsToBounds = true
        return scrollView
    }()
    
    private let titleField: UITextField = {
        let field = UITextField()
        field.autocapitalizationType = .none
        field.autocorrectionType = .no
        field.returnKeyType = .continue
        field.attributedPlaceholder = NSAttributedString(string: "Title...", attributes: [NSAttributedString.Key.font: UIFont(name:"Avenir-Light", size: 16.0) as Any])
        field.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 6, height: 0))
        field.leftViewMode = .always
        field.backgroundColor = .clear
        return field
    }()
    
    private let bodyField: UITextField = {
        let field = UITextField()
        field.autocapitalizationType = .none
        field.autocorrectionType = .no
        field.returnKeyType = .done
        field.attributedPlaceholder = NSAttributedString(string: "Details...", attributes: [NSAttributedString.Key.font: UIFont(name:"Avenir-Light", size: 16.0) as Any])
        field.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 6, height: 0))
        field.leftViewMode = .always
        field.backgroundColor = .clear
        return field
    }()
    
    private let datePicker: UIDatePicker = {
        let dataPicker = UIDatePicker()
        return dataPicker
    }()
    
    private let saveButton: UIButton = {
        let button = UIButton()
        button.setTitle("Save", for: .normal)
        button.backgroundColor = UIColor.systemBlue
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 20
        button.layer.masksToBounds = true
        button.titleLabel?.font = UIFont(name:"Avenir-Black", size: 18.0)
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        title = "New Reminder"
        view.backgroundColor = .systemBackground
        titleField.delegate = self
        bodyField.delegate = self
        saveButton.addTarget(self,
                              action: #selector(didTapSaveButton),
                              for: .touchUpInside)
        // Add subviews
        view.addSubview(scrollView)
        scrollView.addSubview(titleField)
        scrollView.addSubview(bodyField)
        scrollView.addSubview(datePicker)
        scrollView.addSubview(saveButton)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        scrollView.frame = view.bounds
        titleField.frame = CGRect(x: (scrollView.width-(scrollView.width-60))/2,
                                    y: scrollView.top+30,
                                    width: scrollView.width-60,
                                    height: 40)
        bodyField.frame = CGRect(x: (scrollView.width-(scrollView.width-60))/2,
                                    y: titleField.bottom+20,
                                    width: scrollView.width-60,
                                    height: 40)
        datePicker.frame = CGRect(x: 30,
                                   y: bodyField.bottom+30,
                                   width: scrollView.width-60,
                                   height: 40)
        saveButton.frame = CGRect(x: (scrollView.width-250)/2,
                                     y: datePicker.bottom+30,
                                     width: 250,
                                     height: 45)
        titleField.addBottomBorder(color: .gray, width: 1.0)
        bodyField.addBottomBorder(color: .gray, width: 1.0)
    }
    
    @objc func didTapSaveButton() {
        if let titleText = titleField.text, !titleText.isEmpty,
           let bodyText = bodyField.text, !bodyText.isEmpty {
            let targetDate = datePicker.date
            completion?(titleText, bodyText, targetDate)
        }
        dismiss(animated: true, completion: nil)
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}
