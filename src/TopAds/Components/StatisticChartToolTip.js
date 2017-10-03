import React from 'react'
import { G, Rect, Polygon, Text } from 'react-native-svg'
import color from '../Helper/Color'

const StatisticChartToolTip = ({ x, y, datum }) => {
  const len = datum.valueText.length
  const adders = (len < 5 ? 5 : len) * 5.8
  const containerWidth = 20 + adders

  const arrow1stPoint = `${containerWidth / 2 - 6},43`
  const arrow2ndPoint = `${containerWidth / 2 + 6},43`
  const arrow3rdPoint = `${containerWidth / 2}, 50`

  const arrowPoints = `${arrow1stPoint} ${arrow2ndPoint} ${arrow3rdPoint}`

  const centerX = x - containerWidth / 2
  const centerY = y - 55

  return (
    <G>
      <Rect
        x={centerX}
        y={centerY}
        rx="2"
        ry="2"
        height="44"
        width={containerWidth}
        fill={color.tooltipBlack}
      />
      <Polygon
        x={centerX}
        y={centerY}
        rx="2"
        ry="2"
        points={arrowPoints}
        fill={color.tooltipBlack}
        strokeLinecap="round"
        strokeLinejoin="round"
        stroke={color.tooltipBlack}
        strokeWidth="4"
      />
      <Text
        x={centerX + 10}
        y={centerY + 7}
        fontSize="10"
        fill={color.tooltipGrey}
      >
        {datum.dateText}
      </Text>
      <Text x={centerX + 10} y={centerY + 21} fontSize="11" fill="white">
        {datum.valueText}
      </Text>
    </G>
  )
}

module.exports = StatisticChartToolTip
