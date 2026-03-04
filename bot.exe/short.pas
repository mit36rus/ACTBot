unit short;

{$mode objfpc}{$H+}

interface

uses
  Classes,
  SysUtils,
  CRT,
  var_bot,
  load_settings,
  api_binance,
  api_bybit;

procedure WorkShort;
procedure CheckBuyOrders;
procedure FastBuyOrder;
procedure OrderCreateBuy;
procedure OrderCancelSell;
procedure OrderCreateSell;

implementation

procedure WorkShort;
var
  StopWork: boolean = False;
begin
  WriteLn(' Wellcome Spot Short');
  WriteLn('');


  case EXCHANGE of
    'BINANCE':
      repeat
      until LoadAllOrdersBinance;
    'BYBIT':
      repeat
      until LoadAllOrdersBybit;
  end;

  // Загружаем лимиты и делители с биржи
  case EXCHANGE of
    'BINANCE':
      repeat
      until GetLimitBinance;
    'BYBIT':
      repeat
      until GetLimitBybit;
  end;

  while not StopWork do
  begin
    LoadSettings;

    // Загружаем RSI
    if (FIRST_RSI_ORDER) or (NEXT_ORDER_RSI) then
    begin
      case EXCHANGE of
        'BINANCE':
          repeat
          until GetRsiBinanceRSIShoot(CB_TIME_FRAME);
        'BYBIT':
          repeat
          until GetRsiBybitRSIShoot(CB_TIME_FRAME);
      end;
    end;

    // проверка BUY ордера
    if (VAL_1_ORDERS.Count > 0) then
    begin
      CheckBuyOrders;
    end;

    // Быстрая остановка
    if (FASTSTOP = 1) and (VAL_1_ORDERS.Count > 0) then
    begin
      FastBuyOrder;
    end;

    // Запрашиваем цены на рынке и текущий баланс
    case EXCHANGE of
      'BINANCE': begin
        repeat
        until GetMarketPriceBinance;
        repeat
        until GetBalanceBinance;
      end;
      'BYBIT': begin
        repeat
        until GetMarketPriceBybit;
        repeat
        until GetBalanceBybit;
      end;
    end;

    // Работа стоплосс
    if (VAL_1_ORDERS.Count > 0) and (VAL_2_ORDERS.Count = 0) and (TOTAL_AMMOUNT + NEXT_DEPOSIT_ORDER >= USES_DEPOSIT) and (LAST_MIN > ASKS) then
    begin
      LAST_MIN := ASKS;
      Save;
    end;

    // создание ордера на покупку или переставляем с новым профитом
    if ((VAL_1_BALANS >= MIN_VAL_1) and (CutDec(VAL_1_BALANS / BIDS, DEC_MIN_VAL_2) >= MIN_VAL_2)) or ((VAL_1_ORDERS.Count > 0) and (NEW_PROFIT <> PROFIT)) then
    begin
      if (VAL_1_ORDERS.Count > 0) and (NEW_PROFIT <> PROFIT) then
      begin
        TextColor(4);
        WriteLn(' >>> Change profit ');
      end;
      OrderCreateBuy;
    end;

    // Остановка бота
    if ((STOP = 1) and (VAL_1_ORDERS.Count = 0) and (VAL_1_BALANS < MIN_VAL_1)) then
    begin
      TextColor(4);
      WriteLn('');
      WriteLn('-----------------------------------------------');
      WriteLn(' Work procedure Stop Bot');
      OrderCancelSell;
      if ((VAL_2_ORDERS.Count = 0) and (VAL_1_BALANS < MIN_VAL_1)) then
      begin
        TextColor(4);
        Writeln(' Bot stoped!');
        WriteLn('-----------------------------------------------');
        Readln;
        Break;
      end;
    end;


    // открытие ордеров
    if ((VAL_2_ORDERS.Count = 0) and (VAL_1_ORDERS.Count = 0) and (VAL_2_BALANS > MIN_VAL_2) and (VAL_1_BALANS < MIN_VAL_1)) then
    begin
      if (FIRST_RSI_ORDER = False) then
      begin
        OrderCreateSell;
      end
      else
      begin
        if ((FIRST_RSI_ORDER = True) and (SHOOT_SHORT = True)) then
        begin
          OrderCreateSell;
        end;
      end;
    end
    else
    begin
      if ((VAL_2_ORDERS.Count < OPEN_ORDERS) and (VAL_2_BALANS > MIN_VAL_2) and (VAL_1_BALANS < MIN_VAL_1) and (TOTAL_AMMOUNT + NEXT_DEPOSIT_ORDER < USES_DEPOSIT)) then
      begin
        if ((FIRST_RSI_ORDER = False) and (NEXT_ORDER_RSI = False)) then
        begin
          OrderCreateSell;
        end
        else
        begin
          if ((FIRST_RSI_ORDER = True) and (NEXT_ORDER_RSI = False)) then
          begin
            OrderCreateSell;
          end
          else
          begin
            if ((NEXT_ORDER_RSI = True) and (ASKS > PRICE_ORDER) and (SHOOT_SHORT = True)) then
            begin
              OrderCreateBuy;
            end;
          end;
        end;
      end;
    end;

    // Перезапуск одеров на покупку
    if ((VAL_2_ORDERS.Count > 0) and (VAL_1_ORDERS.Count = 0) and (ASKS <= PRICE_RELOAD) and (VAL_1_BALANS < MIN_VAL_1)) then
    begin
      TextColor(9);
      WriteLn('');
      WriteLn('-----------------------------------------------');
      WriteLn(' Reload orders');
      OrderCancelSell;
      TextColor(9);
      WriteLn('-----------------------------------------------');
    end;

    // Текстовая информация в консоли
    TextColor(15);
    WriteLn('');
    WriteLn('-----------------------------------------------');
    TextColor(14);
    WriteLn(' Market price Asks : ' + FloatToStr(ASKS, fs) + ' Bids : ' + FloatToStr(BIDS, fs));
    WriteLn(' Price reload : ' + FloatToStr(PRICE_RELOAD, fs));
    WriteLn(' Your balans ' + VAL_1 + ' : ' + FloatToStr(VAL_1_BALANS, fs) + ' ' + VAL_2 + ' : ' + FloatToStr(VAL_2_BALANS, fs));
    TextColor(2);
    WriteLn(' Your open order Buy : ' + IntToStr(VAL_1_ORDERS.Count));
    TextColor(4);
    WriteLn(' Your open order Sell : ' + IntToStr(VAL_2_ORDERS.Count));

    if (VAL_1_ORDERS.Count > 0) and (VAL_2_ORDERS.Count = 0) and (TOTAL_AMMOUNT + NEXT_DEPOSIT_ORDER >= USES_DEPOSIT) then
    begin
      WriteLn(' Price STOPLOSS : ' + FloatToStr(PRICE_ORDER + (PRICE_ORDER * STOPLOSS / 100), fs));
      WriteLn(' Last Min price: ' + FloatToStr(LAST_MIN, fs));
      WriteLn(' Traling STOPLOSS : ' + FloatToStr(LAST_MIN + (LAST_MIN * STOPLOSS / 100), fs));
    end;

    TextColor(3);
    WriteLn(' Limit not more than : ' + FloatToStr(USES_DEPOSIT, fs));
    WriteLn(' Use total ammount + next : ' + FloatToStr(TOTAL_AMMOUNT + NEXT_DEPOSIT_ORDER, fs));
    TextColor(15);
    WriteLn(' $ Total profit : ' + FloatToStr(TOTAL_PROFIT, FS));
    WriteLn('-----------------------------------------------');
    WriteLn('');

    if ((VAL_1_ORDERS.Count > 0) and (VAL_2_ORDERS.Count = 0) and (TOTAL_AMMOUNT + NEXT_DEPOSIT_ORDER >= USES_DEPOSIT) and (PRICE_ORDER + (PRICE_ORDER * STOPLOSS / 100) < ASKS)) and
      ((VAL_1_ORDERS.Count > 0) and (VAL_2_ORDERS.Count = 0) and (TOTAL_AMMOUNT + NEXT_DEPOSIT_ORDER >= USES_DEPOSIT) and (LAST_MIN + (LAST_MIN * STOPLOSS / 100) < ASKS)) then FastBuyOrder;
  end;

