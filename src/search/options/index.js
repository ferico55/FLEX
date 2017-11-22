// @flow
import Navigator from 'native-navigation'
import React from 'react'
import {
  FlatList,
  Keyboard,
  View,
  Text,
  Image,
  TouchableWithoutFeedback,
} from 'react-native'
import { connect } from 'react-redux'
import { batchActions } from 'redux-batched-actions'
import fpRaw from 'lodash/fp'
import { change, getFormValues } from 'redux-form'
import Apply from '../Apply'
import formConnector from '../HOC/formConnector'
import provider from '../HOC/provider'
import SearchBar from './SearchBar'
import { dispatch, getState, actions } from '../redux'
import Category from './Category'
import formName from '../formName'
import initialValuesFromDynamicFilterData from '../filters/initialValuesFromDynamicFilterData'
import AlphabetSidebar from './AlphabetSidebar'
import styles, { separatorHeight } from './styles'
import selector from './selector'
import LetterHeader from './LetterHeader'
import RenderItem from './RenderItem'
import NoConnectionBar from '../NoConnectionBar'

const fp = fpRaw.convert({
  cap: false,
})

const rowHeight = 64
const separatorHeightDiff = rowHeight - separatorHeight - 1 // -1 for margin
const handleOnApply = () => Navigator.pop()
const formValuesSelector = getFormValues(formName)
const iconNotFound = { uri: 'search-page1' }

const leftImage = {
  uri: 'icon_cancel_grey',
  scale: 1.5,
}

