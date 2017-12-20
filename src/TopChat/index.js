import withStore from '../withStore'
import store from './Store'
import MainContainers from './containers/main/MainContainers'
import DetailContainers from './containers/detail/DetailContainers'
import ProductAttach from './containers/product/ProductContainers'
import SendChatView from './containers/send_chat/SendChatContainers'
import ChatTemplateSettingView from './containers/chat_template/setting_template/ChatTemplateSettingContainers'
import ChatTemplateFormView from './containers/chat_template/form_template/ChatTemplateFormContainers'

const provided = withStore(store)

export default {
  TopChatMain: provided(MainContainers),
  TopChatDetail: provided(DetailContainers),
  ProductAttachTopChat: provided(ProductAttach),
  ChatTemplateSetting: provided(ChatTemplateSettingView),
  ChatTemplateForm: provided(ChatTemplateFormView),
  SendChat: provided(SendChatView),
}
