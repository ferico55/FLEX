import React, { Component } from 'react'
import { Image } from 'react-native'

class DynamicSizeImage extends Component {
  constructor(props) {
    super(props)
    this.isFirstRequest = true
    this.state = { source: { uri: this.props.uri } }
  }

  componentWillMount() {
    if (!this.isFirstRequest) {
      return
    }
    this.isFirstRequest = false
    Image.getSize(this.props.uri, (width, height) => {
      if (this.mounted) {
        if (this.props.width && !this.props.height) {
          this.setState({
            width: this.props.width,
            height: height * (this.props.width / width),
          })
        } else if (!this.props.width && this.props.height) {
          this.setState({
            width: width * (this.props.height / height),
            height: this.props.height,
          })
        } else {
          this.setState({ width, height })
        }
      }
    })
  }

  componentDidMount() {
    this.mounted = true
  }

  componentWillUnmount() {
    this.mounted = false
  }

  render() {
    return (
      <Image
        source={this.state.source}
        style={{ height: this.state.height, width: this.state.width }}
      />
    )
  }
}

export default DynamicSizeImage
