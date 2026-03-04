unit futures;

{$mode objfpc}{$H+}

interface

uses
  Classes,
  SysUtils,
  CRT,
  var_bot,
  load_settings,
  api_binance_futures,
  api_bybit_futures;

procedure WorkFutures;
procedure OrderCreateClosePosition;
procedure OrderCreate;
procedure CheckOrderClosePosition;

implementation

procedure WorkFutures;
var
  StopWork: boolean = False;
begin
  WriteLn(' Wellcome Futures');
  WriteLn('');

  case EXCHANGE of
    'BINANCE_F': begin
      ChangePositionModeBinance;
      ChangeMarginTypeBinance;
      SwitchLevelBinance;
    end;
    'BYBIT_F': begin
      repeat
      until PositionModeSwitchBybit;
      repeat
      until SwitchLevelBybit;
      repeat
      until SetLeverageBybit;
    end;
  end;

  case EXCHANGE of
    'BINANCE_F':
      repeat
      until LoadAllOrdersBinanceFutures;
    'BYBIT_F':
      repeat
      until LoadAllOrdersBybitFutures;
  end;

  // Загружаем лимиты и делители с биржи
  case EXCHANGE of
    'BINANCE_F':
      repeat
      until GetLimitBinanceFutures;
    'BYBIT_F':
      repeat
      until GetLimitBybitFutures;
  end;

  while not StopWork do
  begin
    LoadSettings;

    // Загружаем RSI
    if (FIRST_RSI_ORDER) or (NEXT_ORDER_RSI) then
    begin
      case EXCHANGE of
        'BINANCE_F':
          repeat
          until GetRsiBinanceFuturesRSIShoot(CB_TIME_FRAME);
        'BYBIT_F':
          repeat
          until GetRsiBybitFuturesRSIShoot(CB_TIME_FRAME);
      end;
    end;

    case EXCHANGE of
      'BINANCE_F':
        repeat
        until BalanceBinanceFutures;
      'BYBIT_F':
        repeat
        until BalanceBybitFutures;
    end;

    case EXCHANGE of
      'BINANCE_F':
        repeat
        until GetPositionBinance;
      'BYBIT_F':
        repeat
        until GetPositionBybit;
    end;

    case EXCHANGE of
      'BINANCE_F':
        repeat
        until MarketBinanceFutures;
      'BYBIT_F':
        repeat
        until MarketBybitFutures;
    end;

    if (CLOSE_POSITION_ORDER.Count > 0) then CheckOrderClosePosition;

    // быстрый выход
    if ((FASTSTOP = 1) and (POSITION_VOLUME <> 0)) or ((CLOSE_POSITION_ORDER.Count > 0) and (PNL < 0) and (abs(PNL) >= STOPLOOS_DEPOSIT * STOPLOSS / 100)) then
    begin
      TextColor(4);
      WriteLn(' !!! MARKET CLOSE POSITION !!!');
      TextColor(15);
      if (CLOSE_POSITION_ORDER.Count > 0) then
      begin
        case EXCHANGE of
          'BINANCE_F':
            if CancelOrderBinanceFutures(CLOSE_POSITION_ORDER[0]) then
              CLOSE_POSITION_ORDER.Delete(0);
          'BYBIT_F':
            if CancelOrderBybitFutures(CLOSE_POSITION_ORDER[0]) then
              CLOSE_POSITION_ORDER.Delete(0);
        end;
      end;

      case EXCHANGE of
        'BINANCE_F':
          repeat
          until GetPositionBinance;
        'BYBIT_F':
          repeat
          until GetPositionBybit;
      end;

      if POSITION_MODE = 'OneWay' then
      begin
        if STRATEG = 'L' then
          case EXCHANGE of
            'BINANCE_F': CreateOrderBinanceFutures('BOTH', 'SELL', 'MARKET', FloatToStr(0, fs), FloatToStr(POSITION_VOLUME, fs), '0');
            'BYBIT_F': CreateOrderBybitFutures('true', 'Sell', 'Market', FloatToStr(0, fs), FloatToStr(POSITION_NATIONAL, fs), '0');
          end;

        if STRATEG = 'S' then
          case EXCHANGE of
            'BINANCE_F': CreateOrderBinanceFutures('BOTH', 'BUY', 'MARKET', FloatToStr(0, fs), FloatToStr(POSITION_VOLUME, fs), '0');
            'BYBIT_F': CreateOrderBybitFutures('true', 'Buy', 'Market', FloatToStr(0, fs), FloatToStr(POSITION_NATIONAL, fs), '0');
          end;
      end;

      if POSITION_MODE = 'Hedge' then
      begin
        if STRATEG = 'L' then
          case EXCHANGE of
            'BINANCE_F': CreateOrderBinanceFutures('LONG', 'SELL', 'MARKET', FloatToStr(0, fs), FloatToStr(POSITION_VOLUME, fs), '0');
            'BYBIT_F': CreateOrderBybitFutures('true', 'Sell', 'Market', FloatToStr(0, fs), FloatToStr(POSITION_NATIONAL, fs), '0');
          end;

        if STRATEG = 'S' then
          case EXCHANGE of
            'BINANCE_F': CreateOrderBinanceFutures('SHORT', 'BUY', 'MARKET', FloatToStr(0, fs), FloatToStr(POSITION_VOLUME, fs), '0');
            'BYBIT_F': CreateOrderBybitFutures('true', 'Buy', 'Market', FloatToStr(0, fs), FloatToStr(POSITION_NATIONAL, fs), '0');
          end;
      end;

      case EXCHANGE of
        'BINANCE_F':
          repeat
          until GetPositionBinance;
        'BYBIT_F':
          repeat
          until GetPositionBybit;
      end;

      if (POSITION_VOLUME = 0) then
      begin
        case EXCHANGE of
          'BINANCE_F':
          begin
            repeat
            until CancelAllOpenOrdersFuturesBinance;
            repeat
            until LoadAllOrdersBinanceFutures;
          end;
          'BYBIT_F':
          begin
            repeat
            until CancelAllOpenOrdersFuturesBybit;
            repeat
            until LoadAllOrdersBybitFutures;
          end;
        end;
      end;
    end;

    // CLOSE POSITION
    if ((POSITION_VOLUME <> 0) and (CLOSE_POSITION_ORDER.Count = 0)) or ((LAST_POSITION_VOLUME <> POSITION_VOLUME) and (CLOSE_POSITION_ORDER.Count > 0)) or ((PROFIT <> NEW_PROFIT) and (CLOSE_POSITION_ORDER.Count > 0)) then
    begin
      OrderCreateClosePosition;
    end;

    // RELOAD
    if ((STRATEG = 'L') and (OPEN_POSITION_ORDER.Count > 0) and (POSITION_VOLUME = 0) and (CLOSE_POSITION_ORDER.Count = 0) and (PRICE_RELOAD < BIDS)) or ((STRATEG = 'S') and
      (OPEN_POSITION_ORDER.Count > 0) and (POSITION_VOLUME = 0) and (CLOSE_POSITION_ORDER.Count = 0) and (PRICE_RELOAD > ASKS)) or ((OPEN_POSITION_ORDER.Count > 0) and (POSITION_VOLUME = 0) and
      (CLOSE_POSITION_ORDER.Count = 0) and (LAST_POSITION_VOLUME <> POSITION_VOLUME)) then
    begin
      case EXCHANGE of
        'BINANCE_F':
        begin
          repeat
          until CancelAllOpenOrdersFuturesBinance;
          repeat
          until LoadAllOrdersBinanceFutures;
        end;
        'BYBIT_F':
        begin
          repeat
          until CancelAllOpenOrdersFuturesBybit;
          repeat
          until LoadAllOrdersBybitFutures;
        end;
      end;
    end;

    // Остановка бота
    if ((STOP = 1) and (CLOSE_POSITION_ORDER.Count = 0) and (POSITION_VOLUME = 0)) then
    begin
      TextColor(4);
      WriteLn('');
      WriteLn('-----------------------------------------------');
      WriteLn(' WORK PROCEDURE STOP BOT');
      case EXCHANGE of
        'BINANCE_F':
          repeat
          until CancelAllOpenOrdersFuturesBinance;
        'BYBIT_F':
          repeat
          until CancelAllOpenOrdersFuturesBybit;
      end;
      TextColor(4);
      Writeln(' BOT STOPED, CLOSE PROGRAMM!');
      WriteLn('-----------------------------------------------');
      Readln;
      Break;
    end;

    // OPEN ORDERS POSITIONS
    if ((OPEN_POSITION_ORDER.Count = 0) and (CLOSE_POSITION_ORDER.Count = 0) and (POSITION_VOLUME = 0) and (STOP = 0)) then
    begin
      if (FIRST_RSI_ORDER = False) then
      begin
        OrderCreate;
      end
      else
      begin
        if ((FIRST_RSI_ORDER = True) and (STRATEG = 'L') and (SHOOT_LONG = True)) then
        begin
          OrderCreate;
        end;
        if ((FIRST_RSI_ORDER = True) and (STRATEG = 'S') and (SHOOT_SHORT = True)) then
        begin
          OrderCreate;
        end;
      end;
    end
    else
    begin
      if ((OPEN_POSITION_ORDER.Count < OPEN_ORDERS) and (TOTAL_AMMOUNT + NEXT_DEPOSIT_ORDER < USES_DEPOSIT) and (POSITION_VOLUME > 0)) then
      begin
        if ((FIRST_RSI_ORDER = False) and (NEXT_ORDER_RSI = False)) then
        begin
          OrderCreate;
        end
        else
        begin
          if ((FIRST_RSI_ORDER = True) and (NEXT_ORDER_RSI = False)) then
          begin
            OrderCreate;
          end
          else
          begin
            if ((STRATEG = 'L') and (NEXT_ORDER_RSI = True) and (BIDS < PRICE_ORDER) and (SHOOT_LONG = True)) then
            begin
              OrderCreate;
            end;
            if ((STRATEG = 'S') and (NEXT_ORDER_RSI = True) and (ASKS > PRICE_ORDER) and (SHOOT_SHORT = True)) then
            begin
              OrderCreate;
            end;
          end;
        end;
      end;
    end;


    TextColor(15);
    WriteLn('');
    WriteLn('-----------------------------------------------');
    TextColor(14);
    Writeln(' ASKS : ' + FloatToStr(ASKS, fs) + ' BIDS : ' + FloatToStr(BIDS, fs));
    TextColor(14);
    Writeln(' PRICE RELOAD : ' + FloatToStr(PRICE_RELOAD, fs));
    WriteLn(' BALANS ' + val_1 + ' : ' + FloatToStr(VAL_1_BALANS, fs));
    Writeln(' TOTAL AMMOUNT ' + FloatToStr(TOTAL_AMMOUNT, FS));
    Writeln(' TOTAL AMMOUNT + NEXT DEPOSIT ORDER : ' + FloatToStr(TOTAL_AMMOUNT + NEXT_DEPOSIT_ORDER, FS));
    Writeln(' DEPOSIT LIMIT : ' + FloatToStr(USES_DEPOSIT, FS));
    TextColor(3);
    WriteLn(' PRICE POSITION : ' + FloatToStr(PRICE_POSITION, fs));
    WriteLn(' POSITION VOLUME : ' + FloatToStr(POSITION_VOLUME, fs));
    WriteLn(' POSITION NATIONAL : ' + FloatToStr(POSITION_NATIONAL, fs));
    WriteLn(' PNL : ' + FloatToStr(PNL, fs));
    TextColor(4);
    WriteLn(' STOPLOOS PNL : -' + FloatToStr(STOPLOOS_DEPOSIT * STOPLOSS / 100, fs));
    TextColor(2);
    WriteLn(' OPEN POSITION ORDER : ' + IntToStr(OPEN_POSITION_ORDER.Count));
    TextColor(4);
    WriteLn(' CLOSE POSITION ORDER : ' + IntToStr(CLOSE_POSITION_ORDER.Count));
  end;
  TextColor(15);
  WriteLn('-----------------------------------------------');
  WriteLn('');
  TextColor(14);
