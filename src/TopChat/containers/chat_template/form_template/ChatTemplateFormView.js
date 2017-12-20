import React, { Component } from 'react'
import { View, AlertIOS } from 'react-native'
import Navigator from 'native-navigation'
import { ReactInteractionHelper } from 'NativeModules'
import trashIcon from '@img/trashNotActive.png'
import { TextArea } from '@TopChat/components'
import { Subject } from 'rxjs'
import DeviceInfo from 'react-native-device-info'

class ChatTemplateFormView extends Component {
  constructor(props) {
    super(props)
    this.state = {
      messageText: props.messageText,
    }

    this.onPressSave$ = new Subject()
  }

  componentWillMount = () => {
    this.onPressSaveSubcription = this.onPressSave$
      .debounceTime(250)
      .subscribe(() => this.handleSaveAction())
  }

  handleChangeText = messageText => {
    this.setState({
      messageText,
    })
  }

  handleSaveAction = () => {
    let updateTemplates = [...this.props.chatTemplate.templates]

    if (this.props.type === 'UPDATE') {
      updateTemplates = [
        ...updateTemplates.slice(0, this.props.index),
        this.state.messageText,
        ...updateTemplates.slice(this.props.index + 1),
      ]
    } else {
      updateTemplates = [...updateTemplates, this.state.messageText]
    }

    this.props
      .updatingChatTemplate({
        data: updateTemplates,
        enable_template: true,
      })
      .then(({ payload }) => {
        if (payload.success === 1) {
          const type = this.props.type === 'UPDATE' ? 'mengubah' : 'menambahkan'
          ReactInteractionHelper.showStickyAlert(
            `Berhasil ${type} template pesan`,
          )
        } else {
          ReactInteractionHelper.showErrorStickyAlert(
            payload.message_error_original,
          )
        }
        Navigator.pop()
      })
      .catch(() => {})
  }

  handleSaveButton = () => {
    this.onPressSave$.next()
  }

  pressDeleteIcon = index => {
    const updateTemplates = [
      ...this.props.chatTemplate.templates.slice(0, index),
      '_',
      ...this.props.chatTemplate.templates.slice(index + 1),
    ]

    if (this.props.chatTemplate.templates.length === 1) {
      ReactInteractionHelper.showErrorStickyAlert(
        'Anda harus memiliki minimal 1 template',
      )
    } else {
      AlertIOS.alert(
        'Hapus chat template?',
        'Chat template akan terhapus selamanya',
        [
          { text: 'Batal' },
          {
            text: 'Hapus',
            onPress: () => {
              this.props
                .updatingChatTemplate({
                  data: updateTemplates,
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
                  Navigator.pop()
                })
                .catch(() => {})
            },
          },
        ],
      )
    }
  }

  navbarProps = type => {
    let listOfProps = {
      title: 'Tambah Template Pesan',
    }

    if (type === 'UPDATE' && DeviceInfo.isTablet()) {
      listOfProps = {
        title: 'Ubah Template Pesan',
      }
    } else if (
      type === 'UPDATE' &&
      this.props.chatTemplate.templates.length >= 1
    ) {
      listOfProps = {
        title: 'Ubah Template Pesan',
        rightImage: trashIcon,
        onRightPress: () => this.pressDeleteIcon(this.props.index),
      }
    }

    return listOfProps
  }

  render() {
    const placeholder =
      'Silakan tambahkan template untuk membantu Anda melakukan Chat tanpa perlu mengetik pesan yang sama berulang kali.\n\nContoh:\nHalo, barang ini ready ya. Silakan diorder'
    return (
      <Navigator.Config {...this.navbarProps(this.props.type)}>
        <View style={{ flex: 1 }}>
          <TextArea
            onPressSaveButton={this.handleSaveButton}
            onChangeText={this.handleChangeText}
            messageText={this.state.messageText}
            textInputProps={{
              placeholder,
              maxLength: 200,
              minLength: 1,
              multiline: true,
            }}
          />
        </View>
      </Navigator.Config>
    )
  }
}

export default ChatTemplateFormView
