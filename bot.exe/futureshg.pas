unit futuresHG;

{$mode ObjFPC}{$H+}

interface

uses
  Classes,
  SysUtils,
  CRT,
  var_bot,
  load_settings,
  api_binance_futures,
  api_bybit_futures;

procedure WorkFuturesHG;
procedure OrderCreateLong();
procedure OrderCreateShort();
procedure OrderCreateSL();
procedure OrderCreateClosePosition;
procedure CheckOrderOpenPosition;
procedure CheckOrderClosePosition;
procedure CheckOrderSLPosition;
procedure OrderCreateHedg;

var
  LONG_CLOSE_VOLUME: double;

implementation

procedure WorkFuturesHG;
var
  StopWork: boolean = False;
begin
  try
    WriteLn(' Wellcome Futures Long&Short Hedge');
    WriteLn('');

    case EXCHANGE of
      'BINANCE_F_HG': begin
        ChangePositionModeBinance;
        ChangeMarginTypeBinance;
        SwitchLevelBinance;
      end;
      'BYBIT_F_HG': begin
        repeat
        until PositionModeSwitchBybit;
        repeat
        until SwitchLevelBybit;
        repeat
        until SetLeverageBybit;
      end;
    end;

    // Загружаем лимиты и делители с биржи
    case EXCHANGE of
      'BINANCE_F_HG':
        repeat
        until GetLimitBinanceFutures;
      'BYBIT_F_HG':
        repeat
        until GetLimitBybitFutures;
    end;


    STRATEG := 'L';
    case EXCHANGE of
      'BINANCE_F_HG':
        repeat
        until LoadAllOrdersBinanceFutures;
      'BYBIT_F_HG':
        repeat
        until LoadAllOrdersBybitFutures;
    end;

    while not StopWork do
    begin
      LoadSettings;

      if (OPEN_POSITION_ORDER.Count > 0) then CheckOrderOpenPosition;
      if (CLOSE_POSITION_ORDER.Count > 0) then CheckOrderClosePosition;

      case EXCHANGE of
        'BINANCE_F_HG':
          repeat
          until GetPositionLSBinance;
        'BYBIT_F_HG':
          repeat
          until GetPositionLSBybit;
      end;

      // CLOSE POSITION LONG !!!!!!!
      if ((POSITION_VOLUME_LONG <> 0) and (CLOSE_POSITION_ORDER.Count = 0)) or ((LONG_CLOSE_VOLUME <> POSITION_NATIONAL_LONG) and (CLOSE_POSITION_ORDER.Count > 0)) or ((PROFIT <> NEW_PROFIT) and (CLOSE_POSITION_ORDER.Count > 0)) then
        OrderCreateClosePosition;

      //OPEN SHORT !!!!!!!!!!!!!
      if (POSITION_VOLUME_LONG > 0) then
        if (PNL_SUM_PERCENT < -ABS(STOPLOSS)) then
          if (PNL_SHORT > PNL_LONG) then
            if (CutDec(POSITION_VOLUME_LONG / 3, DEC_MIN_VAL_1) > POSITION_VOLUME_SHORT) then
              if (CutDec((POSITION_VOLUME_LONG / 3) - POSITION_VOLUME_SHORT, DEC_MIN_VAL_1) > MIN_VAL_1) then
                if (CutDec((POSITION_NATIONAL_LONG / 3) - POSITION_NATIONAL_SHORT, DEC_MIN_VAL_2) > MIN_VAL_2) then
                  OrderCreateShort;

      // скидываем шорт в плюсе
      if (POSITION_VOLUME_SHORT > 0) then
        if (POSITION_VOLUME_LONG > 0) then
          if ((PNL_SHORT > PNL_LONG) and (PNL_SHORT > 0)) then
            if (PRICE_POSITION_SHORT > PRICE_POSITION_LONG) then
              if (PRICE_POSITION_SHORT > BIDS) then
              begin
                STRATEG := 'S';
                case EXCHANGE of
                  'BINANCE_F_HG': CreateOrderBinanceFutures('SHORT', 'BUY', 'MARKET', FloatToStr(0, fs), FloatToStr(POSITION_NATIONAL_SHORT, fs), '0');
                  'BYBIT_F_HG': CreateOrderBybitFutures('true', 'Buy', 'Market', FloatToStr(0, fs), FloatToStr(POSITION_NATIONAL_SHORT, fs), '0');
                end;
              end;

      // sl short
      if (POSITION_VOLUME_SHORT > 0) then
        if (SL_ORDER_SHORT.Count = 0) then
          OrderCreateSL;

      // RSI
      if (FIRST_RSI_ORDER = True) or (NEXT_ORDER_RSI = True) then
        case EXCHANGE of
          'BINANCE_F_HG':
            repeat
            until GetRsiBinanceFuturesRSIShoot(CB_TIME_FRAME);
          'BYBIT_F_HG':
            repeat
            until GetRsiBybitFuturesRSIShoot(CB_TIME_FRAME);
        end;

      case EXCHANGE of
        'BINANCE_F_HG':
          repeat
          until MarketBinanceFutures;
        'BYBIT_F_HG':
          repeat
          until MarketBybitFutures;
      end;

      // Перезапуск лонг ордеров
      if ((OPEN_POSITION_ORDER.Count > 0) and (CLOSE_POSITION_ORDER.Count = 0) and (POSITION_VOLUME_LONG = 0) and (BIDS >= PRICE_RELOAD)) or ((OPEN_POSITION_ORDER.Count > 0) and
        (CLOSE_POSITION_ORDER.Count = 0) and (POSITION_VOLUME_LONG = 0) and (LONG_CLOSE_VOLUME <> POSITION_VOLUME_LONG)) then
      begin
        case EXCHANGE of
          'BINANCE_F_HG':
          begin
            repeat
            until CancelAllOpenOrdersFuturesBinance;
            repeat
            until LoadAllOrdersBinanceFutures;
          end;
          'BYBIT_F_HG':
          begin
            repeat
            until CancelAllOpenOrdersFuturesBybit;
            repeat
            until LoadAllOrdersBybitFutures;
          end;
        end;
        LONG_CLOSE_VOLUME := 0;
      end;

      // Остановка бота
      if ((STOP = 1) and (POSITION_VOLUME_LONG = 0)) then
      begin
        TextColor(4);
        WriteLn('');
        WriteLn('-----------------------------------------------');
        WriteLn(' WORK PROCEDURE STOP BOT');
        case EXCHANGE of
          'BINANCE_F_HG':
            repeat
            until CancelAllOpenOrdersFuturesBinance;
          'BYBIT_F_HG':
            repeat
            until CancelAllOpenOrdersFuturesBybit;
        end;
        TextColor(4);
        Writeln(' BOT STOPED, CLOSE PROGRAMM!');
        WriteLn('-----------------------------------------------');
        Readln;
        Break;
      end;

      // OPEN LONG
      if (OPEN_POSITION_ORDER.Count = 0) then
        if ((POSITION_VOLUME_LONG = 0) and (STOP = 0)) then
        begin
          if ((FIRST_RSI_ORDER = True) and (SHOOT_LONG = True)) then
            OrderCreateLong;
          if (FIRST_RSI_ORDER = False) then
            OrderCreateLong;
        end
        else
        begin
          if ((POSITION_VOLUME_LONG > 0) and (NEXT_ORDER_RSI = True) and (PRICE_ORDER_LONG >= ASKS) and (SHOOT_LONG = True)) then
            OrderCreateLong;
          if ((POSITION_VOLUME_LONG > 0) and (NEXT_ORDER_RSI = False)) then
            OrderCreateLong;
        end;

      // WRITE INFO
      TextColor(15);
      WriteLn('');
      WriteLn('-----------------' + TimeToStr(NOW) + '---------------------');
      TextColor(14);
      Writeln(' ASKS : ' + FloatToStr(ASKS, fs) + ' BIDS : ' + FloatToStr(BIDS, fs));
      WriteLn(' BALANS ' + val_1 + ' : ' + FloatToStr(VAL_1_BALANS, fs));
      Writeln(' DEPOSIT LIMIT : ' + FloatToStr(USES_DEPOSIT, FS));
      WriteLn('');
      TextColor(2);
      WriteLn(' > PNL LONG : ' + FloatToStr(PNL_LONG, fs));
      WriteLn(' OPEN POSITION LONG ORDER : ' + IntToStr(OPEN_POSITION_ORDER.Count) + ' NEXT PRICE ORDER : ' + FloatToStr(PRICE_ORDER_LONG, fs));
      WriteLn(' POSITION VOLUME LONG : ' + FloatToStr(POSITION_VOLUME_LONG, fs));
      WriteLn(' POSITION NATIONAL LONG : ' + FloatToStr(POSITION_NATIONAL_LONG, fs));
      WriteLn(' AVG PRICE POSITION LONG : ' + FloatToStr(PRICE_POSITION_LONG, fs));
      WriteLn('');
      TextColor(4);
      WriteLn(' > PNL SHORT : ' + FloatToStr(PNL_SHORT, fs));
      WriteLn(' POSITION VOLUME SHORT : ' + FloatToStr(POSITION_VOLUME_SHORT, fs));
      WriteLn(' POSITION NATIONAL SHORT : ' + FloatToStr(POSITION_NATIONAL_SHORT, fs));
      WriteLn(' AVG PRICE POSITION SHORT : ' + FloatToStr(PRICE_POSITION_SHORT, fs));
      TextColor(15);
      WriteLn('');
      WriteLn(' > PNL SUM : ' + FloatToStr(PNL_LONG + PNL_SHORT, fs));
      WriteLn(' > PNL SUM PERCENT : ' + FloatToStr(PNL_SUM_PERCENT, fs));
      WriteLn('-----------------------------------------------');
      Writeln('');
      //==============
    end;
  except
    on E: Exception do
    begin
      TextColor(12);
      WriteLn(' ! ERROR > ' + E.Message + ' WorkFuturesHG');
      TextColor(15);
    end;
  end;
