import React, { Component } from 'react'
import {
  Image,
  View,
  StyleSheet,
  ActivityIndicator,
  Animated,
} from 'react-native'

const styles = StyleSheet.create({
  centered: {
    ...StyleSheet.absoluteFillObject,
    alignItems: 'center',
    justifyContent: 'center',
  },
})

export default class ImageProgress extends Component {
  constructor(props) {
    super(props)
    this.state = {
      loading: false,
      width: 350,
      height: 150,
    }

    this.opacity = new Animated.Value(1)
  }

  handleStartLoadImage = () => {
    this.setState({
      loading: true,
    })
  }

  handleEndLoadImage = () => {
    Animated.spring(this.opacity, {
      toValue: 0,
    }).start(() => {
      this.setState({ loading: false })
    })
  }

  handleImageProgress = ({ nativeEvent: { loaded, total } }) => {
    console.log('====================================')
    console.log(loaded, total)
    console.log('====================================')
  }

  handleOnLayout = ({ nativeEvent }) => {
    const containerWidth = nativeEvent.layout.width

    if (this.props.ratio) {
      this.setState({
        width: containerWidth,
        height: containerWidth * this.props.ratio,
      })
    } else {
      Image.getSize(this.props.source, (width, height) => {
        this.setState({
          width: containerWidth,
          height: containerWidth * height / width,
        })
      })
    }
  }

  render() {
    return (
      <View
        style={{ width: this.state.width, height: this.state.height }}
        onLayout={this.handleOnLayout}
      >
        <Image
          onLoadStart={this.handleStartLoadImage}
          onLoadEnd={this.handleEndLoadImage}
          onProgress={this.handleImageProgress}
          style={{ width: this.state.width, height: this.state.height }}
          {...this.props}
        />
        <Animated.View
          style={[
            styles.centered,
            { backgroundColor: 'rgb(244,244,244)', opacity: this.opacity },
          ]}
        >
          <ActivityIndicator animating={this.state.loading} size={'large'} />
        </Animated.View>
      </View>
    )
  }
}
