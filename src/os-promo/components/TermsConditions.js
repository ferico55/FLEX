import React, { Component } from 'react'
import { View, Text, WebView, StyleSheet } from 'react-native'
import { AllHtmlEntities as Entities } from 'html-entities'


const entities = new Entities()

class TermsConds extends Component {
    render() {
        const { termsCondition } = this.props.navigation.state.params
        const decodeHtml = entities.decode(termsCondition)

        return (
            <WebView source={{ html: decodeHtml }} />
        )
    }

    static navigationOptions = {
        title: 'Syarat & Ketentuan',
        headerTintColor: '#FFF',
        fontWeight: '300',
        headerStyle: {
            backgroundColor: '#42B549'
        }
    };
}

export default TermsConds