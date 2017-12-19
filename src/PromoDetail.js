import React from 'react'
import {
  StyleSheet,
  ScrollView,
  Text,
  View,
  Image,
  ActivityIndicator,
  Clipboard,
  TouchableOpacity,
} from 'react-native'
import HTMLView from 'react-native-htmlview'
import entities from 'entities'

import {
  TKPReactURLManager,
  ReactNetworkManager,
  ReactInteractionHelper,
  HybridNavigationManager,
  ReactPopoverHelper,
} from 'NativeModules'

import { flatten, map } from 'lodash'
import PreAnimatedImage from './PreAnimatedImage'
import NoResultView from './NoResultView'

const monthNames = [
  'Januari',
  'Februari',
  'Maret',
  'April',
  'Mei',
  'Juni',
  'Juli',
  'Agustus',
  'September',
  'Oktober',
  'November',
  'Desember',
]

const styles = StyleSheet.create({
  headerImage: {
    resizeMode: 'cover',
    aspectRatio: 1.91,
  },
  shareButton: {
    borderRadius: 52,
    height: 52,
    width: 52,
    backgroundColor: 'white',
    justifyContent: 'center',
    alignItems: 'center',
    marginTop: -26,
    alignSelf: 'flex-end',
    marginRight: 15,
  },
  shareImage: {
    height: 23,
    width: 20,
  },
  titleHolder: {
    marginTop: -26,
    paddingHorizontal: 18,
    paddingTop: 32,
    paddingBottom: 22,
    backgroundColor: 'white',
  },
  title: {
    textAlign: 'center',
    fontWeight: '600',
    fontSize: 16,
    color: 'rgba(0,0,0,0.7)',
  },
  descriptionHolder: {
    marginTop: 15,
    backgroundColor: 'white',
  },
  greyText: {
    color: 'rgba(0,0,0,0.38)',
  },
  descriptionIcon: {
    width: 24,
    height: 27,
  },
  innerDescriptionHolder: {
    flex: 1,
    paddingVertical: 16,
  },
  headerText: {
    fontSize: 14,
    color: 'rgba(0,0,0,0.7)',
    textAlign: 'center',
  },
  codeHolder: {
    borderRadius: 3,
    borderColor: 'rgb(224,224,224)',
    borderWidth: 1,
    marginTop: 18,
    marginBottom: 8,
    flexDirection: 'row',
  },
  innerCodeHolder: {
    padding: 9,
  },
  detailHolder: {
    marginTop: 16,
    paddingVertical: 16,
    backgroundColor: 'white',
    marginBottom: 16,
  },
  detail: {
    padding: 16,
    paddingBottom: 0,
    flex: 1,
  },
  shopButton: {
    position: 'absolute',
    bottom: 0,
    width: '100%',
    backgroundColor: 'rgb(66,181,73)',
    paddingVertical: 18,
    alignItems: 'center',
    zIndex: 10,
  },
  shopText: {
    color: 'white',
    fontSize: 14,
    fontWeight: '600',
  },
  boldHorizontalSeparator: {
    borderTopWidth: 1.5,
    borderColor: 'rgba(0,0,0,0.12)',
    marginTop: 19,
  },
  readMore: {
    paddingHorizontal: 16,
    color: 'rgb(66,181,73)',
    alignSelf: 'center',
    paddingTop: 8,
  },
  subtitle: {
    textAlign: 'center',
    marginTop: 12,
    fontSize: 12,
  },
})

class PromoDetail extends React.PureComponent {
  constructor(props) {
    super(props)
    this.state = {
      isLoading: true,
      promoName: props.navigation.state.params,
      isDetailExpanded: false,
    }
    let tag = props.navigation.state.key
    tag = tag.substring(tag.indexOf('-') + 1, tag.length)
    HybridNavigationManager.setTitle(parseInt(tag, 2), 'Promo Detail')
  }

  componentDidMount() {
    this.loadData()
  }

