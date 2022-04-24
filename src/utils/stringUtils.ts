const removeSpecialCharacters = (str) => {
  const stringValue = str ? str.toString() : '';
  return stringValue.replace(/[^\x20-\x7E]/g, '');
};

module.exports = {
  removeSpecialCharacters,
};
