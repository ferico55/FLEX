import React from 'react'
import { Image, StyleSheet, View, TouchableOpacity, Text } from 'react-native'
import moment from 'moment'
import entities from 'entities'
import { ReactTPRoutes } from 'NativeModules'

const styles = StyleSheet.create({
  mutedText: {
    color: 'rgba(0,0,0,0.54)',
  },
  replyText: { fontSize: 13, lineHeight: 21, marginTop: 8 },
  separator: {
    height: 1,
    flex: 1,
    borderTopWidth: 1,
    borderColor: '#rgb(224,224,224)',
  },
  replyHeaderContainer: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    alignItems: 'center',
  },
  moreContainer: {
    alignItems: 'center',
    justifyContent: 'center',
    height: 20,
    width: 20,
  },
  sellerBadge: {
    backgroundColor: 'rgb(213,0,0)',
    borderRadius: 3,
    paddingHorizontal: 4,
    paddingVertical: 4,
  },
})

const ReplyComponent = ({
  item,
  merchantShopID,
  shopName,
  userID,
  isReplyDisabled,
  handleReplyOptionClick,
}) => {
  const isSameYear = moment
    .unix(item.review_data.review_response.response_create_time.unix_timestamp)
    .utcOffset(0)
    .isSame(moment(), 'year')
  const dateFormat = isSameYear ? 'D MMM' : 'D MMM YYYY'
  return (
    <View>
      <View style={styles.separator} />
      <View style={{ paddingLeft: 30, paddingRight: 8, paddingVertical: 16 }}>
        <View style={styles.replyHeaderContainer}>
          <TouchableOpacity
            onPress={() => {
              ReactTPRoutes.navigate(`tokopedia://shop/${merchantShopID}`)
            }}
          >
            <Text style={{ color: 'rgba(0,0,0,0.54)', lineHeight: 19 }}>
              {'Oleh '}
              <Text style={{ color: 'rgba(0,0,0,0.7)', fontWeight: '500' }}>
                {entities.decodeHTML(shopName)}
              </Text>
            </Text>
          </TouchableOpacity>
          {userID === `${item.review_data.review_response.response_by}` &&
          !isReplyDisabled && (
            <TouchableOpacity onPress={handleReplyOptionClick}>
              <View style={styles.moreContainer}>
                <Image
                  source={{ uri: 'icon_more_grey' }}
                  style={{ height: 3, width: 13 }}
                />
              </View>
            </TouchableOpacity>
          )}
        </View>
        <View
          style={{
            flexDirection: 'row',
            marginTop: 2,
            alignItems: 'center',
          }}
        >
          <View style={styles.sellerBadge}>
            <Text style={{ color: 'white', fontSize: 12 }}>{'Penjual'}</Text>
          </View>
          <Text
            style={{
              color: 'rgba(0,0,0,0.38)',
              fontSize: 12,
              marginLeft: 5,
            }}
          >
            {moment
              .unix(
                item.review_data.review_response.response_create_time
                  .unix_timestamp,
              )
              .utcOffset(0)
              .format(dateFormat)}
          </Text>
        </View>
        <Text style={[styles.mutedText, styles.replyText]}>
          {entities.decodeHTML(
            item.review_data.review_response.response_message,
          )}
        </Text>
      </View>
    </View>
  )
}

export default ReplyComponent
