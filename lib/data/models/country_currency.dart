class CurrencyOption {
  const CurrencyOption(
    this.countryCode,
    this.countryName,
    this.currencyCode,
    this.currencyName,
    this.symbol,
  );

  
  final String countryCode;
  final String countryName;

  
  final String currencyCode;
  final String currencyName;
  final String symbol;

  
  String get flag {
    return String.fromCharCodes(
      countryCode.toUpperCase().codeUnits.map((int c) => 0x1F1E6 + c - 0x41),
    );
  }

  
  String get displaySymbol {
    final bool endsWithLetter = RegExp(r'[A-Za-z]$').hasMatch(symbol);
    return endsWithLetter ? '$symbol ' : symbol;
  }
}

class CurrencyCatalog {
  CurrencyCatalog._();

  static const List<CurrencyOption> _data = <CurrencyOption>[
    CurrencyOption('AF', 'Afghanistan', 'AFN', 'Afghan Afghani', '؋'),
    CurrencyOption('AL', 'Albania', 'ALL', 'Albanian Lek', 'L'),
    CurrencyOption('DZ', 'Algeria', 'DZD', 'Algerian Dinar', 'DA'),
    CurrencyOption('AR', 'Argentina', 'ARS', 'Argentine Peso', '\$'),
    CurrencyOption('AM', 'Armenia', 'AMD', 'Armenian Dram', '֏'),
    CurrencyOption('AU', 'Australia', 'AUD', 'Australian Dollar', 'A\$'),
    CurrencyOption('AT', 'Austria', 'EUR', 'Euro', '€'),
    CurrencyOption('AZ', 'Azerbaijan', 'AZN', 'Azerbaijani Manat', '₼'),
    CurrencyOption('BH', 'Bahrain', 'BHD', 'Bahraini Dinar', 'BD'),
    CurrencyOption('BD', 'Bangladesh', 'BDT', 'Bangladeshi Taka', '৳'),
    CurrencyOption('BY', 'Belarus', 'BYN', 'Belarusian Ruble', 'Br'),
    CurrencyOption('BE', 'Belgium', 'EUR', 'Euro', '€'),
    CurrencyOption('BO', 'Bolivia', 'BOB', 'Boliviano', 'Bs.'),
    CurrencyOption(
        'BA', 'Bosnia and Herzegovina', 'BAM', 'Convertible Mark', 'KM'),
    CurrencyOption('BR', 'Brazil', 'BRL', 'Brazilian Real', 'R\$'),
    CurrencyOption('BN', 'Brunei', 'BND', 'Brunei Dollar', 'B\$'),
    CurrencyOption('BG', 'Bulgaria', 'EUR', 'Euro', '€'),
    CurrencyOption('KH', 'Cambodia', 'KHR', 'Cambodian Riel', '៛'),
    CurrencyOption('CA', 'Canada', 'CAD', 'Canadian Dollar', 'C\$'),
    CurrencyOption('CL', 'Chile', 'CLP', 'Chilean Peso', '\$'),
    CurrencyOption('CN', 'China', 'CNY', 'Chinese Yuan', '¥'),
    CurrencyOption('CO', 'Colombia', 'COP', 'Colombian Peso', '\$'),
    CurrencyOption('CR', 'Costa Rica', 'CRC', 'Costa Rican Colon', '₡'),
    CurrencyOption('HR', 'Croatia', 'EUR', 'Euro', '€'),
    CurrencyOption('CY', 'Cyprus', 'EUR', 'Euro', '€'),
    CurrencyOption('CZ', 'Czechia', 'CZK', 'Czech Koruna', 'Kč'),
    CurrencyOption('DK', 'Denmark', 'DKK', 'Danish Krone', 'kr'),
    CurrencyOption('DO', 'Dominican Republic', 'DOP', 'Dominican Peso', 'RD\$'),
    CurrencyOption('EC', 'Ecuador', 'USD', 'US Dollar', '\$'),
    CurrencyOption('EG', 'Egypt', 'EGP', 'Egyptian Pound', 'E£'),
    CurrencyOption('EE', 'Estonia', 'EUR', 'Euro', '€'),
    CurrencyOption('ET', 'Ethiopia', 'ETB', 'Ethiopian Birr', 'Br'),
    CurrencyOption('FI', 'Finland', 'EUR', 'Euro', '€'),
    CurrencyOption('FR', 'France', 'EUR', 'Euro', '€'),
    CurrencyOption('GE', 'Georgia', 'GEL', 'Georgian Lari', '₾'),
    CurrencyOption('DE', 'Germany', 'EUR', 'Euro', '€'),
    CurrencyOption('GH', 'Ghana', 'GHS', 'Ghanaian Cedi', '₵'),
    CurrencyOption('GR', 'Greece', 'EUR', 'Euro', '€'),
    CurrencyOption('GT', 'Guatemala', 'GTQ', 'Guatemalan Quetzal', 'Q'),
    CurrencyOption('HK', 'Hong Kong', 'HKD', 'Hong Kong Dollar', 'HK\$'),
    CurrencyOption('HU', 'Hungary', 'HUF', 'Hungarian Forint', 'Ft'),
    CurrencyOption('IS', 'Iceland', 'ISK', 'Icelandic Krona', 'kr'),
    CurrencyOption('IN', 'India', 'INR', 'Indian Rupee', '₹'),
    CurrencyOption('ID', 'Indonesia', 'IDR', 'Indonesian Rupiah', 'Rp'),
    CurrencyOption('IR', 'Iran', 'IRR', 'Iranian Rial', '﷼'),
    CurrencyOption('IQ', 'Iraq', 'IQD', 'Iraqi Dinar', 'IQD'),
    CurrencyOption('IE', 'Ireland', 'EUR', 'Euro', '€'),
    CurrencyOption('IL', 'Israel', 'ILS', 'Israeli Shekel', '₪'),
    CurrencyOption('IT', 'Italy', 'EUR', 'Euro', '€'),
    CurrencyOption('CI', 'Ivory Coast', 'XOF', 'West African CFA Franc', 'CFA'),
    CurrencyOption('JM', 'Jamaica', 'JMD', 'Jamaican Dollar', 'J\$'),
    CurrencyOption('JP', 'Japan', 'JPY', 'Japanese Yen', '¥'),
    CurrencyOption('JO', 'Jordan', 'JOD', 'Jordanian Dinar', 'JD'),
    CurrencyOption('KZ', 'Kazakhstan', 'KZT', 'Kazakhstani Tenge', '₸'),
    CurrencyOption('KE', 'Kenya', 'KES', 'Kenyan Shilling', 'KSh'),
    CurrencyOption('KW', 'Kuwait', 'KWD', 'Kuwaiti Dinar', 'KD'),
    CurrencyOption('LV', 'Latvia', 'EUR', 'Euro', '€'),
    CurrencyOption('LB', 'Lebanon', 'LBP', 'Lebanese Pound', 'L£'),
    CurrencyOption('LY', 'Libya', 'LYD', 'Libyan Dinar', 'LD'),
    CurrencyOption('LT', 'Lithuania', 'EUR', 'Euro', '€'),
    CurrencyOption('LU', 'Luxembourg', 'EUR', 'Euro', '€'),
    CurrencyOption('MY', 'Malaysia', 'MYR', 'Malaysian Ringgit', 'RM'),
    CurrencyOption('MV', 'Maldives', 'MVR', 'Maldivian Rufiyaa', 'Rf'),
    CurrencyOption('MT', 'Malta', 'EUR', 'Euro', '€'),
    CurrencyOption('MU', 'Mauritius', 'MUR', 'Mauritian Rupee', 'Rs'),
    CurrencyOption('MX', 'Mexico', 'MXN', 'Mexican Peso', 'Mex\$'),
    CurrencyOption('MN', 'Mongolia', 'MNT', 'Mongolian Tugrik', '₮'),
    CurrencyOption('MA', 'Morocco', 'MAD', 'Moroccan Dirham', 'MAD'),
    CurrencyOption('MM', 'Myanmar', 'MMK', 'Myanmar Kyat', 'K'),
    CurrencyOption('NP', 'Nepal', 'NPR', 'Nepalese Rupee', 'Rs'),
    CurrencyOption('NL', 'Netherlands', 'EUR', 'Euro', '€'),
    CurrencyOption('NZ', 'New Zealand', 'NZD', 'New Zealand Dollar', 'NZ\$'),
    CurrencyOption('NG', 'Nigeria', 'NGN', 'Nigerian Naira', '₦'),
    CurrencyOption('NO', 'Norway', 'NOK', 'Norwegian Krone', 'kr'),
    CurrencyOption('OM', 'Oman', 'OMR', 'Omani Rial', 'OMR'),
    CurrencyOption('PK', 'Pakistan', 'PKR', 'Pakistani Rupee', 'Rs'),
    CurrencyOption('PA', 'Panama', 'PAB', 'Panamanian Balboa', 'B/.'),
    CurrencyOption('PY', 'Paraguay', 'PYG', 'Paraguayan Guarani', '₲'),
    CurrencyOption('PE', 'Peru', 'PEN', 'Peruvian Sol', 'S/'),
    CurrencyOption('PH', 'Philippines', 'PHP', 'Philippine Peso', '₱'),
    CurrencyOption('PL', 'Poland', 'PLN', 'Polish Zloty', 'zł'),
    CurrencyOption('PT', 'Portugal', 'EUR', 'Euro', '€'),
    CurrencyOption('QA', 'Qatar', 'QAR', 'Qatari Riyal', 'QR'),
    CurrencyOption('RO', 'Romania', 'RON', 'Romanian Leu', 'lei'),
    CurrencyOption('RU', 'Russia', 'RUB', 'Russian Ruble', '₽'),
    CurrencyOption('SA', 'Saudi Arabia', 'SAR', 'Saudi Riyal', 'SR'),
    CurrencyOption('SN', 'Senegal', 'XOF', 'West African CFA Franc', 'CFA'),
    CurrencyOption('RS', 'Serbia', 'RSD', 'Serbian Dinar', 'din'),
    CurrencyOption('SG', 'Singapore', 'SGD', 'Singapore Dollar', 'S\$'),
    CurrencyOption('SK', 'Slovakia', 'EUR', 'Euro', '€'),
    CurrencyOption('SI', 'Slovenia', 'EUR', 'Euro', '€'),
    CurrencyOption('SO', 'Somalia', 'SOS', 'Somali Shilling', 'Sh'),
    CurrencyOption('ZA', 'South Africa', 'ZAR', 'South African Rand', 'R'),
    CurrencyOption('KR', 'South Korea', 'KRW', 'South Korean Won', '₩'),
    CurrencyOption('ES', 'Spain', 'EUR', 'Euro', '€'),
    CurrencyOption('LK', 'Sri Lanka', 'LKR', 'Sri Lankan Rupee', 'Rs'),
    CurrencyOption('SD', 'Sudan', 'SDG', 'Sudanese Pound', 'SDG'),
    CurrencyOption('SE', 'Sweden', 'SEK', 'Swedish Krona', 'kr'),
    CurrencyOption('CH', 'Switzerland', 'CHF', 'Swiss Franc', 'CHF'),
    CurrencyOption('SY', 'Syria', 'SYP', 'Syrian Pound', 'S£'),
    CurrencyOption('TW', 'Taiwan', 'TWD', 'New Taiwan Dollar', 'NT\$'),
    CurrencyOption('TZ', 'Tanzania', 'TZS', 'Tanzanian Shilling', 'TSh'),
    CurrencyOption('TH', 'Thailand', 'THB', 'Thai Baht', '฿'),
    CurrencyOption(
        'TT', 'Trinidad and Tobago', 'TTD', 'Trinidad Dollar', 'TT\$'),
    CurrencyOption('TN', 'Tunisia', 'TND', 'Tunisian Dinar', 'DT'),
    CurrencyOption('TR', 'Turkey', 'TRY', 'Turkish Lira', '₺'),
    CurrencyOption('UG', 'Uganda', 'UGX', 'Ugandan Shilling', 'USh'),
    CurrencyOption('UA', 'Ukraine', 'UAH', 'Ukrainian Hryvnia', '₴'),
    CurrencyOption('AE', 'United Arab Emirates', 'AED', 'UAE Dirham', 'AED'),
    CurrencyOption('GB', 'United Kingdom', 'GBP', 'Pound Sterling', '£'),
    CurrencyOption('US', 'United States', 'USD', 'US Dollar', '\$'),
    CurrencyOption('UY', 'Uruguay', 'UYU', 'Uruguayan Peso', '\$U'),
    CurrencyOption('UZ', 'Uzbekistan', 'UZS', 'Uzbekistani Som', 'soʻm'),
    CurrencyOption('VE', 'Venezuela', 'VES', 'Venezuelan Bolivar', 'Bs.S'),
    CurrencyOption('VN', 'Vietnam', 'VND', 'Vietnamese Dong', '₫'),
    CurrencyOption('YE', 'Yemen', 'YER', 'Yemeni Rial', 'YER'),
    CurrencyOption('ZM', 'Zambia', 'ZMW', 'Zambian Kwacha', 'ZK'),
  ];

  
  static final List<CurrencyOption> all = List<CurrencyOption>.of(_data)
    ..sort((CurrencyOption a, CurrencyOption b) =>
        a.countryName.compareTo(b.countryName));

  static CurrencyOption get defaultOption => byCountry('US');

  static CurrencyOption byCountry(String countryCode) {
    for (final CurrencyOption o in _data) {
      if (o.countryCode == countryCode) {
        return o;
      }
    }
    return _data.firstWhere((CurrencyOption o) => o.countryCode == 'US');
  }
}
