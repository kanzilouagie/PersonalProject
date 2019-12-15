//
//  SettingsSections.swift
//  Bash
//
//  Created by Kanzi Louagie on 08/12/2019.
//  Copyright © 2019 Kanzi Louagie. All rights reserved.
//


protocol SectionType: CustomStringConvertible {
    var containsSwitch: Bool { get }
}

enum SettingsSections: Int, CaseIterable, CustomStringConvertible {
    case Social
    case Communication
    
    var description: String {
        switch self {
        case .Social: return "Sociaal"
        case .Communication: return "Communicatie"
        }
    }
}

enum SocialOptions: Int, CaseIterable, SectionType {
    case editProfile
    case logOut
    case friendList
    case requestList
    
    var containsSwitch: Bool { return false}
    var description: String {
        switch self {
        case .editProfile: return "Uitloggen"
        case .logOut: return "Vrienden Toevoegen"
        case .friendList: return "Vriendenlijst"
        case .requestList: return "Vriendschapsverzoeken"
        }
    }
    
}

enum CommunicationOptions: Int, CaseIterable, SectionType {
    case notifications
    case reportCrashes
    
    var containsSwitch: Bool {
        switch self {
        case .notifications: return true
        case .reportCrashes: return true
        }
        
    }
    var description: String {
        switch self {
        case .notifications: return "Notificaties"
        case .reportCrashes: return "Rapporteer Crashes"
        }
    }
}
