//
//  WebSocketClient.swift
//  Kairos
//
//  Created by Ronaël Bajazet on 20/01/2017.
//  Copyright © 2017 Kairos-app. All rights reserved.
//

import Foundation
import Starscream
import SwiftyJSON

class WebSocketClient: WebSocketDelegate {
    
    private var urlString: String
    private var socket: WebSocket
    private var chatRoom: ChatRoom
    
    var onReceive: ((Message) -> Void)?
    var onSend = [((Message) -> Void)]()
    
    init(chatRoom: ChatRoom) {
        self.chatRoom = chatRoom
        let credentials = UserManager.shared.getCredentials()
        let accessToken = credentials["access-token"]
        let client = credentials["client"]
        let uid = credentials["uid"]

        urlString = "ws://apikairos-formule3.c9users.io:8080/cable?" //"ws://kairos-api-ro22e0.c9users.io:8080/cable?"
        urlString += "token=\(accessToken!)&uid=\(uid!)&client=\(client!)"
        socket = WebSocket(url: URL(string: urlString)!)
        socket.delegate = self
    }
    
    func connect() {
        socket.connect()
    }
    
    func send(text: String) {
        let user = UserManager.shared.current.user
        var message = "{\"command\": \"message\", \"identifier\": \"{\\\"channel\\\": \\\"ChatRoomChannel\\\"," +
        "\\\"id\\\": \\\""
        message += "\(chatRoom.chatRoomID!)" + "\\\"}\", \"data\": \"{\\\"body\\\": \\\"" + text + "\\\", " + "\\\"action\\\": \\\"send_message\\\", \\\"user_id\\\": " + "\(user!.userID!)" + "}\"}"
        socket.write(string: message)
    }
    
    func websocketDidConnect(socket: WebSocket) {
        print("websocket is connected")
        
        var message = "{\"command\": \"subscribe\", \"identifier\": \"{\\\"channel\\\": \\\"ChatRoomChannel\\\","
        message += "\\\"id\\\": \\\"" + "\(chatRoom.chatRoomID!)" + "\\\"}\"}"
        socket.write(string: message.description)
    }
    
    func websocketDidDisconnect(socket: WebSocket, error: NSError?) {
        print("websocket is disconnected: \(error?.localizedDescription)")
        connect()
    }
    
    func websocketDidReceiveMessage(socket: WebSocket, text: String) {
        print("got some text: \(text)")
        if let dataFromString = text.data(using: .utf8, allowLossyConversion: false) {
            let json = JSON(data: dataFromString).dictionaryValue
            if json["type"]?.string == nil {
                if let data = json["message"]?["data"] {
//                    DataSync.syncMessages(data) {
//                        if let message = Message.find("id == %@", args: data["id"].int32Value) as? Message {
//                            if let handler = self.onSend.first {
//                                handler(message)
//                                _ = self.onSend.remove(at: 0)
//                            }
//                            if let onReceive = self.onReceive {
//                                onReceive(message)
//                            } else {
//                                DispatchQueue.main.async {
//                                    Spinner.shout(message: message)
//                                }
//                            }
//                        }
//                    }
                }
            }
        }
    }
    
    func websocketDidReceiveData(socket: WebSocket, data: Data) {
        print("got some data: \(data.count)")
    }
    
    func websocketDidReceivePong(socket: WebSocket, data: Data?) {
        print("Got pong! Maybe some data: \(data?.count)")
    }
}
