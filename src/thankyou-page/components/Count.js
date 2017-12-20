import React, { Component } from 'react'
import {
    View,
    Text
} from 'react-native'



export default class Count extends Component {
    constructor(props) {
        super(props)
        
        this.state = { 
            time: {}, 
            seconds: props.timestamp 
        }
        this.timer = 0
        this.startTimer = this.startTimer.bind(this)
        this.countDown = this.countDown.bind(this)
    }

    secondsToTime(secs){
        let hours = Math.floor(secs / (60 * 60))

        let divisor_for_minutes = secs % (60 * 60)
        let minutes = Math.floor(divisor_for_minutes / 60)

        let divisor_for_seconds = divisor_for_minutes % 60
        let seconds = Math.ceil(divisor_for_seconds)

        let obj = {
            "h": hours,
            "m": minutes,
            "s": seconds
        };
        return obj
    }

    componentDidMount() {
        let timeLeftVar = this.secondsToTime(this.state.seconds)
        this.setState({ time: timeLeftVar })
        this.startTimer()
    }

    startTimer() {
        if (this.timer == 0) {
            this.timer = setInterval(this.countDown, 1000)
        }
    }

    countDown() {
        // Remove one second, set state so a re-render happens.
        let seconds = this.state.seconds - 1
        this.setState({
            time: this.secondsToTime(seconds),
            seconds: seconds,
        })
        
        // Check if we're at zero.
        if (seconds == 0) { 
            clearInterval(this.timer)
        }
    }

    render() {
        return(
            <View style={{flexDirection: 'row'}}>
                <View>
                    <Text style={{ fontSize: 36, marginTop: 10, color: 'rgba(0, 0, 0, 0.7)' }}>{this.state.time.h} </Text>
                    <Text style={{ fontSize: 12, color: 'rgba(0,0,0,0.54)', textAlign: 'center' }}>Jam</Text>
                </View>
                <View>
                    <Text style={{ fontSize: 36, marginTop: 10, color: 'rgba(0, 0, 0, 0.7)' }}>: </Text>
                </View>
                <View>
                    <Text style={{ fontSize: 36, marginTop: 10, color: 'rgba(0, 0, 0, 0.7)' }}>{this.state.time.m}</Text>
                    <Text style={{ fontSize: 12, color: 'rgba(0,0,0,0.54)', textAlign: 'center' }}>Menit</Text>
                </View>
                <View>
                    <Text style={{ fontSize: 36, marginTop: 10, color: 'rgba(0, 0, 0, 0.7)' }}> : </Text>
                </View>
                <View>
                    <Text style={{ fontSize: 36, marginTop: 10, color: 'rgba(0, 0, 0, 0.7)' }}>{this.state.time.s}</Text>
                    <Text style={{ fontSize: 12, color: 'rgba(0,0,0,0.54)', textAlign: 'center' }}>Detik</Text>
                </View>
            </View>
        )
    }
}
