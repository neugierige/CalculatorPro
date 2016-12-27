//
//  CalculatorModel.swift
//  Calculator
//
//  Created by Luyuan Xing on 12/12/16.
//  Copyright © 2016 Luyuan Xing. All rights reserved.
//

import Foundation

class CalculatorModel {
    
    private var accumulator = 0.0
    private var internalProgram = [AnyObject]()
    
    func setOperand(operand: Double) {
        accumulator = operand
        internalProgram.append(operand as AnyObject)
    }
    
    private let operations: Dictionary<String, Operation> = [
        "÷": Operation.BinaryOperation({$0 / $1}),
        "✕": Operation.BinaryOperation({$0 * $1}),
        "-": Operation.BinaryOperation({$0 - $1}),
        "+": Operation.BinaryOperation({$0 + $1}),
        "=": Operation.Equals,
        "π": Operation.Constant(M_PI),
        "e": Operation.Constant(M_E),
        "√": Operation.UniaryOperation(sqrt),
        "±": Operation.UniaryOperation({-$0}),
        "%": Operation.UniaryOperation({$0*0.01}),
        "sin": Operation.UniaryOperation(sin),
        "cos": Operation.UniaryOperation(cos),
        "tan": Operation.UniaryOperation(tan),
        "sinh": Operation.UniaryOperation(sinh),
        "cosh": Operation.UniaryOperation(cosh),
        "tanh": Operation.UniaryOperation(tanh),
         "x!": Operation.Factorial,
    ]
    

    
    private enum Operation {
    // enums can have functions!
    // all enums have associated values
    // in fact, optionals ARE enums
        case Constant(Double)
        case UniaryOperation((Double)->Double)
        case BinaryOperation((Double, Double)->Double)
        case Equals
        case Factorial
    }
    
    
    func performOperation(symbol: String) {
        internalProgram.append(symbol as AnyObject)
        if let interpretedOperation = operations[symbol] {
            switch interpretedOperation {
            case .Constant(let associatedValue): accumulator = associatedValue
            case .UniaryOperation(let function): accumulator = function(accumulator)
            case .BinaryOperation(let function): pending = PendingBinary(binaryFunction: function, firstNum: accumulator)
            case .Equals:
                if pending != nil {
                    accumulator = pending!.binaryFunction(pending!.firstNum, accumulator)
                    pending = nil
                }
            case .Factorial:
                if accumulator > 0 && floor(accumulator) == accumulator {
                    accumulator = Double(factorial(n: Int(accumulator)))
                } else if accumulator == 0 {
                    accumulator = 1
                }
            }
        }
        
//        if let constant = operations[symbol] {
//            accmulator = constant
//        }
        
//        switch symbol {
//        case "π": accumulator = M_PI
//        case "√": accumulator = sqrt(accumulator)
//        default: break
//        }
    }
    
    func factorial(n: Int) -> Int {
        return n == 0 ? 1 : n * factorial(n: n-1)
    }
    
    
    private var pending: PendingBinary?
    
    private struct PendingBinary {
    // almost identical to classes
    // structs passed by value (like enums) -> it gets COPIED!
    // (Swift is smart, it doesn't ACTUALLY copy it until you try to touch it)
    // classes are passed by reference: passing a pointer to it, have the same one
        
        var binaryFunction: (Double, Double) -> Double
        var firstNum: Double
        
    }
    
    // documentation for reader that PropertyList is really just AnyObject
    typealias PropertyList = AnyObject
    var program: PropertyList {
        get {
            // arrays are value types, not reference types, so it gets COPIED
            return internalProgram as CalculatorModel.PropertyList
        }
        set {
            clear()
            if let arrayOfOps = newValue as? [AnyObject] {
                for op in arrayOfOps {
                    if let operand = op as? Double {
                        setOperand(operand: operand)
                    } else if let operation = op as? String {
                        performOperation(symbol: operation)
                    }
                }
            }
        }
    }
    
    func clear() {
        accumulator = 0.0
        pending = nil
        internalProgram.removeAll()
    }
    
    
    var result: Double {
        get {
            return accumulator
        }
    }
    
    
}
