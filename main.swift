import Foundation
// Function to parse input string and extract information
func parseInput(input: String) -> [String] {
    // Split the input string into an array of words
    let words = input.components(separatedBy: " ")
    var final: [String] = []
    // Process each word or perform specific parsing logic
    for word in words {
        switch word.lowercased() {
        case "and":
            final.append("∧")
        case "or":
            final.append("∨")
        case "not":
            final.append("¬")
        case "xor":
            final.append("⊕")
        case "implies":
            final.append("→")
        case "equals":
            final.append("=")
        case "notequals":
            final.append("≠")
        default:
            final.append(word)
        }
    }
    return final
}
func createInput() -> [String] {
    // Get text input from the user
    print("Enter some text:")
    let input = readLine()!
    let parsed = parseInput(input: input)
//    guard parsed.count > 2 else {fatalError("Not enough arguments, needs at least two variables and an operator.")}
//    guard parsed.count % 2 == 1 else {fatalError("Incorrect number of arguments.")}
    return parsed
}
func power(b: Double, e: Double) -> Int {
    return Int(pow(b, e))
}

func table(input: [String]) {
    var strInput = ""
    for n in input {
        strInput += "\(n) "
    }
    strInput.removeLast()
    let symbols = ["¬", "(", ")", "∧", "∨", "⊕", "→", "=", "≠"]
    var varNames : [String] = []
    var varPos : [Int] = []
    var fixedValues : [Bool?] = []
    for name in 0 ..< input.count {
        if !symbols.contains(input[name]) {
            varNames.append(input[name])
            varPos.append(name)
        }
    }
    guard input.count > 1 else {
        print("Error: Too Short")
        return
    }
    // Guard against more than one normal variable occurring in a row
    guard !varPos.contains(where: { varPos.contains($0 + 1) }) else {
        print("Error: Invalid syntax - More than one normal variable in a row.")
        return
    }

    // Guard against a variable being before a parenthesis or not operator
    for n in 0 ..< input.count - 1 {
        guard !(!symbols.contains(input[n]) && (input[n + 1] == "(" || input[n + 1] == "¬")) else {
            print("Error: Invalid syntax - Variable before a parenthesis or not operator.")
            return
        }
    }

    // Guard against ending with an operator (exception, ending with ")" or beginning with the not operator or "(")
        guard !symbols.contains(input.last!) || input.last! == ")" || input.first! == "¬" || input.first! == "(" else {
            print("Error: Invalid syntax - Ending with an operator.")
            return
        }

        // Guard against abnormal use of parentheses (not having ")" before "(", etc.)
        guard !(input.contains("(") && !input.contains(")")) && !(input.contains(")") && !input.contains("(")) else {
            print("Error: Invalid syntax - Abnormal use of parentheses.")
            return
        }
    for current in varNames {
        print("\(current)|", terminator:"")    
           if current.lowercased() == "true" {
               fixedValues.append(true)
           } else if current.lowercased() == "false" {
               fixedValues.append(false)
           } else {
               fixedValues.append(nil)
           }
    }
    print(strInput)
    let columns = varNames.count
    // Count the number of variables with fixed values
    let numFixedVariables = fixedValues.filter { $0 != nil }.count
    // Generate rows based on the number of fixed variables
    for column in 0 ..< power(b:2, e: Double(columns - numFixedVariables)) {
        var row = ""
        var fixedIndex = 0
        var values : [Bool] = []

        for position in 0..<columns {
            if let fixedValue = fixedValues[position] {
                // If a fixed value is specified, use it
                values.append(fixedValue ? true : false)
                row += fixedValue ? "T" : "F"
            } else {
                // Otherwise, extract the value from the column
                let bit = (column & (1 << fixedIndex)) != 0
                values.append(bit ? true : false)
                row += bit ? "T" : "F"
                fixedIndex += 1
            }
            for _ in 0 ..< varNames[position].count - 1{
                row += " "
            }
            row += "|"
        }
        var expressed = input
        for n in 0 ..< input.count {
            if varPos.contains(n) {
                expressed[n] = String(values[varPos.firstIndex(of:n)!]).lowercased()
            }
        }
        print("\(row) -> \(evaluateBooleanExpression(input: expressed))")
    }
}

func evaluateBooleanExpression(input: [String]) -> String {
    // Convert "true" and "false" strings to corresponding boolean values
    var symbols : [String] = []
    var isBool : [Bool] = []
    for n in 0 ..< input.count {
        if input[n].count == 1 {
            symbols.append(input[n])
            isBool.append(false)
        } else {
            isBool.append(true)
        }
    }
    let booleanValues = input.map { $0.lowercased() == "true" }
    //print(symbols);    print(isBool);    print(booleanValues)
    // Evaluate the boolean expression
    let result = evaluateExpressionRecursively(booleanValues, symbols, isBool)

    // Print the result
    if result == true {
        return "T"
    }
    return "F"
}

