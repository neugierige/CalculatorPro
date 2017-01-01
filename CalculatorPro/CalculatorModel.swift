//
//  CalculatorModel.swift
//  Calculator
//
//  Created by Luyuan Xing on 12/12/16.
//  Copyright © 2016 Luyuan Xing. All rights reserved.
//

import Foundation

class CalculatorModel {
    
    var result: Double {
        get {
            return accumulator
        }
    }
    
    private var accumulator = 0.0
    private var internalProgram = [Any]()
    
    func setOperand(operand: Double) {
        accumulator = operand
        internalProgram.append(operand)
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
    
    
    typealias PropertyList = AnyObject // documentation for reader that PropertyList is really just AnyObject
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
    
    private let operations: Dictionary<String, Operation> = [
        "÷": Operation.HighOrderBinaryOperation({$0 / $1}),
        "✕": Operation.HighOrderBinaryOperation({$0 * $1}),
        "-": Operation.LowOrderBinaryOperation({$0 - $1}),
        "+": Operation.LowOrderBinaryOperation({$0 + $1}),
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
        "x²": Operation.UniaryOperation({$0*$0}),
        "x^3": Operation.UniaryOperation({pow($0, 3)}),
        "x^y": Operation.HighOrderBinaryOperation({pow($0, $1)}),
        "10^x": Operation.UniaryOperation({pow(10.0, $0)}),
        "1/x": Operation.UniaryOperation({1/$0}),
        "e^x": Operation.UniaryOperation({pow(M_E, $0)}),
        "x!": Operation.Factorial,
    ]
    

    private enum Operation {
    // enums can have functions!
    // all enums have associated values
    // in fact, optionals ARE enums
        case Constant(Double)
        case UniaryOperation((Double)->Double)
        case HighOrderBinaryOperation((Double, Double)->Double)
        case LowOrderBinaryOperation((Double, Double)->Double)
        case Equals
        case Factorial
        
        var isHighOrder: Bool {
            switch self {
            case .LowOrderBinaryOperation(_):
                return false
            default:
                return true
            }
        }
    }
    
//    private func shouldEvaluate(_ currentOp: Operation) -> Bool {
//        // check if last operator was a high order operation
//        // return true if last operator was high order or if `operation` is low order
//        
//        let lastOp = internalProgram.last as! Operation
//        // TODO: return true if there is no "lastOp"
//        
//        return lastOp.isHighOrder && !currentOp.isHighOrder
//    }
    
    
    func performOperation(symbol: String) {
        if let operationInput = operations[symbol] {
            internalProgram.append(operationInput)
            
            // guard shouldEvaluate(interpretedOperation) else { return }
            var interpretedOperation = operationInput
            if internalProgram.count > 3 {
                interpretedOperation = operations["="]!
            }
            
            switch interpretedOperation {
            case .Constant(let associatedValue):
                accumulator = associatedValue
            case .UniaryOperation(let function):
                accumulator = function(accumulator)
            case .HighOrderBinaryOperation(let function):
                pending = PendingBinary(binaryFunction: function, firstNum: accumulator)
            case .LowOrderBinaryOperation(let function):
                pending = PendingBinary(binaryFunction: function, firstNum: accumulator)
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
    
    
    func clear() {
        accumulator = 0.0
        pending = nil
        internalProgram.removeAll()
    }
    
    
}
