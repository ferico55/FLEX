import React from 'react'
import { View, StyleSheet } from 'react-native'
import PropTypes from 'prop-types'
import Row from './row'

const Grid = ({ columns, data, onLoadMore, rows, limit, offset, onSlideMore, isFetching, canFetch }) => {
  if (data.length === 0) {
    return null
  }
  let lastRow = false
  const rowsArray = []
  let rowData = null

  for (let i = 0; i < rows; i++) {
    if (i === rows - 1) {
      lastRow = true
    }
    rowData = data.slice(i * columns, columns * i + columns)
    rowsArray.push(<Row
      cells={columns}
      key={i}
      lastRow={lastRow}
      rowData={rowData}
      onLoadMore={onLoadMore}
      limit={limit}
      offset={offset}
      onSlideMore={onSlideMore}
      canFetch={canFetch}
      isFetching={isFetching}
    />)
  }

  return (
    <View style={styles.container}>
      {rowsArray}
    </View>
  )
}

const styles = StyleSheet.create({
  container: {
    backgroundColor: '#fff'
  }
})

Grid.propTypes = {
  rows: PropTypes.number,
  columns: PropTypes.number,
  data: PropTypes.array,
  onLoadMore: PropTypes.func,
}

export default Grid