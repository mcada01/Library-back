import * as countryTelData from 'country-telephone-data';

export const getPhoneNumnberWithCountryCode = (
  countryPar: string,
  phone: string,
): any => {
  const countryData = countryTelData.allCountries.filter(
    (country) => country.name.toLowerCase() === countryPar.toLowerCase(),
  );
  if (countryData.length > 0) {
    let country = countryData[0];
    let code = '+' + country.dialCode;
    let numberCode = code + phone;
    return numberCode;
  } else {
    return false;
  }
};
