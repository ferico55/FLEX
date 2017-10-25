import Navigator from 'native-navigation'
import { Svg, G, Path } from 'react-native-svg'
import { ReactTopAdsManager, TKPReactAnalytics } from 'NativeModules'
import { bindActionCreators } from 'redux'
import { connect } from 'react-redux'
import React, { Component } from 'react'
import {
  StyleSheet,
  Text,
  TextInput,
  View,
  TouchableOpacity,
  TouchableWithoutFeedback,
  Keyboard,
  Image,
  ActivityIndicator,
} from 'react-native'

import { requestGroupList } from '../Helper/Requests'
import color from '../Helper/Color'
import BigGreenButton2 from '../Components/BigGreenButton2'
import * as Actions from '../Redux/Actions/AddPromoActions'

import checkImg from '../Icon/check.png'

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
    paddingTop: 21,
    paddingLeft: 15,
    paddingRight: 31,
    backgroundColor: 'white',
  },
  separator: {
    height: 1,
    flex: 1,
    backgroundColor: color.lineGrey,
  },
  tipsView: {
    flexDirection: 'row',
    alignItems: 'center',
    marginBottom: 30,
    width: 50,
    height: 30,
  },
  tipsInfoIcon: {
    marginLeft: 5,
    height: 12,
    width: 12,
  },
  pilihPromoLabel: {
    fontSize: 24,
    marginBottom: 20,
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
  cellChecklistContainer: {
    width: 16,
    marginRight: 19,
    alignItems: 'center',
    justifyContent: 'center',
  },
  cellChecklistView: {
    height: 16,
    width: 16,
    borderWidth: 1,
    borderRadius: 8,
    borderColor: color.darkerGrey,
    overflow: 'hidden',
  },
  cellChecklistImageView: {
    height: 16,
    width: 16,
  },
  cellDetailContainer: {
    marginTop: 17,
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

class AddPromoPage extends Component {
  constructor(props) {
    super(props)
    this.state = {
      isInitialLoad: true,
      isEditPosted: false,
      prevGroupType: 0,
      prevExistingGroup: {},
      isMakeNewFromEdit: false,
      currentGroups: [],
    }
  }
  componentDidMount = () => {
    this.setState({
      prevGroupType: this.props.groupType,
      prevExistingGroup: this.props.existingGroup,
    })

    requestGroupList(this.props.authInfo.shop_id, '')
      .then(result => {
        if (result.data) {
          this.setState({
            currentGroups: result.data,
          })
        }
      })
      .catch(_ => {})
  }
  componentDidUpdate = () => {
    if (
      this.props.isEdit &&
      this.props.isDonePost &&
      !this.state.isMakeNewFromEdit
    ) {
      this.setState({
        isEditPosted: true,
      })
      Navigator.pop()
      if (this.props.groupType < 2) {
        Navigator.pop()
      }
      this.props.resetAddPromoGroupRequestState()
    }
  }
  componentWillUnmount = () => {
    if (this.state.isEditPosted || !this.props.isEdit) {
      this.props.resetProgressAddPromo()
    } else {
      this.props.changeGroupTypeAddPromo(this.state.prevGroupType)
      this.props.setExistingGroupAddPromo(this.state.prevExistingGroup)
    }
  }
  onAppear = () => {
    if (this.props.isDonePost && this.state.isMakeNewFromEdit) {
      Navigator.pop()
      this.props.resetAddPromoGroupRequestState()
    }
  }
  newGroupNameValidationErrorString = () => {
    if (this.props.groupType === 0 && this.props.newGroupName === '') {
      return 'Nama grup harus diisi.'
    } else if (
      this.props.groupType === 0 &&
      this.props.newGroupName.length > 70
    ) {
      return 'Maksimum 70 karakter.'
    }
    if (
      this.state.currentGroups.some(
        group => group.group_name === this.props.newGroupName,
      )
    ) {
      return 'Nama grup Anda telah digunakan.'
    }

    return ''
  }
  selectedGroupValidationErrorString = () => {
    if (
      this.props.groupType === 1 &&
      (this.props.existingGroup.group_id === '' ||
        this.props.existingGroup.group_id == 0)
    ) {
      return 'Grup harus dipilih.'
    }

    return ''
  }
  cellSelected = index => {
    this.setState({
      isInputEmpty: false,
      isMakeNewFromEdit: false,
    })
    if (!this.props.isEdit) {
      this.props.setSelectedProductsAddPromo([])
      this.props.saveSelectedProductsAddPromo()
      this.props.setMaxPriceAddPromo(0)
      this.props.setBudgetTypeAddPromo(0)
      this.props.setBudgetPerDayAddPromo(0)
      this.props.changeScheduleTypeAddPromo(0)
    }
    this.props.resetAddPromoGroupRequestState()
    this.props.changeGroupTypeAddPromo(index)
  }
  handleGroupNameTapped = () => {
    Navigator.push('FilterDetailPage', {
      shopId: this.props.authInfo.shop_id,
      isGroupAddPromo: true,
      reduxKey: '',
    })
  }
  handleDeleteSelectedGroup = () => {
    this.props.setExistingGroupAddPromo({
      group_id: '',
      group_name: '',
      total_item: 0,
    })
  }
  nextButtonTapped = () => {
    const isNoInputError =
      this.newGroupNameValidationErrorString() === '' &&
      this.selectedGroupValidationErrorString() === ''

    if (this.props.isEdit && isNoInputError) {
      const groupId =
        this.props.groupType == 2 ? '0' : this.props.existingGroup.group_id

      if (this.props.groupType == 2) {
        this.props.setSelectedProductsAddPromo([])
        this.props.saveSelectedProductsAddPromo()
        this.props.setMaxPriceAddPromo(0)
        this.props.setBudgetTypeAddPromo(0)
        this.props.setBudgetPerDayAddPromo(0)
        this.props.changeScheduleTypeAddPromo(0)
        this.setState({
          isMakeNewFromEdit: true,
        })
        Navigator.push('AddPromoPageStep2', {
          authInfo: this.props.authInfo,
          isEdit: true,
          isMakeNewFromEdit: true,
        })
      } else if (this.props.groupType == 0) {
        TKPReactAnalytics.trackEvent({
          name: 'topadsios',
          category: 'ta - product',
          action: 'Click',
          label: `Edit Product Promo - Atur Grup Grup Baru`,
        })
        this.props.postAddPromoGroup({
          newGroupName: this.props.newGroupName,
          shopId: this.props.authInfo.shop_id,
          selectedProducts: [
            {
              product_id: this.props.productId,
              ad_id: this.props.adId,
            },
          ],
          maxPrice: this.props.maxPrice,
          scheduleType: this.props.scheduleType,
          startDate: this.props.startDate,
          endDate: this.props.endDate,
          budgetType: this.props.budgetType,
          budgetPerDay: this.props.budgetPerDay,
        })
      } else {
        TKPReactAnalytics.trackEvent({
          name: 'topadsios',
          category: 'ta - product',
          action: 'Click',
          label: `Edit Product Promo - Atur Grup Grup yang Ada`,
        })
        this.props.moveProductAd(
          this.props.authInfo.shop_id,
          groupId,
          this.props.adId,
        )
      }
    } else if (isNoInputError) {
      const trackerPromoOptions = ['Grup Baru', 'Grup yang Ada', 'Tanpa Grup']
      TKPReactAnalytics.trackEvent({
        name: 'topadsios',
        category: 'ta - product',
        action: 'Click',
        label: `Add Promo - ${trackerPromoOptions[this.props.groupType]}`,
      })
      Navigator.push('AddPromoPageStep1', { authInfo: this.props.authInfo })
    } else {
      this.setState({
        isInitialLoad: false,
      })
    }
  }
  showToolTip = () => {
    ReactTopAdsManager.showAddPromoTooltip()
  }
  renderBigGreenButton = () => {
    let stepTitle = this.props.isEdit ? 'Simpan' : 'Selanjutnya'
    stepTitle = this.props.groupType == 2 ? 'Selanjutnya' : stepTitle
    const title = this.props.isFailedPost ? 'Coba Lagi' : stepTitle

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
        title={title}
        buttonAction={this.nextButtonTapped}
        disabled={false}
      />
    )
  }
  renderCell = (title, index) => (
    <TouchableOpacity onPress={() => this.cellSelected(index)}>
      <View style={styles.cellContainer}>
        <View style={styles.cellChecklistContainer}>
          <View
            style={{
              height: 34,
              justifyContent: 'center',
              marginRight: 5,
            }}
          >
            {this.props.groupType === index ? (
              <Image style={styles.cellChecklistImageView} source={checkImg} />
            ) : (
              <View style={styles.cellChecklistView} />
            )}
          </View>
        </View>
        <Text style={{ fontSize: 16 }}>{title}</Text>
      </View>
    </TouchableOpacity>
  )
  render = () => {
    const cancelImage = {
      uri: 'icon_close',
      scale: 2,
    }

    const isNewGroupNameError = this.newGroupNameValidationErrorString() !== ''
    const isNoSelectedGroup = this.selectedGroupValidationErrorString() !== ''

    return (
      <Navigator.Config
        title={!this.props.isEdit ? 'Tambah Promo' : 'Atur Grup'}
        leftImage={!this.props.isEdit && cancelImage}
        onLeftPress={!this.props.isEdit && Navigator.dismiss}
        onAppear={this.onAppear}
      >
        <View style={{ flex: 1 }}>
          <TouchableWithoutFeedback onPress={Keyboard.dismiss}>
            <View style={styles.container}>
              {!this.props.isEdit && (
                <View>
                  <TouchableOpacity
                    style={styles.tipsView}
                    onPress={this.showToolTip}
                  >
                    <Image
                      style={{ height: 30, width: 30, marginRight: 10 }}
                      source={{ uri: 'lamp_yellow' }}
                    />
                    <Text>Tips</Text>
                    <Image
                      source={{ uri: 'icon_information' }}
                      style={styles.tipsInfoIcon}
                    />
                  </TouchableOpacity>
                  <Text style={styles.pilihPromoLabel}>{'Pilih Promo'}</Text>
                </View>
              )}
              <View style={styles.cellOuterContainer}>
                {this.renderCell('Grup Baru', 0)}
                {this.props.groupType === 0 && (
                  <View style={styles.cellDetailContainer}>
                    <Text style={styles.cellTopLabel}>Nama Grup</Text>
                    <TextInput
                      value={this.props.newGroupName}
                      multiline={false}
                      numberOfLines={1}
                      editable
                      selectionColor={color.mainGreen}
                      onChangeText={text => {
                        this.props.setNewGroupNameAddPromo(text)
                      }}
                      onSubmitEditing={Keyboard.dismiss}
                    />
                    <View style={styles.cellUnderline} />
                    <Text
                      style={
                        isNewGroupNameError && !this.state.isInitialLoad ? (
                          styles.cellBottomLabelRed
                        ) : (
                          styles.cellBottomLabel
                        )
                      }
                    >
                      {isNewGroupNameError && !this.state.isInitialLoad ? (
                        this.newGroupNameValidationErrorString()
                      ) : (
                        'Produk akan dimasukkan ke grup promo baru'
                      )}
                    </Text>
                  </View>
                )}
              </View>
              <View style={styles.cellOuterContainer}>
                {this.renderCell('Grup yang Ada', 1)}
                {this.props.groupType === 1 && (
                  <View style={styles.cellDetailContainer}>
                    <Text style={styles.cellTopLabel}>Pilih Grup</Text>
                    <View style={{ height: 30, flexDirection: 'row' }}>
                      <TouchableOpacity
                        style={{
                          flex: 1,
                          justifyContent: 'center',
                        }}
                        onPress={this.handleGroupNameTapped}
                      >
                        <Text style={styles.cellGroupNameLabel}>
                          {this.props.existingGroup.group_id === '' ||
                          this.props.existingGroup.group_id == 0 ? (
                            'Grup belum dipilih.'
                          ) : (
                            this.props.existingGroup.group_name
                          )}
                        </Text>
                      </TouchableOpacity>
                      {this.props.existingGroup.group_id != 0 && (
                        <TouchableOpacity
                          style={{
                            width: 30,
                            height: 30,
                            justifyContent: 'center',
                            alignItems: 'center',
                          }}
                          onPress={this.handleDeleteSelectedGroup}
                        >
                          <Image
                            style={{
                              width: 12,
                              height: 12,
                            }}
                            source={{ uri: 'green_x' }}
                          />
                        </TouchableOpacity>
                      )}
                    </View>
                    <View style={{ overflow: 'hidden', marginBottom: 9.5 }}>
                      <Svg height="1" width="1000">
                        <G fill="none" stroke={color.mainGreen} strokeWidth="4">
                          <Path
                            strokeDasharray="2,4"
                            d="M0 0 L0 1 L1000 1 L1000 0"
                          />
                        </G>
                      </Svg>
                    </View>
                    <Text
                      style={
                        isNoSelectedGroup && !this.state.isInitialLoad ? (
                          styles.cellBottomLabelRed
                        ) : (
                          styles.cellBottomLabel
                        )
                      }
                    >
                      {isNoSelectedGroup && !this.state.isInitialLoad ? (
                        'Grup harus dipilih.'
                      ) : (
                        'Produk akan dimasukkan ke grup promo yang sudah ada'
                      )}
                    </Text>
                  </View>
                )}
              </View>
              <View style={styles.cellOuterContainer}>
                {this.renderCell('Tanpa Grup', 2)}
                {this.props.groupType === 2 && (
                  <Text style={styles.cellBottomLabel}>
                    Produk tidak masuk grup promo, pengaturannya akan dilakukan
                    per promo.
                  </Text>
                )}
              </View>
            </View>
          </TouchableWithoutFeedback>
          {this.renderBigGreenButton()}
        </View>
      </Navigator.Config>
    )
  }
}

export default connect(mapStateToProps, mapDispatchToProps)(AddPromoPage)
