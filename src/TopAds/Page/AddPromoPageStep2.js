import Navigator from 'native-navigation'
import { TextInputMask, MaskService } from 'react-native-masked-text'
import { KeyboardAwareScrollView } from 'react-native-keyboard-aware-scroll-view'
import { TKPReactAnalytics } from 'NativeModules'
import { bindActionCreators } from 'redux'
import { connect } from 'react-redux'
import React, { Component } from 'react'
import {
  StyleSheet,
  Text,
  View,
  TouchableOpacity,
  TouchableWithoutFeedback,
  Keyboard,
  Image,
  ActivityIndicator,
} from 'react-native'

import color from '../Helper/Color'
import BigGreenButton2 from '../Components/BigGreenButton2'
import * as AddPromoActions from '../Redux/Actions/AddPromoActions'
import * as DashboardActions from '../Redux/Actions/DashboardActions'

import checkImg from '../Icon/check.png'

function mapStateToProps(state) {
  return {
    ...state.addPromoReducer,
    creditState: state.topAdsDashboardCreditReducer,
  }
}

function mapDispatchToProps(dispatch) {
  return bindActionCreators(
    { ...AddPromoActions, ...DashboardActions },
    dispatch,
  )
}

const styles = StyleSheet.create({
  progressBarContainer: {
    height: 2,
    flexDirection: 'row',
  },
  progressBarValueSide: {
    backgroundColor: color.mainGreen,
  },
  progressBarEmptySide: {
    backgroundColor: color.backgroundGrey,
  },
  container: {
    flex: 1,
    paddingHorizontal: 15,
    backgroundColor: 'white',
  },
  separator: {
    height: 1,
    flex: 1,
    backgroundColor: color.lineGrey,
  },
  biayaLabel: {
    marginTop: 25,
    fontSize: 24,
    fontWeight: '300',
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
  cellDetailTopLabel: {
    fontSize: 12,
    color: color.greyText,
    marginBottom: 5,
  },
  cellDetailUnderline: {
    height: 1,
    marginTop: 6.5,
    marginBottom: 9.5,
    backgroundColor: color.mainGreen,
  },
  cellDetailUnderlineGrey: {
    height: 1,
    marginTop: 6.5,
    marginBottom: 9.5,
    backgroundColor: color.lineGrey,
  },
  cellDetailBottomLabelContainer: {
    flexDirection: 'row',
  },
  cellDetailBottomLabel: {
    fontSize: 11,
    color: color.greyText,
  },
  cellDetailBottomRedLabel: {
    fontSize: 11,
    color: 'red',
  },
  cellDetailBottomGreenLabel: {
    fontSize: 11,
    fontWeight: 'bold',
    color: color.mainGreen,
  },
  anggaranLabel: {
    marginTop: 24,
    marginBottom: 20,
    fontSize: 24,
    fontWeight: '300',
  },
})

class AddPromoPageStep2 extends Component {
  constructor(props) {
    super(props)
    this.state = {
      isInitialLoad: true,
      isPriceBidInputInvalid: false,
      isBudgetInputInvalid: false,
    }
  }
  componentDidMount = () => {
    if (this.props.creditState.credit <= 0) {
      this.props.getDashboardCredit(this.props.authInfo.shop_id)
    }

    if (this.props.isEdit && this.props.groupType < 2) {
      this.props.getSuggestionPrice(this.props.authInfo.shop_id, true, [
        parseInt(this.props.existingGroup.group_id),
      ])
    } else if (!this.props.isEdit && !this.props.isCreateShop) {
      const ids = this.props.selectedProducts.map(
        product => product.department_id,
      )
      this.props.getSuggestionPrice(this.props.authInfo.shop_id, false, ids)
    }
  }
  componentDidUpdate = () => {
    if (this.props.isDonePost && !this.props.isMakeNewFromEdit) {
      if (this.props.isEdit) {
        Navigator.pop()
        this.props.resetAddPromoGroupRequestState()
        if (this.props.groupType === 3) {
          this.props.changeIsNeedRefreshDashboard(true)
        }
      } else {
        Navigator.dismiss()
        this.props.resetProgressAddPromo()
        this.props.changeIsNeedRefreshDashboard(true)
      }
    }
  }
  componentWillUnmount = () => {
    if (!this.props.isMakeNewFromEdit) {
      if (this.props.isDirectEdit) {
        this.props.resetProgressAddPromo()
      } else {
        this.props.resetAddPromoGroupRequestState()
      }
    }
  }
  onAppear = () => {
    if (this.props.isDonePost && this.props.isMakeNewFromEdit) {
      Navigator.pop()
    } else if (this.props.maxPrice <= 0) {
      this.refs.maxPriceInput.getElement().focus()
    }
  }
  maxPriceValidationErrorMessage = () => {
    if (this.props.maxPrice < 1) {
      return 'Biaya harus diisi.'
    } else if (this.props.maxPrice > 2000) {
      return 'Biaya maksimum Rp 2.000'
    } else if (this.props.maxPrice % 50 !== 0) {
      return 'Biaya harus kelipatan Rp 50'
    }
    return ''
  }
  budgetValidationErrorMessage = () => {
    if (this.props.budgetType === 0) {
      return ''
    } else if (this.props.budgetPerDay <= 0) {
      return 'Anggaran harus diisi.'
    } else if (this.props.budgetPerDay < this.props.maxPrice * 10) {
      return 'Biaya per hari minimal 10x biaya maks per klik.'
    } else if (this.props.budgetPerDay > this.props.creditState.credit) {
      return 'Kredit TopAds harus lebih besar dari Anggaran. Silahkan tambah kredit TopAds terlebih dahulu.'
    }
    return ''
  }
  cellSelected = index => {
    this.props.setBudgetTypeAddPromo(index)
  }
  nextButtonTapped = () => {
    if (
      this.maxPriceValidationErrorMessage() !== '' ||
      this.budgetValidationErrorMessage() !== ''
    ) {
      this.setState({
        isInitialLoad: false,
        isPriceBidInputInvalid: this.maxPriceValidationErrorMessage() !== '',
        isBudgetInputInvalid: this.budgetValidationErrorMessage() !== '',
      })
      return
    }

    if (this.props.isEdit) {
      if (this.props.isMakeNewFromEdit) {
        // edit atur grup tapi tanpa grup, jadi buat baru
        Navigator.push('AddPromoPageStep3', {
          authInfo: this.props.authInfo,
          isEdit: true,
          isCreateShop: false,
          isMakeNewFromEdit: true,
        })
      } else if (this.props.groupType == 2 || this.props.groupType == 3) {
        // edit promo tanpa grup atau shop
        if (this.props.groupType == 2) {
          TKPReactAnalytics.trackEvent({
            name: 'topadsios',
            category: 'ta - product',
            action: 'Click',
            label: `Edit Product Promo - Biaya ${this.props.budgetType === 0
              ? 'Anggaran Tidak Dibatasi'
              : 'Perhari'}`,
          })
        }
        this.props.patchProductPromo({
          status: this.props.status,
          adId: this.props.adId,
          groupId: `${this.props.existingGroup.group_id}`,
          shopId: this.props.authInfo.shop_id,
          maxPrice: this.props.maxPrice,
          budgetType: this.props.budgetType,
          budgetPerDay: this.props.budgetPerDay,
          scheduleType: this.props.scheduleType,
          startDate: this.props.startDate,
          endDate: this.props.endDate,
        })
      } else {
        // edit promo grup baru atau grup yang sudah ada
        TKPReactAnalytics.trackEvent({
          name: 'topadsios',
          category: 'ta - product',
          action: 'Click',
          label: `Edit Group Promo - Biaya ${this.props.budgetType === 0
            ? 'Anggaran Tidak Dibatasi'
            : 'Perhari'}`,
        })
        this.props.patchGroupPromo({
          status: this.props.status,
          groupId: `${this.props.existingGroup.group_id}`,
          shopId: this.props.authInfo.shop_id,
          newGroupName: this.props.newGroupName,
          maxPrice: this.props.maxPrice,
          budgetType: this.props.budgetType,
          budgetPerDay: this.props.budgetPerDay,
          scheduleType: this.props.scheduleType,
          startDate: this.props.startDate,
          endDate: this.props.endDate,
        })
      }
    } else if (this.props.stepCount > 2 || this.props.isCreateShop) {
      if (this.props.isCreateShop) {
        TKPReactAnalytics.trackEvent({
          name: 'topadsios',
          category: 'ta - shop',
          action: 'Click',
          label: `Add Shop Promo Budget  Step 1 - ${this.props.budgetType === 0
            ? 'Anggaran Tidak Dibatasi'
            : 'Perhari'}`,
        })
      } else {
        TKPReactAnalytics.trackEvent({
          name: 'topadsios',
          category: 'ta - product',
          action: 'Click',
          label: `New Promo Step 2 - ${this.props.budgetType === 0
            ? 'Anggaran Tidak Dibatasi'
            : 'Perhari'}`,
        })
      }

      Navigator.push('AddPromoPageStep3', {
        authInfo: this.props.authInfo,
        isCreateShop: this.props.isCreateShop,
      })
    } else {
      TKPReactAnalytics.trackEvent({
        name: 'topadsios',
        category: 'ta - product',
        action: 'Click',
        label: `Without Group Step 2 - ${this.props.budgetType === 0
          ? 'Anggaran Tidak Dibatasi'
          : 'Perhari'}`,
      })
      this.props.postAddPromo({
        shopId: this.props.authInfo.shop_id,
        groupId:
          this.props.groupType === 1
            ? `${this.props.existingGroup.group_id}`
            : '0',
        selectedProducts: this.props.selectedProducts,
        maxPrice: this.props.maxPrice,
        scheduleType: this.props.scheduleType,
        startDate: this.props.startDate,
        endDate: this.props.endDate,
        budgetType: this.props.budgetType,
        budgetPerDay: this.props.budgetPerDay,
      })
    }
  }
  handleApplyRecPrice = () => {
    this.setState({
      isPriceBidInputInvalid: false,
    })
    this.props.setMaxPriceAddPromo(this.props.suggestionPrice)
  }
  handleMaxPriceOnChangeText = () => {
    this.props.setMaxPriceAddPromo(this.refs.maxPriceInput.getRawValue())
  }
  handleBudgetOnChangeText = () => {
    this.props.setBudgetPerDayAddPromo(this.refs.perDayPriceInput.getRawValue())
  }
  renderProgressBar = () => (
    <View style={styles.progressBarContainer}>
      <View
        style={[
          styles.progressBarValueSide,
          { flex: this.props.stepCount - (this.props.stepCount - 2) },
        ]}
      />
      <View
        style={[
          styles.progressBarEmptySide,
          { flex: this.props.stepCount - 2 },
        ]}
      />
    </View>
  )
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
            {this.props.budgetType === index ? (
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
  renderBigGreenButton = () => {
    let stepTitle = this.props.stepCount > 2 ? 'Selanjutnya' : 'Simpan'
    stepTitle = this.props.isEdit ? 'Simpan' : stepTitle
    stepTitle =
      this.props.isCreateShop || this.props.isMakeNewFromEdit
        ? 'Selanjutnya'
        : stepTitle
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
  render = () => {
    let navTitle = this.props.isEdit
      ? 'Biaya'
      : `2 dari ${this.props.stepCount} step`
    navTitle = this.props.isCreateShop ? `1 dari 2 step` : navTitle

    const suggestionPriceBid = MaskService.toMask(
      'money',
      this.props.suggestionPrice,
      {
        precision: 0,
        unit: 'Rp ',
      },
    )

    const cancelImage = {
      uri: 'icon_close',
      scale: 2,
    }

    const B = props => (
      <Text style={{ fontWeight: 'bold' }}>{props.children}</Text>
    )
    let suggestionPriceComponent = <Text />
    let isShowSuggestionBid = false
    if (this.props.isEdit) {
      isShowSuggestionBid = this.props.suggestionPrice > this.props.maxPrice
      isShowSuggestionBid = isShowSuggestionBid && this.props.groupType === 1
      suggestionPriceComponent = isShowSuggestionBid ? (
        <Text style={styles.cellDetailBottomLabel}>
          Rekomendasi biaya <B>{suggestionPriceBid}</B>
        </Text>
      ) : (
        <Text style={styles.cellDetailBottomLabel}>
          Sesuaikan biaya dengan anggaran promo Anda.
        </Text>
      )

      if (
        this.props.groupType === 2 ||
        this.props.groupType === 3 ||
        this.props.isCreateShop
      ) {
        suggestionPriceComponent = (
          <Text style={styles.cellDetailBottomLabel}>
            Rekomendasi biaya: Rp 50 sampai Rp 200 per klik.
          </Text>
        )
        isShowSuggestionBid = false
      }
    } else {
      isShowSuggestionBid = this.props.suggestionPrice > 0
      suggestionPriceComponent = isShowSuggestionBid ? (
        <Text style={styles.cellDetailBottomLabel}>
          Rekomendasi biaya <B>{suggestionPriceBid}</B>
        </Text>
      ) : (
        <Text style={styles.cellDetailBottomLabel}>
          Sesuaikan biaya dengan anggaran promo Anda.
        </Text>
      )
    }

    const priceBidErrorString = this.maxPriceValidationErrorMessage()
    const budgetErrorString = this.budgetValidationErrorMessage()

    return (
      <Navigator.Config
        title={navTitle}
        leftImage={this.props.isCreateShop && cancelImage}
        onLeftPress={this.props.isCreateShop && Navigator.dismiss}
        onAppear={this.onAppear}
      >
        <View style={{ flex: 1 }}>
          <KeyboardAwareScrollView style={{ flex: 1 }} scrollEnabled={false}>
            {!this.props.isEdit && this.renderProgressBar()}
            <TouchableWithoutFeedback onPress={Keyboard.dismiss}>
              <View style={styles.container}>
                {!this.props.isEdit && (
                  <Text style={styles.biayaLabel}>Biaya</Text>
                )}
                <View style={styles.cellDetailContainer}>
                  <Text style={styles.cellDetailTopLabel}>Biaya Maks</Text>
                  <TextInputMask
                    value={this.props.maxPrice > 0 ? this.props.maxPrice : null}
                    ref="maxPriceInput"
                    type={'money'}
                    options={{
                      precision: 0,
                      unit: 'Rp ',
                    }}
                    multiline={false}
                    numberOfLines={1}
                    editable
                    selectionColor={color.greyText}
                    onChangeText={this.handleMaxPriceOnChangeText}
                    onSubmitEditing={Keyboard.dismiss}
                  />
                  <View style={styles.cellDetailUnderline} />
                  {priceBidErrorString !== '' &&
                  !this.state.isInitialLoad && (
                    <Text style={styles.cellDetailBottomRedLabel}>
                      {priceBidErrorString}
                    </Text>
                  )}
                  <View
                    style={[
                      styles.cellDetailBottomLabelContainer,
                      { marginTop: 3 },
                    ]}
                  >
                    {suggestionPriceComponent}
                    {isShowSuggestionBid && (
                      <TouchableOpacity
                        onPress={this.handleApplyRecPrice}
                        style={{ marginLeft: 5 }}
                      >
                        <Text style={styles.cellDetailBottomGreenLabel}>
                          Terapkan
                        </Text>
                      </TouchableOpacity>
                    )}
                  </View>
                </View>
                <Text style={styles.anggaranLabel}>Anggaran</Text>
                <View style={styles.cellOuterContainer}>
                  {this.renderCell('Tidak Dibatasi', 0)}
                </View>
                <View style={styles.cellOuterContainer}>
                  {this.renderCell('Per Hari', 1)}
                  {this.props.budgetType === 1 && (
                    <View style={styles.cellDetailContainer}>
                      <Text style={styles.cellDetailTopLabel}>
                        Biaya Per Hari
                      </Text>
                      <TextInputMask
                        value={
                          this.props.budgetPerDay > 0 ? (
                            this.props.budgetPerDay
                          ) : null
                        }
                        ref="perDayPriceInput"
                        type={'money'}
                        options={{
                          precision: 0,
                          unit: 'Rp ',
                        }}
                        multiline={false}
                        numberOfLines={1}
                        editable
                        selectionColor={color.mainGreen}
                        onChangeText={this.handleBudgetOnChangeText}
                        onSubmitEditing={Keyboard.dismiss}
                      />
                      <View style={styles.cellDetailUnderline} />
                      {budgetErrorString !== '' &&
                      !this.state.isInitialLoad && (
                        <Text style={styles.cellDetailBottomRedLabel}>
                          {budgetErrorString}
                        </Text>
                      )}
                      <Text
                        style={[styles.cellDetailBottomLabel, { marginTop: 3 }]}
                      >
                        {
                          'Batas anggaran dihitung dari akumulasi biaya promo jika dalam satu grup promo.'
                        }
                      </Text>
                    </View>
                  )}
                </View>
              </View>
            </TouchableWithoutFeedback>
          </KeyboardAwareScrollView>
          {this.renderBigGreenButton()}
        </View>
      </Navigator.Config>
    )
  }
}

export default connect(mapStateToProps, mapDispatchToProps)(AddPromoPageStep2)
