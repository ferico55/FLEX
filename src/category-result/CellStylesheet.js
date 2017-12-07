import { StyleSheet } from 'react-native'

module.exports = StyleSheet.create({
  thumbnailImageGrid: {
    resizeMode: 'cover',
    aspectRatio: 1.0,
    marginTop: 10,
    marginLeft: 10,
    marginRight: 10,
    marginBottom: 4,
    borderRadius: 3,
  },
  thumbnailImageList: {
    resizeMode: 'cover',
    aspectRatio: 1.0,
    width: 117,
    marginTop: 10,
    marginLeft: 10,
    marginRight: 2,
    marginBottom: 4,
    borderRadius: 3,
  },
  productName: {
    color: 'rgba(0,0,0,0.7)',
    fontSize: 13,
    fontWeight: '600',
    marginLeft: 10,
    marginRight: 10,
  },
  productPrice: {
    color: 'rgba(255,87,34,1)',
    fontSize: 13,
    fontWeight: '600',
    marginLeft: 10,
    marginBottom: 4,
  },
  shopName: {
    marginLeft: 10,
    marginBottom: 3.4,
  },
  shopNameHTML: {
    color: 'rgba(0,0,0,0.54)',
    fontSize: 11,
  },
  shopLocation: {
    color: 'rgba(0,0,0,0.38)',
    fontSize: 11,
    marginLeft: 2,
  },
  discussion: {
    alignSelf: 'flex-end',
    color: 'rgba(0,0,0,0.54)',
    fontSize: 11,
    marginRight: 10,
  },
})
