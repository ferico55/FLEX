import React, { Component } from 'react'
import { View, TouchableWithoutFeedback, Text, Image, Animated, StyleSheet, Dimensions, Platform } from 'react-native'
import { icons } from '../lib/icons'


const { width, height } = Dimensions.get('window')

class BackToTop extends Component {

  static defaultProps = {
    floatingVisible: true,
    onBottomVisible: false,
    onTap: () => {},
  }

  propTypes: {
    floatingVisible: Boolean,
    onBottomVisible: Boolean,
    onTap: Function,
  }

  state = {
    isVisible: true,
    slideAnim: new Animated.Value(-45),
  }

  componentWillReceiveProps(nextProps) {
    if (nextProps.onBottomVisible) {
      Animated.timing(this.state.slideAnim, {
        toValue: 55,
        duration: 150,
      }).start()
    } else {
      Animated.timing(this.state.slideAnim, {
        toValue: -45,
        duration: 150,
      }).start()
    }
  }
  
  render() {
    const arrowTop = icons.arrow_top
    return (
      <View style={styles.backToTopContainer}>
        { 
          <Animated.View
            style={[styles.floatingBackToTopContainer, {bottom: this.state.slideAnim}]}
          >
            <TouchableWithoutFeedback onPress={this.props.onTap}>
              <View style={styles.floatingBackToTop}>
                <Text style={styles.backToTopText}>Kembali ke atas</Text>
                <Image source={{uri: arrowTop}} style={styles.arrowImage} />
              </View>
            </TouchableWithoutFeedback>
          </Animated.View>
        }
        
        {
          !(this.props.floatingVisible) && (
            <TouchableWithoutFeedback onPress={this.props.onTap}>
              <View style={styles.bottomBackToTop}>
                <Text style={styles.backToTopText}>Kembali Ke Atas</Text>
                <Image source={{uri: arrowTop}} style={styles.arrowImage} />
              </View>
            </TouchableWithoutFeedback>
          )
        }
      </View>
    )
  }
}

const shadow = Platform.OS === 'ios'
  ? {
    shadowColor: 'rgba(0, 0, 0, .31)',
    shadowOffset: {
      width: 0,
      height: 4,
    },
    shadowRadius: 20,
  } : {
    elevation: 3,
  }

const styles = StyleSheet.create({
  backToTopContainer: {
    width,
    height: 45,
    alignItems: 'center',
    justifyContent: 'center'
  },
  floatingBackToTopContainer: {
    position: 'absolute',
    backgroundColor: '#FFF',
    borderRadius: 25,
    ...shadow
  },
  floatingBackToTop: {
    height: 35,
    width: 145,
    flexDirection: 'row',
    alignItems: 'center',
    justifyContent: 'center',
  },
  bottomBackToTop: {
    flex: 1,
    width,
    height: 45,
    flexDirection: 'row',
    alignItems: 'center',
    justifyContent: 'center',
    backgroundColor: '#FFF',
    borderTopWidth: 0.5,
    borderColor: '#E0E0E0',
  },
  backToTopText: {
    lineHeight: 20,
    marginRight: 5,
    color: 'rgba(0, 0, 0, .7)'
  },
  arrowImage: {
    width: 15,
    height: 20,
    resizeMode: 'contain',
  }
})

export default BackToTop