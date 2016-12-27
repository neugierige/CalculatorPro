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
        // "x!": Operation.UniaryOperation(),
    ]
    

    
    private enum Operation {
    // enums can have functions!
    // all enums have associated values
    // in fact, optionals ARE enums
        case Constant(Double)
        case UniaryOperation((Double)->Double)
        // case FailableUniaryOperation((Double)->AnyObject)
        case BinaryOperation((Double, Double)->Double)
        case Equals
    }
    
    
    func performOperation(symbol: String) {
        internalProgram.append(symbol as AnyObject)
        if let interpretedOperation = operations[symbol] {
            switch interpretedOperation {
            case .Constant(let associatedValue): accumulator = associatedValue
            case .UniaryOperation(let function): accumulator = function(accumulator)
            // case .FailableUniaryOperation(let function): result = function(accumulator)
            case .BinaryOperation(let function): pending = PendingBinary(binaryFunction: function, firstNum: accumulator)
            case .Equals:
                if pending != nil {
                    accumulator = pending!.binaryFunction(pending!.firstNum, accumulator)
                    pending = nil
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
    
    func factorial(num: Double) -> AnyObject {
        if num < 0 || floor(num) != num {
            return "Error" as AnyObject
        } else if num == 0 {
            return 1 as AnyObject
        }
        
        var result = num
        while result > 0 {
            result *= result - 1
            result -= 1
        }
        return result as AnyObject
    }
    
    var result: Double {
        get {
            return accumulator
        }
    }
    
    
}
