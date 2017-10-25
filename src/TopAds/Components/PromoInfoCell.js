import React, { Component } from 'react'
import { StyleSheet, Text, View, Image, ActivityIndicator } from 'react-native'
import color from '../Helper/Color'

const styles = StyleSheet.create({
  promoInfoContainer: {
    backgroundColor: 'white',
    paddingHorizontal: 30,
    paddingBottom: 17,
  },
  promoInfoTitleLabel: {
    fontWeight: '500',
    height: 20,
    fontSize: 16,
    marginTop: 15,
    marginBottom: 3,
    color: color.blackText,
  },
  promoInfoActiveContainer: {
    height: 20,
    marginBottom: 2,
    flexDirection: 'row',
    alignItems: 'center',
  },
  promoInfoActiveImageView: {
    height: 8,
    width: 8,
    borderRadius: 4,
    marginRight: 7,
  },
  promoInfoActiveLabel: {
    color: color.greyText,
  },
  promoInfoPerClickLabel: {
    color: color.greyText,
    height: 20,
    marginBottom: 11,
  },
  promoInfoUsedCreditsLabel: {
    fontWeight: '500',
    color: color.blackText,
    fontSize: 16,
    height: 20,
    marginRight: 4,
  },
  priceDailyBarOuter: {
    marginTop: 17,
    height: 5,
    borderRadius: 3,
    backgroundColor: color.lineGrey,
    marginBottom: 5,
  },
  priceDailyBarInner: {
    borderRadius: 3,
    backgroundColor: color.mainGreen,
  },
  priceInfoContainer: {
    height: 20,
    flexDirection: 'row',
  },
  drawerIconOuterContainer: {
    position: 'absolute',
    top: 0,
    left: 0,
    right: 0,
    bottom: 0,
    alignItems: 'center',
    flexDirection: 'row-reverse',
  },
  drawerIconContainer: {
    width: 30,
    alignItems: 'center',
    justifyContent: 'center',
  },
})

class PromoInfoCell extends Component {
  populatedCell = () => {
    const ad = this.generateCellDataFromAd(this.props.adType, this.props.ad)

    return (
      <View style={styles.promoInfoContainer}>
        <Text style={styles.promoInfoTitleLabel}>{ad.title}</Text>
        <View style={styles.promoInfoActiveContainer}>
          <View
            style={[
              styles.promoInfoActiveImageView,
              {
                backgroundColor:
                  ad.status !== 3 ? color.mainGreen : color.lineGrey,
              },
            ]}
          />
          <Text style={styles.promoInfoActiveLabel}>{ad.statusDesc}</Text>
        </View>
        <Text style={styles.promoInfoPerClickLabel}>{ad.perClickLabel}</Text>
        <Text style={styles.promoInfoUsedCreditsLabel}>
          {ad.usedCreditsLabel}
        </Text>
        {this.additionalInfo(ad)}
        {this.props.adType === 0 && (
          <View style={styles.drawerIconOuterContainer}>
            <View style={styles.drawerIconContainer}>
              <Image
                source={{ uri: 'flick' }}
                style={{
                  height: 12,
                  width: 8,
                }}
              />
            </View>
          </View>
        )}
      </View>
    )
  }
  additionalInfo = ad => {
    if (
      this.props.adType !== 1 &&
      (ad.dailyPriceSpent !== '-' && ad.dailyPriceSpent !== '')
    ) {
      const greenFlex = parseFloat(ad.dailyPriceBar)
      const emptyFlex = 100 - greenFlex

      return (
        <View>
          <View style={[styles.priceDailyBarOuter, { flexDirection: 'row' }]}>
            <View style={[styles.priceDailyBarInner, { flex: greenFlex }]} />
            <View style={{ flex: emptyFlex }} />
          </View>
          <View style={styles.priceInfoContainer}>
            <Text style={{ color: color.greyText, fontSize: 14 }}>
              Anggaran Harian
            </Text>
            <Text
              style={{
                flex: 1,
                textAlign: 'right',
                color: color.blackText,
                fontSize: 14,
                fontWeight: '500',
              }}
            >
              {ad.dailyPriceSpent}
              <Text
                style={{ color: color.greyText }}
              >{` / ${ad.dailyPrice}`}</Text>
            </Text>
          </View>
        </View>
      )
    } else if (this.props.adType === 1 && ad.groupId !== 0) {
      return (
        <Text
          style={{ color: color.greyText, marginTop: 5, fontSize: 14 }}
        >{`Grup: ${ad.groupName}`}</Text>
      )
    }

    return <View />
  }
  loadingCell = () => <ActivityIndicator size="large" />

  generateCellDataFromAd = (adType, ad) => {
    // adType: 0 = group, 1 = product, 2 = shop
    let title = '-'
    let status = 3
    let statusDesc = ''
    let perClickLabel = '-'
    let usedCreditsLabel = '-'
    let dailyPrice = '-'
    let dailyPriceSpent = '-'
    let dailyPriceBar = '0.000'
    let groupName = '-'
    let groupId = 0

    if (ad) {
      if (adType === 2) {
        title = ad.shop_name
        status = ad.ad_status
        statusDesc = ad.ad_status_desc
        perClickLabel = `${ad.ad_price_bid_fmt
          ? ad.ad_price_bid_fmt
          : ''} ${ad.label_per_click}`
        usedCreditsLabel = `Terpakai ${ad.stat_total_spent}`
        dailyPrice = ad.ad_price_daily_fmt
        dailyPriceSpent = ad.ad_price_daily_spent_fmt
        dailyPriceBar = ad.ad_price_daily_bar
      } else if (adType === 0) {
        title = ad.group_name
        status = ad.group_status
        statusDesc = ad.group_status_desc
        perClickLabel = `${ad.group_price_bid_fmt
          ? ad.group_price_bid_fmt
          : ''} ${ad.label_per_click}`
        usedCreditsLabel = `Terpakai ${ad.stat_total_spent}`
        dailyPrice = ad.group_price_daily_fmt
        dailyPriceSpent = ad.group_price_daily_spent_fmt
        dailyPriceBar = ad.group_price_daily_bar
      } else if (adType === 1) {
        title = ad.product_name
        status = ad.ad_status
        statusDesc = ad.ad_status_desc
        perClickLabel = `${ad.ad_price_bid_fmt
          ? ad.ad_price_bid_fmt
          : ''} ${ad.label_per_click}`
        usedCreditsLabel = `Terpakai ${ad.stat_total_spent}`
        groupId = ad.group_id
        groupName = ad.group_name
      }
    }

    return {
      title,
      status,
      statusDesc,
      perClickLabel,
      usedCreditsLabel,
      dailyPrice,
      dailyPriceSpent,
      dailyPriceBar,
      groupId,
      groupName,
    }
  }
  render() {
    return (
      <View>
        {this.props.isLoading ? this.loadingCell() : this.populatedCell()}
      </View>
    )
  }
}

export default PromoInfoCell
