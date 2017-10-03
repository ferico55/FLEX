export const changeDateRange = ({
  actionId,
  theSelectedIndex,
  theStartDate,
  theEndDate,
  key,
}) => ({
  type: actionId,
  payload: {
    selectedIndex: theSelectedIndex,
    startDate: theStartDate,
    endDate: theEndDate,
  },
  key,
})