  getPromoPeriod = (startDateString, endDateString) => {
    const startDate = new Date(startDateString)
    const endDate = new Date(endDateString)
    let period = startDate.getDate()
    if (startDate.getMonth() !== endDate.getMonth()) {
      period += ` ${monthNames[startDate.getMonth()]}`
    }
    if (startDate.getFullYear() !== endDate.getFullYear()) {
      period += ` ${startDate.getFullYear()}`
    }

    period += ` - ${endDate.getDate()} ${monthNames[
      endDate.getMonth()
    ]} ${endDate.getFullYear()}`
    return period
  }

  copyPromoCode = promoCode => {
    Clipboard.setString(promoCode)
    ReactInteractionHelper.showStickyAlert('Kode Promo berhasil disalin')
  }

  htmlView = () => {
    if (this.state.isDetailExpanded) {
      return (
        <View>
          <View style={styles.detail}>
            <Text>
              <HTMLView
                value={this.state.data.content.rendered}
                RootComponent={Text}
                renderNode={this.renderNode}
              />
            </Text>
          </View>
        </View>
      )
    }
    return (
      <View>
        <View style={styles.detail}>
          <Text numberOfLines={15}>
            <HTMLView
              value={this.state.data.content.rendered}
              RootComponent={Text}
              ellipsizeMode="tail"
              renderNode={this.renderNode}
            />
          </Text>
        </View>
        <TouchableOpacity
          onPress={() => {
            this.setState({
              isDetailExpanded: !this.state.isDetailExpanded,
            })
          }}
        >
          <Text style={styles.readMore}>{'Baca Selengkapnya'}</Text>
        </TouchableOpacity>
      </View>
    )
  }

  loadData() {
    this.setState({
      isLoading: true,
    })

    ReactNetworkManager.request({
      method: 'GET',
      baseUrl: TKPReactURLManager.tokopediaUrl,
      path: '/promo/wp-json/wp/v2/posts/',
      params: {
        slug: this.state.promoName,
      },
    })
      .then(responseData => {
        const response = responseData[0]
        response.content.rendered = response.content.rendered.replace(/\n/g, '')
        this.setState({
          data: response,
          isLoading: false,
        })
      })
      .catch(_ => {
        this.setState({
          isLoading: false,
          data: null,
        })
      })
  }

  renderNode = (node, index, siblings, parent, defaultRenderer) => {
    if (node.name === 'li') {
      if (
        siblings[0].parent.parent &&
        siblings[0].parent.parent.name === 'li'
      ) {
        return (
          <Text key={index}>
            {index === 0 ? '\n\n\n' : ''}
            {entities.decodeHTML('&#8226;')}{' '}
            {defaultRenderer(node.children, parent)}
            {'\n\n'}
          </Text>
        )
      }
      return (
        <Text key={index}>
          {index + 1}. {defaultRenderer(node.children, parent)}
          {index + 1 === siblings.length ? '' : '\n\n'}
        </Text>
      )
    } else if (node.name === 'ol' || node.name === 'ul') {
      return (
        <Text
          key={index}
          style={{ textAlign: 'justify', color: 'rgba(0,0,0,0.54)' }}
          ellipsizeMode="tail"
        >
          {index === 0 ? '' : '\n\n'}
          {defaultRenderer(node.children, parent)}
          {index + 1 === siblings.length ? '' : '\n'}
        </Text>
      )
    } else if (
      siblings[0].parent &&
      siblings[0].parent.name === 'a' &&
      node.type !== 'text'
    ) {
      console.log(node)
      return (
        <Text key={index} style={{ color: '#42b549', fontWeight: '600' }}>
          {defaultRenderer(node.children, parent)}
        </Text>
      )
    } else if (node.name === 'a') {
      return (
        <Text
          key={index}
          style={{ color: '#42b549' }}
          onPress={() => {
            this.props.navigation.navigate('tproutes', {
              url: node.attribs.href,
            })
          }}
        >
          {defaultRenderer(node.children, parent)}
        </Text>
      )
    } else if (node.name === 'p') {
      return (
        <Text
          key={index}
          style={{ textAlign: 'justify', color: 'rgba(0,0,0,0.54)' }}
        >
          {index === 0 ? '' : '\n'}
          {defaultRenderer(node.children, parent)}
          {'\n'}
        </Text>
      )
    }
  }

