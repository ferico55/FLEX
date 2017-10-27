import moment from 'moment'

export const expiryTime = dateString => {
  if (!dateString) {
    return moment()
      .add(10, 'years')
      .valueOf()
  }

  return moment(dateString, 'YYYY-MM-DD hh:mm:ss').valueOf()
}
