import Navigator from 'native-navigation'
import { TKPReactAnalytics } from 'NativeModules'
import { bindActionCreators } from 'redux'
import { connect } from 'react-redux'
import React, { Component } from 'react'
import {
  StyleSheet,
  Text,
  TextInput,
  View,
  TouchableWithoutFeedback,
  Keyboard,
  ActivityIndicator,
} from 'react-native'

import color from '../Helper/Color'
import BigGreenButton2 from '../Components/BigGreenButton2'
import * as Actions from '../Redux/Actions/AddPromoActions'

function mapStateToProps(state) {
  return {
    ...state.addPromoReducer,
  }
}

function mapDispatchToProps(dispatch) {
  return bindActionCreators(Actions, dispatch)
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
    paddingTop: 17,
    paddingHorizontal: 15,
    backgroundColor: 'white',
  },
  separator: {
    height: 1,
    flex: 1,
    backgroundColor: color.lineGrey,
  },
  cellOuterContainer: {
    marginBottom: 10,
  },
  cellContainer: {
    height: 34,
    marginLeft: 2,
    flexDirection: 'row',
    alignItems: 'center',
  },
  cellDetailContainer: {
    height: 69,
  },
  cellTopLabel: {
    fontSize: 12,
    color: color.greyText,
    marginBottom: 5,
  },
  cellUnderline: {
    height: 1,
    marginTop: 6.5,
    marginBottom: 9.5,
    backgroundColor: color.mainGreen,
  },
  cellGroupNameLabel: {
    color: color.greyText,
    fontSize: 16,
  },
  cellBottomLabel: {
    fontSize: 11,
    color: color.greyText,
  },
  cellBottomLabelRed: {
    fontSize: 11,
    color: 'red',
  },
})

class EditPromoGroupNamePage extends Component {
  constructor(props) {
    super(props)
    this.state = {
      tempName: this.props.prevName,
      isInputEmpty: false,
    }
  }
  componentDidUpdate = () => {
    if (this.props.isDonePost) {
      Navigator.pop()
      this.props.resetAddPromoGroupRequestState()
    }
  }
  componentWillUnmount = () => {}
  saveButtonTapped = () => {
    if (this.state.tempName === '') {
      this.setState({ isInputEmpty: true })
    } else {
      TKPReactAnalytics.trackEvent({
        name: 'topadsios',
        category: 'ta - product',
        action: 'Click',
        label: 'Edit Group Promo - Ganti Nama Grup',
      })
      this.props.patchGroupPromo({
        status: this.props.status,
        groupId: `${this.props.existingGroup.group_id}`,
        shopId: this.props.authInfo.shop_id,
        newGroupName: this.state.tempName,
        maxPrice: this.props.maxPrice,
        budgetType: this.props.budgetType,
        budgetPerDay: this.props.budgetPerDay,
        scheduleType: this.props.scheduleType,
        startDate: this.props.startDate,
        endDate: this.props.endDate,
      })
      this.setState({ isInputEmpty: false })
    }
  }
  renderBigGreenButton = () => {
    if (this.props.isLoadingPost) {
      return (
        <View
          style={{
            height: 52,
            justifyContent: 'center',
            alignItems: 'center',
            position: 'absolute',
            bottom: 0,
            left: 0,
            right: 0,
          }}
        >
          <ActivityIndicator />
        </View>
      )
    }
    return (
      <BigGreenButton2
        title={this.props.isFailedPost ? 'Coba Lagi' : 'Simpan'}
        buttonAction={this.saveButtonTapped}
        disabled={false}
      />
    )
  }
  render = () => (
    <Navigator.Config title="Grup">
      <View style={{ flex: 1 }}>
        <TouchableWithoutFeedback onPress={Keyboard.dismiss}>
          <View style={styles.container}>
            <View style={styles.cellOuterContainer}>
              <View style={styles.cellDetailContainer}>
                <Text style={styles.cellTopLabel}>Nama Grup</Text>
                <TextInput
                  value={this.state.tempName}
                  multiline={false}
                  numberOfLines={1}
                  editable
                  selectionColor={color.mainGreen}
                  onChangeText={text => this.setState({ tempName: text })}
                  onSubmitEditing={Keyboard.dismiss}
                />
                <View style={styles.cellUnderline} />
                {this.state.isInputEmpty && (
                  <Text style={styles.cellBottomLabelRed}>
                    Nama grup harus diisi.
                  </Text>
                )}
              </View>
            </View>
          </View>
        </TouchableWithoutFeedback>
        {this.renderBigGreenButton()}
      </View>
    </Navigator.Config>
  )
}

export default connect(mapStateToProps, mapDispatchToProps)(
  EditPromoGroupNamePage,
)
