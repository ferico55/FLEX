import React, { Component } from 'react'
import { connect } from 'react-redux'
import {
  Button,
  StyleSheet,
  TouchableNativeFeedback,
  TouchableOpacity,
  Platform,
  Text,
  View,
  Image,
} from 'react-native'
import Icon from 'react-native-vector-icons/Ionicons'
import { addToWishlist, removeFromWishlist } from '../../actions/actions'

class Wishlist extends Component {
  _onTap = (isWishlist, pId) => {
    if (isWishlist) {
      this.props.dispatch(removeFromWishlist(pId))
    } else {
      this.props.dispatch(addToWishlist(pId))
    }
  }
  render() {
    const isWishlist = this.props.isWishlist || false
    const productId = this.props.productId
    const Touchable = Platform.OS === 'android' ? TouchableNativeFeedback : TouchableOpacity
    return (
      <View style={styles.wrapper}>
        <Touchable onPress={() => this._onTap(isWishlist, productId)}>
           <View>
            {
              isWishlist ? (<Icon name='ios-heart' size={25} color="#f33960" />) :
                (<Icon name='ios-heart-outline' size={25} />)
            }
          </View> 
        </Touchable>
      </View>
    )
  }
}

const styles = StyleSheet.create({
  wrapper: {
    position: 'absolute',
    right: 0,
    top: 0,
    paddingTop: 2,
    paddingRight: 0,
    paddingBottom: 1,
    paddingLeft: 2,
    backgroundColor: '#fff',
    borderWidth: 0,
    width: 35,
    height: 35,
    borderRadius: 20,
    elevation: 4,
    justifyContent: 'center',
    alignItems: 'center'
  }
})

export default connect()(Wishlist)
