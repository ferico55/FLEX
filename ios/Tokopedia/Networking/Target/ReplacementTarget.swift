//
//  ReplacementTarget.swift
//  Tokopedia
//
//  Created by Renny Runiawati on 3/31/17.
//  Copyright © 2017 TOKOPEDIA. All rights reserved.
//

import UIKit
import Moya

class ReplacementProvider: RxMoyaProvider<ReplacementTarget> {
    
    init() {
        super.init(endpointClosure: ReplacementProvider.endpointClosure,
                   manager: DefaultAlamofireManager.sharedManager,
                   plugins: [NetworkLoggerPlugin(verbose: true),NetworkPlugin()])
    }
    
    private static func endpointClosure(target: ReplacementTarget) -> Endpoint<ReplacementTarget> {
        return NetworkProvider.defaultEndpointCreator(for: target)
    }
    
}

enum ReplacementTarget {
    case listReplacement(filters: [String:String], query: String, page: Int)
    case takeReplacement(id: String)
}

extension ReplacementTarget: TargetType {
    
    var baseURL: URL { return URL(string: NSString.v4Url())! }
    var path: String {
        switch self {
        case .listReplacement( _):
            return "/v4/order/replacement/list"
        case .takeReplacement( _):
            return "/v4/order/replacement"
        }
    }
    var method: Moya.Method {
        switch self {
        case .listReplacement( _):
            return .get
        case .takeReplacement( _):
            return .post
        }
    }
    
    var parameters: [String: Any]? {
        switch self {
        case .listReplacement(let filters, let query, let page):
            let parameter =
                ["page" : page,
                 "search" : query,
                 "per_page" : "10"] as [String : Any]
            var parameters = parameter.merged(with: filters) as NSDictionary
            parameters = parameters.autoParameters() as NSDictionary
            let bindedParameters = parameters as! [String : Any]
            
            return bindedParameters
        case .takeReplacement(let replacementId):
            return ["r_id" : replacementId]
        }
    }
    var parameterEncoding: ParameterEncoding {
        return URLEncoding.default
    }
    
