unit futuresLS;

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

procedure WorkFuturesLS;
procedure OrderCreateLong();
procedure OrderCreateShort();

implementation

procedure WorkFuturesLS;
var
  StopWork: boolean = False;
begin
  WriteLn(' Wellcome Futures Long&Short');
  WriteLn('');

  case EXCHANGE of
    'BINANCE_F_LS': begin
      ChangePositionModeBinance;
      ChangeMarginTypeBinance;
      SwitchLevelBinance;
    end;
    'BYBIT_F_LS': begin
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
    'BINANCE_F_LS':
      repeat
      until GetLimitBinanceFutures;
    'BYBIT_F_LS':
      repeat
      until GetLimitBybitFutures;
  end;

  case EXCHANGE of
    'BINANCE_F_LS':
      repeat
      until BalanceBinanceFutures;
    'BYBIT_F_LS':
      repeat
      until BalanceBybitFutures;
  end;

  while not StopWork do
  begin
    LoadSettings;

    case EXCHANGE of
      'BINANCE_F_LS':
        repeat
        until GetRsiBinanceFuturesRSIShoot(CB_TIME_FRAME);
      'BYBIT_F_LS':
        repeat
        until GetRsiBybitFuturesRSIShoot(CB_TIME_FRAME);
    end;

    case EXCHANGE of
      'BINANCE_F_LS':
        repeat
        until BalanceBinanceFutures;
      'BYBIT_F_LS':
        repeat
        until BalanceBybitFutures;
    end;

    case EXCHANGE of
      'BINANCE_F_LS':
        repeat
        until MarketBinanceFutures;
      'BYBIT_F_LS':
        repeat
        until MarketBybitFutures;
    end;

    case EXCHANGE of
      'BINANCE_F_LS':
        repeat
        until GetPositionLSBinance;
      'BYBIT_F_LS':
        repeat
        until GetPositionLSBybit;
    end;

    // close position
    if ((PNL_LONG > 0) and (SHOOT_SHORT = True)) then
    begin
      WriteLn(' CLOSE LONG >>>');
      STRATEG := 'L';
      case EXCHANGE of
        'BINANCE_F_LS': CreateOrderBinanceFutures('LONG', 'SELL', 'MARKET', FloatToStr(0, fs), FloatToStr(POSITION_NATIONAL_LONG, fs), '0');
        'BYBIT_F_LS': CreateOrderBybitFutures('true', 'Sell', 'Market', FloatToStr(0, fs), FloatToStr(POSITION_NATIONAL_LONG, fs), '0');
      end;
    end;

    if ((PNL_SHORT > 0) and (SHOOT_LONG = True)) then
    begin
      WriteLn(' CLOSE SHORT >>>');
      STRATEG := 'S';
      case EXCHANGE of
        'BINANCE_F_LS': CreateOrderBinanceFutures('SHORT', 'BUY', 'MARKET', FloatToStr(0, fs), FloatToStr(POSITION_NATIONAL_SHORT, fs), '0');
        'BYBIT_F_LS': CreateOrderBybitFutures('true', 'Buy', 'Market', FloatToStr(0, fs), FloatToStr(POSITION_NATIONAL_SHORT, fs), '0');
      end;
    end;
    //===============

    // Остановка бота
    if ((STOP = 1) and (POSITION_VOLUME_LONG = 0) and (POSITION_VOLUME_SHORT = 0)) then
    begin
      TextColor(4);
      WriteLn('');
      WriteLn('-----------------------------------------------');
      WriteLn(' WORK PROCEDURE STOP BOT');
      TextColor(4);
      Writeln(' BOT STOPED, CLOSE PROGRAMM!');
      WriteLn('-----------------------------------------------');
      Readln;
      Break;
    end;

    // LONG OPEN
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
      if ((POSITION_VOLUME_LONG > 0) and (NEXT_ORDER_RSI = False) and (PRICE_ORDER_LONG >= ASKS)) then
        OrderCreateLong;
    end;

    // SHORT OPEN
    if ((POSITION_VOLUME_SHORT = 0) and (STOP = 0)) then
    begin
      if ((FIRST_RSI_ORDER = True) and (SHOOT_SHORT = True)) then
        OrderCreateShort;
      if (FIRST_RSI_ORDER = False) then
        OrderCreateShort;
    end
    else
    begin
      if ((POSITION_VOLUME_SHORT > 0) and (NEXT_ORDER_RSI = True) and (PRICE_ORDER_SHORT <= BIDS) and (SHOOT_SHORT = True)) then
        OrderCreateShort;
      if ((POSITION_VOLUME_SHORT > 0) and (NEXT_ORDER_RSI = False) and (PRICE_ORDER_SHORT <= BIDS)) then
        OrderCreateShort;
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
    WriteLn(' > MINIMUM PNL LONG: ' + FloatToStr(POSITION_VOLUME_LONG * PROFIT / 100, fs));
    WriteLn(' POSITION VOLUME LONG: ' + FloatToStr(POSITION_VOLUME_LONG, fs));
    WriteLn(' POSITION NATIONAL LONG: ' + FloatToStr(POSITION_NATIONAL_LONG, fs));
    WriteLn(' + NEXT LONG ORDER MIN PRICE: ' + FloatToStr(PRICE_ORDER_LONG, fs));
    WriteLn('');
    TextColor(4);
    WriteLn(' > PNL SHORT : ' + FloatToStr(PNL_SHORT, fs));
    WriteLn(' > MINIMUM PNL SHORT: ' + FloatToStr(POSITION_VOLUME_SHORT * PROFIT / 100, fs));
    WriteLn(' POSITION VOLUME SHORT: ' + FloatToStr(POSITION_VOLUME_SHORT, fs));
    WriteLn(' POSITION NATIONAL SHORT: ' + FloatToStr(POSITION_NATIONAL_SHORT, fs));
    WriteLn(' + NEXT SHORT ORDER MIN PRICE: ' + FloatToStr(PRICE_ORDER_SHORT, fs));
    TextColor(15);
    WriteLn('-----------------------------------------------');
    Writeln('');
    //==============
  end;