end;

procedure OrderCreateLong();
var
  TMP: string;
begin
  try
    if ((POSITION_VOLUME_LONG = 0) and (OPEN_POSITION_ORDER.Count = 0) and (CLOSE_POSITION_ORDER.Count = 0)) then
    begin
      TextColor(14);
      WriteLn('');
      WriteLn('-----------------------------------------------');
      WriteLn(' "NEW" WE WORK ON THE CREATION OF ORDERS ');
      TIME_FIRST_ORDER := GetTime;

      TextColor(10);
      Writeln(' LOAD BALANCE ...');
      case EXCHANGE of
        'BINANCE_F_HG':
          repeat
          until BalanceBinanceFutures;
        'BYBIT_F_HG':
          repeat
          until BalanceBybitFutures;
      end;
      TextColor(10);
      Writeln(' LOAD MARKET PRICE ...');
      case EXCHANGE of
        'BINANCE_F_HG':
          repeat
          until MarketBinanceFutures;
        'BYBIT_F_HG':
          repeat
          until MarketBybitFutures;
      end;

      TEMP_STEP_LONG := ORDERS_STEP;
      USES_DEPOSIT := ((VAL_1_BALANS * CREDIT) * LIMIT_DEPOSIT) / 100;
      TEMP_DEPOSIT_ORDER_LONG := CutDec(USES_DEPOSIT * DEPOSIT_ORDERS / 100, DEC_MIN_VAL_1);

      if TEMP_DEPOSIT_ORDER_LONG < MIN_VAL_1 then  TEMP_DEPOSIT_ORDER_LONG := MIN_VAL_1;

      PRICE_ORDER_LONG := CutDec(BIDS - (BIDS * FIRST_STEP / 100), DEC_PRICE);
      PRICE_RELOAD := CutDec(BIDS + (BIDS * RELOAD / 100), DEC_PRICE);

      AMMOUNT_ORDER_LONG := CutDec(TEMP_DEPOSIT_ORDER_LONG / PRICE_ORDER_LONG, DEC_MIN_VAL_2);

      repeat
        if CutDec(PRICE_ORDER_LONG * AMMOUNT_ORDER_LONG, DEC_MIN_VAL_1) < TEMP_DEPOSIT_ORDER_LONG then
          AMMOUNT_ORDER_LONG := CutDec(AMMOUNT_ORDER_LONG + QTY_STEP, DEC_MIN_VAL_2);
      until (AMMOUNT_ORDER_LONG >= MIN_VAL_2) and (CutDec(PRICE_ORDER_LONG * AMMOUNT_ORDER_LONG, DEC_MIN_VAL_1) > TEMP_DEPOSIT_ORDER_LONG);

    end;


    TextColor(10);

    STRATEG := 'L';
    case EXCHANGE of
      'BINANCE_F_HG': TMP := CreateOrderBinanceFutures('LONG', 'BUY', 'LIMIT', FloatToStr(PRICE_ORDER_LONG, fs), FloatToStr(AMMOUNT_ORDER_LONG, fs), '0');
      'BYBIT_F_HG': TMP := CreateOrderBybitFutures('false', 'Buy', 'Limit', FloatToStr(PRICE_ORDER_LONG, fs), FloatToStr(AMMOUNT_ORDER_LONG, fs), '0');
    end;

    if (TMP <> 'FALSE') then
    begin
      TextColor(2);
      WriteLn(' + OPEN POSITION LONG ORDER CREATE ID : ' + TMP + ' PRICE : ' + FloatToStr(PRICE_ORDER_LONG, FS));
      TextColor(15);
      OPEN_POSITION_ORDER.add(TMP);

      PRICE_ORDER_LONG := CutDec(PRICE_ORDER_LONG - (PRICE_ORDER_LONG * TEMP_STEP_LONG / 100), DEC_PRICE);
      TEMP_DEPOSIT_ORDER_LONG := CutDec(TEMP_DEPOSIT_ORDER_LONG + (TEMP_DEPOSIT_ORDER_LONG * MARTINGALE / 100), DEC_MIN_VAL_1);
      AMMOUNT_ORDER_LONG := CutDec(TEMP_DEPOSIT_ORDER_LONG / PRICE_ORDER_LONG, DEC_MIN_VAL_2);

      if X2 = False then
      begin
        repeat
          if CutDec(PRICE_ORDER_LONG * AMMOUNT_ORDER_LONG, DEC_MIN_VAL_1) < TEMP_DEPOSIT_ORDER_LONG then
            AMMOUNT_ORDER_LONG := CutDec(AMMOUNT_ORDER_LONG + QTY_STEP, DEC_MIN_VAL_2);
        until (AMMOUNT_ORDER_LONG >= MIN_VAL_2) and (CutDec(PRICE_ORDER_LONG * AMMOUNT_ORDER_LONG, DEC_MIN_VAL_1) > TEMP_DEPOSIT_ORDER_LONG);
      end
      else
      begin
        repeat
          if CutDec(PRICE_ORDER_LONG * AMMOUNT_ORDER_LONG, DEC_MIN_VAL_1) < TEMP_DEPOSIT_ORDER_LONG * 2 then
            AMMOUNT_ORDER_LONG := CutDec(AMMOUNT_ORDER_LONG + QTY_STEP, DEC_MIN_VAL_2);
        until (AMMOUNT_ORDER_LONG >= MIN_VAL_2) and (CutDec(PRICE_ORDER_LONG * AMMOUNT_ORDER_LONG, DEC_MIN_VAL_1) >= TEMP_DEPOSIT_ORDER_LONG * 2);
      end;

      TEMP_STEP_LONG := TEMP_STEP_LONG + (TEMP_STEP_LONG * RATIO);
    end
    else
    begin
      TextColor(12);
      WriteLn(' - FAIL OPEN POSITION LONG ORDER CREATE ');
      TextColor(15);
    end;

    Save;
  except
    on E: Exception do
    begin
      TextColor(12);
      WriteLn(' ! ERROR > ' + E.Message + ' OrderCreateLong');
      TextColor(15);
    end;
  end;
