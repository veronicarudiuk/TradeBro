func debugOutput(_ message: @autoclosure () -> String) {
    #if DEBUG
    print("🐞 \(message())")
    #endif
}

func debugOutput(_ message: @autoclosure () -> Error) {
    #if DEBUG
    print("🐞 \(message().localizedDescription)")
    #endif
}

