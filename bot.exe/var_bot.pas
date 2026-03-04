unit var_bot;

{$mode objfpc}{$H+}

interface

uses
  Classes,
  SysUtils,
  Windows,
  DateUtils,
  jsonparser,
  fpjson;

var
  H: THandle;
  FS: TFormatSettings;

  HTTP_PAUSE: integer = 300;

  // user
  KEY_BINANCE: string;
  KEY_BYBIT: string;

  SECRET_BINANCE: string;
  SECRET_BYBIT: string;

  //=================
  VAL_1: string;
  VAL_2: string;

  VAL_1_BALANS: double;
  VAL_2_BALANS: double;
  STOPLOOS_DEPOSIT: double;

  VAL_1_ORDERS: TStringList;
  VAL_2_ORDERS: TStringList;

  OPEN_POSITION_ORDER: TStringList;
  CLOSE_POSITION_ORDER: TStringList;
  SL_ORDER_SHORT: TStringList;
  POSITION: string;

  ASKS: double;
  BIDS: double;

  TIME_FIRST_ORDER: int64;
  USES_DEPOSIT: double;
  TOTAL_AMMOUNT: double;
  PRICE_ORDER: double;
  AMMOUNT_ORDER: double;
  PRICE_RELOAD: double;
  TEMP_STEP: double;
  NEXT_DEPOSIT_ORDER: double;
  LAST_HIGH: double;
  LAST_MIN: double;
  TOTAL_PROFIT: double;
  LAST_PROFIT: double;

  POSITION_VOLUME: double = 0;
  POSITION_NATIONAL: double = 0;
  LAST_POSITION_VOLUME: double = 0;
  PRICE_POSITION: double = 0;
  MARK_PRICE: double = 0;
  PNL: double = 0;
  LAST_MARK_PRICE: double = 0;

  //futuresLS
  PNL_LONG: double = 0;
  LAST_PNL_LONG: double = 0;
  POSITION_VOLUME_LONG: double = 0;
  PRICE_POSITION_LONG: double = 0;
  POSITION_NATIONAL_LONG: double = 0;

  PNL_SHORT: double = 0;
  LAST_PNL_SHORT: double = 0;
  POSITION_VOLUME_SHORT: double = 0;
  POSITION_NATIONAL_SHORT: double = 0;
  PRICE_POSITION_SHORT: double = 0;

  PRICE_ORDER_LONG: double;
  PRICE_ORDER_SHORT: double;
  LAST_PRICE_ORDER_LONG: double;
  LAST_PRICE_ORDER_SHORT: double;
  AMMOUNT_ORDER_LONG: double;
  AMMOUNT_ORDER_SHORT: double;
  TOTAL_AMMOUNT_LONG: double;
  TOTAL_AMMOUNT_SHORT: double;

  TEMP_STEP_LONG: double;
  TEMP_STEP_SHORT: double;

  TEMP_DEPOSIT_ORDER_LONG: double;
  TEMP_DEPOSIT_ORDER_SHORT: double;

  //=================
  MIN_AMMOUNT_BUY: double;
  MIN_AMMOUNT_SELL: double;

  MIN_VAL_1: double;
  MIN_VAL_2: double;

  DEC_PRICE: integer;
  DEC_MIN_VAL_1: integer;
  DEC_MIN_VAL_2: integer;

  QTY_STEP: double;

  maintMarginPercent: double;

  // LAUNCHER SETTING
  OPEN_ORDERS: integer;
  FIRST_STEP: double;
  ORDERS_STEP: double;
  RATIO: double;
  DEPOSIT_ORDERS: double;
  MARTINGALE: double;
  SUM_ALL: double;
  SUM_ORDER: double;
  PROFIT: double;
  NEW_PROFIT: double;
  RELOAD: double;
  LIMIT_DEPOSIT: double;
  STDDEV: integer;
  STOP: integer;
  EXCHANGE: string;
  STRATEG: string;
  STOPLOSS: double;
  FASTSTOP: integer = 0;
  CREDIT: integer;
  X2: boolean = False;

  // RSI
  FIRST_RSI_ORDER: boolean;
  NEXT_ORDER_RSI: boolean;
  LENGTH_RSI_LOW: integer;
  LENGTH_RSI_HIGH: integer;
  DATA_FOR_RSI: string;
  CB_TIME_FRAME: string;
  RSI_OPEN_LONG: integer;
  RSI_OPEN_SHORT: integer;
  RSI: double;
  Pre_RSI: double;
  SHOOT_LONG: boolean = False;
  SHOOT_SHORT: boolean = False;

  jD, jD2, jD3, jD4: TJSONData;

  POSITION_MODE: string;

  //url_bybit : String = 'https://api-demo.bybit.com';
  url_bybit: string = 'https://api.bybit.com';
  PNL_PERCENT_LONG: double;
  PNL_PERCENT_SHORT: double;
  PRICE_SHORT_STOP: double;
  SL_ORDER_SHORT_VOLUME: double;
  PNL_SUM_PERCENT: double;

