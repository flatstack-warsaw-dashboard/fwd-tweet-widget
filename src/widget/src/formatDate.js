const formatDate = (date) => date.toLocaleDateString(
  'default', { month: 'short', day: '2-digit', year: 'numeric' }
);

export default formatDate;