func evaluateExpressionRecursively(_ booleanValues1: [Bool], _ symbols1: [String], _ isBool1: [Bool]) -> Bool {
    //  let symList = ["¬", "(", "∧", "∨", "⊕", "→", "=", "≠"]
    var cursymInd = 0
    var booleanValues = booleanValues1
    var symbols = symbols1
    var isBool = isBool1
    var curisBool = 0
    var currentIndex = 0
    var symbolIndex = -1
    while cursymInd < 5 {
        while currentIndex < booleanValues.count {
            if isBool[curisBool] == false {
                symbolIndex += 1
                let operatorSymbol = symbols[symbolIndex]
                if operatorSymbol == "(" && cursymInd == 0 {
                    //parathensis recursion
                    let leftLoc = [curisBool, currentIndex, symbolIndex]
                    var rightLoc : [Int] = []
                    for _ in currentIndex + 1 ..< booleanValues.count {
                        curisBool += 1
                        currentIndex += 1
                        if !isBool[curisBool] {
                            symbolIndex += 1
                        }
                        if symbols[symbolIndex] == ")" {
                            rightLoc = [curisBool, currentIndex, symbolIndex]
                        }
                    }
                    booleanValues[leftLoc[1] + 1] = evaluateExpressionRecursively(Array(booleanValues[leftLoc[1] + 1 ... rightLoc[1] - 1]), Array(symbols[leftLoc[2] + 1 ... rightLoc[2] - 1]), Array(isBool[leftLoc[0] + 1 ... rightLoc[0] - 1]))
                    isBool.removeSubrange(leftLoc[0] + 2 ... rightLoc[0])
                    booleanValues.removeSubrange(leftLoc[1] + 2 ... rightLoc[1])
                    symbols.removeSubrange(leftLoc[2] + 1 ... rightLoc[2])
                    isBool.remove(at: leftLoc[0])
                    booleanValues.remove(at: leftLoc[1])
                    symbols.remove(at: leftLoc[2])
                    curisBool -= 1
                    currentIndex -= 1
                    symbolIndex -= 1
                } else if operatorSymbol == "¬" && cursymInd == 1 {
                    //not operator (priority before parathensis)
                    booleanValues[currentIndex + 1] = !booleanValues[currentIndex + 1]
                    booleanValues.remove(at: currentIndex)
                    symbols.remove(at: symbolIndex)
                    isBool.remove(at: curisBool)
                    symbolIndex -= 1
                    currentIndex -= 1
                    curisBool -= 1
                } else if operatorSymbol == "∧" && cursymInd == 2 {
                    // "and" operations
                    booleanValues[currentIndex - 1] = (booleanValues[currentIndex - 1] == booleanValues[currentIndex + 1]) && booleanValues[currentIndex + 1] == true
                    booleanValues.removeSubrange(currentIndex ... currentIndex + 1)
                    symbols.remove(at: symbolIndex)
                    isBool.removeSubrange(curisBool ... curisBool + 1)
                    symbolIndex -= 1
                    currentIndex -= 2
                    curisBool -= 2
                } else if (operatorSymbol == "⊕" || operatorSymbol == "→" || operatorSymbol == "∨") && cursymInd == 3 {
                    // XOR, Implies, and Or have equal priority
                    if operatorSymbol == "⊕" && (booleanValues[currentIndex - 1] != booleanValues[currentIndex + 1]) {
                        booleanValues[currentIndex - 1] = true
                    } else if operatorSymbol == "→" && !(booleanValues[currentIndex - 1] == true && booleanValues[currentIndex + 1] == false) {
                        booleanValues[currentIndex - 1] = true
                    } else if operatorSymbol == "∨" && (booleanValues[currentIndex - 1] == true || booleanValues[currentIndex + 1] == true) {
                        booleanValues[currentIndex - 1] = true
                    } else {
                        booleanValues[currentIndex - 1] = false
                    }
                    booleanValues.removeSubrange(currentIndex ... currentIndex + 1)
                    symbols.remove(at: symbolIndex)
                    isBool.removeSubrange(curisBool ... curisBool + 1)
                    symbolIndex -= 1
                    currentIndex -= 2
                    curisBool -= 2
                } else if cursymInd == 4 {
                    // Equals and Not Equals have the lowest priority
                    if operatorSymbol == "=" && (booleanValues[currentIndex - 1] == booleanValues[currentIndex + 1]) {
                         booleanValues[currentIndex - 1] = true
                    } else if operatorSymbol == "≠" && (booleanValues[currentIndex - 1] != booleanValues[currentIndex + 1]) {
                        booleanValues[currentIndex - 1] = true
                    } else {
                        booleanValues[currentIndex - 1] = false
                    }
                    booleanValues.removeSubrange(currentIndex ... currentIndex + 1)
                    symbols.remove(at: symbolIndex)
                    isBool.removeSubrange(curisBool ... curisBool + 1)
                    symbolIndex -= 1
                    currentIndex -= 2
                    curisBool -= 2
                }
            }
            curisBool += 1
            currentIndex += 1
        }
        cursymInd += 1
        curisBool = 0
        currentIndex = 0
        symbolIndex = -1
    }
    return booleanValues[0]
}
//evaluateBooleanExpression(input: ["true", "=", "(", "false", "or", "true", ")", "xor", "false", "and", "false"])


//credit to chatgpt for doing some of it :)


table(input:createInput())
