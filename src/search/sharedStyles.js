import { StyleSheet } from 'react-native'

export default StyleSheet.create({
  flexContainer: {
    flex: 1,
    alignItems: 'stretch',
    justifyContent: 'center',
  },
  container: {
    backgroundColor: '#e1e1e1',
    flex: 1,
  },
  panel: {
    marginBottom: 1,
    height: 64,
    backgroundColor: 'white',
  },
  sideBySide: {
    marginTop: 22,
    marginBottom: 22,
    marginLeft: 15,
    marginRight: 15,
    flex: 1,
    alignItems: 'center',
    flexDirection: 'row',
    justifyContent: 'space-between',
  },
  textLabel: {
    fontSize: 17,
  },
  iconForward: {
    tintColor: 'rgb(66, 181, 73)',
    width: 14,
    height: 14,
    marginTop: 2,
    marginRight: 2,
  },
  badgeAndTextContainer: {
    flex: 1,
    alignItems: 'center',
    flexDirection: 'row',
    justifyContent: 'flex-start',
  },
  badgeImage: {
    marginLeft: 10,
    width: 16,
    height: 16,
  },
})
