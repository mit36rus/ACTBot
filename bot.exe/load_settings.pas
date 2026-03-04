unit load_settings;

{$mode objfpc}{$H+}

interface

uses
  Classes,
  SysUtils,
  INIFiles,
  CRT,
  var_bot;

procedure LoadAPI;
procedure LoadSettings;
procedure Save;

implementation

procedure LoadAPI;
var
  ini: TINIFile;
begin
  try
    try
      ini := TINIFile.Create('API.ini');

      KEY_BINANCE := ini.ReadString('API_KEY', 'KEY_BINANCE', '');
      KEY_BYBIT := ini.ReadString('API_KEY', 'KEY_BYBIT', '');

      SECRET_BINANCE := ini.ReadString('API_SECRET', 'SECRET_BINANCE', '');
      SECRET_BYBIT := ini.ReadString('API_SECRET', 'SECRET_BYBIT', '');
    except
      on E: Exception do
      begin
        TextColor(12);
        WriteLn(' ! ERROR > ' + E.Message + ' LoadAPI');
        TextColor(15);
      end;
    end;
  finally
    FreeAndNil(ini);
  end;
end;

procedure LoadSettings;
var
  ini: TINIFile;
begin
  try
    try
      if (EXCHANGE = 'BYBIT_F_LS') or (EXCHANGE = 'BINANCE_F_LS') or (EXCHANGE = 'BYBIT_F_HG') or (EXCHANGE = 'BINANCE_F_HG') then
        ini := TINIFile.Create('SETTINGS\' + VAL_1 + '_' + VAL_2 + '_' + EXCHANGE + '.ini')
      else
        ini := TINIFile.Create('SETTINGS\' + VAL_1 + '_' + VAL_2 + '_' + EXCHANGE + '_' + STRATEG + '.ini');

      OPEN_ORDERS := ini.ReadInteger('SETTINGS', 'OPEN_ORDERS', OPEN_ORDERS);
      FIRST_STEP := StrToFloat(ini.ReadString('SETTINGS', 'FIRST_STEP', FloatToStr(FIRST_STEP, fs)), fs);
      ORDERS_STEP := StrToFloat(ini.ReadString('SETTINGS', 'ORDERS_STEP', FloatToStr(ORDERS_STEP, fs)), fs);
      RATIO := StrToFloat(ini.ReadString('SETTINGS', 'RATIO', FloatToStr(RATIO, fs)), fs);
      RELOAD := StrToFloat(ini.ReadString('SETTINGS', 'RELOAD_ORDERS', FloatToStr(RELOAD, fs)), fs);
      DEPOSIT_ORDERS := StrToFloat(ini.ReadString('SETTINGS', 'DEPOSIT_ORDER', FloatToStr(DEPOSIT_ORDERS, fs)), fs);
      MARTINGALE := StrToFloat(ini.ReadString('SETTINGS', 'MARTINGALE', FloatToStr(MARTINGALE, fs)), fs);
      LIMIT_DEPOSIT := StrToFloat(ini.ReadString('SETTINGS', 'DEPOSIT_LIMIT', FloatToStr(LIMIT_DEPOSIT, fs)), fs);
      PROFIT := StrToFloat(ini.ReadString('SETTINGS', 'PROFIT', FloatToStr(PROFIT, fs)), fs);
      STOPLOSS := StrToFloat(ini.ReadString('SETTINGS', 'STOPLOSS', FloatToStr(STOPLOSS, fs)), fs);
      X2 := ini.ReadBool('SETTINGS', 'X2', X2);

      FIRST_RSI_ORDER := ini.ReadBool('RSI', 'FIRST_RSI_ORDER', FIRST_RSI_ORDER);
      NEXT_ORDER_RSI := ini.ReadBool('RSI', 'NEXT_ORDER_RSI', NEXT_ORDER_RSI);
      LENGTH_RSI_LOW := ini.ReadInteger('RSI', 'LENGTH_RSI_LOW', LENGTH_RSI_LOW);
      LENGTH_RSI_HIGH := ini.ReadInteger('RSI', 'LENGTH_RSI_HIGH', LENGTH_RSI_HIGH);
      DATA_FOR_RSI := ini.ReadString('RSI', 'DATA_FOR_RSI', DATA_FOR_RSI);
      CB_TIME_FRAME := ini.ReadString('RSI', 'CB_TIME_FRAME', CB_TIME_FRAME);
      RSI_OPEN_LONG := ini.ReadInteger('RSI', 'RSI_OPEN_LONG', RSI_OPEN_LONG);
      RSI_OPEN_SHORT := ini.ReadInteger('RSI', 'RSI_OPEN_SHORT', RSI_OPEN_SHORT);

      CREDIT := ini.ReadInteger('MARGIN SETTINGS', 'CREDIT', CREDIT);
      POSITION_MODE := ini.ReadString('MARGIN SETTINGS', 'POSITION_MODE', POSITION_MODE);

      HTTP_PAUSE := ini.ReadInteger('TIMEOUT SETTINGS', 'HTTP_TIMEOUT', HTTP_PAUSE);

      STOP := ini.ReadInteger('BOT', 'STOP', STOP);
      FASTSTOP := ini.ReadInteger('BOT', 'FASTSTOP', 0);
      if FASTSTOP = 1 then STOP := 1;

      TIME_FIRST_ORDER := ini.ReadInt64('SAVE', 'TIME_FIRST_ORDER', TIME_FIRST_ORDER);
      USES_DEPOSIT := StrToFloat(ini.ReadString('SAVE', 'USES_DEPOSIT', FloatToStr(USES_DEPOSIT, fs)), fs);
      PRICE_ORDER := StrToFloat(ini.ReadString('SAVE', 'PRICE_ORDER', FloatToStr(PRICE_ORDER, fs)), FS);
      PRICE_RELOAD := StrToFloat(ini.ReadString('SAVE', 'PRICE_RELOAD', FloatToStr(PRICE_RELOAD, fs)), FS);
      AMMOUNT_ORDER := StrToFloat(ini.ReadString('SAVE', 'AMMOUNT_ORDER', FloatToStr(AMMOUNT_ORDER, fs)), FS);
      NEXT_DEPOSIT_ORDER := StrToFloat(ini.ReadString('SAVE', 'NEXT_DEPOSIT_ORDER', FloatToStr(NEXT_DEPOSIT_ORDER, fs)), FS);
      TOTAL_AMMOUNT := StrToFloat(ini.ReadString('SAVE', 'TOTAL_AMMOUNT', FloatToStr(TOTAL_AMMOUNT, fs)), FS);
      TEMP_STEP := StrToFloat(ini.ReadString('SAVE', 'TEMP_STEP', FloatToStr(TEMP_STEP, fs)), FS);
      TEMP_STEP_LONG := StrToFloat(ini.ReadString('SAVE', 'TEMP_STEP_LONG', FloatToStr(TEMP_STEP, fs)), FS);
      TEMP_STEP_SHORT := StrToFloat(ini.ReadString('SAVE', 'TEMP_STEP_SHORT', FloatToStr(TEMP_STEP, fs)), FS);
      LAST_HIGH := StrToFloat(ini.ReadString('SAVE', 'LAST_HIGH', FloatToStr(LAST_HIGH, fs)), FS);
      LAST_MIN := StrToFloat(ini.ReadString('SAVE', 'LAST_MIN', FloatToStr(LAST_MIN, fs)), FS);

      LAST_POSITION_VOLUME := StrToFloat(ini.ReadString('SAVE', 'LAST_POSITION_VOLUME', FloatToStr(LAST_POSITION_VOLUME, fs)), FS);
      PRICE_POSITION := StrToFloat(ini.ReadString('SAVE', 'PRICE_POSITION', FloatToStr(PRICE_POSITION, fs)), FS);
      POSITION_VOLUME := StrToFloat(ini.ReadString('SAVE', 'POSITION_VOLUME', FloatToStr(POSITION_VOLUME, fs)), FS);

      //========
      STOPLOOS_DEPOSIT := StrToFloat(ini.ReadString('SAVE', 'STOPLOOS_DEPOSIT', FloatToStr(STOPLOOS_DEPOSIT, fs)), FS);

      PRICE_ORDER_LONG := StrToFloat(ini.ReadString('SAVE', 'PRICE_ORDER_LONG', FloatToStr(PRICE_ORDER_LONG, fs)), FS);
      PRICE_ORDER_SHORT := StrToFloat(ini.ReadString('SAVE', 'PRICE_ORDER_SHORT', FloatToStr(PRICE_ORDER_SHORT, fs)), FS);
      AMMOUNT_ORDER_LONG := StrToFloat(ini.ReadString('SAVE', 'AMMOUNT_ORDER_LONG', FloatToStr(AMMOUNT_ORDER_LONG, fs)), FS);
      AMMOUNT_ORDER_SHORT := StrToFloat(ini.ReadString('SAVE', 'AMMOUNT_ORDER_SHORT', FloatToStr(AMMOUNT_ORDER_SHORT, fs)), FS);
      TEMP_DEPOSIT_ORDER_LONG := StrToFloat(ini.ReadString('SAVE', 'TEMP_DEPOSIT_ORDER_LONG', FloatToStr(TEMP_DEPOSIT_ORDER_LONG, fs)), FS);
      TEMP_DEPOSIT_ORDER_SHORT := StrToFloat(ini.ReadString('SAVE', 'TEMP_DEPOSIT_ORDER_SHORT', FloatToStr(TEMP_DEPOSIT_ORDER_SHORT, fs)), FS);
    except
      on E: Exception do
      begin
        TextColor(12);
        WriteLn(' ! ERROR > ' + E.Message + ' LoadSettings');
        TextColor(15);
      end;
    end;
  finally
    FreeAndNil(ini);
  end;
end;

procedure Save;
var
  ini: TINIFile;
begin
  try
    try
      if (EXCHANGE = 'BYBIT_F_LS') or (EXCHANGE = 'BINANCE_F_LS') or (EXCHANGE = 'BYBIT_F_HG') or (EXCHANGE = 'BINANCE_F_HG') then
        ini := TINIFile.Create('SETTINGS\' + VAL_1 + '_' + VAL_2 + '_' + EXCHANGE + '.ini')
      else
        ini := TINIFile.Create('SETTINGS\' + VAL_1 + '_' + VAL_2 + '_' + EXCHANGE + '_' + STRATEG + '.ini');

      ini.WriteInt64('SAVE', 'TIME_FIRST_ORDER', TIME_FIRST_ORDER);
      ini.WriteString('SAVE', 'USES_DEPOSIT', FloatToStr(USES_DEPOSIT, fs));
      ini.WriteString('SAVE', 'PRICE_ORDER', FloatToStr(PRICE_ORDER, fs));
      ini.WriteString('SAVE', 'PRICE_RELOAD', FloatToStr(PRICE_RELOAD, fs));
      ini.WriteString('SAVE', 'AMMOUNT_ORDER', FloatToStr(AMMOUNT_ORDER, fs));
      ini.WriteString('SAVE', 'NEXT_DEPOSIT_ORDER', FloatToStr(NEXT_DEPOSIT_ORDER, fs));
      ini.WriteString('SAVE', 'TOTAL_AMMOUNT', FloatToStr(TOTAL_AMMOUNT, fs));
      ini.WriteString('SAVE', 'TEMP_STEP', FloatToStr(TEMP_STEP, fs));
      ini.WriteString('SAVE', 'TEMP_STEP_LONG', FloatToStr(TEMP_STEP_LONG, fs));
      ini.WriteString('SAVE', 'TEMP_STEP_SHORT', FloatToStr(TEMP_STEP_SHORT, fs));
      ini.WriteString('SAVE', 'LAST_HIGH', FloatToStr(LAST_HIGH, fs));
      ini.WriteString('SAVE', 'LAST_MIN', FloatToStr(LAST_MIN, fs));
      ini.WriteString('SAVE', 'LAST_POSITION_VOLUME', FloatToStr(LAST_POSITION_VOLUME, fs));
      ini.WriteString('SAVE', 'PRICE_POSITION', FloatToStr(PRICE_POSITION, fs));
      ini.WriteString('SAVE', 'POSITION_VOLUME', FloatToStr(POSITION_VOLUME, fs));
      ini.WriteString('SAVE', 'STOPLOOS_DEPOSIT', FloatToStr(STOPLOOS_DEPOSIT, fs));

      ini.WriteString('SAVE', 'PRICE_ORDER_LONG', FloatToStr(PRICE_ORDER_LONG, fs));
      ini.WriteString('SAVE', 'PRICE_ORDER_SHORT', FloatToStr(PRICE_ORDER_SHORT, fs));
      ini.WriteString('SAVE', 'AMMOUNT_ORDER_LONG', FloatToStr(AMMOUNT_ORDER_LONG, fs));
      ini.WriteString('SAVE', 'AMMOUNT_ORDER_SHORT', FloatToStr(AMMOUNT_ORDER_SHORT, fs));
      ini.WriteString('SAVE', 'TEMP_DEPOSIT_ORDER_LONG', FloatToStr(TEMP_DEPOSIT_ORDER_LONG, fs));
      ini.WriteString('SAVE', 'TEMP_DEPOSIT_ORDER_SHORT', FloatToStr(TEMP_DEPOSIT_ORDER_SHORT, fs));
    except
      on E: Exception do
      begin
        TextColor(12);
        WriteLn(' ! ERROR > ' + E.Message + ' Save');
        TextColor(15);
      end;
    end;
  finally
    FreeAndNil(ini);
  end;
end;

end.