end;

procedure OrderCreateClosePosition;
var
  TMP: string = '';
  p: double;
begin
  if (CLOSE_POSITION_ORDER.Count > 0) then
  begin
    case EXCHANGE of
      'BINANCE_F':
        if CancelOrderBinanceFutures(CLOSE_POSITION_ORDER[0]) then
          CLOSE_POSITION_ORDER.Delete(0);
      'BYBIT_F':
        if CancelOrderBybitFutures(CLOSE_POSITION_ORDER[0]) then
          CLOSE_POSITION_ORDER.Delete(0);
    end;
  end;

  case EXCHANGE of
    'BINANCE_F':
      repeat
        p := GetHistoryFuturesBinance;
      until p <> -1;
    'BYBIT_F':
      repeat
      until GetPositionBybit;
  end;

  if POSITION_MODE = 'OneWay' then
  begin
    if STRATEG = 'L' then
      case EXCHANGE of
        'BINANCE_F': TMP := CreateOrderBinanceFutures('BOTH', 'SELL', 'LIMIT', FloatToStr(p, fs), FloatToStr(POSITION_VOLUME, fs), FloatToStr(CutDec(PRICE_POSITION, DEC_PRICE), fs));
        'BYBIT_F': TMP := CreateOrderBybitFutures('true', 'Sell', 'Limit', FloatToStr(CutDec(PRICE_POSITION + (PRICE_POSITION * (PROFIT) / 100), DEC_PRICE), fs), FloatToStr(POSITION_NATIONAL, fs),
            FloatToStr(CutDec(PRICE_POSITION, DEC_PRICE), fs));
      end;

    if STRATEG = 'S' then
      case EXCHANGE of
        'BINANCE_F': TMP := CreateOrderBinanceFutures('BOTH', 'BUY', 'LIMIT', FloatToStr(p, fs), FloatToStr(POSITION_VOLUME, fs), FloatToStr(CutDec(PRICE_POSITION, DEC_PRICE), fs));
        'BYBIT_F': TMP := CreateOrderBybitFutures('true', 'Buy', 'Limit', FloatToStr(CutDec(PRICE_POSITION - (PRICE_POSITION * (PROFIT) / 100), DEC_PRICE), fs), FloatToStr(POSITION_NATIONAL, fs),
            FloatToStr(CutDec(PRICE_POSITION, DEC_PRICE), fs));
      end;
  end;

  if POSITION_MODE = 'Hedge' then
  begin
    if STRATEG = 'L' then
      case EXCHANGE of
        'BINANCE_F': TMP := CreateOrderBinanceFutures('LONG', 'SELL', 'LIMIT', FloatToStr(p, fs), FloatToStr(POSITION_VOLUME, fs), FloatToStr(CutDec(PRICE_POSITION, DEC_PRICE), fs));
        'BYBIT_F': TMP := CreateOrderBybitFutures('true', 'Sell', 'Limit', FloatToStr(CutDec(PRICE_POSITION + (PRICE_POSITION * (PROFIT) / 100), DEC_PRICE), fs), FloatToStr(POSITION_NATIONAL, fs),
            FloatToStr(CutDec(PRICE_POSITION, DEC_PRICE), fs));
      end;

    if STRATEG = 'S' then
      case EXCHANGE of
        'BINANCE_F': TMP := CreateOrderBinanceFutures('SHORT', 'BUY', 'LIMIT', FloatToStr(p, fs), FloatToStr(POSITION_VOLUME, fs), FloatToStr(CutDec(PRICE_POSITION, DEC_PRICE), fs));
        'BYBIT_F': TMP := CreateOrderBybitFutures('true', 'Buy', 'Limit', FloatToStr(CutDec(PRICE_POSITION - (PRICE_POSITION * (PROFIT) / 100), DEC_PRICE), fs), FloatToStr(POSITION_NATIONAL, fs),
            FloatToStr(CutDec(PRICE_POSITION, DEC_PRICE), fs));
      end;
  end;

  if (TMP <> 'FALSE') then
  begin
    TextColor(2);
    WriteLn(' + CLOSE POSITION ORDER CREATE ID : ' + TMP);
    TextColor(15);
    case EXCHANGE of
      'BINANCE_F':
      begin
        repeat
        until LoadAllOrdersBinanceFutures;
      end;
      'BYBIT_F':
      begin
        repeat
        until LoadAllOrdersBybitFutures;
      end;
    end;
    NEW_PROFIT := PROFIT;
    LAST_POSITION_VOLUME := POSITION_VOLUME;
    Save;
  end;
