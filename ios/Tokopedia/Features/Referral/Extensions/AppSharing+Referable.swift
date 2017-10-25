//
//  AppSharing+Referable.swift
//  Tokopedia
//
//  Created by Vishun Dayal on 23/10/17.
//  Copyright © 2017 TOKOPEDIA. All rights reserved.
//

import Foundation
class AppSharing:NSObject, Referable {
    var desktopUrl: String {
        return "https://itunes.apple.com/id/app/tokopedia/id1001394201"
    }
    var deeplinkPath: String {
        return "home"
    }
    var feature = "App"
    var title = "Tokopedia, Satu Aplikasi untuk Semua Kebutuhan"
    var buoDescription = "Mudahnya beli produk idaman, pulsa, token listrik, tiket liburan, hingga bayar berbagai tagihan, semua dimulai dari aplikasi Tokopedia. Kamu juga bisa mulai & kembangkan bisnis di sini. Yuk, download sekarang!"
    var utm_campaign = "app"
}
