import React from 'react'
import {
  Modal,
  StyleSheet,
  View,
  Image,
  TouchableWithoutFeedback,
  TouchableOpacity,
  Text,
} from 'react-native'
import PropTypes from 'prop-types'

const styles = StyleSheet.create({
  modalContainer: {
    flex: 1,
    padding: 8,
    backgroundColor: 'rgba(0,0,0,0.5)',
    justifyContent: 'flex-end',
  },
  modalContentContainer: {
    borderRadius: 3,
    backgroundColor: 'white',
    paddingHorizontal: 10,
    paddingTop: 24,
    paddingBottom: 8,
  },
  titleText: {
    fontWeight: '500',
    fontSize: 20,
    lineHeight: 30,
    color: 'rgba(0,0,0,0.7)',
  },
  contentContainer: {
    flexDirection: 'row',
    justifyContent: 'center',
    marginVertical: 16,
  },
  actionButton: {
    borderRadius: 3,
    backgroundColor: '#42b549',
    height: 52,
    justifyContent: 'center',
    alignItems: 'center',
  },
  actionText: {
    color: 'white',
    fontWeight: '500',
    fontSize: 14,
    height: 21,
  },
  contentText: {
    color: 'rgba(0,0,0,0.54)',
    fontSize: 13,
    lineHeight: 19,
    flex: 1,
  },
})

const ReplyComponent = ({
  visible,
  onRequestClose,
  imageUri,
  title,
  message,
  renderContent,
}) => (
  <Modal animationType={'fade'} transparent visible={visible}>
    <TouchableWithoutFeedback onPress={onRequestClose}>
      <View style={styles.modalContainer}>
        <View style={styles.modalContentContainer}>
          <Text style={styles.titleText}>{title}</Text>
          {renderContent && (
            <View style={{ marginBottom: 32 }}>{renderContent()}</View>
          )}
          {!renderContent && (
            <View>
              <View style={styles.contentContainer}>
                <Text style={styles.contentText}>{message}</Text>
                <Image
                  source={{ uri: imageUri }}
                  style={{ marginLeft: 4, width: 80, flex: 1 }}
                  resizeMode="contain"
                />
              </View>
            </View>
          )}
          <TouchableOpacity onPress={onRequestClose}>
            <View style={styles.actionButton}>
              <Text style={styles.actionText}>Tutup</Text>
            </View>
          </TouchableOpacity>
        </View>
      </View>
    </TouchableWithoutFeedback>
  </Modal>
)

ReplyComponent.propTypes = {
  visible: PropTypes.bool,
  onRequestClose: PropTypes.func.isRequired,
  imageUri: PropTypes.string,
  title: PropTypes.string.isRequired,
  message: PropTypes.string,
  renderContent: PropTypes.func,
}

ReplyComponent.defaultProps = {
  visible: false,
  renderContent: null,
  message: '',
  imageUri: '',
}

export default ReplyComponent
