import React, { PureComponent } from 'react'
import {
  StyleSheet,
  View,
  TouchableOpacity,
  Text,
  Keyboard,
  DeviceEventEmitter,
  ActivityIndicator,
} from 'react-native'
import Navigator from 'native-navigation'
import PropTypes from 'prop-types'

import {
  TKPReactURLManager,
  ReactNetworkManager,
  ReactInteractionHelper,
} from 'NativeModules'

import { bindActionCreators } from 'redux'
import { connect } from 'react-redux'
import * as Actions from '../Redux/Actions'
import RadioOption from '../Components/RadioOption'

function mapStateToProps(state) {
  return {
    ...state.inboxReviewReducer,
  }
}

function mapDispatchToProps(dispatch) {
  return bindActionCreators(Actions, dispatch)
}

const styles = StyleSheet.create({
  mutedText: {
    color: 'rgba(0,0,0,0.54)',
  },
  actionButtonText: {
    fontWeight: '500',
    fontSize: 14,
  },
  actionButtonContainer: {
    marginVertical: 16,
    marginHorizontal: 8,
    height: 52,
    borderRadius: 3,
    alignItems: 'center',
    justifyContent: 'center',
  },
})

const reportOptions = [
  'Ini adalah spam',
  'Konten mengandung SARA, diskriminasi, vulgar, ancaman, dan pelanggaran nilai / norma sosial',
  'Lainnya',
]

class ReportReviewScreen extends PureComponent {
  constructor(props) {
    super(props)
    this.state = {
      shouldEnableSubmit: false,
      isLoading: false,
    }
  }

  componentDidMount() {
    DeviceEventEmitter.addListener('SET_INVOICE', () => {
      Navigator.pop()
    })
  }

  reportReview = () => {
    this.setState({
      isLoading: true,
      shouldEnableSubmit: false,
    })
    const params = {
      element_id: this.props.data.review_id,
      shop_id: this.props.shopID,
      reason: this.radioOption.selectedOption(),
      otherreason: this.radioOption.otherText(),
    }
    ReactNetworkManager.request({
      method: 'POST',
      baseUrl: TKPReactURLManager.v4Url,
      path: '/reputationapp/review/api/v1/report',
      params,
    })
      .then(response => {
        if (response.data.is_success === 1) {
          Navigator.pop()
          ReactInteractionHelper.showSuccessAlert(
            'Anda berhasil melaporkan ulasan ini.',
          )
        } else {
          this.setState({
            isLoading: false,
            shouldEnableSubmit: true,
          })
          ReactInteractionHelper.showDangerAlert(response.message_error[0])
        }
      })
      .catch(_ => {
        this.setState({
          isLoading: false,
          shouldEnableSubmit: true,
        })
        ReactInteractionHelper.showDangerAlert('Terjadi gangguan pada koneksi.')
      })
  }

  render = () => (
    <Navigator.Config title="Laporkan">
      <View
        style={{
          backgroundColor: '#f1f1f1',
          flex: 1,
        }}
      >
        <View
          style={{
            backgroundColor: 'white',
            marginTop: 8,
            paddingVertical: 16,
            paddingHorizontal: 8,
          }}
        >
          <Text style={[styles.mutedText, { fontSize: 15, lineHeight: 21 }]}>
            {
              'Bantu kami memahami apa yang terjadi. Mengapa Anda melaporkan ulasan ini?'
            }
          </Text>
          <RadioOption
            ref={option => {
              this.radioOption = option
            }}
            options={reportOptions}
            otherIndex={2}
            selectedIndex={-1}
            style={{ marginTop: 20 }}
            validationChanged={isValid => {
              this.setState({
                shouldEnableSubmit: isValid,
              })
            }}
          />
        </View>
        <TouchableOpacity
          onPress={() => {
            Keyboard.dismiss()
          }}
          style={{ flex: 1 }}
        >
          <View style={{ flex: 1 }} />
        </TouchableOpacity>

        <TouchableOpacity
          onPress={() => {
            if (!this.state.shouldEnableSubmit) {
              return
            }
            this.reportReview()
          }}
        >
          <View
            style={[
              styles.actionButtonContainer,
              {
                backgroundColor: this.state.shouldEnableSubmit
                  ? 'rgb(66,181,73)'
                  : 'rgb(224,224,224)',
              },
            ]}
          >
            {this.state.isLoading && (
              <ActivityIndicator
                animating
                style={[styles.centering, { height: 44 }]}
                size="small"
              />
            )}
            {!this.state.isLoading && (
              <Text
                style={[
                  styles.actionButtonText,
                  {
                    color: this.state.shouldEnableSubmit
                      ? 'white'
                      : 'rgba(0,0,0,0.28)',
                  },
                ]}
              >
                {'Kirim'}
              </Text>
            )}
          </View>
        </TouchableOpacity>
      </View>
    </Navigator.Config>
  )
}

ReportReviewScreen.propTypes = {
  data: PropTypes.object.isRequired,
  shopID: PropTypes.string.isRequired,
}

export default connect(mapStateToProps, mapDispatchToProps)(ReportReviewScreen)
