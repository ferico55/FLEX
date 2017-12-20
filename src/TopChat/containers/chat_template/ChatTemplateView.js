import React, { PureComponent } from 'react'
import PropTypes from 'prop-types'
import {
  ScrollView,
  Text,
  View,
  Animated,
  TouchableHighlight,
  Image,
} from 'react-native'
import Navigator from 'native-navigation'
import chatGear from '@img/chatGear.png'
import DeviceInfo from 'react-native-device-info'

class ChatTemplateView extends PureComponent {
  onPressTemplate = text => {
    this.props.onPressTemplate(text)
  }

  toSettingPage = () => {
    if (DeviceInfo.isTablet()) {
      Navigator.present(
        'ChatTemplateSetting',
        {},
        {
          modalPresentationStyle: 'formSheet',
        },
      )
    } else {
      Navigator.push('ChatTemplateSetting')
    }
  }

  renderItemChatTemplate = enableTemplate => {
    if (!enableTemplate) {
      return null
    }

    return this.props.chatTemplate.templates.map((v, k) => (
      <TouchableHighlight
        underlayColor={'rgba(212,239,213,0.54)'}
        onPress={() => this.onPressTemplate(v)}
        key={k}
        style={{
          maxWidth: 150,
          height: 32,
          justifyContent: 'center',
          backgroundColor: 'white',
          paddingHorizontal: 10,
          paddingVertical: 9,
          borderRadius: 16,
          borderWidth: 1,
          borderColor: 'rgb(66,181,73)',
          marginRight: 5,
        }}
      >
        <Text
          style={{
            lineHeight: 16,
            fontSize: 12,
            color: 'rgb(66,181,73)',
          }}
          numberOfLines={1}
        >
          {v}
        </Text>
      </TouchableHighlight>
    ))
  }

  renderSettingIcon = () => (
    <TouchableHighlight
      underlayColor={'rgba(212,239,213,0.54)'}
      onPress={() => this.toSettingPage()}
      style={{
        width: 32,
        height: 32,
        justifyContent: 'center',
        alignItems: 'center',
        backgroundColor: 'white',
        paddingVertical: 9,
        borderRadius: 32,
        borderWidth: 1,
        borderColor: 'rgb(66,181,73)',
      }}
    >
      <Image
        source={chatGear}
        style={{ height: 16, width: 15, tintColor: 'rgb(66,181,73)' }}
        resizeMode={'contain'}
      />
    </TouchableHighlight>
  )

  render() {
    if (this.props.animated) {
      const bottomAnimated = this.props.offsetY.interpolate({
        inputRange: [0, 100],
        outputRange: [this.props.bottomOffset, 0],
        extrapolate: 'clamp',
      })
      return (
        <Animated.View
          style={{
            height: 45,
            position: 'absolute',
            bottom: bottomAnimated,
            left: 0,
            right: 0,
            justifyContent: 'center',
          }}
        >
          <ScrollView
            style={{ paddingBottom: 10 }}
            contentContainerStyle={{ paddingHorizontal: 10 }}
            horizontal
            keyboardShouldPersistTaps={'always'}
          >
            <View
              style={{
                flex: 1,
                flexDirection: 'row',
                alignItems: 'flex-start',
              }}
            >
              {this.renderItemChatTemplate(this.props.chatTemplate.is_enable)}
              {this.renderSettingIcon()}
            </View>
          </ScrollView>
        </Animated.View>
      )
    }

    return (
      <View
        style={{
          height: 45,
          position: 'absolute',
          bottom: this.props.bottomOffset,
          left: 0,
          right: 0,
          justifyContent: 'center',
        }}
      >
        <ScrollView
          style={{ paddingBottom: 10 }}
          contentContainerStyle={{ paddingHorizontal: 10 }}
          horizontal
          keyboardShouldPersistTaps={'always'}
        >
          <View
            style={{
              flex: 1,
              flexDirection: 'row',
              alignItems: 'flex-start',
            }}
          >
            {this.renderItemChatTemplate(this.props.chatTemplate.is_enable)}
            {this.renderSettingIcon()}
          </View>
        </ScrollView>
      </View>
    )
  }
}

ChatTemplateView.defaultProps = {
  chatTemplate: {
    templates: [],
  },
  onPressTemplate: () => {},
  bottomOffset: 0,
}

ChatTemplateView.propTypes = {
  bottomOffset: PropTypes.number,
  onPressTemplate: PropTypes.func,
  chatTemplate: PropTypes.shape({
    templates: PropTypes.array.isRequired,
    is_enable: PropTypes.bool,
    loading: PropTypes.bool,
    success: PropTypes.number,
  }),
}

export default ChatTemplateView
