import React, { Component } from 'react'
import { connect } from 'react-redux'
import { ReactTPRoutes } from 'NativeModules'
import { fetchBanners } from '../actions/actions'
import BannerList from '../components/bannerList'

class BannerContainer extends Component {
  componentDidMount() {
    const { dispatch } = this.props
    dispatch(fetchBanners())
  }

  onBannerPress = (e, banner) => {
    // TODO: Add GTM Event.
    ReactTPRoutes.navigate(banner.redirect_url)
  }

  onViewAllPress = () => {
    ReactTPRoutes.navigate('https://www.tokopedia.com/promo/belanja/official-store')
  }

  render() {
    console.log('BannerContainer rendered')
    const banners = this.props.banners.items
    return this.props.banners.isFetching ? null : (
      <BannerList
        banners={banners}
        onBannerPress={this.onBannerPress}
        onViewAllPress={this.onViewAllPress}
      />
    )
  }
}

const mapStateToProps = state => {
  const banners = state.banners
  return {
    banners,
  }
}

export default connect(mapStateToProps)(BannerContainer)
