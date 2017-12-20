import { connect } from 'react-redux'
import { bindActionCreators } from 'redux'
import { fetchChatTemplate } from '@TopChat/redux/chat_template/Actions'
import SendChatView from './SendChatView'

const mapStateToProps = ({ chatTemplate }) => ({
  chatTemplate,
})

const mapDispatchToProps = dispatch => ({
  fetchChatTemplate: bindActionCreators(fetchChatTemplate, dispatch),
})

export default connect(mapStateToProps, mapDispatchToProps)(SendChatView)
