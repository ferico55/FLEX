import React, { Component } from 'react'
import {
  Image,
  Text,
  View
} from 'react-native'

export default class CellHelper extends Component {
  static renderStar = (rate, totalReview) => {

    if (rate == null || rate == 0) {
      return <View/>
    }

    let stars = []
    let totalStar = Math.round(rate / 20)

    for (i = 0; i < totalStar; i++) {
      stars.push(<Image key={`active_${i}`} style={{width:12, height: 12}} source={require('../img/icon-review.png')}/>)
    }

    for (i = 0; i < 5 - totalStar; i++) {
      stars.push(<Image key={`inactive_${i}`} style={{width:12, height: 12}} source={require('../img/icon-review-empty.png')}/>)
    }

    stars.push(<Text key='total-review' style={{fontSize: 11, color:'rgba(0,0,0,0.36)', marginLeft: 4}}>({totalReview})</Text>)

    return stars;
  }

  static renderLabels = (labels) => {
    return labels != null ? labels.map((label) =>
      <View
        key={label.title}
         style={{
          backgroundColor: label.color,
          borderRadius: 2,
          justifyContent: 'center',
          marginRight: 4,
          borderWidth: label.color == '#ffffff' ? 1 : 0,
          borderColor: 'rgba(0,0,0,0.12)'
        }}>
        {label.color == '#ffffff' ? (
          <Text style={{fontSize: 10, color:'rgba(0,0,0,0.54)', margin: 4, textAlign: 'center'}}>{label.title}</Text>
        ) :
        (
          <Text style={{fontSize: 10, color:'white', margin: 4, textAlign: 'center', fontWeight: '600'}}>{label.title}</Text>
        )
        }
      </View>
    ) :
     (
      <View/>
    )
  }
}