end;

procedure OrderCreateLong();
begin
  WriteLn('');
  TextColor(10);
  WriteLn('++++ ORDER CREATE LONG ++++');
  if (POSITION_VOLUME_LONG = 0) then
  begin
    TextColor(10);
    Writeln('LOAD BALANCE ...');
    case EXCHANGE of
      'BINANCE_F_LS':
        repeat
        until BalanceBinanceFutures;
      'BYBIT_F_LS':
        repeat
        until BalanceBybitFutures;
    end;
    TextColor(10);
    Writeln(' LOAD MARKET PRICE ...');
    case EXCHANGE of
      'BINANCE_F_LS':
        repeat
        until MarketBinanceFutures;
      'BYBIT_F_LS':
        repeat
        until MarketBybitFutures;
    end;

    TEMP_STEP_LONG := ORDERS_STEP;
    USES_DEPOSIT := ((VAL_1_BALANS * CREDIT) * LIMIT_DEPOSIT) / 100;
    TEMP_DEPOSIT_ORDER_LONG := CutDec(USES_DEPOSIT * DEPOSIT_ORDERS / 100, DEC_MIN_VAL_1);

    if TEMP_DEPOSIT_ORDER_LONG < MIN_VAL_1 then  TEMP_DEPOSIT_ORDER_LONG := MIN_VAL_1;
    AMMOUNT_ORDER_LONG := MIN_VAL_2;

    repeat
      if CutDec(ASKS * AMMOUNT_ORDER_LONG, DEC_MIN_VAL_1) < TEMP_DEPOSIT_ORDER_LONG then
        AMMOUNT_ORDER_LONG := CutDec(AMMOUNT_ORDER_LONG + QTY_STEP, DEC_MIN_VAL_2);
    until (AMMOUNT_ORDER_LONG >= MIN_VAL_2) and (CutDec(ASKS * AMMOUNT_ORDER_LONG, DEC_MIN_VAL_1) >= TEMP_DEPOSIT_ORDER_LONG);
  end;


  TextColor(10);
  Writeln(' CREATE ORDER ...');
  STRATEG := 'L';
  case EXCHANGE of
    'BINANCE_F_LS': CreateOrderBinanceFutures('LONG', 'BUY', 'MARKET', FloatToStr(0, fs), FloatToStr(AMMOUNT_ORDER_LONG, fs), '0');
    'BYBIT_F_LS': CreateOrderBybitFutures('false', 'Buy', 'Market', FloatToStr(0, fs), FloatToStr(AMMOUNT_ORDER_LONG, fs), '0');
  end;

  PRICE_ORDER_LONG := CutDec(ASKS - (ASKS * TEMP_STEP_LONG / 100), DEC_PRICE);
  TEMP_DEPOSIT_ORDER_LONG := CutDec(TEMP_DEPOSIT_ORDER_LONG + (TEMP_DEPOSIT_ORDER_LONG * MARTINGALE / 100), DEC_MIN_VAL_1);

  if X2 = False then
  begin
    repeat
      if CutDec(PRICE_ORDER_LONG * AMMOUNT_ORDER_LONG, DEC_MIN_VAL_1) < TEMP_DEPOSIT_ORDER_LONG then
        AMMOUNT_ORDER_LONG := CutDec(AMMOUNT_ORDER_LONG + QTY_STEP, DEC_MIN_VAL_2);
    until (AMMOUNT_ORDER_LONG >= MIN_VAL_2) and (CutDec(PRICE_ORDER_LONG * AMMOUNT_ORDER_LONG, DEC_MIN_VAL_1) >= TEMP_DEPOSIT_ORDER_LONG);
  end
  else
  begin
    repeat
      if CutDec(PRICE_ORDER_LONG * AMMOUNT_ORDER_LONG, DEC_MIN_VAL_1) < TEMP_DEPOSIT_ORDER_LONG * 2 then
        AMMOUNT_ORDER_LONG := CutDec(AMMOUNT_ORDER_LONG + QTY_STEP, DEC_MIN_VAL_2);
    until (AMMOUNT_ORDER_LONG >= MIN_VAL_2) and (CutDec(PRICE_ORDER_LONG * AMMOUNT_ORDER_LONG, DEC_MIN_VAL_1) >= TEMP_DEPOSIT_ORDER_LONG * 2);
  end;

  TEMP_STEP_LONG := TEMP_STEP_LONG + (TEMP_STEP_LONG * RATIO);
  Save;
