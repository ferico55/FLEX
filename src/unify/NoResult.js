import React from 'react'
import {
  View,
  Image,
  Text,
  TouchableOpacity,
  StyleSheet,
  ViewPropTypes,
} from 'react-native'

import PropTypes from 'prop-types'

const styles = StyleSheet.create({
  container: { alignItems: 'center' },
  image: { width: 100, height: 100 },
  button: {
    marginTop: 15,
    backgroundColor: '#42b549',
    minWidth: 100,
    alignItems: 'center',
    padding: 8,
    borderWidth: 1,
    borderColor: '#42b549',
    borderRadius: 3,
  },
  buttonTitle: { color: 'white' },
})

const NoResult = ({
  style,
  title,
  subtitle,
  onButtonPress,
  buttonTitle,
  showButton,
}) => (
  <View style={[styles.container, style]}>
    <Image source={{ uri: 'icon_no_data' }} style={styles.image} />
    <Text style={{ fontWeight: '500', marginBottom: 3 }}>{title}</Text>
    <Text style={{ color: '#ababab' }}>{subtitle}</Text>

    {showButton ? (
      <TouchableOpacity style={styles.button} onPress={onButtonPress}>
        <Text style={styles.buttonTitle}>{buttonTitle}</Text>
      </TouchableOpacity>
    ) : null}
  </View>
)

NoResult.propTypes = {
  style: ViewPropTypes.style,
  title: PropTypes.string.isRequired,
  subtitle: PropTypes.string.isRequired,
  onButtonPress: PropTypes.func,
  buttonTitle: PropTypes.string,
  showButton: PropTypes.bool,
}

NoResult.defaultProps = {
  onButtonPress: () => {},
  style: {},
  showButton: true,
  buttonTitle: '',
}

NoResult.displayName = 'NoResult'

export default NoResult
