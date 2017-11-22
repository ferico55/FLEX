import { StyleSheet, Dimensions } from 'react-native'

const hargaUnderlineWidth = (Dimensions.get('window').width - 67) / 2

export default StyleSheet.create({
  hargaDivider: {
    backgroundColor: '#e0e0e0',
    width: 7,
    height: 1,
    marginTop: 54,
  },
  hargaUnderline: {
    marginTop: 10,
    height: 2,
    width: hargaUnderlineWidth,
    backgroundColor: '#e0e0e0',
  },
  hargaPanel: {
    flex: 1,
    height: 97,
    backgroundColor: 'white',
  },
  hargaPanelSlider: {
    flex: 1,
    height: 74,
    backgroundColor: 'white',
  },
  hargaPanelContainer: {
    flex: 1,
    flexDirection: 'row',
    justifyContent: 'space-between',
    alignItems: 'flex-start',
  },
  hargaPanelContainerMin: {
    flex: 1,
    alignItems: 'flex-start',
    paddingLeft: 15,
  },
  hargaPanelContainerMax: {
    flex: 1,
    alignItems: 'flex-end',
    paddingRight: 15,
  },
  hargaTypeLabelMin: {
    fontSize: 12,
    color: 'grey',
    marginBottom: 5,
    marginTop: 22,
  },
  hargaTypeLabelMax: {
    textAlign: 'right',
    fontSize: 12,
    color: 'grey',
    marginBottom: 5,
    marginTop: 22,
  },
  hargaValueMin: {
    fontSize: 17,
    width: hargaUnderlineWidth,
  },
  hargaValueMax: {
    textAlign: 'right',
    fontSize: 17,
    width: hargaUnderlineWidth,
  },
  invalid: {
    color: 'red',
  },
  multiSlider: {
    flex: 1,
    justifyContent: 'center',
    alignItems: 'center',
  },
  multiSliderTrack: {
    backgroundColor: '#66b573',
    borderWidth: 2,
    borderColor: '#66b573',
  },
})
