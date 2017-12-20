import React, { PureComponent } from 'react'
import {
  View,
  Animated,
  Easing,
  StyleSheet,
  Text,
  Image,
  TouchableOpacity,
} from 'react-native'
import DeviceInfo from 'react-native-device-info'
import dragIcon from '@img/dragIcon.png'
import trashIcon from '@img/trashNotActive.png'

const styles = StyleSheet.create({
  container: {
    flex: 1,
    justifyContent: 'center',
    alignItems: 'center',
    backgroundColor: '#eee',
  },

  title: {
    fontSize: 20,
    paddingVertical: 20,
    color: '#999999',
  },

  list: {
    flex: 1,
  },

  row: {
    flexDirection: 'row',
    alignItems: 'center',
    backgroundColor: '#fff',
    height: 65,
    paddingVertical: 24,
    flex: 1,
    borderBottomWidth: 0.5,
    borderBottomColor: 'rgb(224,224,224)',
  },

  image: {
    width: 16,
    height: 16,
  },

  text: {
    fontSize: 14,
    color: 'rgba(0,0,0,0.7)',
  },
})

class Row extends PureComponent {
  constructor(props) {
    super(props)

    this.active = new Animated.Value(0)

    this.style = {
      transform: [
        {
          scale: this.active.interpolate({
            inputRange: [0, 1],
            outputRange: [1, 0.9],
          }),
        },
      ],
      shadowRadius: this.active.interpolate({
        inputRange: [0, 1],
        outputRange: [2, 10],
      }),
    }
  }

  componentWillReceiveProps(nextProps) {
    if (this.props.active !== nextProps.active) {
      Animated.timing(this.active, {
        duration: 300,
        easing: Easing.bounce,
        toValue: Number(nextProps.active),
      }).start()
    }
  }

  renderByDevice = (index, data, totalItem) => {
    if (DeviceInfo.isTablet()) {
      return (
        <View style={{ flexDirection: 'row', flex: 1, paddingRight: 16 }}>
          <View style={{ justifyContent: 'center', flex: 0.05 }}>
            <Image
              source={dragIcon}
              style={[styles.image, { tintColor: 'rgb(66,181,73)' }]}
              resizeMode={'contain'}
            />
          </View>
          <View style={{ justifyContent: 'center', flex: 0.65 }}>
            <Text numberOfLines={2} style={styles.text}>
              {data.text}
            </Text>
          </View>
          <View
            style={{
              flex: 0.3,
              alignItems: 'center',
              justifyContent: 'flex-end',
              flexDirection: 'row',
            }}
          >
            <TouchableOpacity
              onPress={() => this.props.onPressEdit(data.text, index)}
            >
              <Image
                source={{ uri: 'icon_edit_plain' }}
                style={[styles.image, { tintColor: 'rgb(102,102,102)' }]}
                resizeMode={'contain'}
              />
            </TouchableOpacity>
            {totalItem === 1 ? null : (
              <View
                style={{
                  width: 1,
                  height: 24,
                  backgroundColor: 'rgb(224,224,224)',
                  marginHorizontal: 16,
                }}
              />
            )}
            {totalItem === 1 ? null : (
              <TouchableOpacity
                onPress={() => this.props.onPressDelete(data.text, index)}
              >
                <Image
                  source={trashIcon}
                  style={[styles.image, { tintColor: 'rgb(102,102,102)' }]}
                  resizeMode={'contain'}
                />
              </TouchableOpacity>
            )}
          </View>
        </View>
      )
    }

    return (
      <View style={{ flexDirection: 'row', flex: 1, paddingRight: 16 }}>
        <TouchableOpacity
          onPress={() => this.props.onPressEdit(data.text, index)}
          style={{
            flex: 0.7,
            justifyContent: 'center',
          }}
        >
          <Text numberOfLines={2} style={styles.text}>
            {data.text}
          </Text>
        </TouchableOpacity>
        <View
          style={{
            flex: 0.3,
            alignItems: 'center',
            justifyContent: 'flex-end',
            flexDirection: 'row',
          }}
        >
          <TouchableOpacity
            onPress={() => this.props.onPressEdit(data.text, index)}
          >
            <Image
              source={{ uri: 'icon_edit_plain' }}
              style={[styles.image, { tintColor: 'rgb(102,102,102)' }]}
              resizeMode={'contain'}
            />
          </TouchableOpacity>
          <View
            style={{
              width: 1,
              height: 24,
              backgroundColor: 'rgb(224,224,224)',
              marginHorizontal: 16,
            }}
          />
          <Image
            source={dragIcon}
            style={[styles.image, { tintColor: 'rgb(102,102,102)' }]}
            resizeMode={'contain'}
          />
        </View>
      </View>
    )
  }

  render() {
    const { index, data, active, totalItem } = this.props
    return (
      <Animated.View style={[styles.row, this.style]}>
        {this.renderByDevice(index, data, totalItem)}
      </Animated.View>
    )
  }
}

export default Row
