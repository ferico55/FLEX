import React, { PureComponent } from 'react'
import { StyleSheet, Image, View, TouchableOpacity, Text } from 'react-native'

const styles = StyleSheet.create({
  mascot: {
    width: 80,
    height: 80,
    marginTop: 50,
  },
  buttonHolder: {
    borderRadius: 3,
    backgroundColor: '#42b549',
    marginTop: 12,
    paddingVertical: 12,
    paddingHorizontal: 64,
  },
})

class NoResultView extends PureComponent {
  render() {
    return (
      <View style={{ alignItems: 'center' }}>
        <Image
          source={{
            uri: this.props.imageUri
              ? this.props.imageUri
              : 'icon_no_data_grey',
          }}
          style={[
            styles.mascot,
            this.props.isLarge ? { width: 200, height: 129 } : null,
          ]}
        />
        {!this.props.isPreHidden && (
          <Text style={{ fontSize: 17, marginTop: 12 }}>Whoops!</Text>
        )}
        <Text style={{ fontSize: 17, marginTop: 6 }}>
          {this.props.titleText ? (
            this.props.titleText
          ) : (
            'Terjadi kendala pada koneksi internet'
          )}
        </Text>
        {this.props.subtitleText !== '' && (
          <Text
            style={{
              fontSize: 14,
              textAlign: 'center',
              marginTop: 12,
              color: 'rgba(0,0,0,0.54)',
            }}
          >
            {this.props.subtitleText || this.props.subtitleText === '' ? (
              this.props.subtitleText
            ) : (
              'Harap coba lagi'
            )}
          </Text>
        )}
        {!this.props.isButtonHidden && (
          <TouchableOpacity onPress={this.props.onRefresh}>
            <View style={styles.buttonHolder}>
              <Text style={{ color: 'white', fontSize: 16 }}>
                {this.props.buttonText ? this.props.buttonText : 'Coba Lagi'}
              </Text>
            </View>
          </TouchableOpacity>
        )}
      </View>
    )
  }
}

module.exports = NoResultView
