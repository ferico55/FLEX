import React, { Component } from 'react'
import {
  Text,
  View,
  ScrollView,
  Switch,
  TouchableOpacity,
  Image,
} from 'react-native'
import SortableList from 'react-native-sortable-list'
import Navigator from 'native-navigation'
import { ReactInteractionHelper, ReactTopChatManager } from 'NativeModules'
import DeviceInfo from 'react-native-device-info'
import Row from './Row'
import infoImage from '@img/info.png'

class ChatTemplateSettingView extends Component {
  constructor(props) {
    super(props)

    // cast to object instead of array, because the SortableList expected object on data type
    const templates = props.chatTemplate.templates.reduce(
      (result, item, index) => {
        result[index] = {
          index,
          text: item,
        }
        return result
      },
      {},
    )
    const currentOrder = Object.keys(templates)

    this.state = {
      templates,
      currentOrder,
      prevOrder: currentOrder, // on initial state we make prev order is currentOrder
      enable_template: props.chatTemplate.is_enable,
      showCustomAlertInfo: false,
      showCustomAlert: false,
    }
  }

  componentWillReceiveProps = nextProps => {
    // if from sort, don't rerender
    if (!nextProps.chatTemplate.from_sort) {
      const templates = nextProps.chatTemplate.templates.reduce(
        (result, item, index) => {
          result[index] = {
            index,
            text: item,
          }
          return result
        },
        {},
      )

      this.setState({ templates })
    }
  }

  handleToggleSwitch = enable_template => {
    this.setState(
      {
        enable_template,
      },
      () => {
        this.props.updatingChatTemplate({
          data: this.props.chatTemplate.templates,
          enable_template,
        })
      },
    )
  }

  handleChangeOrder = currentOrder => {
    this.setState(prevState => ({
      prevOrder: prevState.currentOrder,
      currentOrder,
    }))
  }

  handleReleaseRow = () => {
    if (this.state.currentOrder === this.state.prevOrder) {
      return
    }

    const updateTemplates = this.state.currentOrder.map(
      v => this.state.templates[parseInt(v, 10)].text,
    )

    this.props
      .updatingChatTemplate({
        data: updateTemplates,
        enable_template: this.state.enable_template,
        from_sort: true,
      })
      .then(() => {
        this.setState(
          {
            prevOrder: this.state.currentOrder,
          },
          () => {
            ReactInteractionHelper.showStickyAlert(
              'Berhasil mengubah urutan template',
            )
          },
        )
      })
      .catch(() => {})
  }

  handlePressEdit = (messageText, index) => {
    Navigator.push('ChatTemplateForm', {
      type: 'UPDATE',
      messageText,
      index,
    })
  }

  handlePressDelete = (messageText, index) => {
    const updateTemplates = [
      ...this.props.chatTemplate.templates.slice(0, index),
      '_',
      ...this.props.chatTemplate.templates.slice(index + 1),
    ]

    this.updateTemplates = updateTemplates

    this.setState({
      showCustomAlert: true,
    })
  }

  handlePressInfo = () => {
    if (DeviceInfo.isTablet()) {
      this.setState({ showCustomAlertInfo: true })
    } else {
      ReactTopChatManager.showChatTemplateTips()
    }
  }

  handleAlertAction = () => {
    this.setState({ showCustomAlert: false }, () => {
      this.props
        .updatingChatTemplate({
          data: this.updateTemplates,
          enable_template: true,
        })
        .then(({ payload }) => {
          if (payload.success === 1) {
            ReactInteractionHelper.showStickyAlert(
              'Berhasil menghapus template pesan',
            )
          } else {
            ReactInteractionHelper.showErrorStickyAlert(
              payload.message_error_original,
            )
          }
        })
        .catch(() => {})
    })
  }

  navbarProps = () => {
    let listOfProps = {
      title: 'Pengaturan',
    }

    if (DeviceInfo.isTablet()) {
      listOfProps = {
        ...listOfProps,
        leftImage: {
          uri: 'icon_close',
          scale: 2,
        },
        onLeftPress: () => Navigator.dismiss(),
      }
    }

    return listOfProps
  }

  handlePress = () => Navigator.push('ChatTemplateForm', { type: 'ADD' })
  handlePressDisabled = () =>
    ReactInteractionHelper.showErrorStickyAlert(
      'Hapus salah satu template untuk bisa membuat template baru.',
    )

