//
//  NewCardViewController.swift
//  Skill-Link
//
//  Created by Sayed on 21/12/2025.
//

import UIKit

class NewCardViewController : BaseViewController,UITextFieldDelegate {
    
    @IBOutlet weak var holderNameTextField: UITextField!
    @IBOutlet weak var cardNumberTextField: UITextField!
    @IBOutlet weak var cvvTExtField: UITextField!
    @IBOutlet weak var confirmButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTextFields()
    }
    
    private func setupTextFields() {
        // Set up text field delegates for real-time validation
        holderNameTextField.delegate = self
        cardNumberTextField.delegate = self
        cvvTExtField.delegate = self
        
        // Set up keyboard types
        cardNumberTextField.keyboardType = .numberPad
        cvvTExtField.keyboardType = .numberPad
        
        // Add targets for editing changed events
        holderNameTextField.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
        cardNumberTextField.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
        cvvTExtField.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
    }
    
    @IBAction func confirmButtonTapped(_ sender: Any) {
        guard validateAllFields() else {
            return
        }
        
        // All validation passed
        print(
            "Card Holder: \(holderNameTextField.text ?? "")",
            "Card Number: \(cardNumberTextField.text ?? "")",
            "CVV: \(cvvTExtField.text ?? "")"
        )
        
        // Proceed with your logic (e.g., API call, navigation, etc.)
    }
    
    // MARK: - Validation Methods
    
    private func validateAllFields() -> Bool {
        let isNameValid = validateCardHolderName()
        let isCardNumberValid = validateCardNumber()
        let isCVVValid = validateCVV()
        
        if !isNameValid {
            showAlert(message: "Please enter a valid card holder name (letters and spaces only)")
            return false
        }
        
        if !isCardNumberValid {
            showAlert(message: "Please enter a valid 16-digit card number")
            return false
        }
        
        if !isCVVValid {
            showAlert(message: "Please enter a valid 3-digit CVV")
            return false
        }
        
        return true
    }
    
    private func validateCardHolderName() -> Bool {
        guard let name = holderNameTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines),
              !name.isEmpty else {
            return false
        }
        
        // Allow letters, spaces, and common punctuation in names
        let nameRegex = "^[a-zA-Z]+(?:[\\s.'-][a-zA-Z]+)*$"
        let namePredicate = NSPredicate(format: "SELF MATCHES %@", nameRegex)
        return namePredicate.evaluate(with: name) && name.count >= 2
    }
    
    private func validateCardNumber() -> Bool {
        guard let cardNumber = cardNumberTextField.text?.replacingOccurrences(of: " ", with: ""),
              !cardNumber.isEmpty else {
            return false
        }
        
        // Check if it's exactly 16 digits and contains only numbers
        return cardNumber.count == 16 && CharacterSet(charactersIn: cardNumber).isSubset(of: CharacterSet.decimalDigits)
    }
    
    private func validateCVV() -> Bool {
        guard let cvv = cvvTExtField.text,
              !cvv.isEmpty else {
            return false
        }
        
        // CVV should be 3 digits (standard for Visa/MasterCard)
        return cvv.count == 3 && CharacterSet(charactersIn: cvv).isSubset(of: CharacterSet.decimalDigits)
    }
    
    // MARK: - Helper Methods
    
    private func formatCardNumber(_ text: String) -> String {
        let numbers = text.replacingOccurrences(of: " ", with: "")
        var result = ""
        
        for (index, character) in numbers.enumerated() {
            if index > 0 && index % 4 == 0 {
                result += " "
            }
            result.append(character)
        }
        
        return String(result.prefix(19)) // Max: 16 digits + 3 spaces
    }
    
    private func showAlert(message: String) {
        let alert = UIAlertController(title: "Validation Error",
                                    message: message,
                                    preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
    
    @objc private func textFieldDidChange(_ textField: UITextField) {
        if textField == cardNumberTextField {
            // Format card number with spaces
            let text = textField.text ?? ""
            let formattedText = formatCardNumber(text)
            if textField.text != formattedText {
                textField.text = formattedText
            }
        }
        
        // Enable/disable confirm button based on validation
        updateConfirmButtonState()
    }
    
    private func updateConfirmButtonState() {
        let isNameValid = validateCardHolderName()
        let isCardNumberValid = validateCardNumber()
        let isCVVValid = validateCVV()
        
        confirmButton.isEnabled = isNameValid && isCardNumberValid && isCVVValid
        confirmButton.alpha = confirmButton.isEnabled ? 1.0 : 0.5
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let currentText = textField.text ?? ""
        let newText = (currentText as NSString).replacingCharacters(in: range, with: string)
        
        if textField == holderNameTextField {
            // Limit name length and allow only letters, spaces, and common punctuation
            let maxLength = 50
            if newText.count > maxLength {
                return false
            }
            
            // Allow backspace
            if string.isEmpty { return true }
            
            // Allow letters, spaces, and common name characters
            let allowedCharacters = CharacterSet.letters
                .union(CharacterSet.whitespaces)
                .union(CharacterSet(charactersIn: ".'-"))
            let characterSet = CharacterSet(charactersIn: string)
            return allowedCharacters.isSuperset(of: characterSet)
            
        } else if textField == cardNumberTextField {
            // Allow only digits and limit to 16 digits (without spaces)
            let numbersOnly = newText.replacingOccurrences(of: " ", with: "")
            if numbersOnly.count > 16 {
                return false
            }
            
            // Allow backspace
            if string.isEmpty { return true }
            
            // Allow only digits
            let allowedCharacters = CharacterSet.decimalDigits
            let characterSet = CharacterSet(charactersIn: string)
            return allowedCharacters.isSuperset(of: characterSet)
            
        } else if textField == cvvTExtField {
            // Limit CVV to 3 digits (standard for Visa/MasterCard)
            if newText.count > 3 {
                return false
            }
            
            // Allow backspace
            if string.isEmpty { return true }
            
            // Allow only digits
            let allowedCharacters = CharacterSet.decimalDigits
            let characterSet = CharacterSet(charactersIn: string)
            return allowedCharacters.isSuperset(of: characterSet)
        }
        
        return true
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        // Move to next field when return is tapped
        if textField == holderNameTextField {
            cardNumberTextField.becomeFirstResponder()
        } else if textField == cardNumberTextField {
            cvvTExtField.becomeFirstResponder()
        } else {
            textField.resignFirstResponder()
        }
        return true
    }
  }