end;

procedure CheckBuyOrders;
var
  TMP: string = '';
begin
  try
    TextColor(14);
    WriteLn('');
    WriteLn('-----------------------------------------------');
    repeat
      case EXCHANGE of
        'BINANCE': TMP := CheckOrderBinance(VAL_1_ORDERS[0]);
        'BYBIT': TMP := CheckOrderBybit(VAL_1_ORDERS[0]);
      end;
      TextColor(4);
      WriteLn(' Check BUY order ID ' + VAL_1_ORDERS[0] + ' : ' + TMP);
      TextColor(14);
    until TMP <> 'FALSE';
    WriteLn('-----------------------------------------------');
    WriteLn('');

    if TMP = 'NO' then
    begin
      VAL_1_ORDERS.Clear;
      OrderCancelSell;

      if ((VAL_1_ORDERS.Count = 0) and (VAL_2_ORDERS.Count = 0) and (VAL_1_BALANS < MIN_VAL_1)) then
      begin
        TextColor(13);
        WriteLn('');
        WriteLn(' $ Victory order buy ! ');
        case EXCHANGE of
          'BINANCE':
            repeat
            until LoadProfitBinance;
          'BYBIT':
            repeat
            until LoadProfitBybit;
        end;
        WriteLn(' $ Last profit : ' + FloatToStr(LAST_PROFIT, FS));
        TOTAL_PROFIT := TOTAL_PROFIT + LAST_PROFIT;
      end;
    end;
  except
    on E: Exception do
    begin
      TextColor(12);
      WriteLn(' ! ERROR > ' + E.Message + ' CheckBuyOrders');
      TextColor(15);
    end;
  end;