end;

procedure OrderCreateShort();
var
  TMP: string;
begin
  try
    WriteLn('');
    TextColor(10);
    WriteLn(' ++++ ORDER CREATE SHORT ++++');

    AMMOUNT_ORDER_SHORT := CutDec((POSITION_NATIONAL_LONG / 3) - POSITION_NATIONAL_SHORT, DEC_MIN_VAL_2);

    STRATEG := 'S';
    case EXCHANGE of
      'BINANCE_F_HG': TMP := CreateOrderBinanceFutures('SHORT', 'SELL', 'MARKET', FloatToStr(0, fs), FloatToStr(AMMOUNT_ORDER_SHORT, fs), '0');
      'BYBIT_F_HG': TMP := CreateOrderBybitFutures('false', 'Sell', 'Market', FloatToStr(0, fs), FloatToStr(AMMOUNT_ORDER_SHORT, fs), '0');
    end;

    case EXCHANGE of
      'BINANCE_F_HG':
        repeat
        until GetPositionLSBinance;
      'BYBIT_F_HG':
        repeat
        until GetPositionLSBybit;
    end;

    if (TMP <> 'FALSE') then
      OrderCreateSL();
  except
    on E: Exception do
    begin
      TextColor(12);
      WriteLn(' ! ERROR > ' + E.Message + ' OrderCreateShort');
      TextColor(15);
    end;
  end;
