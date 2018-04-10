//
//  AppSharing+Referable.swift
//  Tokopedia
//
//  Created by Vishun Dayal on 23/10/17.
//  Copyright © 2017 TOKOPEDIA. All rights reserved.
//

import Foundation
internal class AppSharing:NSObject, Referable {
    internal var desktopUrl: String {
        return "https://itunes.apple.com/id/app/tokopedia/id1001394201"
    }
    internal var deeplinkPath: String {
        return "home"
    }
    internal var feature = "App"
    internal var title = "Tokopedia, Satu Aplikasi untuk Semua Kebutuhan "
    internal var buoDescription = "Mudahnya beli produk idaman, pulsa, token listrik, tiket liburan, hingga bayar berbagai tagihan, semua dimulai dari aplikasi Tokopedia. Kamu juga bisa mulai & kembangkan bisnis di sini. Yuk, download sekarang!"
    internal var utmCampaign = "app"
}
