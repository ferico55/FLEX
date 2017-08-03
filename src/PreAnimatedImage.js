import React, { Component } from 'react';
import {
  StyleSheet,
  Image,
  ActivityIndicator,
  View
} from 'react-native';

class PreAnimatedImage extends React.Component {
  setNativeProps = (nativeProps) => {
    this._root.setNativeProps(nativeProps);
  }
  isLoaded = false;

  render() {
    return (
      <View>
        <Image source={{ uri: this.props.source }} style={styles.photo} />
        {!this.isLoaded &&
          <ActivityIndicator animating={true} style={[styles.loader]} size="small" />
        }
      </View>
    );
  }
}

const styles = StyleSheet.create({
  photo: {
    resizeMode: 'cover',
    aspectRatio: 1.91,
    justifyContent: 'center',
    zIndex: 10
  },
  loader: {
    alignItems: 'center',
    justifyContent: 'center',
    padding: 8,
    height: 44,
    marginTop: -22,
    marginLeft: -22,
    position: 'absolute',
    left: '50%',
    top: '50%'
  },
})

module.exports = PreAnimatedImage;