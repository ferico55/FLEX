// @flow
import React from 'react'
import { Text, StyleSheet, View, PanResponder, Dimensions } from 'react-native'
import fp from 'lodash/fp'

const topOffset = Dimensions.get('window').height / 2 - 200
const styles = StyleSheet.create({
  container: {
    position: 'absolute',
    right: 0,
    top: topOffset,
    backgroundColor: 'transparent',
    alignItems: 'center',
    paddingRight: 11,
    paddingLeft: 11,
  },
  letter: {
    fontSize: 12,
    color: 'rgb(66,181,73)',
  },
  circle: {
    marginTop: 4,
    marginBottom: 4,
    width: 4,
    height: 4,
    borderRadius: 2,
    backgroundColor: 'rgb(66,181,73)',
  },
  selectedLetter: {
    position: 'absolute',
    right: 30,
    width: 40,
    height: 40,
    borderRadius: 20,
    backgroundColor: 'rgb(66,181,73)',
    alignItems: 'center',
    justifyContent: 'center',
  },
  selectedLetterText: {
    backgroundColor: 'rgb(66,181,73)',
    color: 'white',
    fontSize: 22,
  },
})
export const alphabet = 'abcdefghijklmnopqrstuvwxyz'.toUpperCase().split('')
const customAlphabet = 'adgjmpsvz'
  .toUpperCase()
  .split('')
  .join('*')
  .split('')
  .map((letter, index) => {
    if (letter === '*') {
      return <View key={index} style={styles.circle} /> // eslint-disable-line
    }
    return (
      <View key={index}><Text style={styles.letter}>{letter}</Text></View> // eslint-disable-line
    )
  })

const SelectedLetter = ({
  letter,
  offset,
}: {
  letter: string,
  offset: number,
}) => (
  <View style={[styles.selectedLetter, { top: offset - 30 }]}>
    <Text style={styles.selectedLetterText}>{letter || '-'}</Text>
  </View>
)

export default class AlphabetSidebar extends React.Component {
  constructor(props) {
    super(props)
    this.handleOnLayout = this.handleOnLayout.bind(this)
    this.convertToPosition = this.convertToPosition.bind(this)
    this.state = { pressed: false, letter: '' }
  }

  componentWillMount() {
    this.panResponder = PanResponder.create({
      // Ask to be the responder:
      onStartShouldSetPanResponder: () => true,
      onStartShouldSetPanResponderCapture: () => true,
      onMoveShouldSetPanResponder: () => true,
      onMoveShouldSetPanResponderCapture: () => true,

      onPanResponderGrant: (evt, { y0 }) => {
        this.setState({ pressed: true })
        this.convertToPosition(y0)
        // The gesture has started. Show visual feedback so the user knows
        // what is happening!
        // gestureState.d{x,y} will be set to zero now
      },
      onPanResponderMove: (evt, { moveY }) => {
        this.convertToPosition(moveY)
        // The most recent move distance is gestureState.move{X,Y}
        // The accumulated gesture distance since becoming responder is
        // gestureState.d{x,y}
      },
      onPanResponderTerminationRequest: () => true,
      // The user has released all touches while this view is the
      // responder. This typically means a gesture has succeeded
      onPanResponderRelease: () => {
        this.setState({ pressed: false })
      },
      // Another component has become the responder, so this gesture
      // should be cancelled
      onPanResponderTerminate: () => {},
      // Returns whether this component should block native components from becoming the JS
      // responder. Returns true by default. Is currently only supported on android.
      onShouldBlockNativeResponder: () => true,
    })
  }
  convertToPosition(rawValue) {
    const { props: { onSelect }, layout: { y, height } } = this
    const offset = rawValue - y
    const value = fp.clamp(0, 1, offset / height)
    const letter = alphabet[Math.round((alphabet.length - 1) * value)]
    this.setState({
      letter,
      offset,
    })
    onSelect(letter)
  }
  props: { onSelect: Function }
  handleOnLayout(event) {
    this.layout = event.nativeEvent.layout
  }
  render() {
    const { pressed, letter, offset } = this.state

    return (
      <View
        {...this.panResponder.panHandlers}
        style={styles.container}
        onLayout={this.handleOnLayout}
      >
        {customAlphabet}
        {pressed ? <SelectedLetter letter={letter} offset={offset} /> : null}
      </View>
    )
  }
}
