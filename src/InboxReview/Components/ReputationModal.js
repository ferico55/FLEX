import React from 'react'
import { Image, StyleSheet, View, Text } from 'react-native'

import InfoModal from '../../unify/InfoModal'
import DynamicSizeImage from '../Components/DynamicSizeImage'

const styles = StyleSheet.create({
  smileyModal: { width: 24, height: 24, marginRight: 8 },
  modalText: {
    color: 'rgba(0,0,0,0.38)',
    fontSize: 11,
    lineHeight: 17,
    marginRight: 16,
  },
})

const ReputationModal = ({ onRequestClose, visible, reviewee_data }) => (
  <InfoModal
    visible={visible}
    onRequestClose={onRequestClose}
    title={
      reviewee_data.reviewee_role_id === 1 ? (
        'Reputasi Pembeli'
      ) : (
        'Reputasi Toko'
      )
    }
    renderContent={() => {
      if (reviewee_data.reviewee_role_id === 1) {
        return (
          <View>
            <Text
              style={{
                fontSize: 13,
                lineHeight: 21,
                color: 'rgba(0,0,0,0.54)',
                marginVertical: 8,
              }}
            >
              {'Nilai pembeli yang diberikan penjual'}
            </Text>
            <View
              style={{
                flex: 1,
                flexDirection: 'row',
                alignItems: 'center',
                marginTop: 16,
              }}
            >
              <Image
                source={{ uri: 'icon_smile50' }}
                style={styles.smileyModal}
              />
              <Text style={styles.modalText}>
                {reviewee_data.reviewee_buyer_badge.positive}
              </Text>
              <Image
                source={{ uri: 'icon_sad50' }}
                style={styles.smileyModal}
              />
              <Text style={styles.modalText}>
                {reviewee_data.reviewee_buyer_badge.negative}
              </Text>
              <Image
                source={{ uri: 'icon_neutral50' }}
                style={styles.smileyModal}
              />
              <Text style={styles.modalText}>
                {reviewee_data.reviewee_buyer_badge.neutral}
              </Text>
            </View>
          </View>
        )
      }
      return (
        <View>
          <Text
            style={{
              fontSize: 13,
              lineHeight: 21,
              color: 'rgba(0,0,0,0.54)',
              marginVertical: 8,
            }}
          >
            {'Nilai toko yang diberikan pembeli'}
          </Text>
          <View
            style={{
              flex: 1,
              flexDirection: 'row',
              alignItems: 'center',
              marginTop: 8,
            }}
          >
            <DynamicSizeImage
              uri={reviewee_data.reviewee_shop_badge.reputation_badge_url}
              height={24}
            />
            <Text
              style={{
                marginLeft: 8,
                fontSize: 13,
                lineHeight: 21,
                color: 'rgba(0,0,0,0.54)',
              }}
            >{`${reviewee_data.reviewee_shop_badge.score} Poin`}</Text>
          </View>
        </View>
      )
    }}
  />
)

export default ReputationModal