end;

procedure OrderCreate;
var
  i: integer;
  TMP: string;
begin
  try
    if (OPEN_POSITION_ORDER.Count = 0) and (CLOSE_POSITION_ORDER.Count = 0) and (POSITION_VOLUME = 0) then
    begin
      TextColor(14);
      WriteLn('');
      WriteLn('-----------------------------------------------');
      WriteLn(' "NEW" WE WORK ON THE CREATION OF ORDERS ');

      TIME_FIRST_ORDER := GetTime;
      LAST_POSITION_VOLUME := 0;

      case EXCHANGE of
        'BINANCE_F':
          repeat
          until BalanceBinanceFutures;
        'BYBIT_F':
          repeat
          until BalanceBybitFutures;
      end;

      case EXCHANGE of
        'BINANCE_F':
          repeat
          until MarketBinanceFutures;
        'BYBIT_F':
          repeat
          until MarketBybitFutures;
      end;


      USES_DEPOSIT := ((VAL_1_BALANS * CREDIT) * LIMIT_DEPOSIT) / 100;
      STOPLOOS_DEPOSIT := VAL_1_BALANS;
      DEPOSIT_ORDERS := CutDec(USES_DEPOSIT * DEPOSIT_ORDERS / 100, DEC_MIN_VAL_1);
      if CutDec(DEPOSIT_ORDERS, DEC_MIN_VAL_1) < MIN_VAL_1 then  DEPOSIT_ORDERS := MIN_VAL_1;

      if STRATEG = 'L' then
      begin
        PRICE_ORDER := CutDec(BIDS - (BIDS * FIRST_STEP / 100), DEC_PRICE);
        PRICE_RELOAD := CutDec(BIDS + (BIDS * RELOAD / 100), DEC_PRICE);
      end;

      if STRATEG = 'S' then
      begin
        PRICE_ORDER := CutDec(ASKS + (ASKS * FIRST_STEP / 100), DEC_PRICE);
        PRICE_RELOAD := CutDec(ASKS - (ASKS * RELOAD / 100), DEC_PRICE);
      end;

      AMMOUNT_ORDER := MIN_VAL_2;

      repeat
        if CutDec(PRICE_ORDER * AMMOUNT_ORDER, DEC_MIN_VAL_1) < DEPOSIT_ORDERS then
          AMMOUNT_ORDER := CutDec(AMMOUNT_ORDER + QTY_STEP, DEC_MIN_VAL_2);
      until (AMMOUNT_ORDER >= MIN_VAL_2) and (CutDec(PRICE_ORDER * AMMOUNT_ORDER, DEC_MIN_VAL_1) >= DEPOSIT_ORDERS);

      TOTAL_AMMOUNT := 0;
      TEMP_STEP := ORDERS_STEP;
      NEXT_DEPOSIT_ORDER := CutDec(PRICE_ORDER * AMMOUNT_ORDER, DEC_MIN_VAL_1);

      Writeln(' MIN_VAL_1 ' + FloatToStr(MIN_VAL_1, FS));
      Writeln(' MIN_VAL_2 ' + FloatToStr(MIN_VAL_2, FS));
      Writeln(' DEC_MIN_VAL_1 ' + IntToStr(DEC_MIN_VAL_1));
      Writeln(' DEC_MIN_VAL_2 ' + IntToStr(DEC_MIN_VAL_2));
      Writeln(' DEC_PRICE ' + IntToStr(DEC_PRICE));
      Writeln(' QTY_STEP ' + FloatToStr(QTY_STEP, FS));
      WriteLn('+++++++++++++++++++++++++++++++++++++++++++++++');
      Writeln(' DEPOSIT_ORDERS ' + FloatToStr(PRICE_ORDER * AMMOUNT_ORDER, FS));
      Writeln(' AMMOUNT_ORDER ' + FloatToStr(AMMOUNT_ORDER, FS));
      Writeln(' PRICE_ORDER ' + FloatToStr(PRICE_ORDER, FS));
      Writeln(' USES_DEPOSIT ' + FloatToStr(USES_DEPOSIT, FS));
      Writeln(' NEXT_DEPOSIT_ORDER > ' + FloatToStr(NEXT_DEPOSIT_ORDER, FS));
      TextColor(14);
      WriteLn('');
      WriteLn('-----------------------------------------------');
      Save;
    end;

    for i := OPEN_POSITION_ORDER.Count to OPEN_ORDERS - 1 do
    begin

      if POSITION_MODE = 'OneWay' then
      begin
        if STRATEG = 'L' then
          case EXCHANGE of
            'BINANCE_F': TMP := CreateOrderBinanceFutures('BOTH', 'BUY', 'LIMIT', FloatToStr(PRICE_ORDER, fs), FloatToStr(AMMOUNT_ORDER, fs), '0');
            'BYBIT_F': TMP := CreateOrderBybitFutures('false', 'Buy', 'Limit', FloatToStr(PRICE_ORDER, fs), FloatToStr(AMMOUNT_ORDER, fs), '0');
          end;

        if STRATEG = 'S' then
          case EXCHANGE of
            'BINANCE_F': TMP := CreateOrderBinanceFutures('BOTH', 'SELL', 'LIMIT', FloatToStr(PRICE_ORDER, fs), FloatToStr(AMMOUNT_ORDER, fs), '0');
            'BYBIT_F': TMP := CreateOrderBybitFutures('false', 'Sell', 'Limit', FloatToStr(PRICE_ORDER, fs), FloatToStr(AMMOUNT_ORDER, fs), '0');
          end;
      end;

      if POSITION_MODE = 'Hedge' then
      begin
        if STRATEG = 'L' then
          case EXCHANGE of
            'BINANCE_F': TMP := CreateOrderBinanceFutures('LONG', 'BUY', 'LIMIT', FloatToStr(PRICE_ORDER, fs), FloatToStr(AMMOUNT_ORDER, fs), '0');
            'BYBIT_F': TMP := CreateOrderBybitFutures('false', 'Buy', 'Limit', FloatToStr(PRICE_ORDER, fs), FloatToStr(AMMOUNT_ORDER, fs), '0');
          end;

        if STRATEG = 'S' then
          case EXCHANGE of
            'BINANCE_F': TMP := CreateOrderBinanceFutures('SHORT', 'SELL', 'LIMIT', FloatToStr(PRICE_ORDER, fs), FloatToStr(AMMOUNT_ORDER, fs), '0');
            'BYBIT_F': TMP := CreateOrderBybitFutures('false', 'Sell', 'Limit', FloatToStr(PRICE_ORDER, fs), FloatToStr(AMMOUNT_ORDER, fs), '0');
          end;
      end;

      if (TMP <> 'FALSE') then
      begin
        TextColor(2);
        WriteLn(' + OPEN POSITION ORDER CREATE ID : ' + TMP + ' PRICE : ' + FloatToStr(PRICE_ORDER, FS));
        TextColor(15);
        OPEN_POSITION_ORDER.add(TMP);

        TOTAL_AMMOUNT := TOTAL_AMMOUNT + (PRICE_ORDER * AMMOUNT_ORDER);

        if STRATEG = 'L' then
          if (NEXT_ORDER_RSI = True) then
            PRICE_ORDER := CutDec(BIDS - (BIDS * TEMP_STEP / 100), DEC_PRICE)
          else
            PRICE_ORDER := CutDec(PRICE_ORDER - (PRICE_ORDER * TEMP_STEP / 100), DEC_PRICE);

        if STRATEG = 'S' then
          if (NEXT_ORDER_RSI = True) then
            PRICE_ORDER := CutDec(ASKS + (ASKS * TEMP_STEP / 100), DEC_PRICE)
          else
            PRICE_ORDER := CutDec(PRICE_ORDER + (PRICE_ORDER * TEMP_STEP / 100), DEC_PRICE);

        TEMP_STEP := TEMP_STEP + (TEMP_STEP * RATIO);
        NEXT_DEPOSIT_ORDER := CutDec(NEXT_DEPOSIT_ORDER + (NEXT_DEPOSIT_ORDER * MARTINGALE / 100), DEC_MIN_VAL_1);

        if X2 = False then
        begin
          repeat
            if CutDec(PRICE_ORDER * AMMOUNT_ORDER, DEC_MIN_VAL_1) < NEXT_DEPOSIT_ORDER then
              AMMOUNT_ORDER := CutDec(AMMOUNT_ORDER + QTY_STEP, DEC_MIN_VAL_2);
          until (AMMOUNT_ORDER >= MIN_VAL_2) and (CutDec(PRICE_ORDER * AMMOUNT_ORDER, DEC_MIN_VAL_1) >= NEXT_DEPOSIT_ORDER);
        end
        else
        begin
          repeat
            if CutDec(PRICE_ORDER * AMMOUNT_ORDER, DEC_MIN_VAL_1) < TOTAL_AMMOUNT * 2 then
              AMMOUNT_ORDER := CutDec(AMMOUNT_ORDER + QTY_STEP, DEC_MIN_VAL_2);
          until (AMMOUNT_ORDER >= MIN_VAL_2) and (CutDec(PRICE_ORDER * AMMOUNT_ORDER, DEC_MIN_VAL_1) >= TOTAL_AMMOUNT * 2);
        end;

        NEXT_DEPOSIT_ORDER := CutDec(PRICE_ORDER * AMMOUNT_ORDER, DEC_MIN_VAL_1);
        Writeln(' NEXT_AMMOUNT_ORDER > ' + FloatToStr(AMMOUNT_ORDER, FS));
        Writeln(' NEXT_DEPOSIT_ORDER > ' + FloatToStr(NEXT_DEPOSIT_ORDER, FS));
        Save;

        if (TOTAL_AMMOUNT + NEXT_DEPOSIT_ORDER > USES_DEPOSIT) or (NEXT_ORDER_RSI = True) then break;
      end
      else
        Break;
    end;

  except
    on E: Exception do
    begin
      TextColor(12);
      WriteLn(' ! ERROR > ' + E.Message + ' OrderCreateBuy');
      TextColor(15);
    end;
  end;
