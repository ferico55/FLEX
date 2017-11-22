import { connect } from '../../redux'
import LabelTags from './LabelTags'
import { categorySelector } from './selector'

export default connect(categorySelector)(LabelTags)
