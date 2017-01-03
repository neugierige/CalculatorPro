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
    
    private var offsetLength: Int {
        get {
            return display.text?.characters.count ?? 1
        }
        set { }
    }
    
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
            model.setOperand(operand: displayValue)
            userTypingNumber = false
        } else {
            print("user typing \(sender.currentTitle!) -> FALSE")
        }
        
        if let symbol = sender.currentTitle {
            // if symbol is a binary operator, set evaluated to false
            let binaryOperators = ["÷", "✕", "-", "+"]
            if binaryOperators.contains(symbol) {
                evaluated = false
            }
            
            model.performOperation(symbol: symbol)
            
            switch symbol {
                case "x!": formula.text = formula.text! + "!"
                case "x²": formula.text = formula.text! + "²"
                case "x^3": formula.text = formula.text! + "^3"
                case "x^y": formula.text = formula.text! + "^"
                
                // PREPEND
                case "√": formula.text!.insert("√", at: formula.text!.index(formula.text!.endIndex, offsetBy: -1 * offsetLength))
                case "±": formula.text = "-" + formula.text!
                case "1/x":
                    let range = formula.text!.index(formula.text!.endIndex, offsetBy: offsetLength * -1)..<formula.text!.endIndex
                    formula.text!.removeSubrange(range)
                    formula.text = formula.text! + symbol + display.text!
                case "sin": prependSymbol(symbol: "sin(", offsetLength: offsetLength)
                case "cos": prependSymbol(symbol: "cos(", offsetLength: offsetLength)
                case "tan": prependSymbol(symbol: "cos(", offsetLength: offsetLength)
                case "sinh": prependSymbol(symbol: "sin(", offsetLength: offsetLength)
                case "cosh": prependSymbol(symbol: "cos(", offsetLength: offsetLength)
                case "tanh": prependSymbol(symbol: "cos(", offsetLength: offsetLength)
                
                
                default: formula.text = formula.text! + symbol
            }
            // formula.text = symbolFormat
        }
        displayValue = model.result
    }
    
    private func prependSymbol(symbol: String, offsetLength: Int) {
        let range = formula.text!.index(formula.text!.endIndex, offsetBy: offsetLength * -1)..<formula.text!.endIndex
        formula.text!.removeSubrange(range)
        formula.text = formula.text! + symbol + display.text! + ")"
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

