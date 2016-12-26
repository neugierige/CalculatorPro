//
//  ViewController.swift
//  Calculator
//
//  Created by Luyuan Xing on 12/12/16.
//  Copyright © 2016 Luyuan Xing. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    
    @IBOutlet private weak var display: UILabel!
    
    internal var userTypingNumber = false
    
    override func viewWillAppear(_ animated: Bool) {
        let displayTextRect = CGRect(x: display.frame.minX + 5, y: display.frame.minY, width: display.frame.width - 50, height: display.frame.height)
        display.textRect(forBounds: displayTextRect, limitedToNumberOfLines: 1)
    }
    
    
    @IBAction private func touchDigit(_ sender: UIButton) {
        let number = sender.currentTitle!
        if userTypingNumber {
            display.text = display.text! + number
        } else {
            display.text = number
        }
        userTypingNumber = true
    }

    @IBAction private func touchDot(_ sender: UIButton) {
        if !(display.text!.characters.contains(".")) {
            touchDigit(sender)
        }
    }
    
    private var displayValue: Double {
        get {
            return Double(display.text!)!
        }
        set {
            display.text = String(newValue)
        }
    }
    
    private var model = CalculatorModel()
    
    @IBAction private func performOperand(_ sender: UIButton) {
        if userTypingNumber {
            model.setOperand(operand: displayValue)
            userTypingNumber = false
        }
        
        if let symbol = sender.currentTitle {
            model.performOperation(symbol: symbol)
        }
        displayValue = model.result
    }
    
    
    var savedProgram: CalculatorModel.PropertyList?
    func save() {
        savedProgram = model.program
    }
    
    func restore() {
        if savedProgram != nil {
            model.program = savedProgram!
            displayValue = model.result
        }
    }
    

}

