import React from 'react'
import { View, StyleSheet } from 'react-native'
import PropTypes from 'prop-types'
import Cell from './cell'

const Row = ({ cells, lastRow, rowData, onLoadMore, limit, offset, onSlideMore, canFetch, isFetching }) => {
  let isLastCell = false
  const cellArray = []

  for (let i = 0; i < cells; i++) {
    if (i === cells - 1) {
      isLastCell = true
    }

    cellArray.push(<Cell
      key={i}
      isLastRowCell={lastRow}
      isLastCell={isLastCell}
      data={rowData[i]}
      loadMore={onLoadMore}
      limit={limit}
      onSlideMore={onSlideMore}
      canFetch={canFetch}
      isFetching={isFetching}
      offset={offset} />)
  }
  return (
    <View style={styles.container}>
      {cellArray}
    </View>
  )
}

const styles = StyleSheet.create({
  container: {
    borderTopWidth: 1,
    borderColor: '#e0e0e0',
    flexGrow: 1,
    flexDirection: 'row',
    alignItems: 'center'
  }
})

export default Row