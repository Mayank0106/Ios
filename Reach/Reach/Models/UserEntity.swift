//
//  UserEntity.swift
//  SnapClient
//
//  Copyright © 2018年 Kboy. All rights reserved.
//

import Foundation

struct UserEntity {
    let displayName: String?
    let avatar: String?
    let email: String?
    let externalId: String?

    private enum CodingKeys: String, CodingKey {
        case data
    }

    private enum DataKeys: String, CodingKey {
        case me
    }

    private enum MeKeys: String, CodingKey {
        case displayName
        case bitmoji
        case externalId
        case email
    }

    private enum BitmojiKeys: String, CodingKey {
        case avatar
    }
}

extension UserEntity: Decodable {

    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        let data = try values.nestedContainer(keyedBy: DataKeys.self, forKey: .data)
        let me = try data.nestedContainer(keyedBy: MeKeys.self, forKey: .me)
        displayName = try? me.decode(String.self, forKey: .displayName)
        externalId = try? me.decode(String.self, forKey: .externalId)
        email = try? me.decode(String.self, forKey: .email)
        let bitmoji = try me.nestedContainer(keyedBy: BitmojiKeys.self, forKey: .bitmoji)
        avatar = try? bitmoji.decode(String.self, forKey: .avatar)
    }
}
