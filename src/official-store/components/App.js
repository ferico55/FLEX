import React, { Component } from 'react'
import { ScrollView, View, RefreshControl } from 'react-native'
import { connect } from 'react-redux'
import BannerContainer from '../containers/bannerContainer'
import CampaignContainer from '../containers/campaignContainer'
import BrandContainer from '../containers/brandContainer'
import Infographic from '../components/infographic'
import BackToTop from '../common/BackToTop/backToTop'
import Seo from '../components/seo'
import OfficialStoreIntro from '../components/OfficialStoreIntro'
import {
  fetchBanners,
  fetchCampaigns,
  fetchBrands,
  refreshState,
} from '../actions/actions'
import GridContainer from '../containers/gridContainer'
import AllBrand from './AllBrand'

class App extends Component {
  constructor(props) {
    super(props)
    this.state = { showBtn: false, refreshing: false }
  }
  onBackToTopTap = () => {
    this.refs.scrollView.scrollTo({ x: 0, y: 0, animated: true })
  }

  onScroll = event => {
    if (event.nativeEvent.contentOffset.y > 800) {
      this.setState({
        showBtn: true,
      })
    } else {
      this.setState({
        showBtn: false,
      })
    }
  }

  _onRefresh = () => {
    this.setState({ refreshing: true })
    const { dispatch } = this.props
    dispatch(refreshState())
    dispatch(fetchBanners())
    dispatch(fetchCampaigns())
    dispatch(fetchBrands(10, 0))
    setTimeout(() => {
      this.setState({ refreshing: false })
    }, 5000)
  }

  render() {
    return (
      <View>
        <ScrollView
          ref="scrollView"
          onScroll={this.onScroll}
          scrollEventThrottle={100}
          refreshControl={
            <RefreshControl
              refreshing={this.state.refreshing}
              onRefresh={this._onRefresh}
              colors={['#42b549']}
            />
          }
        >
          <OfficialStoreIntro />
          <BannerContainer />
          <AllBrand />
          <GridContainer />
          <CampaignContainer />
          <BrandContainer />
          <Infographic />
          <Seo />
        </ScrollView>
        {this.state.showBtn ? <BackToTop onTap={this.onBackToTopTap} /> : null}
      </View>
    )
  }
}

export default connect()(App)
