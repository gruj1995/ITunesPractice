//
//  LocaleManager.swift
//  ITunesPractice
//
//  Created by 李品毅 on 2023/3/25.
//

import Foundation

enum LocaleManager {
    static var currentLocale: Locale {
        return Locale.current
    }

    static var countryCode: String {
        if #available(iOS 16, *) {
            return currentLocale.language.region?.identifier ?? ""
        } else {
            return currentLocale.regionCode ?? ""
        }
    }

    static var languageId: String {
        if #available(iOS 16, *) {
            return currentLocale.language.languageCode?.identifier ?? ""
        } else {
            return currentLocale.languageCode ?? ""
        }
    }
}
