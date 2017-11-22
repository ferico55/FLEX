import { compose } from 'react-apollo'
import Screen from './Screen'
import {
  CommentsWithData,
  SendCommentWithData,
  DeleteCommentWithData,
} from './graphql'

export default compose(
  CommentsWithData,
  SendCommentWithData,
  DeleteCommentWithData,
)(Screen)