end;

procedure OrderCreateSL();
var
  TMP: string;
  p: double;
begin
  try
    if (SL_ORDER_SHORT.Count > 0) then
    begin
      WriteLn(' - CANCEL ORDER STOPLOOS SHORT');
      case EXCHANGE of
        'BINANCE_F_HG':
          if CancelOrderBinanceFutures(SL_ORDER_SHORT[0]) then
            SL_ORDER_SHORT.Delete(0);
        'BYBIT_F_HG':
          if CancelOrderBybitFutures(SL_ORDER_SHORT[0]) then
            SL_ORDER_SHORT.Delete(0);
      end;
    end;

    if PRICE_POSITION_LONG > PRICE_POSITION_SHORT then
      p := CutDec(PRICE_POSITION_LONG - PRICE_POSITION_SHORT, DEC_PRICE);

    if PRICE_POSITION_SHORT > PRICE_POSITION_LONG then
      p := PRICE_POSITION_LONG;

    if ((POSITION_VOLUME_SHORT > 0) and (SL_ORDER_SHORT.Count = 0)) then
    begin
      WriteLn('');
      TextColor(10);
      WriteLn(' ++++ ORDER CREATE STOPLOOS SHORT ++++');
      STRATEG := 'S';
      case EXCHANGE of
        'BINANCE_F_HG': TMP := CreateOrderBinanceFutures('SHORT', 'BUY', 'STOP_MARKET', FloatToStr(p, fs), FloatToStr(POSITION_NATIONAL_SHORT, fs), FloatToStr(CutDec(PRICE_POSITION_LONG, DEC_PRICE), fs));
        'BYBIT_F_HG': TMP := CreateOrderStopBybitFutures('false', 'Buy', 'Market', FloatToStr(p, fs), FloatToStr(POSITION_NATIONAL_SHORT, fs), FloatToStr(PRICE_POSITION_LONG, fs));
      end;


      if (TMP <> 'FALSE') then
      begin
        TextColor(2);
        WriteLn(' + ORDER STOPLOOS SHORT CREATE ID : ' + TMP);
        TextColor(15);
        STRATEG := 'L';
        case EXCHANGE of
          'BINANCE_F_HG':
          begin
            repeat
            until LoadAllOrdersBinanceFutures;
          end;
          'BYBIT_F_HG':
          begin
            repeat
            until LoadAllOrdersBybitFutures;
          end;
        end;

        Save;
      end
      else
      begin
        TextColor(12);
        WriteLn(' - FAIL ORDER STOPLOOS SHORT CREATE');
        TextColor(15);
      end;
    end;
  except
    on E: Exception do
    begin
      TextColor(12);
      WriteLn(' ! ERROR > ' + E.Message + ' OrderCreateSL');
      TextColor(15);
    end;
  end;
