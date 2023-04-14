const formatDate = (date) => [
  date.toLocaleDateString(
    'default', { month: 'short', day: '2-digit', year: 'numeric' }
  ),
  date.toLocaleTimeString('en-US', { hour12: false }),
].join(" ");

export default formatDate;
