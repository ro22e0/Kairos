//
//  ChatRoomManager.swift
//  Kairos
//
//  Created by Ronaël Bajazet on 19/01/2017.
//  Copyright © 2017 Kairos-app. All rights reserved.
//

import Foundation

// MARK: Singleton
class ChatRoomManager {
    
    static let shared = ChatRoomManager()
    fileprivate init() {}

    var socketClients = [ChatRoom: WebSocketClient]()

    func fetch(_ handler: (() -> Void)? = nil) {
        DataSync.fetchChatRooms() { (status) in
            switch status {
            case .success:
                if handler != nil {
                    handler!()
                }
            case .error(let error):
                print(error)
            }
        }
    }
    
    func all() -> [ChatRoom] {
        if let chatRooms = ChatRoom.all() as? [ChatRoom] {
            return chatRooms
        } else {
            return [ChatRoom]()
        }
    }
    
    func chatRooms() -> [ChatRoom] {
        if let rooms = UserManager.shared.current.user?.chatRooms?.allObjects as? [ChatRoom] {
            return rooms
        }
        return [ChatRoom]()
    }
    
    func messages(for chatroom: ChatRoom) -> [Message] {
        if let messages = chatroom.messages?.allObjects as? [Message] {
            return messages
        }
        return [Message]()
    }
    
    func lastMessage(for chatroom: ChatRoom) -> Message? {
        if var messages = chatroom.messages?.allObjects as? [Message] {
            messages = messages.sorted(by: { $0.createdAt!.compare($1.createdAt as! Date) == .orderedAscending })
            return messages.last
        }
        return nil
    }
    
    func receivers(for chatroom: ChatRoom) -> [User] {
        let users = self.users(for: chatroom)
        var receivers = [User]()

        for u in users {
            if u != UserManager.shared.current.user! {
                receivers.append(u)
            }
        }
        return receivers
    }
    
    func users(for chatroom: ChatRoom) -> [User] {
        if let users = chatroom.users?.allObjects as? [User] {
            return users
        }
        return [User]()
    }
    
    func listen(for chatroom: ChatRoom) {
        if socketClients[chatroom] == nil {
            let webSocket = WebSocketClient(chatRoom: chatroom)
            socketClients[chatroom] = webSocket
            webSocket.connect()
        }
    }
    
    func onReceiveMessage(for chatRoom: ChatRoom, handler: @escaping (Message) -> Void) {
        if let client = socketClients[chatRoom] {
            client.onReceive = handler
        }
    }

    func cleanReceiveHandler(for chatRoom: ChatRoom) {
        if let client = socketClients[chatRoom] {
            client.onReceive = nil
        }
    }
    
    func onSendMessage(_ message: String, for chatRoom: ChatRoom, handler: @escaping (Message) -> Void) {
        if let client = socketClients[chatRoom] {
            client.onSend.append(handler)
            client.send(text: message)
        }
    }
    
    func delete(_ parameters: [String: Any], completionHandler: @escaping (StatusRequest) -> Void) {
        RouterWrapper.shared.request(.deleteChatRoom(parameters)) { (response) in
            switch response.result {
            case .success:
                switch response.response!.statusCode {
                case 200...299:
                    completionHandler(.success(nil))
                default:
                    completionHandler(.error("kFail"))
                }
            case .failure(let error):
                completionHandler(.error(error.localizedDescription))
            }
        }
    }
}