end;

procedure OrderCreateShort();
begin
  WriteLn('');
  TextColor(10);
  WriteLn('++++ ORDER CREATE SHORT ++++');
  if (POSITION_VOLUME_SHORT = 0) then
  begin
    TextColor(10);
    Writeln(' LOAD BALANCE ...');
    case EXCHANGE of
      'BINANCE_F_LS':
        repeat
        until BalanceBinanceFutures;
      'BYBIT_F_LS':
        repeat
        until BalanceBybitFutures;
    end;
    TextColor(10);
    Writeln(' LOAD MARKET PRICE ...');
    case EXCHANGE of
      'BINANCE_F_LS':
        repeat
        until MarketBinanceFutures;
      'BYBIT_F_LS':
        repeat
        until MarketBybitFutures;
    end;

    TEMP_STEP_SHORT := ORDERS_STEP;
    USES_DEPOSIT := ((VAL_1_BALANS * CREDIT) * LIMIT_DEPOSIT) / 100;
    TEMP_DEPOSIT_ORDER_SHORT := CutDec(USES_DEPOSIT * DEPOSIT_ORDERS / 100, DEC_MIN_VAL_1);

    if TEMP_DEPOSIT_ORDER_SHORT < MIN_VAL_1 then  TEMP_DEPOSIT_ORDER_SHORT := MIN_VAL_1;
    AMMOUNT_ORDER_SHORT := MIN_VAL_2;

    repeat
      if CutDec(ASKS * AMMOUNT_ORDER_SHORT, DEC_MIN_VAL_1) < TEMP_DEPOSIT_ORDER_SHORT then
        AMMOUNT_ORDER_SHORT := CutDec(AMMOUNT_ORDER_SHORT + QTY_STEP, DEC_MIN_VAL_2);
    until (AMMOUNT_ORDER_SHORT >= MIN_VAL_2) and (CutDec(ASKS * AMMOUNT_ORDER_SHORT, DEC_MIN_VAL_1) >= TEMP_DEPOSIT_ORDER_SHORT);
  end;


  TextColor(10);
  Writeln(' CREATE ORDER ...');
  STRATEG := 'S';
  case EXCHANGE of
    'BINANCE_F_LS': CreateOrderBinanceFutures('SHORT', 'SELL', 'MARKET', FloatToStr(0, fs), FloatToStr(AMMOUNT_ORDER_SHORT, fs), '0');
    'BYBIT_F_LS': CreateOrderBybitFutures('false', 'Sell', 'Market', FloatToStr(0, fs), FloatToStr(AMMOUNT_ORDER_SHORT, fs), '0');
  end;

  PRICE_ORDER_SHORT := CutDec(BIDS + (BIDS * TEMP_STEP_SHORT / 100), DEC_PRICE);
  TEMP_DEPOSIT_ORDER_SHORT := CutDec(TEMP_DEPOSIT_ORDER_SHORT + (TEMP_DEPOSIT_ORDER_SHORT * MARTINGALE / 100), DEC_MIN_VAL_1);

  if X2 = False then
  begin
    repeat
      if CutDec(PRICE_ORDER_SHORT * AMMOUNT_ORDER_SHORT, DEC_MIN_VAL_1) < TEMP_DEPOSIT_ORDER_SHORT then
        AMMOUNT_ORDER_SHORT := CutDec(AMMOUNT_ORDER_SHORT + QTY_STEP, DEC_MIN_VAL_2);
    until (AMMOUNT_ORDER_SHORT >= MIN_VAL_2) and (CutDec(PRICE_ORDER_SHORT * AMMOUNT_ORDER_SHORT, DEC_MIN_VAL_1) >= TEMP_DEPOSIT_ORDER_SHORT);
  end
  else
  begin
    repeat
      if CutDec(PRICE_ORDER_SHORT * AMMOUNT_ORDER_SHORT, DEC_MIN_VAL_1) < TEMP_DEPOSIT_ORDER_SHORT * 2 then
        AMMOUNT_ORDER_SHORT := CutDec(AMMOUNT_ORDER_SHORT + QTY_STEP, DEC_MIN_VAL_2);
    until (AMMOUNT_ORDER_SHORT >= MIN_VAL_2) and (CutDec(PRICE_ORDER_SHORT * AMMOUNT_ORDER_SHORT, DEC_MIN_VAL_1) >= TEMP_DEPOSIT_ORDER_SHORT * 2);
  end;

  TEMP_STEP_SHORT := TEMP_STEP_SHORT + (TEMP_STEP_SHORT * RATIO);
  Save();
end;

end.
