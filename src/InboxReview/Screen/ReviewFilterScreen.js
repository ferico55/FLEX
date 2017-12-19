import React, { PureComponent } from 'react'
import { ScrollView, Image } from 'react-native'
import Navigator from 'native-navigation'
import PropTypes from 'prop-types'

import { bindActionCreators } from 'redux'
import { connect } from 'react-redux'
import * as Actions from '../Redux/Actions'
import FilterRadioGroup from '../Components/FilterRadioGroup'

function mapStateToProps(state) {
  return {
    ...state.inboxReviewReducer,
  }
}

function mapDispatchToProps(dispatch) {
  return bindActionCreators(Actions, dispatch)
}

class ReviewFilterScreen extends PureComponent {
  constructor(props) {
    super(props)
    const params = this.props.params[this.props.pageIndex]
    this.state = {
      selectedFilter: {
        time_filter: params.time_filter == null ? 1 : params.time_filter,
        score_filter: params.score_filter == null ? 0 : params.score_filter,
      },
      pageIndex: this.props.pageIndex,
    }
    this.handleRightPress = this.handleRightPress.bind(this)
  }
  leftImage = () => (
    <Image source={{ uri: 'thumb_product' }} style={{ width: 8, height: 8 }} />
  )

  handleRightPress = () => {
    const filter = {
      time_filter: this.timeOption.selectedOption(),
      score_filter: this.statusOption ? this.statusOption.selectedIndex() : 0,
      keyword: this.props.keyword,
    }

    this.props.setFilter(
      this.props.params[this.props.pageIndex],
      filter,
      this.state.pageIndex,
    )
    Navigator.dismiss()
  }

  render() {
    const cancelImage = {
      uri: 'icon_close',
      scale: 2,
    }

    const doneButton = [
      {
        title: 'Selesai',
        foregroundColor: 'rgb(66, 181, 73)',
      },
    ]

    const timeOptions = [
      'Semua waktu',
      '7 hari terakhir',
      'Bulan ini',
      '3 bulan terakhir',
    ]
    const statusOptions = ['Semua', 'Belum dinilai', 'Sudah dinilai']

    return (
      <Navigator.Config
        title="Filter"
        rightButtons={doneButton}
        leftImage={cancelImage}
        onLeftPress={_ => Navigator.dismiss()}
        onRightPress={_ => this.handleRightPress()}
      >
        <ScrollView style={{ backgroundColor: '#f1f1f1' }}>
          <FilterRadioGroup
            ref={timeOption => {
              this.timeOption = timeOption
            }}
            title="Waktu"
            option={timeOptions}
            selectedIndex={this.state.selectedFilter.time_filter - 1}
          />
          {this.props.pageIndex === 2 && (
            <FilterRadioGroup
              ref={statusOption => {
                this.statusOption = statusOption
              }}
              title="Status"
              option={statusOptions}
              selectedIndex={this.state.selectedFilter.score_filter}
              style={{ marginTop: 8 }}
            />
          )}
        </ScrollView>
      </Navigator.Config>
    )
  }
}

ReviewFilterScreen.propTypes = {
  params: PropTypes.arrayOf(PropTypes.object).isRequired,
  pageIndex: PropTypes.number.isRequired,
  keyword: PropTypes.string,
}

ReviewFilterScreen.defaultProps = {
  keyword: '',
}

export default connect(mapStateToProps, mapDispatchToProps)(ReviewFilterScreen)
