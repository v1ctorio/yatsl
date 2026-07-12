import Foundation
@main
struct yatsl {

    

public static func main() {

    if CommandLine.arguments.count < 2 {
        print("ERROR: no input file provided")
        exit(33)
    }
    let sourcefile = CommandLine.arguments[1]
    let sourceurl = URL(fileURLWithPath: sourcefile)
    guard let source = try? String(contentsOf: sourceurl) else {
        print("ERROR: unable to read \(sourcefile)")
        exit(33)
    }
    print(source)
    debugP("-----------")

    let lexer = Lexer(sourcefile, source)
    let tokens = tokenize(lexer)
    
    debugP("-----------")
    var i = 0
    for token in tokens {
        print("\(i): \(token.display())")
        i += 1
    }
}

}