end;

procedure OrderCreateClosePosition;
var
  TMP: string = '';
  p: double;
begin
  WriteLn('');
  TextColor(10);
  WriteLn(' ++++ ORDER CREATE CLOSE LONG ++++');
  Writeln(' CREATE ORDER ...');

  try
    if (CLOSE_POSITION_ORDER.Count > 0) then
    begin
      case EXCHANGE of
        'BINANCE_F_HG':
          if CancelOrderBinanceFutures(CLOSE_POSITION_ORDER[0]) then
            CLOSE_POSITION_ORDER.Delete(0);
        'BYBIT_F_HG':
          if CancelOrderBybitFutures(CLOSE_POSITION_ORDER[0]) then
            CLOSE_POSITION_ORDER.Delete(0);
      end;
    end;

    case EXCHANGE of
      'BINANCE_F_HG':
        repeat
          p := GetHistoryFuturesBinance;
        until p <> -1;
      'BYBIT_F_HG':
        repeat
        until GetPositionBybit;
    end;

    STRATEG := 'L';
    case EXCHANGE of
      'BINANCE_F_HG': TMP := CreateOrderBinanceFutures('LONG', 'SELL', 'LIMIT', FloatToStr(p, fs), FloatToStr(POSITION_NATIONAL_LONG, fs), FloatToStr(CutDec(PRICE_POSITION_LONG, DEC_PRICE), fs));
      'BYBIT_F_HG': TMP := CreateOrderBybitFutures('true', 'Sell', 'Limit', FloatToStr(CutDec(PRICE_POSITION_LONG + (PRICE_POSITION_LONG * PROFIT / 100), DEC_PRICE), fs),
          FloatToStr(POSITION_NATIONAL_LONG, fs), FloatToStr(CutDec(PRICE_POSITION_LONG, DEC_PRICE), fs));
    end;

    if (TMP <> 'FALSE') then
    begin
      TextColor(2);
      WriteLn(' + CLOSE POSITION ORDER CREATE ID : ' + TMP);
      TextColor(15);
      STRATEG := 'L';
      case EXCHANGE of
        'BINANCE_F_HG':
        begin
          repeat
          until LoadAllOrdersBinanceFutures;
        end;
        'BYBIT_F_HG':
        begin
          repeat
          until LoadAllOrdersBybitFutures;
        end;
      end;
      NEW_PROFIT := PROFIT;
      LONG_CLOSE_VOLUME := POSITION_NATIONAL_LONG;
      Save;
      if PRICE_POSITION_SHORT > 0 then OrderCreateSL;
    end
    else
    begin
      TextColor(12);
      WriteLn(' - FAIL CLOSE POSITION ORDER CREATE');
      TextColor(15);
    end;
  except
    on E: Exception do
    begin
      TextColor(12);
      WriteLn(' ! ERROR > ' + E.Message + ' OrderCreateClosePosition');
      TextColor(15);
    end;
  end;
