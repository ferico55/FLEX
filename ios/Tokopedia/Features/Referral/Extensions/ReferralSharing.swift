//
//  ReferralSharing.swift
//  Tokopedia
//
//  Created by Vishun Dayal on 26/12/17.
//  Copyright © 2017 TOKOPEDIA. All rights reserved.
//

import Foundation
internal class ReferralSharing:NSObject, Referable {
    internal var coupanCode: String?
    internal var desktopUrl: String {
        return "https://itunes.apple.com/id/app/tokopedia/id1001394201"
    }
    internal var deeplinkPath: String {
        var path = "referral"
        if let code = self.coupanCode, let name = UserAuthentificationManager().getUserShortName() {
            path += "/" + code
            path += "/" + name
        }
        return path
    }
    internal var feature = "App"
    internal var ogTitle = "Beli & Bayar Ini Itu Mudah, Bonus Cashback s.d 30rb"
    internal var ogDescription = "Cobain mudahnya penuhi semua kebutuhan harianmu lewat Aplikasi Tokopedia, yuk! Download sekarang & nikmati cashback s.d 30rb untuk transaksi pertamamu. Kode: "
    internal var title = "Tokopedia, Satu Aplikasi untuk Semua Kebutuhan "
    internal var buoDescription = "Mudahnya beli produk idaman, pulsa, token listrik, tiket liburan, hingga bayar berbagai tagihan, semua dimulai dari aplikasi Tokopedia. Kamu juga bisa mulai & kembangkan bisnis di sini. Yuk, download sekarang!"
    internal var utmCampaign = "app"
}
