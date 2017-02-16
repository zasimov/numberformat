# numberformat

numberformat provides module HumanFriendly.NumberFormat that contains:

  - getDecimalPoint returns decimal point for user's locale (calls initNumberFormat)
  - decimalPoint returns decimal point and do not call initNumberFormat
  - showFloat returns locale-specific float representation
  - showDouble returns locale-specific float representation

Warning: you should call initNumberFormat to apply locale-specific
decimal point.