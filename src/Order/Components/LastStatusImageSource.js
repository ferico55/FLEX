import waitingSellerResponse from '../Icon/menunggu-respon-penjual.png'
import replacementOnProcess from '../Icon/pencarian-toko-pengganti.png'
import replacementSuccess from '../Icon/pencarian-toko-pengganti-berhasil.png'
import finished from '../Icon/pesanan-selesai.png'
import delivered from '../Icon/pesanan-sampai-ditujuan.png'
import cancelledShipping from '../Icon/pesanan-gagal-dikirim.png'
import shipped from '../Icon/pesanan-dalam-pengiriman.png'
import cancelledOrder from '../Icon/pesanan-dibatalkan.png'
import awaitingShipment from '../Icon/pesanan-diterima-penjual.png'
import cancelledDeliver from '../Icon/pesanan-gagal-selesai.png'

import boxGreen from '../Icon/detail/box_green.png'
import boxRed from '../Icon/detail/box_red.png'
import truckGreen from '../Icon/detail/boxcar_green.png'
import truckRed from '../Icon/detail/boxcar_red.png'
import boxHandGreen from '../Icon/detail/boxhand_green.png'
import boxOpenGreen from '../Icon/detail/boxopen_green.png'
import boxOpenRed from '../Icon/detail/boxopen_red.png'
import boxResoGreen from '../Icon/detail/boxreso_green.png'

export function imageSource(status) {
  const allStatus = {
    AWAITING_SHIPMENT: awaitingShipment,
    AWAITING_PROCESS: waitingSellerResponse,
    SHIPPED: shipped,
    DELIVERED: delivered,
    FINISHED: finished,
    CANCELLED_ORDER: cancelledOrder,
    CANCELLED_SHIPPING: cancelledShipping,
    CANCELLED_DELIVER: cancelledDeliver,
    REPLACEMENT_SEARCH: replacementOnProcess,
    REPLACEMENT_SUCCESS: replacementSuccess,
  }

  return allStatus[status] || waitingSellerResponse
}

export function imageSourceDetail(status) {
  const allStatus = {
    AWAITING_SHIPMENT: boxGreen,
    AWAITING_PROCESS: boxGreen,
    SHIPPED: truckGreen,
    DELIVERED: boxHandGreen,
    FINISHED: boxOpenGreen,
    CANCELLED_ORDER: boxRed,
    CANCELLED_SHIPPING: truckRed,
    CANCELLED_DELIVER: boxOpenRed,
    REPLACEMENT_SEARCH: boxResoGreen,
    REPLACEMENT_SUCCESS: boxResoGreen,
  }

  return allStatus[status] || boxGreen
}
