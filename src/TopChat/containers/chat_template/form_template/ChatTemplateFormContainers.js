import { connect } from 'react-redux'
import { bindActionCreators } from 'redux'
import { updatingChatTemplate } from '@TopChat/redux/chat_template/Actions'
import ChatTemplateFormView from './ChatTemplateFormView'

const mapStateToProps = ({ chatTemplate }) => ({
  chatTemplate,
})

const mapDispatchToProps = dispatch => ({
  updatingChatTemplate: bindActionCreators(updatingChatTemplate, dispatch),
})

export default connect(mapStateToProps, mapDispatchToProps)(
  ChatTemplateFormView,
)
