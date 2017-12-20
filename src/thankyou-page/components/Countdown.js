import React, { Component } from 'react'
import {
    View,
    Text
} from 'react-native'
import PropTypes from 'prop-types'
import moment from 'moment'
import TimerMixin from 'react-timer-mixin'



export default class CountDown extends Component {
  static propTypes = {
    duration: PropTypes.number,
  }

  state = {
    isExpired: false,
    durationDate: moment().set('second', moment().second() + this.props.timestamp),
  }

  componentWillMount() {
    const newDate = moment()
    const diff = this.state.durationDate.diff(newDate)

    if (diff < 0) {
      TimerMixin.clearInterval(this.timerInterval)

      this.setState({
        isExpired: true,
        dateDiff: diff,
      })
    }
  }

  componentDidMount() {
    this.timerInterval = TimerMixin.setInterval(() => this.timerTick(), 1000)

  }

  componentDidUpdate() {
    if (this.state.isExpired) {
      TimerMixin.clearInterval(this.timerInterval)
    }
  }

  componentWillUnmount() {
    TimerMixin.clearInterval(this.timerInterval)
  }

  timerTick = () => {
    const newDate = moment();
    const diff = this.state.durationDate.diff(newDate)
    this.setState({
      isExpired: diff < 0,
      dateDiff: diff,
    })

    if (diff < 0) {
      TimerMixin.clearInterval(this.timerInterval)
    }
  }

  render() {
    const duration = moment.duration(this.state.dateDiff);
    let hour = moment.utc(duration.as('milliseconds')).format('HH')
    let minute = moment.utc(duration.as('milliseconds')).format('mm')
    let second = moment.utc(duration.as('milliseconds')).format('ss')

    return (
      <View>
        {
            !this.state.isExpired ? (
                <View style={{flexDirection: 'row'}}>
                    <View>
                      <Text style={{ fontSize: 28, marginTop: 10, fontWeight: '500', color: 'rgba(0, 0, 0, 0.7)' }}>{hour} : </Text>
                      <Text style={{ fontSize: 14, color: 'rgba(0,0,0,0.54)' }}>Jam</Text>
                    </View>
                    <View>
                      <Text style={{ fontSize: 28, marginTop: 10, fontWeight: '500', color: 'rgba(0, 0, 0, 0.7)' }}>{minute} : </Text>
                      <Text style={{ fontSize: 14, color: 'rgba(0,0,0,0.54)' }}>Menit</Text>
                    </View>
                    <View>
                      <Text style={{ fontSize: 28, marginTop: 10, fontWeight: '500', color: 'rgba(0, 0, 0, 0.7)' }}>{second}</Text>
                      <Text style={{ fontSize: 14, color: 'rgba(0,0,0,0.54)' }}>Detik</Text>
                    </View>
                </View>
            ) : (
                <Text>Pembayaran telah mencapain batas maksimal</Text>
            )
        }
      </View>
    )
  }
}
