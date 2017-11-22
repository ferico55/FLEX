import moment from 'moment'

const replyTime = text => {
  const localTime = moment.utc(text).toDate()
  const date = moment(localTime, 'YYYY MMM D HH:mm:ss')

  return date.fromNow()
}

export default replyTime
