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
    @IBOutlet private weak var formula: UILabel!
    
    internal var userTypingNumber = false
    internal var evaluated = false
    
    override func viewWillAppear(_ animated: Bool) {
        view.backgroundColor = UIColor.black
        display.backgroundColor = UIColor.black
        formula.backgroundColor = UIColor.black
        
        formula.adjustsFontSizeToFitWidth = true
        display.adjustsFontSizeToFitWidth = true
        
        
        // DOES NOT WORK
        let displayTextRect = CGRect(x: display.frame.minX + 100, y: display.frame.minY, width: display.frame.width - 50, height: display.frame.height)
        display.textRect(forBounds: displayTextRect, limitedToNumberOfLines: 1)
    }
    
    
    override func viewDidLoad() {
    }
    
    private var displayValue: Double {
        get {
            return Double(display.text ?? "") ?? 0 //Double(display.text!)!
        }
        set {
            if floor(newValue) == newValue {
                display.text = String(Int(newValue))
            } else {
                display.text = String(newValue)
            }
        }
    }
    
    private var model = CalculatorModel()
    
    @IBAction private func touchDigit(_ sender: UIButton) {
        let number = sender.currentTitle!
        
        if userTypingNumber {
            display.text = display.text! + number
        } else {
            display.text = number
        }
        userTypingNumber = true
        
        
        if evaluated {
            formula.text = number
            evaluated = false
        } else {
            formula.text = formula.text! + number
        }
    }

    @IBAction private func touchDot(_ sender: UIButton) {
        if !(display.text!.characters.contains(".")) {
            touchDigit(sender)
        }
    }
    
    @IBAction private func performOperand(_ sender: UIButton) {
        if userTypingNumber {
            print("user typing TRUE")
            model.setOperand(operand: displayValue)
            userTypingNumber = false
        } else {
            print("user typing FALSE")
        }
        
        if let symbol = sender.currentTitle {
            // TODO: if symbol is of type BinaryOperation, set evaluated to false
            model.performOperation(symbol: symbol)
            
            var symbolFormat = symbol
            
            switch symbol {
                case "x!": symbolFormat = formula.text! + "!"
                case "x²": symbolFormat = formula.text! + "²"
                case "x^3": symbolFormat = formula.text! + "^3"
                
                // PREPEND
                case "√": symbolFormat = "√" + formula.text!
                case "±": symbolFormat = "-" + formula.text!
                case "1/x": symbolFormat = "1/" + formula.text!
                
                default: symbolFormat = formula.text! + symbol
            }
            formula.text = symbolFormat
        }
        displayValue = model.result
    }
    
    
    @IBAction private func evaluate(_ sender: UIButton) {
        evaluated = true
    }
    
    @IBAction func clearScreen(_ sender: Any) {
        model.clear()
        userTypingNumber = false
        evaluated = false
        display.text = "0"
        formula.text = ""
        
    }
    
    var savedProgram: CalculatorModel.PropertyList?
    @IBAction func save(_ sender: UIButton) {
        savedProgram = model.program
    }
    
    @IBAction func restore(_ sender: UIButton) {
        if savedProgram != nil {
            model.program = savedProgram!
            displayValue = model.result
            model.setOperand(operand: displayValue)
        }
    }
    
    @IBAction func clearMemory(_ sender: UIButton) {
        savedProgram = nil
    }
    
}

