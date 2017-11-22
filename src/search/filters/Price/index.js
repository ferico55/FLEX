// @flow
import React from 'react'
import { View, Text, TextInput, Dimensions } from 'react-native'
import { connect } from 'react-redux'
import { Fields } from 'redux-form'
import fp from 'lodash/fp'
import { createSelector } from 'reselect'
import MultiSlider from './MultiSlider'
import numeral from './numeral'
import CheckboxFieldOrFields from '../../inputs/CheckboxFieldOrFields'
import styles from './styles'
import createExponentialRange, { levels } from './createExponentialRange'
import initialValuesFromDynamicFilterData from '../initialValuesFromDynamicFilterData'
import { actions, dispatch } from '../../redux'

const multiSliderWidth = Dimensions.get('window').width - 90
const textToNumer = value => Math.abs(numeral(value).value() || 0)

const handleOnChangeMin = value => {
  dispatch(actions.price.set({ min: textToNumer(value) }))
}

const handleOnChangeMax = value => {
  dispatch(actions.price.set({ max: textToNumer(value) }))
}

class Price extends React.Component {
  constructor(props) {
    super(props)
    const { pminLimit: min, pmaxLimit: max } = props
    this.rangeValues = createExponentialRange({ min, max })
    this.handleMultiSliderValuesChange = this.handleMultiSliderValuesChange.bind(
      this,
    )
    this.rangeToPrice = this.rangeToPrice.bind(this)
    this.handleOnEndEditingMin = this.handleOnEndEditingMin.bind(this)
    this.handleOnEndEditingMax = this.handleOnEndEditingMax.bind(this)
    this.priceToRangeValue = this.priceToRangeValue.bind(this)
    this.inLimit = this.inLimit.bind(this)
    this.props.priceRef(this)
  }

  props: {
    priceRef: Function,
    handleEnableScroll: Function,
    handleDisableScroll: Function,
    pminName: string,
    pmaxName: string,
    priceMin: number,
    priceMax: number,
    pmin: {
      meta: {
        active: boolean,
      },
      input: {
        onFocus: Function,
        onBlur: Function,
        onChange: Function,
        value: string,
      },
    },
    pmax: {
      meta: {
        active: boolean,
      },
      input: {
        onFocus: Function,
        onBlur: Function,
        onChange: Function,
        value: string,
      },
    },
    filter: {
      options: Array<Object>,
    },
    pmaxLimit: number,
    pminLimit: number,
  }
  prepareForUnmount() {
    const minActive = this.props.pmin.meta.active
    const maxActive = this.props.pmax.meta.active

    if (minActive) {
      this.handleOnEndEditingMin()
    }
    if (maxActive) {
      this.handleOnEndEditingMax()
    }
  }
  rangeToPrice(range) {
    return this.rangeValues[range]
  }
  handleMultiSliderValuesChange({ min: minRange, max: maxRange, equal }) {
    const { pmin, pmax, priceMin, priceMax } = this.props
    if (minRange !== undefined) {
      const min = equal ? priceMax : this.rangeToPrice(minRange)
      dispatch(actions.price.set({ min }))
      pmin.input.onChange(min)
    }
    if (maxRange !== undefined) {
      const max = equal ? priceMin : this.rangeToPrice(maxRange)
      dispatch(actions.price.set({ max }))
      pmax.input.onChange(max)
    }
  }