end;

procedure FastBuyOrder;
var
  TMP: string = '';
  str: string;
begin
  while VAL_1_ORDERS.Count > 0 do
  begin
    case EXCHANGE of
      'BINANCE': TMP := CancelOrderBinance(VAL_1_ORDERS[0]);
      'BYBIT': TMP := CancelOrderBybit(VAL_1_ORDERS[0]);
    end;

    if TMP = 'YES' then VAL_1_ORDERS.Delete(0);

    if TMP = 'NO' then
    begin
      case EXCHANGE of
        'BINANCE': TMP := SearchOrderBinance('BUY');
        'BYBIT': TMP := SearchOrderBybit('BUY');
      end;
    end;

    if TMP = 'NO' then VAL_1_ORDERS.Delete(0);

    if VAL_1_ORDERS.Count = 0 then
    begin
      case EXCHANGE of
        'BINANCE': begin
          repeat
          until GetBalanceBinance;
        end;
        'BYBIT': begin
          repeat
          until GetBalanceBybit;
        end;
      end;
    end;
  end;

  str := FloatToStr(CutDec(VAL_1_BALANS - (VAL_1_BALANS * 0.2 / 100), DEC_MIN_VAL_1), fs);

  case EXCHANGE of
    'BINANCE': TMP := CreateOrderBinance('MARKET', 'BUY', str, '', '');

    'BYBIT': TMP := CreateOrderBybit('MARKET', 'Buy', str, '', '');

  end;

  if TMP = 'NO' then
  begin
    case EXCHANGE of
      'BINANCE': TMP := SearchOrderBinance('BUY');
      'BYBIT': TMP := SearchOrderBybit('BUY');
    end;
  end;

  if TMP <> 'NO' then
  begin
    //VAL_1_ORDERS.Add(TMP);
    TextColor(4);
    WriteLn(' + Order STOPLOSS create ID : ' + TMP);

    case EXCHANGE of
      'BINANCE': begin
        repeat
        until GetBalanceBinance;
      end;
      'BYBIT': begin
        repeat
        until GetBalanceBybit;
      end;
    end;
    OrderCancelSell;
  end;

end;

procedure OrderCreateBuy;
var
  price_sell: double;
  TMP: string = '';
  str: string;
  i: integer;
  tempOrderSell: TStringList;