const handleKeyboardDismiss = Keyboard.dismiss
const ListOfOptions = provider(
  formConnector(
    connect(selector, {
      handleOnSearchChange: actions.optionsSearch.set,
      handleOnSearchClear: actions.optionsSearch.clear,
    })(
      class ListOfOptions extends React.Component {
        constructor(props) {
          super(props)
          this.getItemLayout = this.getItemLayout.bind(this)
          this.handleOnLeftPress = this.handleOnLeftPress.bind(this)
          this.handleOnRightPress = this.handleOnRightPress.bind(this)
          this.setFlatListRef = this.setFlatListRef.bind(this)
          this.handleLetterSelect = this.handleLetterSelect.bind(this)
          this.renderHeader = this.renderHeader.bind(this)
          this.onKeyboardShow = this.onKeyboardShow.bind(this)
          this.onKeyboardHide = this.onKeyboardHide.bind(this)
          Keyboard.addListener('keyboardDidShow', this.onKeyboardShow)
          Keyboard.addListener('keyboardWillHide', this.onKeyboardHide)

          this.state = {
            keyboardShown: false,
          }

          const thisFormKeys = this.props.options.map(option => option.key)

          this.lastValues = fp.flow([
            formValuesSelector,
            fp.pick(thisFormKeys),
          ])(getState())
        }
        componentWillUnmount() {
          dispatch(actions.optionsSearch.clear())
          Keyboard.removeListener('keyboardDidShow', this.onKeyboardShow)
          Keyboard.removeListener('keyboardWillHide', this.onKeyboardHide)
        }
        onKeyboardShow({ endCoordinates: { height } }) {
          this.setState({ keyboardShown: height })
        }
        onKeyboardHide() {
          this.setState({ keyboardShown: false })
        }
        getItemLayout(data, index) {
          const { headersByLetter, popular } = this.props
          const howManySeparatorsBeforeThisIndex = headersByLetter.filter(
            ({ index: indexLocal }) => indexLocal < index,
          ).length
          const popularOffset = popular.length
            ? popular.length * rowHeight + separatorHeight - 15
            : 0
          const offset =
            index * rowHeight -
            howManySeparatorsBeforeThisIndex * separatorHeightDiff +
            popularOffset
          // - (Dimensions.get('window').height - 64 * 4) / 2

          return {
            index,
            offset,
            length: rowHeight,
          }
        }
        props: {
          connectionState: string,
          handleOnSearchChange: Function,
          handleOnSearchClear: Function,
          search: string,
          popular: Array<Object>,
          options: Array<{ key: string, name: string, input_type: string }>,
          headersByLetter: Array<{ value: string, index: number }>,
          filter: {
            title: string,
            template_name: string,
            search: {
              seachable: number,
            },
          },
        }
        lastValues = {}
        handleOnRightPress() {
          const state = getState()
          const values = initialValuesFromDynamicFilterData(
            state.dynamicFilterData[state.uniqueIdAndSource],
          )
          dispatch(
            batchActions(
              this.props.options.map(option =>
                change(formName, option.key, fp.get(option.key, values)),
              ),
            ),
          )
        }
        handleOnLeftPress() {
          dispatch(
            batchActions([
              ...fp.map((value, key) => change(formName, key, value))(
                this.lastValues,
              ),
            ]),
          )

          Navigator.pop()
        }
        handleLetterSelect(letter) {
          const { headersByLetter } = this.props
          const { index } =
            headersByLetter.find(({ value }) => value >= letter) ||
            fp.last(headersByLetter)

          this.flatListRef.scrollToIndex({
            animated: false,
            index,
          })
        }

        renderHeader() {
          const { popular, search: { length } } = this.props
          if (
            this.props.filter.template_name === 'template_brand' &&
            !length &&
            popular &&
            popular.length
          ) {
            return (
              <View>
                <LetterHeader
                  letter="Populer"
                  style={styles.separatorPopular}
                />
                {popular.map(item => <RenderItem key={item.key} item={item} />)}
              </View>
            )
          }
          return null
        }

        setFlatListRef(el) {
          this.flatListRef = el
        }

        render() {
          const {
            handleLetterSelect,
            state: { keyboardShown },
            props: {
              connectionState,
              handleOnSearchChange,
              handleOnSearchClear,
              search,
              options,
              filter: {
                title,
                template_name,
                search: { searchable, placeholder },
              },
            },
          } = this

          if (template_name === 'template_category') {
            return (
              <Category
                {...this.props}
                leftImage={leftImage}
                onLeftPress={this.handleOnLeftPress}
              />
            )
          }

          return (
            <View
              style={[
                styles.container,
                keyboardShown ? { paddingBottom: keyboardShown } : {},
              ]}
            >
              {
                <Navigator.Config
                  {...{
                    title,
                    leftImage,
                    onLeftPress: this.handleOnLeftPress,
                    rightTitle: 'Reset',
                    rightTitleColor: 'rgb(66,181,73)',
                    onRightPress: this.handleOnRightPress,
                  }}
                />
              }
              {connectionState === 'none' ? <NoConnectionBar /> : null}
              {searchable ? (
                <SearchBar
                  onChange={handleOnSearchChange}
                  onClear={handleOnSearchClear}
                  search={search}
                  placeholder={placeholder}
                />
              ) : null}
              {options.length ? (
                <FlatList
                  initialNumToRender={15}
                  ref={this.setFlatListRef}
                  getItemLayout={this.getItemLayout}
                  data={options}
                  renderItem={RenderItem}
                  ListHeaderComponent={this.renderHeader}
                />
              ) : (
                <TouchableWithoutFeedback onPress={handleKeyboardDismiss}>
                  <View style={styles.notFoundContainer}>
                    <Image source={iconNotFound} style={styles.notFoundIcon} />
                    <Text style={styles.notFoundHeader}>
                      Oops tidak ditemukan
                    </Text>
                    <Text style={styles.notFoundText}>
                      Hasil pencarian untuk {`"${search}"`} tidak ditemukan
                    </Text>
                  </View>
                </TouchableWithoutFeedback>
              )}
              {!keyboardShown && options.length ? (
                <Apply onPress={handleOnApply} label="Simpan" />
              ) : null}
              {template_name === 'template_brand' &&
              !search.length &&
              !keyboardShown ? (
                <AlphabetSidebar onSelect={handleLetterSelect} />
              ) : null}
            </View>
          )
        }
      },
    ),
  ),
)

Navigator.registerScreen('ListOfOptions', () => ListOfOptions)