  renderButtonAddTemplate = total => {
    let textStyle = {
      fontSize: 14,
      color: 'rgb(66,181,73)',
      fontWeight: '700',
      marginLeft: 10,
    }

    let imageStyle = {
      height: 12,
      width: 12,
    }

    if (total === 5) {
      textStyle = {
        fontSize: 14,
        color: 'rgba(0,0,0,0.26)',
        fontWeight: '700',
        marginLeft: 10,
      }

      imageStyle = {
        ...imageStyle,
        tintColor: 'rgba(0,0,0,0.26)',
      }
    }

    return (
      <View
        style={{
          alignItems: 'center',
          justifyContent: 'center',
          flexDirection: 'row',
          paddingRight: 16,
        }}
      >
        <Image
          source={{ uri: 'icon_plus_green' }}
          style={imageStyle}
          resizeMode={'contain'}
        />
        <Text style={textStyle}>Tambah Template</Text>
      </View>
    )
  }

  renderListOfTemplate = () => {
    if (this.state.enable_template) {
      return (
        <View
          style={{
            paddingTop: 24,
            paddingLeft: 16,
            backgroundColor: 'white',
            marginTop: 19,
            shadowColor: 'rgba(0,0,0,0.1)',
            shadowOpacity: 0.1,
            shadowOffset: { height: 3, width: 3 },
            shadowRadius: 3,
          }}
        >
          <View
            style={{
              flex: 1,
              flexDirection: 'row',
              alignItems: 'center',
            }}
          >
            <Text
              style={{
                fontSize: 16,
                fontWeight: 'bold',
                color: 'rgba(0,0,0,0.7)',
                justifyContent: 'center',
              }}
            >
              Daftar Template
            </Text>
            <TouchableOpacity
              style={{ marginLeft: 5 }}
              onPress={this.handlePressInfo}
            >
              <Image source={infoImage} style={{ height: 17, width: 17 }} />
            </TouchableOpacity>
          </View>
          <SortableList
            onChangeOrder={this.handleChangeOrder}
            onReleaseRow={this.handleReleaseRow}
            contentContainerStyle={{
              height: 65 * this.props.chatTemplate.templates.length,
            }}
            data={this.state.templates}
            renderRow={this.renderRow}
          />
          <TouchableOpacity
            style={{
              paddingVertical: 16,
              flex: 1,
              alignItems: 'center',
              justifyContent: 'center',
            }}
            onPress={
              this.props.chatTemplate.templates.length === 5 ? (
                this.handlePressDisabled
              ) : (
                this.handlePress
              )
            }
          >
            {this.renderButtonAddTemplate(
              this.props.chatTemplate.templates.length,
            )}
          </TouchableOpacity>
        </View>
      )
    }

    return null
  }

  renderToggleTemplate = () => (
    <View
      style={{
        paddingVertical: 24,
        paddingHorizontal: 16,
        backgroundColor: 'white',
        shadowColor: 'rgba(0,0,0,0.1)',
        shadowOpacity: 0.1,
        shadowOffset: { height: 3, width: 3 },
        shadowRadius: 3,
      }}
    >
      <View style={{ flexDirection: 'row' }}>
        <View style={{ flex: 1, justifyContent: 'center' }}>
          <Text
            style={{
              fontSize: 16,
              fontWeight: 'bold',
              color: 'rgba(0,0,0,0.7)',
            }}
          >
            Template Pesan
          </Text>
        </View>
        <View
          style={{ flex: 1, alignItems: 'flex-end', justifyContent: 'center' }}
        >
          <Switch
            onValueChange={this.handleToggleSwitch}
            value={this.state.enable_template}
          />
        </View>
      </View>
      <View style={{ paddingRight: 93 }}>
        <Text style={{ fontSize: 14, color: 'rgba(0,0,0,0.54)' }}>
          Buat hingga 5 template untuk membantu Anda melakukan Chat dan Diskusi
          tanpa perlu mengetik pesan yang sama berulang kali
        </Text>
      </View>
    </View>
  )

  renderRow = ({ index, data, active }) => (
    <Row
      data={data}
      active={active}
      index={index}
      onPressEdit={this.handlePressEdit}
      onPressDelete={this.handlePressDelete}
      totalItem={this.props.chatTemplate.templates.length}
      templates={this.state.templates}
    />
  )

