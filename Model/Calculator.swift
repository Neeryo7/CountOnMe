//
//  Model.swift
//  CountOnMe
//
//  Created by Aymerik Vallejo on 20/12/2021.
//  Copyright © 2021 Vincent Saluzzo. All rights reserved.
//

import Foundation

protocol DisplayDelegate: AnyObject {
    func updateDisplay(text: String)
    func presentAlert()
}

class Calculator {
    
    weak var delegate: DisplayDelegate?

    
    var elements: [String] = []

    
    var display: String {
        return elements.joined()
    }
    
    
    // Cheking des possibles erreurs avant calculs
    var expressionIsCorrect: Bool {
        return elements.count >= 3 && expressionHasOperand && !lastElementIsOperand
        && !(display.contains("/0"))
    }
    var lastElementIsOperand: Bool {
        guard let lastElement = elements.last else { return false }
        return lastElement == "+" || lastElement == "-" || lastElement == "x" || lastElement == "/"
    }
    var lastElementIsNumber: Bool {
        guard let lastElement = display.last else { return false }
        return lastElement.isNumber == true
    }
    
    var expressionHasOperand: Bool {
        return elements.contains("+") || elements.contains("-") || elements.contains("x")
        || elements.contains("/")
    }
    var canAddOperator: Bool {
        return elements.count != 0 && !lastElementIsOperand
    }
    var expressionHasResult: Bool {
        return elements.contains("=")
    }
    
    // Fonction du bouton AC
    func reset() {
        elements.removeAll()
        delegate?.updateDisplay(text: "0")
    }
    
    // Fonction qui gère la priorité des calculs (multiplication et divison)
    func managePriorities() -> [String] {
        var operationsToReduce = elements
        while operationsToReduce.contains("x") || operationsToReduce.contains("/") {
            if let index = operationsToReduce.firstIndex(where: { $0 == "x" || $0 == "/" })  {
                let operand = operationsToReduce[index]
                let result: Double
                if let left = Double(operationsToReduce[index - 1]) {
                    if let right = Double(operationsToReduce[index + 1]) {
                        if operand == "x" {
                            result = left * right
                        } else {
                            result = left / right
                        }
                        // On remplace les calculs de la multiplication par son résultat
                        operationsToReduce.remove(at: index + 1)
                        operationsToReduce.remove(at: index)
                        operationsToReduce.remove(at: index - 1)
                        operationsToReduce.insert(formatResult(result), at: index - 1)
                    }
                }
            }
        }
        return operationsToReduce
    }
    
    //This is the main algorithm which will produce the result from the expression:
    func performCalcul() {
        var expression = managePriorities()
        // Iterate over operations while an operand still here:
        while expression.count > 1 {
            guard let left = Double(expression[0]) else { return }
            guard let right = Double(expression[2]) else { return }
            let operand = expression[1]
            let result: Double
            switch operand {
            case "+": result = left + right
            case "-": result = left - right
            default: return
            }
            expression = Array(expression.dropFirst(3))
            expression.insert(formatResult(result), at: 0)
        }
        //Add result to elements to update display
        guard let finalResult = expression.first else { return }
        elements.append("=")
        elements.append("\(finalResult)")
    }
    
    func notifyDisplay() {
        delegate?.updateDisplay(text: display)
    }
    
    //  Fusion des nombres e l'expression  avec les prochains qui vont être cliquer
    func joiningNumbers(next: String) {
        guard let lastElement = elements.last else { return }
        let newElement = lastElement + next
        elements.removeLast()
        elements.append(newElement)
    }
    
    func numberButton(number: String) {
        if expressionHasResult  { // Si il y a déjà un resultat, cliquer sur un novueau numéro reinitialise tout
            elements.removeAll()
            elements.append(number)
        } else if lastElementIsNumber {
            joiningNumbers(next: number)
        } else {
            elements.append(number)
        }
        notifyDisplay()
    }
    func operandButton(operand: String) {
        if expressionHasResult { // Si il y a déjà un resultat, on commence la nouvelle opération avec celui ci
            if let result = elements.last {
                elements.removeAll()
                elements.append("\(result)")
                elements.append("\(operand)")
                notifyDisplay()
            }
        } else {
            if canAddOperator {
                elements.append("\(operand)")
                notifyDisplay()
            }
        }
    }
    
    private func formatResult(_ result: Double) -> String {
        let formatter = NumberFormatter()
        formatter.minimumFractionDigits = 0
        formatter.maximumFractionDigits = 2
        guard let formatedResult = formatter.string(from: NSNumber(value: result)) else { return String() }
        return formatedResult
    }
    func equalButton() {
        // Vérifie si l'opération est possible, sinon envoie un message d'alerte
        guard expressionIsCorrect else {
            delegate?.presentAlert()
            return
        }
        // Puis on vérifie si il y a déjà un résultat avant le calcul, du coup le bouton egal ne renvoi rien
        if !expressionHasResult  {
            performCalcul()
            notifyDisplay()
            return
        }
    }
}