end;

procedure CheckOrderClosePosition;
var
  TMP: boolean = False;
begin
  Textcolor(10);
  Writeln(' >>> CHECK PROFIT ORDER : ' + CLOSE_POSITION_ORDER[0]);
  Textcolor(15);

  case EXCHANGE of
    'BINANCE_F': TMP := CheckOrderFuturesBinance(CLOSE_POSITION_ORDER[0]);
    'BYBIT_F': TMP := CheckOrderFuturesBybit(CLOSE_POSITION_ORDER[0]);
  end;

  if TMP = True then
  begin
    WriteLn(' ! ORDER FIILED !');
    case EXCHANGE of
      'BINANCE_F':
        repeat
        until GetPositionBinance;
      'BYBIT_F':
        repeat
        until GetPositionBybit;
    end;

    if (POSITION_VOLUME <> 0) then
    begin
      case EXCHANGE of
        'BINANCE_F':
        begin
          repeat
          until LoadAllOrdersBinanceFutures;
        end;
        'BYBIT_F':
        begin
          repeat
          until LoadAllOrdersBybitFutures;
        end;
      end;
    end;

    if (POSITION_VOLUME = 0) then
    begin
      case EXCHANGE of
        'BINANCE_F':
        begin
          repeat
          until CancelAllOpenOrdersFuturesBinance;
          repeat
          until LoadAllOrdersBinanceFutures;
        end;
        'BYBIT_F':
        begin
          repeat
          until CancelAllOpenOrdersFuturesBybit;
          repeat
          until LoadAllOrdersBybitFutures;
        end;
      end;
      LAST_POSITION_VOLUME := 0;
    end;
  end;
end;

end.
