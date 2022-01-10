//
//  Model.swift
//  CountOnMe
//
//  Created by Aymerik Vallejo on 20/12/2021.
//  Copyright © 2021 Vincent Saluzzo. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    let calculator = Calculator()
    
    @IBOutlet weak var textView: UITextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        calculator.delegate = self
        textView.text = "0"
    }
    
    // Actions
    
    @IBAction func resetButton(_ sender: UIButton) {
        calculator.reset()
    }
    @IBAction func tappedNumberButton(_ sender: UIButton) {
        guard let numberButton = sender.title(for: .normal) else { return }
        calculator.numberButton(number: numberButton)
    }
    @IBAction func tappedOperandButton(_ sender: UIButton) {
        guard let operandButton = sender.title(for: .normal) else {  return }
        calculator.operandButton(operand: operandButton)
    }
    @IBAction func tappedEqualButton(_ sender: UIButton) {
        calculator.equalButton()
        textView.scrollToBottom()
    }
}

// Extension

extension ViewController: DisplayDelegate {
    
    func updateDisplay(text: String) {
        textView.text = text
    }
    
    func presentAlert() {
        let alertVC = UIAlertController(title: "Erreur", message:
            "Veuillez entrer une expression correcte !", preferredStyle: .alert)
        alertVC.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
        return self.present(alertVC, animated: true, completion: nil)
    }
}

extension UITextView {
    func scrollToBottom() {
        let textCount: Int = text.count
        guard textCount >= 1 else { return }
        scrollRangeToVisible(NSRange(location: textCount - 1, length: 1))
    }
}

