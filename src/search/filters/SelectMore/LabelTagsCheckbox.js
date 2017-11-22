import { connect } from '../../redux'
import LabelTags from './LabelTags'
import { selector } from './selector'

export default connect(selector)(LabelTags)
