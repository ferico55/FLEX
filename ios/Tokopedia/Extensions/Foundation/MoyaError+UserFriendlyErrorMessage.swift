//
//  MoyaError+UserFriendlyErrorMessage.swift
//  Tokopedia
//
//  Created by Oscar Yuandinata on 12/13/17.
//  Copyright © 2017 TOKOPEDIA. All rights reserved.
//

import Moya

extension MoyaError {
    func userFriendlyErrorMessage() -> String {
        
        guard let response = self.response else {
            if (self as NSError).code == 4 {
                return "Tidak ada koneksi internet."
            }
            return ""
        }
        
        switch response.statusCode {
            // add handling for other status code if necessary
        default:
            return "Terjadi kendala pada server. Mohon coba beberapa saat lagi."
        }
    }
}
