import React from 'react'
import { View, TouchableOpacity, StyleSheet, Text } from 'react-native'
import Icon from 'react-native-vector-icons/EvilIcons'

const BackToTop = (props) => {
  return (
    <View style={{ alignItems: 'center', }}>
      <TouchableOpacity style={styles.backToTopBtn}
        underlayColor='#fff' onPress={props.onTap}>
        <View style={ styles.backToTopCenter }>
          <Text style={ styles.backToTopText }>Kembali ke atas</Text>
          <Icon name='chevron-up' size={30}/>
        </View>
      </TouchableOpacity>
    </View>
  )
}

const styles = StyleSheet.create({
  backToTopCenter : {
    flex: 1, 
    flexDirection: 'row', 
    padding: 10, 
    alignSelf: 'center', 
    justifyContent: 'center', 
  },
  backToTopText : {
    color: 'rgba(0,0,0,.7)', 
    textAlign: 'center', 
    fontSize: 13
  },
  backToTopBtn: {
    elevation: 4,
    backgroundColor: '#fff',
    borderWidth: 1,
    borderColor: '#fff',
    borderRadius: 25,
    height: 40,
    width: 150,
    alignItems: 'center',
    justifyContent: 'center',
    position: 'absolute',
    bottom: 10,
    shadowColor: "#000000",
    shadowOpacity: 0.31,
    shadowRadius: 2,
    shadowOffset: {
      height: 1,
      width: 0
    }
  }
})

export default BackToTop