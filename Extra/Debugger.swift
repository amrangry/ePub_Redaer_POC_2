//
//  Debugger.swift
//  BookStore
//
//  Created by AmrAngry on 5/8/21.
//  Copyright © 2021 ADKA Tech. All rights reserved.
//

import Foundation

/// Debugger
public class Debugger {
    
    /// Logger method
    /// - Parameters:
    ///   - message:String to be logged
    ///   - file:String  The name of the file in which it appears.
    ///   - function:String  The name of the declaration in which it appears.
    ///   - line: Int   The line number on which it appears.
    ///   - column:Int   The column number in which it begins.
    func eventLogger(_ message: String = "", file: String = #file, function: String = #function, line: Int = #line, column: Int = #column) {
        let fileString: NSString = NSString(string: file)
        printOut("message:\(message) called from file:\(fileString.lastPathComponent) function:\(function) line:\(line) column:\(column)", context: .none)
    }
    
    /// Writes the textual representations of the given items most suitable for
    /// debugging into the standard output.
    /// - Parameters:
    ///   - items: Zero or more items to print.
    ///   - context: DebuggerContext , The default is print
    func printOut(_ items: Any..., context: DebuggerContext = .print) {
        printOut(items, context: context, separator: " ", terminator: "\n")
    }
    
    /// Writes the textual representations of the given items most suitable for
    /// debugging into the standard output.
    ///
    /// You can pass zero or more items to the
    /// `debugPrint(_:separator:terminator:)` function. The textual representation
    /// for each item is the same as that obtained by calling
    /// `String(reflecting: item)`. The following example prints the debugging
    /// representation of a string, a closed range of integers, and a group of
    /// floating-point values to standard output:
    ///
    ///     debugPrint("One two three four five")
    ///     // Prints "One two three four five"
    ///
    ///     debugPrint(1...5)
    ///     // Prints "ClosedRange(1...5)"
    ///
    ///     debugPrint(1.0, 2.0, 3.0, 4.0, 5.0)
    ///     // Prints "1.0 2.0 3.0 4.0 5.0"
    ///
    /// To print the items separated by something other than a space, pass a string
    /// as `separator`.
    ///
    ///     debugPrint(1.0, 2.0, 3.0, 4.0, 5.0, separator: " ... ")
    ///     // Prints "1.0 ... 2.0 ... 3.0 ... 4.0 ... 5.0"
    ///
    /// The output from each call to `debugPrint(_:separator:terminator:)` includes
    /// a newline by default. To print the items without a trailing newline, pass
    /// an empty string as `terminator`.
    ///
    ///     for n in 1...5 {
    ///         debugPrint(n, terminator: "")
    ///     }
    ///     // Prints "12345"
    ///
    /// - Parameters:
    ///   - items: Zero or more items to print.
    ///   - context: DebuggerContext , The default is print
    ///   - separator: A string to print between each item. The default is a single
    ///     space (`" "`).
    ///   - terminator: The string to print after all items have been printed. The
    ///     default is a newline (`"\n"`).
    func printOut(_ items: Any..., context: DebuggerContext = .print, separator: String = " ", terminator: String = "\n") {
        
        if context.isConsolePrintEnable {
            var printableItems = [Any]()
            printableItems.append(context.value)
            printableItems.append(contentsOf: items)
            debugPrint(printableItems, separator: separator, terminator: terminator)
        } else {
            // print not enabled
#if DEBUG
        
#endif
        }
    }
    
    /// Writes the textual representations of the given items most suitable for
    /// debugging into the given output stream.
    ///
    /// You can pass zero or more items to the
    /// `debugPrint(_:separator:terminator:to:)` function. The textual
    /// representation for each item is the same as that obtained by calling
    /// `String(reflecting: item)`. The following example prints a closed range of
    /// integers to a string:
    ///
    ///     var range = "My range: "
    ///     debugPrint(1...5, to: &range)
    ///     // range == "My range: ClosedRange(1...5)\n"
    ///
    /// To print the items separated by something other than a space, pass a string
    /// as `separator`.
    ///
    ///     var separated = ""
    ///     debugPrint(1.0, 2.0, 3.0, 4.0, 5.0, separator: " ... ", to: &separated)
    ///     // separated == "1.0 ... 2.0 ... 3.0 ... 4.0 ... 5.0\n"
    ///
    /// The output from each call to `debugPrint(_:separator:terminator:to:)`
    /// includes a newline by default. To print the items without a trailing
    /// newline, pass an empty string as `terminator`.
    ///
    ///     var numbers = ""
    ///     for n in 1...5 {
    ///         debugPrint(n, terminator: "", to: &numbers)
    ///     }
    ///     // numbers == "12345"
    ///
    /// - Parameters:
    ///   - items: Zero or more items to print.
    ///   - separator: A string to print between each item. The default is a single
    ///     space (`" "`).
    ///   - context: DebuggerContext , The default is print
    ///   - terminator: The string to print after all items have been printed. The
    ///     default is a newline (`"\n"`).
    ///   - output: An output stream to receive the text representation of each
    ///     item.
    func printOut<Target>(_ items: Any..., context: DebuggerContext = .print, separator: String = " ", terminator: String = "\n", to output: inout Target) where Target: TextOutputStream {
#if DEBUG
        debugPrint(items, separator: separator, terminator: terminator, to: &output)
#endif
    }
}

/// DebuggerContext
public enum DebuggerContext {
    /// custome(String)
    case custome(String)
    /// print level
    case print
    /// error level
    case error
    /// errorParsing level
    case errorParsing
    /// technical level should be reported to dev team
    case technical
    /// display in debugging mode
    case debug
    /// None is meant to do nothing
    case none
}

public extension DebuggerContext {
    
    /// value of DebuggerContext enum
    var value: String {
        var result = "DebuggerContext_"
        if case .custome(let new) = self {
            result = "\(result)\(new)"
        } else {
            result = "\(result)\(self)"
            //String(describing: self)
        }
        return result
    }
    
    /// isConsolePrintEnable
    var isConsolePrintEnable: Bool {
        switch self {
        case .none:
            return false
        default:
            return true
        }
    }
}

extension DebuggerContext: Equatable { }

extension DebuggerContext: Hashable { }

//extension DebuggerContext: CustomDebugStringConvertible {
//    public var debugDescription: String {
//        var output = "DebuggerContext_"
//        if case .custome(let new) = self {
//            output = "\(output)\(new)"
//        } else {
//            output = "\(output)\(self)"
//        }
//        return output
//    }
//}