  renderPromoCode = () => {
    if (this.state.data.acf.multiple_promo_code) {
      const promoCodes = flatten(
        map(this.state.data.acf.promo_codes, code => code.group_code),
      )
      const arr = promoCodes.map((v, k) => (
        <TouchableOpacity
          key={k}
          style={{
            width: '45%',
            margin: '2.5%',
            borderRadius: 3,
            borderColor: 'rgb(224,224,224)',
            borderWidth: 1,
            height: 40,
          }}
          onPress={() => this.copyPromoCode(v.single_code)}
        >
          <View
            style={{
              flex: 1,
              flexDirection: 'row',
              backgroundColor: 'rgb(248,248,248)',
            }}
          >
            <View
              style={{
                flex: 1,
                alignItems: 'center',
                justifyContent: 'center',
              }}
            >
              <Text style={{ color: 'rgb(255, 87, 34)' }}>{v.single_code}</Text>
            </View>
          </View>
          <View style={{ position: 'absolute', right: 10, top: 10 }}>
            <Image
              source={{ uri: 'ic-copy-mobile' }}
              style={{ width: 19, height: 19 }}
            />
          </View>
          <View
            style={{
              position: 'absolute',
              top: -9,
              left: -1,
              backgroundColor: 'white',
              width: 18,
              height: 18,
              borderRadius: 18,
              borderWidth: 1,
              borderColor: 'rgb(224,224,224)',
              justifyContent: 'center',
              alignItems: 'center',
            }}
          >
            <Text style={{ fontSize: 10, color: '#42b549' }}>{k + 1}</Text>
          </View>
        </TouchableOpacity>
      ))
      return (
        <View
          style={{
            flex: 1,
            flexDirection: 'row',
            flexWrap: 'wrap',
            marginTop: 15,
          }}
        >
          {arr}
        </View>
      )
    } else if (this.state.data.meta.promo_code !== '') {
      return (
        <View style={styles.codeHolder}>
          <View
            style={[
              styles.innerCodeHolder,
              { backgroundColor: 'rgb(248,248,248)' },
            ]}
          >
            <Text style={{ color: 'rgb(255, 87, 34)' }}>
              {this.state.data.meta.promo_code}
            </Text>
          </View>
          <View
            style={{
              borderLeftWidth: 1,
              borderColor: 'rgb(224,224,224)',
            }}
          />
          <TouchableOpacity
            style={styles.innerCodeHolder}
            onPress={() => this.copyPromoCode(this.state.data.meta.promo_code)}
          >
            <Text style={[styles.greyText, { fontSize: 14 }]}>Salin Kode</Text>
          </TouchableOpacity>
        </View>
      )
    }
    return null
  }

