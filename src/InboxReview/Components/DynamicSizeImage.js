import React, { Component } from 'react'
import { Image } from 'react-native'
import PropTypes from 'prop-types'

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

DynamicSizeImage.defaultProps = {
  width: 0,
  height: 0,
}

DynamicSizeImage.propTypes = {
  uri: PropTypes.string.isRequired,
  width: PropTypes.number,
  height: PropTypes.number,
}

export default DynamicSizeImage