  handleOnEndEditingMin() {
    const {
      pmin: { input: { onChange } },
      priceMin: value,
      pmax,
      pminLimit,
      pmaxLimit,
    } = this.props
    const validValue = fp.clamp(pminLimit, pmaxLimit, value)
    const newState = { min: validValue }
    if (validValue > pmax.input.value) {
      pmax.input.onChange(validValue)
      newState.max = validValue
    }
    dispatch(actions.price.set(newState))
    onChange(validValue)
  }
  handleOnEndEditingMax() {
    const {
      pmax: { input: { onChange } },
      pmin,
      pminLimit,
      pmaxLimit,
      priceMax: value,
    } = this.props
    const validValue = fp.clamp(pminLimit, pmaxLimit, value)
    const newState = { max: validValue }
    if (validValue < pmin.input.value) {
      pmin.input.onChange(validValue)
      newState.min = validValue
    }
    dispatch(actions.price.set(newState))
    onChange(validValue)
  }
  priceToRangeValue(price) {
    const firstIndex = 0
    const lastIndex = this.rangeValues.length - 1

    const exactIndex = fp.findIndex(
      rangeValue => rangeValue === price,
      this.rangeValues,
    )
    if (exactIndex > -1) {
      return exactIndex
    }
    const indexBigger = fp.findIndex(
      rangeValue => rangeValue > price,
      this.rangeValues,
    )
    if (indexBigger === -1) {
      return lastIndex
    }
    if (indexBigger === 0) {
      return firstIndex
    }
    const indexSmaller = indexBigger - 1
    if (indexSmaller === firstIndex) {
      return indexBigger
    }
    if (indexBigger === lastIndex) {
      return indexSmaller
    }
    return this.rangeValues[indexBigger] - price >
    price - this.rangeValues[indexSmaller]
      ? indexSmaller
      : indexBigger
  }
  inLimit(number) {
    const { pmaxLimit, pminLimit } = this.props
    return number >= pminLimit && number <= pmaxLimit
  }
  render() {
    const {
      filter: { options },
      pminName,
      pmaxName,
      pmin: { input: { onFocus: onFocusMin, value: reduxValueMin } },
      pmax: { input: { onFocus: onFocusMax, value: reduxValueMax } },
      priceMin: min,
      priceMax: max,
    } = this.props
    const { wholesale } = fp.flow([fp.keyBy('originalKey')])(options)

    const minStyle = [styles.hargaValueMin]
    if (!this.inLimit(min)) {
      minStyle.push(styles.invalid)
    }
    const maxStyle = [styles.hargaValueMax]
    if (!this.inLimit(max)) {
      maxStyle.push(styles.invalid)
    }

    return (
      <View>
        <View style={styles.hargaPanel}>
          <View style={styles.hargaPanelContainer}>
            <View style={styles.hargaPanelContainerMin}>
              <Text style={styles.hargaTypeLabelMin}>{pminName}</Text>
              <TextInput
                {...{
                  onFocus: onFocusMin,
                  keyboardType: 'numeric',
                  style: minStyle,
                  onChangeText: handleOnChangeMin,
                  value: numeral(min).format('$ 0,0'),
                  onEndEditing: this.handleOnEndEditingMin,
                }}
              />
              <View style={styles.hargaUnderline} />
            </View>
            <View style={styles.hargaDivider} />
            <View style={styles.hargaPanelContainerMax}>
              <Text style={styles.hargaTypeLabelMax}>{pmaxName}</Text>
              <TextInput
                {...{
                  onFocus: onFocusMax,
                  keyboardType: 'numeric',
                  style: maxStyle,
                  onChangeText: handleOnChangeMax,
                  value: numeral(max).format('$ 0,0'),
                  onEndEditing: this.handleOnEndEditingMax,
                }}
              />
              <View style={styles.hargaUnderline} />
            </View>
          </View>
        </View>
        <View style={styles.hargaPanelSlider}>
          <MultiSlider
            onValuesChangeStart={this.props.handleDisableScroll}
            onValuesChangeFinish={this.props.handleEnableScroll}
            containerStyle={styles.multiSlider}
            selectedStyle={styles.multiSliderTrack}
            values={[
              this.priceToRangeValue(reduxValueMin),
              this.priceToRangeValue(reduxValueMax),
            ]}
            sliderLength={multiSliderWidth}
            onValuesChange={this.handleMultiSliderValuesChange}
            min={0}
            max={levels - 1}
            step={1}
            snapped
            allowOverlap
          />
        </View>
        {wholesale ? (
          <View>
            <CheckboxFieldOrFields option={wholesale} />
          </View>
        ) : null}
      </View>
    )
  }
}

const pminmaxNamesFromDynamicFilterData = fp.flow([
  fp.get('filter'),
  fp.find(({ template_name }) => template_name === 'template_price'),
  fp.get('options'),
  fp.groupBy('originalKey'),
  fp.mapValues(fp.get('[0].name')),
  fp.pick(['pmin', 'pmax']),
])

const pminMaxLimitSelector = createSelector(
  ({ dynamicFilterData, uniqueIdAndSource }) =>
    dynamicFilterData[uniqueIdAndSource],
  dynamicFilterData => {
    const {
      pmin: pminLimit,
      pmax: pmaxLimit,
    } = initialValuesFromDynamicFilterData(dynamicFilterData)
    const {
      pmin: pminName,
      pmax: pmaxName,
    } = pminmaxNamesFromDynamicFilterData(dynamicFilterData)

    return { pminLimit, pminName, pmaxLimit, pmaxName }
  },
)

export default connect(
  createSelector(
    pminMaxLimitSelector,
    ({ price: { min } }) => min,
    ({ price: { max } }) => max,
    (pminMaxLimit, priceMin, priceMax) => ({
      ...pminMaxLimit,
      priceMin,
      priceMax,
    }),
  ),
)(props => (
  <Fields
    {...{
      names: ['pmin', 'pmax'],
      props,
      component: Price,
    }}
  />
))
