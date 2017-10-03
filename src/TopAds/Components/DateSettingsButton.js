import React from 'react'
import { StyleSheet, Text, View, TouchableOpacity, Image } from 'react-native'
import color from '../Helper/Color'
import calendarImg from '../Icon/calendar.png'
import arrowRightImg from '../Icon/arrow_right.png'

const styles = StyleSheet.create({
  infoDateContainer: {
    height: 64,
    backgroundColor: color.lineGrey,
    paddingVertical: 1,
  },
  infoDateSubContainer: {
    flex: 1,
    flexDirection: 'row',
    backgroundColor: 'white',
  },
  infoDateCalendarImageContainer: {
    marginHorizontal: 17,
    width: 20,
    alignItems: 'center',
    justifyContent: 'center',
  },
  infoDateCalendarImageView: {
    height: 25,
    width: 25,
  },
  infoDateRangeContainer: {
    flex: 6,
    alignItems: 'center',
    flexDirection: 'row-reverse',
  },
  infoDateRangeLabel: {
    color: color.mainGreen,
    fontWeight: '500',
  },
  infoDateRangeArrowImageView: {
    height: 12,
    width: 8,
    marginLeft: 6,
    marginRight: 17,
  },
})

const DateSettingsButton = ({ currentDateRange, buttonTapped }) => {
  const dateString = dateRange => {
    if (!dateRange) {
      return '-'
    }

    if (dateRange.startDate.isSame(dateRange.endDate, 'day')) {
      return dateRange.startDate.format('D MMMM YYYY')
    }
    return dateRange.startDate.isSame(dateRange.endDate, 'year')
      ? `${dateRange.startDate.format('D MMMM')} - ${dateRange.endDate.format(
          'D MMMM YYYY',
        )}`
      : `${dateRange.startDate.format(
          'D MMMM YYYY',
        )} - ${dateRange.endDate.format('D MMMM YYYY')}`
  }

  return (
    <TouchableOpacity
      style={styles.infoDateContainer}
      onPress={() => buttonTapped()}
    >
      <View style={styles.infoDateSubContainer}>
        <View style={styles.infoDateCalendarImageContainer}>
          <Image
            style={styles.infoDateCalendarImageView}
            source={calendarImg}
          />
        </View>
        <View style={styles.infoDateRangeContainer}>
          <Image
            style={styles.infoDateRangeArrowImageView}
            source={arrowRightImg}
          />
          <Text style={styles.infoDateRangeLabel}>
            {dateString(currentDateRange)}
          </Text>
        </View>
      </View>
    </TouchableOpacity>
  )
}

export default DateSettingsButton
