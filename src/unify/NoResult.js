import React from 'react';
import {
  View,
  Image,
  Text,
  TouchableOpacity,
  StyleSheet,
  Dimensions
} from 'react-native';

const { width } = Dimensions.get('window');

import PropTypes from 'prop-types';

const NoResult = ({
  style,
  title,
  subtitle,
  onButtonPress,
  buttonTitle
}) => (
  <View style={[styles.container, style]}>
    <Image source={{ uri: 'icon_no_data_grey' }} style={styles.image} resizeMode={'contain'} />
    <Text style={{ fontSize:17.2, fontWeight: '500', marginBottom: 5.5, marginTop: 20 }}>Whoops!</Text>
    <Text style={{ fontSize:17, fontWeight: '500', marginBottom: 10 }}>{title}</Text>
    <Text style={{ color: '#575757', fontSize:14.5, marginBottom:5 }}>{subtitle}</Text>

    <TouchableOpacity style={styles.button} onPress={onButtonPress}>
      <Text style={styles.buttonTitle}>{buttonTitle}</Text>
    </TouchableOpacity>
  </View>
);

NoResult.propTypes = {
  style: View.propTypes.style,
  title: PropTypes.string.isRequired,
  subtitle: PropTypes.string.isRequired,
  onButtonPress: PropTypes.func,
  buttonTitle: PropTypes.string.isRequired,
};

NoResult.defaultProps = {
  onButtonPress: () => {},
  style: {},
};

NoResult.displayName = "NoResult";

const styles = StyleSheet.create({
  container: {
    flex:1,
    alignItems: 'center',
    backgroundColor:'#e1e1e1'
  },
  image: { width: 80, height: 80, marginTop:50 },
  button: {
    marginTop: 5,
    backgroundColor: '#42b549',
    width: width - ((width/6)*2),
    height:40,
    alignItems: 'center',
    justifyContent: 'center',
    padding: 8,
    borderWidth: 1,
    borderColor: '#42b549',
    borderRadius: 3
  },
  buttonTitle: { color: 'white' },
});

export default NoResult;
