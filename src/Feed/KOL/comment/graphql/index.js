import { graphql } from 'react-apollo'
import gql from 'graphql-tag'
import _ from 'lodash'

import { ReactInteractionHelper } from 'NativeModules'

const GetKOLListComment = gql`
  query GetKOLListComment($idPost: Int!, $cursor: String, $limit: Int!) {
    get_kol_list_comment(idPost: $idPost, cursor: $cursor, limit: $limit) {
      error
      data {
        has_next_page
        lastcursor
        total_data
        comment {
          id
          userID
          userName
          userPhoto
          comment
          isKol
          create_time
          isCommentOwner
        }
      }
    }
  }
`

export const CommentsWithData = graphql(GetKOLListComment, {
  options: props => ({
    variables: {
      idPost: props.cardState.cardID,
      cursor: '',
      limit: 10,
    },
    fetchPolicy: 'network-only',
  }),
  props: result => {
    if (!result.data.loading) {
      return {
        hasNextPage: result.data.get_kol_list_comment.data.has_next_page,
        lastCursor: result.data.get_kol_list_comment.data.lastCursor,
        comments: _.reverse([...result.data.get_kol_list_comment.data.comment]),
        isLoading: false,
        loadMoreEntries: () =>
          result.data.fetchMore({
            query: GetKOLListComment,
            variables: {
              idPost: result.ownProps.cardState.cardID,
              cursor: result.data.get_kol_list_comment.data.lastcursor,
              limit: 10,
            },
            updateQuery: (
              previousResult,
              { fetchMoreResult: { get_kol_list_comment } },
            ) => ({
              get_kol_list_comment: {
                ...get_kol_list_comment,
                data: {
                  ...get_kol_list_comment.data,
                  comment: [
                    ...previousResult.get_kol_list_comment.data.comment,
                    ...get_kol_list_comment.data.comment,
                  ],
                },
              },
            }),
          }),
      }
    }

    return {}
  },
})

const SendComment = gql`
  mutation SendComment($idPost: Int!, $comment: String) {
    create_comment_kol(idPost: $idPost, comment: $comment) {
      error
      data {
        id
        user {
          iskol
          id
          name
          photo
        }
        comment
        create_time
      }
    }
  }
`

export const SendCommentWithData = graphql(SendComment, {
  props: ({ ownProps, mutate }) => ({
    createComment: ({ idPost, comment }) =>
      mutate({
        variables: { idPost, comment },
        update: (proxy, result) => {
          const oldData = proxy.readQuery({
            query: GetKOLListComment,
            variables: {
              idPost: ownProps.cardState.cardID,
              cursor: '',
              limit: 10,
            },
          })

          if (result.data.create_comment_kol.error !== null) {
            ReactInteractionHelper.showErrorStickyAlert(
              'Mohon maaf, terjadi kendala pada server. Silakan coba kembali.',
            )
            return
          }

          const newData = {
            id: result.data.create_comment_kol.data.id,
            comment: result.data.create_comment_kol.data.comment,
            create_time: result.data.create_comment_kol.data.create_time,
            isKol: result.data.create_comment_kol.data.user.iskol,
            userID: result.data.create_comment_kol.data.user.id,
            userName: result.data.create_comment_kol.data.user.name,
            userPhoto: result.data.create_comment_kol.data.user.photo,
            isCommentOwner: true,
            __typename: 'CommentDetailType',
          }

          oldData.get_kol_list_comment.data.comment.unshift(newData)

          proxy.writeQuery({ query: GetKOLListComment, data: oldData })
        },
        refetchQueries: [
          {
            query: GetKOLListComment,
            variables: {
              idPost: ownProps.cardState.cardID,
              cursor: '',
              limit: 10,
            },
          },
        ],
      }),
  }),
})

const DeleteComment = gql`
  mutation DeleteComment($idComment: Int!) {
    delete_comment_kol(idComment: $idComment) {
      error
      data {
        success
      }
    }
  }
`

export const DeleteCommentWithData = graphql(DeleteComment, {
  props: ({ ownProps, mutate }) => ({
    deleteComment: ({ idComment }) =>
      mutate({
        variables: { idComment },
        refetchQueries: [
          {
            query: GetKOLListComment,
            variables: {
              idPost: ownProps.cardState.cardID,
              cursor: '',
              limit: 10,
            },
          },
        ],
      }),
  }),
})