  renderCustomAlertInfo = () => {
    if (!this.state.showCustomAlertInfo) {
      return null
    }

    return (
      <View
        style={{
          position: 'absolute',
          right: 0,
          left: 0,
          top: 0,
          bottom: 0,
          backgroundColor: 'rgba(0,0,0,0.35)',
          alignItems: 'center',
          justifyContent: 'center',
        }}
      >
        <View
          style={{
            width: 360,
            height: 186,
            backgroundColor: 'white',
            borderRadius: 12,
          }}
        >
          <View style={{ flex: 1, flexDirection: 'row', padding: 16 }}>
            <View style={{ flex: 1 }}>
              <Text
                style={{
                  fontSize: 16,
                  fontWeight: 'bold',
                  color: 'rgba(0,0,0,0.7)',
                }}
              >
                Kelola Template Pesan
              </Text>
              <View style={{ marginTop: 8, width: 209 }}>
                <Text style={{ fontSize: 14, color: 'rgba(0,0,0,0.54)' }}>
                  Ubah dengan tekan tombol edit, atau atur urutan dengan tahan
                  dan geser tombol drag.
                </Text>
              </View>
            </View>
            <View
              style={{
                alignItems: 'center',
                marginTop: 17,
              }}
            >
              <Image
                source={{ uri: 'infoDragEdit' }}
                style={{ width: 86, height: 67 }}
              />
            </View>
          </View>
          <TouchableOpacity
            style={{
              backgroundColor: 'rgb(66,181,73)',
              height: 48,
              margin: 16,
              borderRadius: 4,
              justifyContent: 'center',
              alignItems: 'center',
            }}
            onPress={() => this.setState({ showCustomAlertInfo: false })}
          >
            <Text style={{ fontSize: 14, fontWeight: 'bold', color: 'white' }}>
              Tutup
            </Text>
          </TouchableOpacity>
        </View>
      </View>
    )
  }

  renderCustomAlert = () => {
    if (this.state.showCustomAlert) {
      return (
        <View
          style={{
            position: 'absolute',
            right: 0,
            left: 0,
            top: 0,
            bottom: 0,
            backgroundColor: 'rgba(0,0,0,0.35)',
            alignItems: 'center',
            justifyContent: 'center',
          }}
        >
          <View
            style={{
              width: 270,
              height: 140,
              backgroundColor: 'white',
              borderRadius: 12,
            }}
          >
            <View
              style={{
                flex: 1,
                alignItems: 'center',
                paddingTop: 20,
                paddingBottom: 20,
              }}
            >
              <Text
                style={{
                  fontSize: 17,
                  color: 'rgba(3,3,3,0.7)',
                  marginBottom: 15,
                  fontWeight: '500',
                }}
              >
                Hapus template?
              </Text>
              <Text style={{ fontSize: 13, color: 'rgba(3,3,3,0.7)' }}>
                Template akan terhapus selamanya
              </Text>
            </View>
            <View
              style={{
                height: 43,
                flexDirection: 'row',
                borderTopWidth: 1,
                borderTopColor: 'rgba(0,0,0,0.12)',
              }}
            >
              <TouchableOpacity
                style={{
                  flex: 1,
                  alignItems: 'center',
                  justifyContent: 'center',
                  borderRightWidth: 1,
                  borderRightColor: 'rgba(0,0,0,0.12)',
                }}
                onPress={() => this.setState({ showCustomAlert: false })}
              >
                <Text
                  style={{
                    color: 'rgb(66,181,73)',
                    fontSize: 17,
                    fontWeight: '500',
                  }}
                >
                  Batal
                </Text>
              </TouchableOpacity>
              <TouchableOpacity
                style={{
                  flex: 1,
                  alignItems: 'center',
                  justifyContent: 'center',
                }}
                onPress={this.handleAlertAction}
              >
                <Text
                  style={{
                    color: 'rgb(66,181,73)',
                    fontSize: 17,
                  }}
                >
                  Hapus
                </Text>
              </TouchableOpacity>
            </View>
          </View>
        </View>
      )
    }

    return null
  }

  render() {
    return (
      <Navigator.Config {...this.navbarProps()}>
        <View style={{ flex: 1, backgroundColor: 'rgb(248,248,248)' }}>
          <ScrollView bounces={false}>
            {this.renderToggleTemplate()}
            {this.renderListOfTemplate()}
          </ScrollView>
          {this.renderCustomAlert()}
          {this.renderCustomAlertInfo()}
        </View>
      </Navigator.Config>
    )
  }
}

export default ChatTemplateSettingView
