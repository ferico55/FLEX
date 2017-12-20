import moment from 'moment'

const unixConverter = (timestamp, format = 'HH:mm', addOffset = true) => {
  return moment.unix(timestamp/1000).format(format)
}

const textToTimeAgo = text => {
  const date = moment(text, 'YYYYMMDD')
  return moment()
    .subtract(moment().diff(date, 'days'), 'days')
    .calendar(null, {
      lastDay: '[KEMARIN]',
      sameDay: '[HARI INI]',
      nextDay: '[Besok]',
      lastWeek(now) {
        if (date.year === now.year) {
          return 'D MMM'
        }
        return 'D MMM YYYY'
      },
      nextWeek: 'dddd',
      sameElse(now) {
        if (date.year === now.year) {
          return 'D MMM'
        }
        return 'D MMM YYYY'
      }
    })
}

const lastReplyTime = text => {
  const date = moment(text, 'YYYY MMM D HH:mm')
  return moment(date).calendar(null, {
    lastDay: '[Kemarin]',
    sameDay: 'HH:mm',
    nextDay: 'L',
    lastWeek: 'D MMM',
    nextWeek: 'L',
    sameElse(now) {
      if (date.year === now.year) {
        return 'D MMM'
      }
      return 'D MMM YYYY'
    },
  })
}

const getTime = () => moment().utc().format()

const getTimeFromNow = (timestamp) => moment.unix(timestamp).fromNow()

const getUnixTime = (offset = 0, format = 'HH:mm') => {
  let timeFormat
  let addOffset
  if (typeof offset === 'number') {
    addOffset = offset
    timeFormat = format
  } else if (typeof offset === 'string') {
    addOffset = 0
    timeFormat = offset
  }

  const unixMiliSecond = moment()
    .add(addOffset, 'hours')
    .unix()

  return {
    unixNanoSecond: unixMiliSecond * 1000,
    unixMiliSecond,
    unixFormat: (milisecond = true) => {
      if (milisecond) {
        return moment.unix(unixMiliSecond).format(timeFormat)
      }
      return moment.unix(unixMiliSecond * 1000).format(timeFormat)
    },
  }
}

export { unixConverter, textToTimeAgo, getTime, getUnixTime, lastReplyTime, getTimeFromNow }
