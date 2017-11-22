import { StyleSheet } from 'react-native'

// To calcluate scrollToIndex for flatView
export const separatorHeight = 52

export default StyleSheet.create({
  container: {
    backgroundColor: '#e1e1e1',
    flex: 1,
    flexDirection: 'column',
    justifyContent: 'space-between',
  },
  notFoundIcon: {
    width: 200,
    height: 107,
    marginBottom: 20,
    marginTop: 20,
  },
  notFoundHeader: {
    fontSize: 16,
  },
  notFoundText: {
    padding: 10,
    color: 'grey',
  },
  notFoundContainer: {
    paddingTop: 10,
    backgroundColor: 'white',
    flex: 1,
    alignItems: 'center',
    justifyContent: 'flex-start',
  },
  separator: {
    height: separatorHeight,
    alignItems: 'flex-start',
    justifyContent: 'center',
    paddingLeft: 10,
  },
  separatorPopular: {
    height: separatorHeight - 15,
    alignItems: 'flex-start',
    justifyContent: 'flex-start',
    paddingLeft: 10,
  },
  separatorText: {
    fontSize: 14,
  },
})