begin
  try

    while VAL_1_ORDERS.Count > 0 do
    begin
      case EXCHANGE of
        'BINANCE': TMP := CancelOrderBinance(VAL_1_ORDERS[0]);
        'BYBIT': TMP := CancelOrderBybit(VAL_1_ORDERS[0]);
      end;

      if TMP = 'YES' then VAL_1_ORDERS.Delete(0);

      if TMP = 'NO' then
      begin
        case EXCHANGE of
          'BINANCE': TMP := SearchOrderBinance('BUY');
          'BYBIT': TMP := SearchOrderBybit('BUY');
        end;
      end;

      if TMP = 'NO' then VAL_1_ORDERS.Delete(0);

      if VAL_1_ORDERS.Count = 0 then
      begin
        case EXCHANGE of
          'BINANCE': begin
            repeat
            until GetBalanceBinance;
          end;

          'BYBIT': begin
            repeat
            until GetBalanceBybit;
          end;
        end;
      end;
    end;

    case EXCHANGE of
      'BINANCE': price_sell := GetHistoryBinance;
      'BYBIT': price_sell := GetHistoryBybit;
    end;

    if price_sell > -1 then
    begin

      case EXCHANGE of
        'KUCOIN': VAL_1_BALANS := CutDec(VAL_1_BALANS - (VAL_1_BALANS * 0.2 / 100), DEC_MIN_VAL_1);
      end;

      str := FloatToStr(CutDec((VAL_1_BALANS) / price_sell, DEC_MIN_VAL_2), FS);

      case EXCHANGE of
        'BINANCE': TMP := CreateOrderBinance('LIMIT', 'BUY', str, FloatToStrF(price_sell, ffFixed, DEC_PRICE, DEC_PRICE, fs), '');
        'BYBIT': TMP := CreateOrderBybit('LIMIT', 'Buy', str, FloatToStrF(price_sell, ffFixed, DEC_PRICE, DEC_PRICE, fs), '');
      end;

      if TMP = 'NO' then
      begin
        case EXCHANGE of
          'BINANCE': TMP := SearchOrderBinance('BUY');
          'BYBIT': TMP := SearchOrderBybit('BUY');
        end;
      end;

      if TMP <> 'NO' then
      begin
        VAL_1_ORDERS.Add(TMP);
        TextColor(4);
        WriteLn(' + Order BUY create ID : ' + TMP + ' Value : ' + str + ' Price : ' + FloatToStrF(price_sell, ffFixed, DEC_PRICE, DEC_PRICE, fs));
        NEW_PROFIT := PROFIT;
      end;
    end;

    // check sell
    if VAL_2_ORDERS.Count > 0 then
    begin
      WriteLn('');
      WriteLn(' ! Check orders SELL ...');
      tempOrderSell := TStringList.Create;
      for i := 0 to VAL_2_ORDERS.Count - 1 do
      begin
        repeat
          case EXCHANGE of
            'BINANCE': TMP := CheckOrderBinance(VAL_2_ORDERS[i]);
            'BYBIT': TMP := CheckOrderBybit(VAL_2_ORDERS[i]);
          end;

          WriteLn(' Check SELL order ID ' + VAL_2_ORDERS[i] + ' : ' + TMP);
        until TMP <> 'FALSE';
        if TMP = 'YES' then
        begin
          tempOrderSell.Add(VAL_2_ORDERS[i]);
        end;
      end;
      VAL_2_ORDERS.Clear;
      VAL_2_ORDERS.Text := tempOrderSell.Text;
      tempOrderSell.Free;
    end;
    // end check buy

  except
    on E: Exception do
    begin
      TextColor(12);
      WriteLn(' ! ERROR > ' + E.Message + ' OrderCreateBuy');
      TextColor(15);
    end;
  end;
end;

procedure OrderCancelSell;
var
  TMP: string;
begin
  try
    case EXCHANGE of
      'BINANCE': begin
        repeat
        until GetBalanceBinance;
      end;
      'BYBIT': begin
        repeat
        until GetBalanceBybit;
      end;
    end;
    while ((VAL_2_ORDERS.Count > 0) and (VAL_1_BALANS < MIN_VAL_1)) do
    begin
      case EXCHANGE of
        'BINANCE': TMP := CancelOrderBinance(VAL_2_ORDERS[0]);
        'BYBIT': TMP := CancelOrderBybit(VAL_2_ORDERS[0]);
      end;

      if TMP = 'YES' then
      begin
        VAL_2_ORDERS.Delete(0);
        case EXCHANGE of
          'BINANCE': begin
            repeat
            until GetBalanceBinance;
          end;
          'BYBIT': begin
            repeat
            until GetBalanceBybit;
          end;
        end;
      end;

      if TMP = 'NO' then break;
    end;
  except
    on E: Exception do
    begin
      TextColor(12);
      WriteLn(' ! ERROR > ' + E.Message + ' OrderCancelBuy');
      TextColor(15);
    end;
  end;
end;

procedure OrderCreateSell;
var
  TMP: string = '';
  i: integer;
  a: double;
