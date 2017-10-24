import React from 'react'
import Grid from '../common/grid/grid'

const brandGrid = props => {
  const isFetching = props.brands.isFetching
  const totalBrands = props.brands.totalBrands
  const totalItemsCount = props.brands.items.length
  let canFetch = true
  if (totalBrands !== 0 && totalBrands === totalItemsCount) {
    canFetch = false
  }
  return (
    <Grid
      data={props.brands.grid.data}
      rows={3}
      columns={3}
      onLoadMore={props.loadMore}
      onSlideMore={props.slideMore}
      limit={props.limit}
      offset={props.offset}
      canFetch={canFetch}
      isFetching={isFetching}
    />
  )
}

export default brandGrid