end;

procedure CheckOrderOpenPosition;
var
  TMP: boolean = False;
begin
  try
    Textcolor(10);
    Writeln(' >>> CHECK OPEN LONG ORDER : ' + OPEN_POSITION_ORDER[0]);
    Textcolor(15);

    case EXCHANGE of
      'BINANCE_F_HG': TMP := CheckOrderFuturesBinance(OPEN_POSITION_ORDER[0]);
      'BYBIT_F_HG': TMP := CheckOrderFuturesBybit(OPEN_POSITION_ORDER[0]);
    end;

    if TMP = True then
    begin
      STRATEG := 'L';
      case EXCHANGE of
        'BINANCE_F_HG':
        begin
          repeat
          until LoadAllOrdersBinanceFutures;
        end;
        'BYBIT_F_HG':
        begin
          repeat
          until LoadAllOrdersBybitFutures;
        end;
      end;
    end;
  except
    on E: Exception do
    begin
      TextColor(12);
      WriteLn(' ! ERROR > ' + E.Message + ' CheckOrderOpenPosition');
      TextColor(15);
    end;
  end;
end;

procedure CheckOrderClosePosition;
var
  TMP: boolean = False;
begin
  try
    Textcolor(10);
    Writeln(' >>> CHECK PROFIT ORDER : ' + CLOSE_POSITION_ORDER[0]);
    Textcolor(15);

    case EXCHANGE of
      'BINANCE_F_HG': TMP := CheckOrderFuturesBinance(CLOSE_POSITION_ORDER[0]);
      'BYBIT_F_HG': TMP := CheckOrderFuturesBybit(CLOSE_POSITION_ORDER[0]);
    end;

    if TMP = True then
    begin
      WriteLn(' ! ORDER FIILED LONG !');
      case EXCHANGE of
        'BINANCE_F_HG':
          repeat
          until GetPositionLSBinance;
        'BYBIT_F_HG':
          repeat
          until GetPositionLSBybit;
      end;

      if (POSITION_VOLUME_LONG <> 0) then
      begin
        STRATEG := 'L';
        case EXCHANGE of
          'BINANCE_F_HG':
          begin
            repeat
            until LoadAllOrdersBinanceFutures;
          end;
          'BYBIT_F_HG':
          begin
            repeat
            until LoadAllOrdersBybitFutures;
          end;
        end;
      end;

      if (POSITION_VOLUME_LONG = 0) then
      begin
        case EXCHANGE of
          'BINANCE_F_HG':
          begin
            repeat
            until CancelAllOpenOrdersFuturesBinance;
          end;
          'BYBIT_F_HG':
          begin
            repeat
            until CancelAllOpenOrdersFuturesBybit;
          end;
        end;
      end;
    end;
  except
    on E: Exception do
    begin
      TextColor(12);
      WriteLn(' ! ERROR > ' + E.Message + ' CheckOrderClosePosition');
      TextColor(15);
    end;
  end;
