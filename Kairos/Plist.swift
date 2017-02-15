//
//  Plist.swift
//  Kairos
//
//  Created by Ronaël Bajazet on 21/04/2016.
//  Copyright © 2016 Kairos-app. All rights reserved.
//

import Foundation

struct Plist {
    //1
    enum PlistError: Error {
        case fileNotWritten
        case fileDoesNotExist
    }
    //2
    let name:String
    //3
    var sourcePath:String? {
        guard let path = Bundle.main.path(forResource: name, ofType: "plist") else { return .none }
        return path
    }
    //4
    var destPath:String? {
        guard sourcePath != .none else { return .none }
        let dir = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
        return (dir as NSString).appendingPathComponent("\(name).plist")
    }
    
    init?(name:String) {
        //1
        self.name = name
        //2
        let fileManager = FileManager.default
        //3
        guard let source = sourcePath else { return nil }
        guard let destination = destPath else { return nil }
        guard fileManager.fileExists(atPath: source) else { return nil }
        //4
        if !fileManager.fileExists(atPath: destination) {
            //5
            do {
                try fileManager.copyItem(atPath: source, toPath: destination)
            } catch let error as NSError {
                print("Unable to copy file. ERROR: \(error.localizedDescription)")
                return nil
            }
        }
    }
    
    //1
    func getValuesInPlistFile() -> NSDictionary?{
        let fileManager = FileManager.default
        if fileManager.fileExists(atPath: destPath!) {
            guard let dict = NSDictionary(contentsOfFile: destPath!) else { return .none }
            return dict
        } else {
            return .none
        }
    }
    //2
    func getMutablePlistFile() -> NSMutableDictionary?{
        let fileManager = FileManager.default
        if fileManager.fileExists(atPath: destPath!) {
            guard let dict = NSMutableDictionary(contentsOfFile: destPath!) else { return .none }
            return dict
        } else {
            return .none
        }
    }
    //3
    func addValuesToPlistFile(_ dictionary:NSDictionary) throws {
        let fileManager = FileManager.default
        if fileManager.fileExists(atPath: destPath!) {
            if !dictionary.write(toFile: destPath!, atomically: false) {
                print("File not written successfully")
                throw PlistError.fileNotWritten
            }
        } else {
            throw PlistError.fileDoesNotExist
        }
    }
}
