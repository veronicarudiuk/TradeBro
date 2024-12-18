import Foundation

func debugOutput(_ message: @autoclosure () -> Any = "",
                 file: String = #file,
                 function: String = #function,
                 line: Int = #line) {
    #if DEBUG
    let fileName = (file as NSString).lastPathComponent
    if let error = message() as? Error {
        print("🐞 [\(fileName):\(line)] \(function): \(error.localizedDescription)")
    } else {
        print("🐞 [\(fileName):\(line)] \(function): \(message())")
    }
    #endif
}
