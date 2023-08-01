//
//  Monitor.swift
//  AITool
//
//  Created by Ken Torimaru on 7/24/23.
//

import Foundation

class Monitor {
    enum State {
        case active(CInt, DispatchSourceFileSystemObject)
        case inactive
    }
    private var state: State = .inactive
    private let queue = DispatchQueue(label: "com.acme.monitor", attributes: .concurrent)
    private let fileURL: URL
    private var fileDidChange: (() -> Void)?

    var fileExists: Bool {
        FileManager.default.fileExists(atPath: fileURL.path)
    }

    var directoryURL: URL {
        fileURL.deletingLastPathComponent()
    }

    init(fileURL: URL, fileDidChange: (() -> Void)?) {
        self.fileURL = fileURL
        self.fileDidChange = fileDidChange
    }

    deinit {
        cancel()
    }

    func start() {
        guard case State.inactive = state else { return }

        let path = fileExists ? fileURL.path : directoryURL.path
        let fileDescriptor = open(path, O_EVTONLY)
        guard fileDescriptor != -1 else { return }
        let source = DispatchSource.makeFileSystemObjectSource(fileDescriptor: fileDescriptor, eventMask: .write, queue: queue)

        source.setEventHandler(handler: eventHandler)
        source.setCancelHandler(handler: cancel)
        source.activate()

        state = .active(fileDescriptor, source)
    }

    private func eventHandler() {
        print(#function)
        guard let fileDidChange = fileDidChange else { return }
        fileDidChange()
    }

    func cancel() {
        guard case let State.active(fileDescriptor, source) = state else { return }
        source.cancel()
        close(fileDescriptor)
        state = .inactive
    }
}
