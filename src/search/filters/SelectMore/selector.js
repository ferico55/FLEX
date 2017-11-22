import createCachedSelector from 're-reselect'
import { getFormValues } from 'redux-form'
import fpRaw from 'lodash/fp'
import { createSelectorCreator, defaultMemoize, createSelector } from 'reselect'
import formName from '../../formName'
import getCheckBoxValuesFromFilters from '../getCheckBoxValuesFromFilters'
import categoryValuesFromFilter from '../../filters/categoryValuesFromFilter'

const fp = fpRaw.convert({ cap: false })
const createDeepEqualSelector = createSelectorCreator(
  defaultMemoize,
  fp.isEqual,
)

const formValuesSelector = getFormValues(formName)
const filterKeysSelector = createCachedSelector(
  (_, props) => props.filter,
  filter =>
    fp.uniq(filter.options.map(option => fp.first(option.key.split('[')))),
)((_, props) => props.filter.filterIndex)

const formValuesSubsetSelector = createCachedSelector(
  [formValuesSelector, filterKeysSelector],
  (form, filterKeys) => fp.pick(filterKeys, form),
)((_, props) => props.filter.filterIndex)

const formValuesSubsetDeepEqualSelector = createCachedSelector(
  formValuesSubsetSelector,
  formValuesSubset => formValuesSubset,
)((_, props) => props.filter.filterIndex, {
  selectorCreator: createDeepEqualSelector,
})

const checkBoxValuesSelector = createCachedSelector(
  (_, props) => props.filter,
  filter => getCheckBoxValuesFromFilters([filter]),
)((_, props) => props.filter.filterIndex)
const categoryValuesFromFilterSelector = createSelector(
  (_, props) => props.filter,
  filter => categoryValuesFromFilter(filter),
)
export const categorySelector = createSelector(
  [formValuesSubsetDeepEqualSelector, categoryValuesFromFilterSelector],
  (formValues, categoryValues) => ({
    values: formValues.sc.map(value => categoryValues[value]),
  }),
)
export const selector = createCachedSelector(
  [formValuesSubsetDeepEqualSelector, checkBoxValuesSelector],
  (values, checkBoxValues) => ({
    values: fp.flow([
      fp.mapValues((valueArray, key) =>
        fp.flow([
          fp.map(
            (value, index) => value && fp.get([key, index], checkBoxValues),
          ),
          fp.map(
            (value, index) =>
              value && { ...value, key: `${value.key}[${index}]` },
          ),
        ])(valueArray),
      ),
      fp.toArray,
      fp.flatten,
      fp.compact,
    ])(values),
  }),
)((_, props) => props.filter.filterIndex)