  renderMainContent = () => (
    <View>
      <PreAnimatedImage
        source={this.state.data.meta.thumbnail_image}
        style={styles.headerImage}
        onLoadEnd={() => {
          this.setNativeProps()
        }}
      />
      <TouchableOpacity
        style={{ zIndex: 10 }}
        onPress={e =>
          ReactInteractionHelper.share(
            this.state.data.link,
            this.state.data.slug,
            `${entities.decodeHTML(
              this.state.data.title.rendered,
            )} | Tokopedia`,
            e.target,
          )}
      >
        <View
          style={styles.shareButton}
          shadowColor="black"
          shadowRadius={2}
          shadowOpacity={0.15}
          shadowOffset={{ height: 2 }}
        >
          <Image
            style={styles.shareImage}
            source={{ uri: 'icon_share_gradient' }}
          />
        </View>
      </TouchableOpacity>
      <View style={styles.titleHolder}>
        <Text style={styles.title}>
          {entities.decodeHTML(this.state.data.title.rendered)}
        </Text>
      </View>

      <View style={styles.descriptionHolder}>
        <View style={{ flexDirection: 'row' }}>
          <View style={styles.innerDescriptionHolder}>
            <Image
              source={{ uri: 'icon_stopwatch' }}
              style={[styles.descriptionIcon, { alignSelf: 'center' }]}
            />
            <Text style={[styles.greyText, styles.subtitle]}>
              Periode Promo
            </Text>
            <Text
              style={[
                styles.headerText,
                { marginTop: 4, paddingHorizontal: 16 },
              ]}
              numberOfLines={2}
            >
              {this.getPromoPeriod(
                this.state.data.meta.start_date,
                this.state.data.meta.end_date,
              )}
            </Text>
          </View>
          <View
            style={{
              borderLeftWidth: 0.5,
              borderColor: 'rgba(0,0,0,0.12)',
            }}
          />
          <View style={styles.innerDescriptionHolder}>
            <Image
              source={{ uri: 'icon_money' }}
              resizeMode="contain"
              style={[styles.descriptionIcon, { alignSelf: 'center' }]}
            />
            <Text style={[styles.greyText, styles.subtitle]}>
              {this.state.data.meta.min_transaction === '' ? (
                'Tanpa Minimum Transaksi'
              ) : (
                'Minimum Transaksi'
              )}
            </Text>
            <Text style={[styles.headerText, { marginTop: 4 }]}>
              {this.state.data.meta.min_transaction}
            </Text>
          </View>
        </View>
        <View
          style={{
            borderTopWidth: 0.5,
            borderColor: 'rgba(0,0,0,0.12)',
          }}
        />
        <View
          style={[
            styles.innerDescriptionHolder,
            {
              alignItems: this.state.data.acf.multiple_promo_code
                ? 'flex-start'
                : 'center',
            },
          ]}
        >
          <View style={{ flexDirection: 'row', marginLeft: 16 }}>
            <Image
              source={{ uri: 'icon_coupon' }}
              style={{ width: 25, height: 14, marginTop: 2 }}
            />
            <Text
              style={[
                styles.greyText,
                styles.subtitle,
                { marginTop: 1, marginLeft: 10, marginRight: 3 },
              ]}
            >
              {this.state.data.meta.promo_code === '' &&
              !this.state.data.acf.multiple_promo_code ? (
                'Tanpa Kode Promo'
              ) : (
                'Kode Promo'
              )}
            </Text>
            {(this.state.data.meta.promo_code !== '' ||
              this.state.data.acf.multiple_promo_code) && (
              <TouchableOpacity
                onPress={() =>
                  ReactPopoverHelper.showTooltip(
                    'Kode Promo',
                    'Masukan Kode Promo di halaman pembayaran',
                    'icon_promo',
                    'Tutup',
                  )}
              >
                <Image
                  source={{ uri: 'icon_information' }}
                  style={{ width: 14, height: 14, marginTop: 1 }}
                />
              </TouchableOpacity>
            )}
          </View>
          {this.renderPromoCode()}
        </View>
      </View>

      <View style={styles.detailHolder}>
        <Text style={[styles.title, { fontSize: 14, marginTop: 5 }]}>
          Syarat & Ketentuan
        </Text>
        <View style={styles.boldHorizontalSeparator} />
        {this.htmlView()}
      </View>
    </View>
  )

  render() {
    return (
      <View style={{ backgroundColor: 'rgb(241,241,241)', flex: 1 }}>
        {!this.state.data &&
        !this.state.isLoading && (
          <NoResultView
            onRefresh={() => {
              this.loadData()
            }}
          />
        )}
        <ScrollView
          style={
            this.state.data && this.state.data.meta.app_link !== '' ? (
              { marginBottom: 52 }
            ) : (
              {}
            )
          }
        >
          {this.state.isLoading && (
            <ActivityIndicator
              animating={this.state.isLoading}
              style={[styles.centering, { height: 44 }]}
              size="small"
            />
          )}
          {this.state.data != null && this.renderMainContent()}
        </ScrollView>
        {!this.state.isLoading &&
        this.state.data &&
        this.state.data.meta.app_link !== '' && (
          <TouchableOpacity
            style={[styles.shopButton]}
            onPress={() =>
              this.props.navigation.navigate('tproutes', {
                url: this.state.data.meta.app_link,
              })}
          >
            <Text style={styles.shopText}>{this.state.data.cta_text}</Text>
          </TouchableOpacity>
        )}
      </View>
    )
  }
}

export default PromoDetail