begin
  try
    // Делаем подсчеты перед открытием новой сетки
    if ((VAL_1_ORDERS.Count = 0) and (VAL_2_ORDERS.Count = 0) and (VAL_1_BALANS < MIN_VAL_1)) then
    begin
      TextColor(14);
      WriteLn('');
      WriteLn('-----------------------------------------------');
      WriteLn(' "New" We work on the creation of orders');
      TIME_FIRST_ORDER := GetTime;
      LAST_MIN := 99999999999;

      USES_DEPOSIT := VAL_2_BALANS * LIMIT_DEPOSIT / 100;
      DEPOSIT_ORDERS := CutDec(USES_DEPOSIT * DEPOSIT_ORDERS / 100, DEC_MIN_VAL_2);
      PRICE_ORDER := CutDec(ASKS + (ASKS * FIRST_STEP / 100), DEC_PRICE);
      PRICE_RELOAD := CutDec(ASKS - (ASKS * RELOAD / 100), DEC_PRICE);
      AMMOUNT_ORDER := CutDec(DEPOSIT_ORDERS / PRICE_ORDER, DEC_MIN_VAL_2);

      a := 0;
      repeat
        DEPOSIT_ORDERS := CutDec(DEPOSIT_ORDERS + (DEPOSIT_ORDERS * a / 100), DEC_MIN_VAL_2);
        a := a + 1;
        AMMOUNT_ORDER := DEPOSIT_ORDERS;
      until (CutDec(AMMOUNT_ORDER * PRICE_ORDER, DEC_MIN_VAL_1) > CutDec(MIN_VAL_1 + (MIN_VAL_1 * 0.4 / 100), DEC_MIN_VAL_1)) and (AMMOUNT_ORDER > MIN_VAL_2 + (MIN_VAL_2 * 1 / 100));

      TOTAL_AMMOUNT := DEPOSIT_ORDERS;
      TEMP_STEP := ORDERS_STEP;
      NEXT_DEPOSIT_ORDER := DEPOSIT_ORDERS;

      Writeln(' MIN_VAL_1 ' + FloatToStr(MIN_VAL_1, FS));
      Writeln(' MIN_VAL_2 ' + FloatToStr(MIN_VAL_2, FS));
      Writeln(' DEC_MIN_VAL_1 ' + IntToStr(DEC_MIN_VAL_1));
      Writeln(' DEC_MIN_VAL_2 ' + IntToStr(DEC_MIN_VAL_2));
      Writeln(' DEC_PRICE ' + IntToStr(DEC_PRICE));

      Writeln(' DEPOSIT_ORDERS ' + FloatToStr(DEPOSIT_ORDERS, FS));
      Writeln(' AMMOUNT_ORDER ' + FloatToStr(AMMOUNT_ORDER, FS));
      Writeln(' PRICE_ORDER ' + FloatToStrF(PRICE_ORDER, ffFixed, DEC_PRICE, DEC_PRICE, fs));
      Writeln(' USES_DEPOSIT ' + FloatToStr(USES_DEPOSIT, FS));
      Writeln(' TOTAL_AMMOUNT ' + FloatToStr(TOTAL_AMMOUNT, FS));
      TextColor(14);
      WriteLn('');
      WriteLn('-----------------------------------------------');
    end;

    // Начинаем выставлять ордера
    if (USES_DEPOSIT > TOTAL_AMMOUNT) then
    begin
      for i := VAL_2_ORDERS.Count to OPEN_ORDERS - 1 do
      begin
        case EXCHANGE of
          'BINANCE': TMP := CreateOrderBinance('LIMIT', 'SELL', FloatToStrF(AMMOUNT_ORDER, ffFixed, DEC_MIN_VAL_2, DEC_MIN_VAL_2, fs), FloatToStrF(PRICE_ORDER, ffFixed, DEC_PRICE, DEC_PRICE, fs), '');
          'BYBIT': TMP := CreateOrderBybit('LIMIT', 'Sell', FloatToStrF(AMMOUNT_ORDER, ffFixed, DEC_MIN_VAL_2, DEC_MIN_VAL_2, fs), FloatToStrF(PRICE_ORDER, ffFixed, DEC_PRICE, DEC_PRICE, fs), '');
        end;

        if (TMP <> 'NO') then
        begin
          TextColor(2);
          WriteLn(' + Order SELL create ID : ' + TMP + ' Value : ' + FloatToStrF(AMMOUNT_ORDER, ffFixed, DEC_MIN_VAL_2, DEC_MIN_VAL_2, fs) + ' Price : ' + FloatToStrF(PRICE_ORDER, ffFixed, DEC_PRICE, DEC_PRICE, FS));
          TextColor(15);
          VAL_2_ORDERS.add(TMP);

          if X2 = False then
            NEXT_DEPOSIT_ORDER := NEXT_DEPOSIT_ORDER + (NEXT_DEPOSIT_ORDER * MARTINGALE / 100)
          else
            NEXT_DEPOSIT_ORDER := TOTAL_AMMOUNT * 2;

          if (NEXT_ORDER_RSI = True) then
            PRICE_ORDER := CutDec(ASKS + (ASKS * TEMP_STEP / 100), DEC_PRICE)
          else
            PRICE_ORDER := CutDec(PRICE_ORDER + (PRICE_ORDER * TEMP_STEP / 100), DEC_PRICE);

          AMMOUNT_ORDER := CutDec(NEXT_DEPOSIT_ORDER / PRICE_ORDER, DEC_MIN_VAL_2);

          a := 0;
          repeat
            NEXT_DEPOSIT_ORDER := CutDec(NEXT_DEPOSIT_ORDER + a, DEC_MIN_VAL_2);
            a := a + 1;
            AMMOUNT_ORDER := NEXT_DEPOSIT_ORDER;
          until (CutDec(AMMOUNT_ORDER * PRICE_ORDER, DEC_MIN_VAL_1) > CutDec(MIN_VAL_1 + (MIN_VAL_1 * 0.4 / 100), DEC_MIN_VAL_1)) and (AMMOUNT_ORDER > MIN_VAL_2 + (MIN_VAL_2 * 1 / 100));

          TEMP_STEP := TEMP_STEP + (TEMP_STEP * RATIO);
          TOTAL_AMMOUNT := TOTAL_AMMOUNT + NEXT_DEPOSIT_ORDER;
          Save;
          if (TOTAL_AMMOUNT > USES_DEPOSIT) or (NEXT_ORDER_RSI = True) then break;
        end;

        if (TMP = 'NO') then
        begin
          case EXCHANGE of
            'BINANCE': TMP := SearchOrderBinance('SELL');
            'BYBIT': TMP := SearchOrderBybit('SELL');
          end;

          if (TMP <> 'NO') and (TMP <> 'FALSE') then
          begin
            TextColor(2);
            WriteLn(' + Order SELL create ID : ' + TMP + ' Value : ' + FloatToStrF(AMMOUNT_ORDER, ffFixed, DEC_MIN_VAL_2, DEC_MIN_VAL_2, fs) + ' Price : ' + FloatToStrF(PRICE_ORDER, ffFixed, DEC_PRICE, DEC_PRICE, FS));
            TextColor(15);
            VAL_2_ORDERS.add(TMP);
            TEMP_STEP := TEMP_STEP + RATIO;

            if X2 = False then
              NEXT_DEPOSIT_ORDER := NEXT_DEPOSIT_ORDER + (NEXT_DEPOSIT_ORDER * MARTINGALE / 100)
            else
              NEXT_DEPOSIT_ORDER := TOTAL_AMMOUNT * 2;

            if (NEXT_ORDER_RSI = True) then
              PRICE_ORDER := CutDec(ASKS + (ASKS * TEMP_STEP / 100), DEC_PRICE)
            else
              PRICE_ORDER := CutDec(PRICE_ORDER + (PRICE_ORDER * TEMP_STEP / 100), DEC_PRICE);

            AMMOUNT_ORDER := CutDec(NEXT_DEPOSIT_ORDER / PRICE_ORDER, DEC_MIN_VAL_2);
            a := 0;
            repeat
              NEXT_DEPOSIT_ORDER := CutDec(NEXT_DEPOSIT_ORDER + a, DEC_MIN_VAL_2);
              a := a + 1;
              AMMOUNT_ORDER := NEXT_DEPOSIT_ORDER;
            until (CutDec(AMMOUNT_ORDER * PRICE_ORDER, DEC_MIN_VAL_1) > CutDec(MIN_VAL_1 + (MIN_VAL_1 * 0.4 / 100), DEC_MIN_VAL_1)) and (AMMOUNT_ORDER > MIN_VAL_2 + (MIN_VAL_2 * 1 / 100));

            TEMP_STEP := TEMP_STEP + (TEMP_STEP * RATIO);
            TOTAL_AMMOUNT := TOTAL_AMMOUNT + NEXT_DEPOSIT_ORDER;
            Save;
            if (TOTAL_AMMOUNT > USES_DEPOSIT) or (NEXT_ORDER_RSI = True) then break;
          end;
        end;
      end;
      TextColor(14);
      WriteLn('');
      WriteLn('-----------------------------------------------');
    end;

  except
    on E: Exception do
    begin
      TextColor(12);
      WriteLn(' ! ERROR > ' + E.Message + ' OrderCreateSell');
      TextColor(15);
    end;
  end;
end;

end.