end;

procedure CheckOrderSLPosition;
var
  TMP: boolean = False;
begin
  try
    Textcolor(10);
    Writeln(' >>> CHECK SL ORDER : ' + SL_ORDER_SHORT[0]);
    Textcolor(15);

    case EXCHANGE of
      'BINANCE_F_HG': TMP := CheckOrderFuturesBinance(SL_ORDER_SHORT[0]);
      'BYBIT_F_HG': TMP := CheckOrderFuturesBybit(SL_ORDER_SHORT[0]);
    end;

    if TMP = True then
    begin
      WriteLn(' ! SL ORDER FIILED !');
      STRATEG := 'L';
      case EXCHANGE of
        'BINANCE_F_HG':
        begin
          repeat
          until LoadAllOrdersBinanceFutures;
        end;
        'BYBIT_F_HG':
        begin
          repeat
          until LoadAllOrdersBybitFutures;
        end;
      end;
    end;
  except
    on E: Exception do
    begin
      TextColor(12);
      WriteLn(' ! ERROR > ' + E.Message + ' CheckOrderSLPosition');
      TextColor(15);
    end;
  end;
end;

procedure OrderCreateHedg;
var
  TMP: string;
begin
  try
    if (SL_ORDER_SHORT.Count > 0) then
    begin
      case EXCHANGE of
        'BINANCE_F_HG':
          if CancelOrderBinanceFutures(SL_ORDER_SHORT[0]) then
            SL_ORDER_SHORT.Delete(0);
        'BYBIT_F_HG':
          if CancelOrderBybitFutures(SL_ORDER_SHORT[0]) then
            SL_ORDER_SHORT.Delete(0);
      end;
    end;


    if (SL_ORDER_SHORT.Count = 0) then
    begin
      //PRICE_POSITION_SHORT := CutDec(PRICE_POSITION_LONG, DEC_PRICE);
      PRICE_POSITION_SHORT := CutDec(PRICE_POSITION_SHORT + (PRICE_POSITION_SHORT * 0.4 / 100), DEC_PRICE);

      STRATEG := 'S';
      WriteLn(' CREATE ORDER STOPLOOS SHORT');

      case EXCHANGE of
        'BINANCE_F_HG': TMP := CreateOrderBinanceFutures('SHORT', 'BUY', 'STOP_MARKET', FloatToStr(PRICE_POSITION_SHORT, fs), FloatToStr(POSITION_NATIONAL_SHORT, fs), FloatToStr(CutDec(PRICE_POSITION_SHORT, DEC_PRICE), fs));
        'BYBIT_F_HG': TMP := CreateOrderStopBybitFutures('false', 'Buy', 'Market', FloatToStr(PRICE_POSITION_SHORT, fs), FloatToStr(POSITION_NATIONAL_SHORT, fs), FloatToStr(PRICE_POSITION_SHORT, fs));
      end;


      if (TMP <> 'FALSE') then
      begin
        TextColor(2);
        WriteLn(' + ORDER STOPLOOS SHORT CREATE ID : ' + TMP);
        TextColor(15);
        STRATEG := 'L';
        case EXCHANGE of
          'BINANCE_F_HG':
          begin
            repeat
            until LoadAllOrdersBinanceFutures;
          end;
          'BYBIT_F_HG':
          begin
            repeat
            until LoadAllOrdersBybitFutures;
          end;
        end;
        if SL_ORDER_SHORT.Count > 0 then
          SL_ORDER_SHORT_VOLUME := POSITION_NATIONAL_SHORT;
        Save;
      end;
    end;
  except
    on E: Exception do
    begin
      TextColor(12);
      WriteLn(' ! ERROR > ' + E.Message + ' OrderCreateHedg');
      TextColor(15);
    end;
  end;
end;

end.