    var sampleData: Data {
        switch self {
        case .listReplacement( _):
            return "{\"config\":null,\"data\":{\"booking\":null,\"order\":{\"is_allow_manage_tx\":1,\"shop_name\":\"Value Store Staging\",\"is_gold_shop\":0,\"total_order_retry\":0},\"paging\":{\"uri_next\":\"https://staging.tokopedia.com/v4/order/replacement/opportunity_list?page=2\",\"uri_previous\":\"0\"},\"list\":[{\"order_replacement_id\":551,\"order_order_id\":12459670,\"order_payment_at\":\"2017-04-04 11:03:26\",\"order_expired_at\":\"2017-04-06 11:03:26\",\"order_cashback_idr\":\"Rp 0\",\"order_cashback\":\"0\",\"order_customer\":{\"customer_url\":\"https://staging.tokopedia.com/people/5480358\",\"customer_id\":\"5480358\",\"customer_name\":\"Emma Watson\",\"customer_image\":\"https://imagerouter-staging.tokopedia.com/image/v1/u/5480358/user_thumbnail/android\"},\"order_payment\":{\"payment_process_due_date\":\"06 April 2017\",\"payment_komisi\":\"Rp 118.180\",\"payment_verify_date\":\"04 April 2017\",\"payment_shipping_due_date\":\"10 April 2017\",\"payment_process_day_left\":2,\"payment_gateway_id\":6,\"payment_gateway_image\":\"https://ecs7.tokopedia.net/img/mandiri-ecash-2.png\",\"payment_shipping_day_left\":6,\"payment_gateway_name\":\"mandiri e-cash\"},\"order_detail\":{\"detail_insurance_price\":\"0\",\"detail_open_amount\":\"118.180\",\"detail_dropship_name\":0,\"detail_total_add_fee\":180,\"detail_partial_order\":\"0\",\"detail_quantity\":1,\"detail_product_price_idr\":\"Rp 100.000\",\"detail_invoice\":\"INV/20170404/XVII/IV/12459620\",\"detail_shipping_price_idr\":\"Rp 18.000\",\"detail_free_return\":0,\"detail_pdf_path\":\"pdf/2017/04/04\",\"detail_free_return_msg\":\"Transaksi ini difasilitasi fitur Free Returns dan akan otomatis selesai dalam waktu 3 hari. Dalam jangka waktu tersebut, Anda bisa menyampaikan komplain lewat Pusat Resolusi untuk mengajukan retur produk.\",\"detail_additional_fee_idr\":\"Rp 180\",\"detail_product_price\":\"100.000\",\"detail_preorder\":{\"preorder_status\":0,\"preorder_process_time_type\":null,\"preorder_process_time_type_string\":null,\"preorder_process_time\":null},\"detail_cancel_request\":{\"cancel_request\":0,\"reason_time\":\"\",\"reason\":\"\"},\"detail_force_insurance\":0,\"detail_open_amount_idr\":\"Rp 118.180\",\"detail_additional_fee\":\"180\",\"detail_dropship_telp\":0,\"detail_order_id\":12459670,\"detail_total_add_fee_idr\":\"Rp 180\",\"detail_order_date\":\"04 April 2017\",\"detail_shipping_price\":\"18000\",\"detail_pay_due_date\":\"06 April 2017\",\"detail_total_weight\":0.1,\"detail_insurance_price_idr\":\"Rp 0\",\"detail_pdf_uri\":\"https://staging.tokopedia.com/invoice.pl?id=12459670&pdf=Invoice-5480358-478945-20170404110326-T1JHT1BKREU\",\"detail_ship_ref_num\":\"\",\"detail_print_address_uri\":\"https://staging.tokopedia.com/print-address.pl?id=12459670\",\"detail_pdf\":\"Invoice-5480358-478945-20170404110326-T1JHT1BKREU.pdf\",\"detail_order_status\":11},\"order_deadline\":{\"deadline_process_day_left\":1,\"deadline_process_hour_left\":45,\"deadline_process\":\"1 Hari 21 Jam\",\"deadline_po_process_day_left\":0,\"deadline_shipping_day_left\":5,\"deadline_shipping_hour_left\":141,\"deadline_shipping\":\"5 Hari 21 Jam\",\"deadline_finish_day_left\":0,\"deadline_finish_hour_left\":0,\"deadline_finish_date\":0,\"deadline_color\":\"\"},\"order_shop\":{\"address_postal\":\"11410\",\"address_district\":\"Jakarta\",\"address_city\":\"Kota Administrasi Jakarta\",\"address_street\":\"Jalan Aipda Ks.Tubun III\",\"shipper_phone\":\"087836804040\",\"address_country\":0,\"address_province\":\"DKI Jakarta\"},\"order_products\":[{\"order_deliver_quantity\":1,\"product_weight_unit\":1,\"order_detail_id\":20261600,\"product_status\":\"1\",\"product_id\":14266689,\"product_current_weight\":\"100\",\"product_picture\":\"https://imagerouter-staging.tokopedia.com/image/v1/p/14266689/product_m_thumbnail/android\",\"product_price\":\"Rp 100.000\",\"product_description\":\"asdasdasd asdlasdkas;d al;skd;askd\r\nasdas;kd;laskld asdka;sldk ;alskd; asl;d \r\nas\r\ndl;askd;askd aslkd;laskd\",\"product_normal_price\":\"100000\",\"product_price_currency\":1,\"product_notes\":0,\"order_subtotal_price\":\"100.000\",\"product_quantity\":1,\"product_weight\":\"0.10\",\"order_subtotal_price_idr\":\"Rp 100.000\",\"product_reject_quantity\":0,\"product_url\":\"https://staging.tokopedia.com/qc54/keyboard-logitech\",\"product_name\":\"Keyboard Logitech\"}],\"order_shipment\":{\"shipment_logo\":\"http://ecs7.tokopedia.net/img/kurir-ninja.png\",\"shipment_package_id\":\"23\",\"shipment_id\":\"12\",\"shipment_product\":\"Next Day\",\"shipment_name\":\"Ninja Xpress\",\"same_day\":0},\"order_last\":{\"last_order_id\":12459670,\"last_shipment_id\":\"12\",\"last_est_shipping_left\":0,\"last_order_status\":\"0\",\"last_status_date\":\"04 April 2017 11:14:24\",\"last_pod_code\":0,\"last_pod_desc\":\"\",\"last_shipping_ref_num\":\"\",\"last_pod_receiver\":0,\"last_comments\":\"refund\",\"last_buyer_status\":\"Transaksi dibatalkan\",\"last_status_date_wib\":\"04 April 2017, 11:14 WIB\",\"last_seller_status\":\"Transaksi dibatalkan\"},\"order_history\":[{\"history_status_date\":\"04/04/2017 11:14\",\"history_status_date_full\":\"04 April 2017 11:14\",\"history_order_status\":\"0\",\"history_comments\":\"refund\",\"history_action_by\":\"Tokopedia\",\"history_buyer_status\":\"Transaksi dibatalkan\",\"history_seller_status\":\"Transaksi dibatalkan\"},{\"history_status_date\":\"04/04/2017 11:03\",\"history_status_date_full\":\"04 April 2017 11:03\",\"history_order_status\":\"220\",\"history_comments\":0,\"history_action_by\":\"Buyer\",\"history_buyer_status\":\"Verifikasi Konfirmasi Pembayaran<br>Pembayaran telah diterima Tokopedia dan pesanan Anda sudah diteruskan ke penjual\",\"history_seller_status\":\"Verifikasi Konfirmasi Pembayaran<br>Pembayaran telah diterima Tokopedia dan pesanan Anda sudah diteruskan ke penjual\"},{\"history_status_date\":\"04/04/2017 11:03\",\"history_status_date_full\":\"04 April 2017 11:03\",\"history_order_status\":\"100\",\"history_comments\":0,\"history_action_by\":\"Buyer\",\"history_buyer_status\":\"Melakukan proses Check Out order<br>Menunggu konfirmasi pembayaran\",\"history_seller_status\":\"Pembeli melakukan proses Check Out order\"}],\"order_destination\":{\"receiver_phone_is_tokopedia\":0,\"receiver_name\":\"selvi\",\"address_country\":\"Indonesia\",\"address_postal\":\"40293\",\"address_district\":\"Bandung\",\"receiver_phone\":\"081294641764\",\"address_street\":\"Komp panorama alam prahyangan bandung\",\"address_city\":\"Kota Bandung\",\"address_province\":\"Jawa Barat\"}}]},\"server_process_time\":0.337908,\"status\":\"OK\",\"error_message\":[]}".data(using: String.Encoding.utf8)!
        case .takeReplacement( _):
            return "{\"jsonapi\":{\"version\":\"1.0\"},\"meta\":null,\"data\":{\"order_id\":0,\"status\":-1,\"message\":\"Untuk mengambil peluang ini, Anda perlu berlangganan fitur Gold Merchant dan memiliki shop score : 60.\"},\"links\":{\"self\":\"\",\"related\":\"\",\"first\":\"\",\"last\":\"\",\"prev\":\"\",\"next\":\"\"}}".data(using: String.Encoding.utf8)!
        }
    }
    
    public var task: Task {
        return .request
    }
}
