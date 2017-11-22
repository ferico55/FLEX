// @flow
import React from 'react'
import {
  View,
  Text,
  Switch,
  Image,
  StyleSheet,
  TouchableOpacity,
  Dimensions,
} from 'react-native'
import CheckboxCircle, { width as circleWidth } from './CheckboxCircle'
import sharedStyles from '../sharedStyles'
import makeStarArray from '../makeStarArray'

const textMaxWidth = Dimensions.get('window').width - circleWidth - 15

const styles = StyleSheet.create({
  colorCircle: {
    width: 40,
    height: 40,
    marginRight: 16,
    borderColor: '#e0e0e0',
    borderWidth: 1,
    borderRadius: 20,
  },
  textLabel: {
    fontSize: 17,
  },
  textLabelCircle: {
    fontSize: 17,
    maxWidth: textMaxWidth,
  },
  pullToLeft: {
    flex: 1,
    flexDirection: 'row',
    alignItems: 'center',
    justifyContent: 'flex-start',
  },
  ratingStar: { width: 20, height: 20 },
})

const starArray = makeStarArray(styles.ratingStar)

const iconUnread = { uri: 'icon_unread' }

export default ({
  input: { value, onChange },
  option: { name, icon, template_name, value: optionValue, hex_color },
  checkboxTemplate,
}: {
  input: { value: boolean, onChange: Function },
  option: {
    name: string,
    metric: string,
    icon: string,
    template_name: string,
    value: string,
    hidden: boolean,
    hex_color?: string,
  },
  checkboxTemplate: string,
}) => {
  switch (template_name) {
    case 'template_color': {
      return (
        <TouchableOpacity onPress={onChange}>
          <View style={sharedStyles.panel}>
            <View style={sharedStyles.sideBySide}>
              <View style={styles.pullToLeft}>
                <Image
                  source={iconUnread}
                  style={[styles.colorCircle, { tintColor: hex_color }]}
                />
                <Text style={styles.textLabel}>{name}</Text>
              </View>
              <CheckboxCircle value={value} />
            </View>
          </View>
        </TouchableOpacity>
      )
    }
    case 'template_rating': {
      const starCount = parseInt(optionValue, 10)

      return (
        <TouchableOpacity onPress={onChange}>
          <View style={sharedStyles.panel}>
            <View style={styles.pullToLeft}>
              <CheckboxCircle value={value} />
              {starArray[starCount]}
            </View>
          </View>
        </TouchableOpacity>
      )
    }

    default:
      if (checkboxTemplate === 'circle') {
        return (
          <TouchableOpacity onPress={onChange}>
            <View style={[sharedStyles.panel, styles.pullToLeft]}>
              <CheckboxCircle value={value} />
              <Text
                style={styles.textLabelCircle}
                numberOfLines={2}
                ellipsizeMode="tail"
              >
                {name}
              </Text>
              {icon.length ? (
                <Image source={{ uri: icon }} style={sharedStyles.badgeImage} />
              ) : null}
            </View>
          </TouchableOpacity>
        )
      }
      return (
        <View style={sharedStyles.panel}>
          <View style={sharedStyles.sideBySide}>
            <View style={sharedStyles.badgeAndTextContainer}>
              <Text style={sharedStyles.textLabel}>{name}</Text>
              {icon.length ? (
                <Image source={{ uri: icon }} style={sharedStyles.badgeImage} />
              ) : null}
            </View>
            <Switch value={value} onValueChange={onChange} />
          </View>
        </View>
      )
  }
}
