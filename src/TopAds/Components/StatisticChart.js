import React, { Component } from 'react'
import chunk from 'lodash/chunk'
import take from 'lodash/take'
import first from 'lodash/first'
import last from 'lodash/last'
import { StyleSheet, Text, View, ActivityIndicator } from 'react-native'
import {
  VictoryLine,
  VictoryScatter,
  VictoryArea,
  VictoryChart,
  VictoryVoronoiContainer,
  VictoryTooltip,
  VictoryTheme,
  VictoryAxis,
} from 'victory-native'
import moment from 'moment'
import StatisticChartToolTip from './StatisticChartToolTip'
import color from '../Helper/Color'

const styles = StyleSheet.create({
  separator: {
    height: 1,
    backgroundColor: color.lineGrey,
  },
  chartHeaderView: {
    backgroundColor: 'white',
    flexDirection: 'row',
    alignItems: 'center',
    paddingHorizontal: 20,
    paddingTop: 20,
  },
  chartHeaderLabel: {
    marginRight: 5,
    fontSize: 14,
    color: color.greyText,
  },
  chartContainer: {
    justifyContent: 'center',
    alignItems: 'center',
    backgroundColor: 'white',
  },
})

class StatisticChart extends Component {
  generateGraphData(rawArray, selectedTabIndex) {
    if (rawArray.length < 1) {
      return {
        data: [],
        dataFMT: [],
        domain: {
          x: [],
          y: [],
        },
        tickValues: {
          x: [],
          y: [],
        },
      }
    }

    const dataArray = rawArray.map(data => {
      const stringDate = `${data['date.day']}-${data['date.month']}-${data[
        'date.year'
      ]}`
      const momentDate = moment(stringDate, 'D-M-YYYY')
      const xData = {
        value: momentDate.valueOf(),
        fmt: momentDate.format('D MMM'),
      }

      let tempValue
      let tempFMT

      switch (selectedTabIndex) {
        case 0:
          tempValue = data.impression_sum
          tempFMT = data.impression_sum_fmt
          break
        case 1:
          tempValue = data.click_sum
          tempFMT = data.click_sum_fmt
          break
        case 2:
          tempValue = Math.round(data.ctr_percentage * 100) / 100
          tempFMT = data.ctr_percentage_fmt
          break
        case 3:
          tempValue = data.conversion_sum
          tempFMT = data.conversion_sum_fmt
          break
        case 4:
          tempValue = Math.round(data.cost_avg * 10) / 10
          tempFMT = data.cost_avg_fmt
          break
        case 5:
          tempValue = Math.round(data.cost_sum * 10) / 10
          tempFMT = data.cost_sum_fmt
          break
        default:
          tempValue = 0
          tempFMT = 0
      }

      const yData = {
        value: tempValue,
        fmt: tempFMT,
      }

      return {
        xData,
        yData,
      }
    })

    const sortedYValues = dataArray
      .map(data => data.yData.value)
      .sort((a, b) => a - b)
    const tempMaxYDomain =
      sortedYValues[sortedYValues.length - 1] +
      sortedYValues[sortedYValues.length - 1] / 4
    let maxYDomain = tempMaxYDomain === 0 ? 100 : tempMaxYDomain

    let headerText = ''
    let valueText = ''

    switch (selectedTabIndex) {
      case 0:
        headerText = 'Jumlah orang yang melihat promo Anda.'
        valueText = ' Tampil'
        maxYDomain =
          tempMaxYDomain === 0 || tempMaxYDomain < 10 ? 10 : tempMaxYDomain
        break
      case 1:
        headerText = 'Jumlah klik pada promo Anda.'
        valueText = ' Klik'
        maxYDomain =
          tempMaxYDomain === 0 || tempMaxYDomain < 10 ? 10 : tempMaxYDomain
        break
      case 2:
        headerText =
          'Perbandingan orang yang melihat promo Anda dengan jumlah klik pada promo tersebut.'
        valueText = '%'
        maxYDomain = tempMaxYDomain === 0 ? 100 : tempMaxYDomain
        break
      case 3:
        headerText = 'Jumlah favorit/transaksi dari promo Anda.'
        valueText = ' Konversi'
        maxYDomain =
          tempMaxYDomain === 0 || tempMaxYDomain < 10 ? 10 : tempMaxYDomain
        break
      case 4:
        headerText = 'Biaya rata-rata yang Anda bayarkan untuk setiap klik.'
        valueText = 'Rp'
        maxYDomain = tempMaxYDomain === 0 ? 1000 : tempMaxYDomain
        break
      case 5:
        headerText = 'Jumlah anggaran yang telah terpakai untuk promosi ini.'
        valueText = 'Rp'
        maxYDomain = tempMaxYDomain === 0 ? 1000 : tempMaxYDomain
        break
      default:
        headerText = ''
        valueText = ''
        maxYDomain = 50
    }

    const domainY = [0, maxYDomain]

    let domainX = [
      dataArray[0].xData.value,
      dataArray[dataArray.length - 1].xData.value,
    ]
    if (dataArray.length === 1) {
      const startDomainValue = moment(dataArray[0].xData.value)
        .subtract(1, 'month')
        .valueOf()
      const endDomainValue = moment(dataArray[0].xData.value)
        .add(1, 'month')
        .valueOf()

      domainX = [startDomainValue, endDomainValue]
    }

    return {
      headerText,
      data: dataArray.map(data => {
        const tempValueText =
          selectedTabIndex > 3
            ? `${valueText} ${data.yData.value}`
            : `${data.yData.value}${valueText}`
        return {
          x: data.xData.value,
          y: data.yData.value,
          dateText: moment(data.xData.value).format('D MMM'),
          valueText: tempValueText,
        }
      }),
      dataFMT: dataArray.map(data => ({
        x: data.xData.fmt,
        y: data.yData.fmt,
      })),
      domain: {
        x: domainX,
        y: domainY,
      },
      tickValues: {
        x: this.generateTickValuesX(dataArray.map(data => data.xData.value)),
        y: [], // unused
      },
    }
  }
  generateTickValuesX = dataArray => {
    if (dataArray.length <= 7) {
      return dataArray
    }
    const chunkNum = dataArray.length / 6
    const chunkedArray = chunk(dataArray, chunkNum)
    const firstItems = chunkedArray.map(first)
    const data = [].concat(take(firstItems, 6), last(dataArray))

    return data
  }
  kFormatter = num => {
    let tempNum = num
    if (num > 999999) {
      tempNum = (num / 1000000).toFixed(1)
      tempNum = tempNum % 1 > 0.0 ? tempNum : (num / 1000000).toFixed(0)
      return `${tempNum}jt`
    } else if (num > 999) {
      tempNum = (num / 1000).toFixed(1)
      tempNum = tempNum % 1 > 0.0 ? tempNum : (num / 1000).toFixed(0)
      return `${tempNum}rb`
    }

    return num
  }
  render() {
    const graphData = this.generateGraphData(
      this.props.dataSource,
      this.props.selectedTabIndex,
    )

    return (
      <View style={{ marginTop: 15 }}>
        <View style={styles.separator} />
        <View style={styles.chartHeaderView}>
          <Text style={styles.chartHeaderLabel}>{graphData.headerText}</Text>
          {this.props.isLoading && (
            <ActivityIndicator style={{ marginHorizontal: 5 }} />
          )}
        </View>
        <View style={styles.chartContainer}>
          <VictoryChart
            theme={VictoryTheme.material}
            domainPadding={{ x: [15, 0] }}
            containerComponent={<VictoryVoronoiContainer />}
            padding={{ top: 50, bottom: 60, left: 50, right: 30 }}
          >
            <VictoryAxis
              dependentAxis
              domain={graphData.domain.y}
              theme={VictoryTheme.material}
              standalone={false}
              tickFormat={x => {
                if (this.props.selectedTabIndex === 2) {
                  return `${x} %`
                } else if (
                  this.props.selectedTabIndex === 4 ||
                  this.props.selectedTabIndex === 5
                ) {
                  return `${this.kFormatter(x)}`
                }
                return x
              }}
              style={{
                grid: {
                  stroke: color.lineGrey,
                  strokeDasharray: '3,5',
                },
                ticks: {
                  size: 0,
                  stroke: 'transparent',
                },
                axis: {
                  stroke: color.lineGrey,
                  strokeWidth: 1,
                },
                tickLabels: {
                  stroke: color.lineGrey,
                  fontSize: 11,
                  fontWeight: '100',
                  padding: 13,
                },
              }}
            />
            <VictoryAxis
              theme={VictoryTheme.material}
              standalone={false}
              tickValues={graphData.tickValues.x}
              tickFormat={x => `${moment(x).format('D MMM')}`}
              style={{
                grid: {
                  stroke: 'transparent',
                },
                ticks: {
                  size: 0,
                  stroke: 'transparent',
                },
                axis: {
                  stroke: color.lineGrey,
                  strokeWidth: 1,
                },
                tickLabels: {
                  stroke: color.lineGrey,
                  fontSize: 9,
                  fontWeight: '100',
                  padding: 19,
                },
              }}
            />
            {graphData.data.length >= 2 && (
              <VictoryLine
                data={graphData.data}
                standalone={false}
                domain={{ x: graphData.domain.x }}
                style={{
                  data: {
                    opacity: 1,
                    stroke: color.graphBlue,
                    strokeWidth: 3,
                    strokeLinecap: 'round',
                    strokeLinejoin: 'round',
                  },
                }}
              />
            )}
            <VictoryScatter
              data={graphData.data}
              standalone={false}
              domain={{ x: graphData.domain.x }}
              labels={() => ``}
              labelComponent={
                <VictoryTooltip flyoutComponent={<StatisticChartToolTip />} />
              }
              style={{
                data: {
                  fill: color.graphBlue,
                  opacity: 1,
                  stroke: color.graphBlue,
                  strokeWidth: 3,
                },
              }}
            />
            {graphData.data.length >= 2 && (
              <VictoryArea
                data={graphData.data}
                standalone={false}
                domain={{ x: graphData.domain.x }}
                style={{
                  data: {
                    fill: color.graphAreaBlue,
                    opacity: 1,
                    strokeWidth: 0,
                  },
                }}
              />
            )}
          </VictoryChart>
        </View>
        <View style={styles.separator} />
      </View>
    )
  }
}

module.exports = StatisticChart
