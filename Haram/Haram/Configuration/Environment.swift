//
//  Environment.swift
//  Haram
//
//  Created by 이건준 on 3/30/24.
//

import Foundation

public enum Environment {
    // MARK: - Keys
    enum Keys {
        enum Plist {
            static let baseURL = "BASE_URL"
            static let naverClientID = "NAVER_CLIENTID"
        }
    }

    // MARK: - Plist
    private static let infoDictionary: [String: Any] = {
        guard let dict = Bundle.main.infoDictionary else {
            fatalError("Plist file not found")
        }
        return dict
    }()

    // MARK: - Plist values
    static let baseURLString: String = {
        guard let rootURLstring = Environment.infoDictionary[Keys.Plist.baseURL] as? String else {
            fatalError("Root URL not set in plist for this environment")
        }
        return rootURLstring
    }()

    static let naverClientID: String = {
        guard let naverClientID = Environment.infoDictionary[Keys.Plist.naverClientID] as? String else {
            fatalError("API Key not set in plist for this environment")
        }
        return naverClientID
    }()
}