function GetKey(): string;
function GetTimeZone: integer;
function GetTime(): int64;
function CutDec(a: double; b: integer): double;
procedure RSI_Calculation(pre_mas, cur_mas: array of double; lenthg: integer);

implementation

function GetKey(): string;
begin
  case EXCHANGE of
    'BINANCE': Result := KEY_BINANCE;
    'BINANCE_F': Result := KEY_BINANCE;
    'BINANCE_F_LS': Result := KEY_BINANCE;
    'BINANCE_F_HG': Result := KEY_BINANCE;
    'BYBIT': Result := KEY_BYBIT;
    'BYBIT_F': Result := KEY_BYBIT;
    'BYBIT_F_LS': Result := KEY_BYBIT;
    'BYBIT_F_HG': Result := KEY_BYBIT;
  end;
end;

function GetTimeZone: integer;
var
  TIME_ZONE: _TIME_ZONE_INFORMATION;
  i: integer;
begin
  GetTimeZoneInformation(TIME_ZONE);
  i := TIME_ZONE.Bias div 60;
  i := i * -1;
  Result := i;
end;

function GetTime(): int64;
var
  str: string;
begin
  str := IntToStr(DateTimeToUnix(now - GetTimeZone / 24) * 1000);
  Result := StrToInt64(str);
end;

procedure RSI_Calculation(pre_mas, cur_mas: array of double; lenthg: integer);
var
  i: integer;

  mas_change: array of double;
  mas_gain: array of double;
  mas_loss: array of double;
  avg_gain: double = 0.0;
  avg_loss: double = 0.0;

  pre_mas_change: array of double;
  pre_mas_gain: array of double;
  pre_mas_loss: array of double;
  pre_avg_gain: double = 0.0;
  pre_avg_loss: double = 0.0;

  RS: double = 0.0;
  Pre_RS: double = 0.0;
begin
  SetLength(mas_change, lenthg + 2);
  SetLength(mas_gain, lenthg + 2);
  SetLength(mas_loss, lenthg + 2);

  SetLength(pre_mas_change, lenthg + 2);
  SetLength(pre_mas_gain, lenthg + 2);
  SetLength(pre_mas_loss, lenthg + 2);

  //change
  for i := 1 to lenthg do
  begin
    mas_change[i] := cur_mas[i] - cur_mas[i - 1];
    pre_mas_change[i] := pre_mas[i] - pre_mas[i - 1];
  end;

  //gain
  for i := 1 to lenthg do
  begin
    if mas_change[i] > 0 then
      mas_gain[i] := mas_change[i]
    else
      mas_gain[i] := 0;

    if pre_mas_change[i] > 0 then
      pre_mas_gain[i] := pre_mas_change[i]
    else
      pre_mas_gain[i] := 0;
  end;

  //loss
  for i := 1 to lenthg do
  begin
    if mas_change[i] < 0 then
      mas_loss[i] := ABS(mas_change[i])
    else
      mas_loss[i] := 0;

    if pre_mas_change[i] < 0 then
      pre_mas_loss[i] := ABS(pre_mas_change[i])
    else
      pre_mas_loss[i] := 0;
  end;

  //avg_gain
  for i := 1 to lenthg do
  begin
    avg_gain := avg_gain + mas_gain[i];
    pre_avg_gain := pre_avg_gain + pre_mas_gain[i];
  end;

  //avg_loss
  for i := 1 to lenthg do
  begin
    avg_loss := avg_loss + mas_loss[i];
    pre_avg_loss := pre_avg_loss + pre_mas_loss[i];
  end;

  if avg_loss > 0.0 then
  begin
    RS := avg_gain / avg_loss;
    RSI := CutDec(100 - (100 / (RS + 1)), 2);
  end
  else
    RSI := 100;

  if pre_avg_loss > 0.0 then
  begin
    Pre_RS := pre_avg_gain / pre_avg_loss;
    Pre_RSI := CutDec(100 - (100 / (Pre_RS + 1)), 2);
  end
  else
    Pre_RSI := 100;
end;

function CutDec(a: double; b: integer): double;
var
  str: string;
  strI: integer;
begin
  try
    str := FloatToStrF(a, ffFixed, 13, 13, fs);
    strI := pos('.', str);
    if strI > 0 then
    begin
      if b > 0 then
        Delete(str, strI + b + 1, length(str))
      else
        Delete(str, strI + b, length(str));
    end;
    Result := StrToFloat(str, fs);

  except
    on E: Exception do
    begin
      WriteLn(' ! ERROR > ' + E.Message + ' CutDec');
    end;
  end;
end;

end.
