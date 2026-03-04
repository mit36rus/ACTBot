unit api_bybit;

{$mode objfpc}{$H+}

interface

uses
  Classes,
  SysUtils,
  CRT,
  Math,
  var_bot,
  httpsend,
  ssl_openssl3,
  ssl_openssl3_lib,
  cHash,
  jsonparser,
  fpjson;

function GetLimitBybit(): boolean;
function GetRsiBybitRSIShoot(time_bar: string): boolean;
function GetMarketPriceBybit(): boolean;
function GetBalanceBybit(): boolean;
function SearchOrderBybit(type_order: string): string;
function CancelOrderBybit(str: string): string;
function GetHistoryBybit(): double;
function CheckOrderBybit(str: string): string;
function CreateOrderBybit(typeorder, market, quantity, rate, stopprice: string): string;
function LoadAllOrdersBybit(): boolean;
function LoadProfitBybit(): boolean;

implementation

function GetLimitBybit(): boolean;
var
  http: THTTPSend;
  responce: TStringStream;
  TMP: string;
  i, j: integer;
begin
  TextColor(14);
  WriteLn(' >>> GetLimitBybit');
  Result := False;
  try
    http := THTTPSend.Create;
    responce := TStringStream.Create();
    try
      http.Protocol := '1.1';
      http.Timeout := 5000;
      http.Sock.SocksTimeout := 5000;
      http.Sock.ConnectionTimeout := 5000;
      http.KeepAlive := True;
      http.UserAgent := 'ACTBot/MIT';
      http.MimeType := 'application/x-www-form-urlencoded';

      if (http.HTTPMethod('GET', 'https://api.bybit.com/v5/market/instruments-info?category=spot&symbol=' + val_2 + val_1)) and (http.ResultCode = 200) then
      begin
        http.Document.SaveToStream(responce);

        jD := GetJSON(responce.DataString);
        if Assigned(jD.FindPath('result.list')) then
        begin
          jD2 := GetJSON(jD.FindPath('result.list').AsJSON);

          for i := 0 to jD2.Count - 1 do
          begin
            jD3 := GetJSON(jD2.FindPath('[' + IntToStr(i) + ']').AsJSON);
            if jD3.FindPath('symbol').AsString = val_2 + val_1 then
            begin
              MIN_VAL_1 := jD3.FindPath('lotSizeFilter.minOrderAmt').AsFloat;
              MIN_VAL_2 := jD3.FindPath('lotSizeFilter.minOrderQty').AsFloat;

              TMP := string(jD3.FindPath('lotSizeFilter.quotePrecision').AsString);
              for j := 1 to Length(TMP) do
              begin
                if (TMP[j] <> '0') and (TMP[j] <> '.') then
                begin
                  DEC_MIN_VAL_1 := j;
                  if DEC_MIN_VAL_1 = 1 then
                    DEC_MIN_VAL_1 := 0;
                  if DEC_MIN_VAL_1 > 1 then
                    DEC_MIN_VAL_1 := DEC_MIN_VAL_1 - 2;
                end;
              end;

              TMP := string(jD3.FindPath('priceFilter.tickSize').AsString);
              for j := 1 to Length(TMP) do
              begin
                if (TMP[j] <> '0') and (TMP[j] <> '.') then
                begin
                  DEC_PRICE := j;
                  if DEC_PRICE = 1 then
                    DEC_PRICE := 0;
                  if DEC_PRICE > 1 then
                    DEC_PRICE := DEC_PRICE - 2;
                end;
              end;

              TMP := jD3.FindPath('lotSizeFilter.basePrecision').AsString;
              if POS('.', TMP) > 0 then
              begin
                j := POS('.', TMP);
                DEC_MIN_VAL_2 := Length(TMP) - j;
              end
              else
                DEC_MIN_VAL_2 := 0;

            end;
            FreeAndNil(jD3);
          end;
          FreeAndNil(jD2);
        end;

        FreeAndNil(jD);

        Result := True;
      end;
    except
      on E: Exception do
      begin
        TextColor(12);
        WriteLn(' ! ERROR > ' + E.Message + ' GetLimitBybit');
        TextColor(15);
      end;
    end;
  finally
    if Assigned(jD3) then FreeAndNil(jD3);
    if Assigned(jD2) then FreeAndNil(jD2);
    if Assigned(jD) then FreeAndNil(jD);
    FreeAndNil(responce);
    FreeAndNil(http);
  end;
end;

function GetRsiBybitRSIShoot(time_bar: string): boolean;
var
  http: THTTPSend;
  responce: TStringStream;
  i, p: integer;
  mas_price: array of double;
  pre_mas_price: array of double;
  mas_price_longe: array of double;
  pre_mas_price_longe: array of double;
  selector: integer;

  temp_Pre_RSI: double;
  temp_RSI: double;
  temp_Pre_RSI_longe: double;
  temp_RSI_longe: double;
begin
  TextColor(14);
  WriteLn(' >>> GetRsiBybitRSIShoot');
  Sleep(HTTP_PAUSE);
  Result := False;
  try
    http := THTTPSend.Create;
    responce := TStringStream.Create;
    try
      http.Protocol := '1.1';
      http.Timeout := 5000;
      http.Sock.SocksTimeout := 5000;
      http.Sock.ConnectionTimeout := 5000;
      http.KeepAlive := True;
      http.UserAgent := 'ACTBot/MIT';

      case time_bar of
        '1m': time_bar := '1';
        '3m': time_bar := '3';
        '5m': time_bar := '5';
        '15m': time_bar := '15';
        '30m': time_bar := '30';
        '1h': time_bar := '60';
        '2h': time_bar := '120';
        '4h': time_bar := '240';
      end;

      if (http.HTTPMethod('GET', url_bybit + '/v5/market/kline?category=spot&symbol=' + val_2 + val_1 + '&interval=' + time_bar + '&limit=50')) and (http.ResultCode = 200) then
      begin
        http.Document.SaveToStream(responce);
        jD := GetJSON(responce.DataString);

        if Assigned(jD.FindPath('result.list')) then
        begin
          jD2 := GetJSON(jD.FindPath('result.list').AsJSON);

          SetLength(pre_mas_price, LENGTH_RSI_LOW + 1);
          SetLength(mas_price, LENGTH_RSI_LOW + 1);
          SetLength(pre_mas_price_longe, LENGTH_RSI_HIGH + 1);
          SetLength(mas_price_longe, LENGTH_RSI_HIGH + 1);

          case DATA_FOR_RSI of
            'OPEN': selector := 1;
            'CLOSE': selector := 4;
            'MAX': selector := 2;
            'MIN': selector := 3;
          end;

          //price
          p := 0;
          for i := LENGTH_RSI_LOW downto 0 do
          begin
            jD3 := GetJSON(jD2.FindPath('[' + IntToStr(i) + ']').AsJSON);
            mas_price[p] := jD3.FindPath('[' + IntToStr(selector) + ']').AsFloat;
            FreeAndNil(jD3);
            p := p + 1;
          end;

          //pre price
          p := 0;
          for i := LENGTH_RSI_LOW + 1 downto 1 do
          begin
            jD3 := GetJSON(jD2.FindPath('[' + IntToStr(i) + ']').AsJSON);
            pre_mas_price[p] := jD3.FindPath('[' + IntToStr(selector) + ']').AsFloat;
            FreeAndNil(jD3);
            p := p + 1;
          end;

          //price_longe
          p := 0;
          for i := LENGTH_RSI_HIGH downto 0 do
          begin
            jD3 := GetJSON(jD2.FindPath('[' + IntToStr(i) + ']').AsJSON);
            mas_price_longe[p] := jD3.FindPath('[' + IntToStr(selector) + ']').AsFloat;
            FreeAndNil(jD3);
            p := p + 1;
          end;

          //pre price_longe
          p := 0;
          for i := LENGTH_RSI_HIGH + 1 downto 1 do
          begin
            jD3 := GetJSON(jD2.FindPath('[' + IntToStr(i) + ']').AsJSON);
            pre_mas_price_longe[p] := jD3.FindPath('[' + IntToStr(selector) + ']').AsFloat;
            FreeAndNil(jD3);
            p := p + 1;
          end;

          FreeAndNil(jD2);

          RSI_Calculation(pre_mas_price, mas_price, LENGTH_RSI_LOW);
          temp_Pre_RSI := Pre_RSI;
          temp_RSI := RSI;
          Writeln(' Previous RSI : ' + FloatToStr(temp_Pre_RSI, fs) + ' Current RSI : ' + FloatToStr(temp_RSI, fs));

          RSI_Calculation(pre_mas_price_longe, mas_price_longe, LENGTH_RSI_HIGH);
          temp_Pre_RSI_longe := Pre_RSI;
          temp_RSI_longe := RSI;
          Writeln(' Previous RSI longe : ' + FloatToStr(temp_Pre_RSI_longe, fs) + ' Current RSI longe : ' + FloatToStr(temp_RSI_longe, fs));

          if (temp_Pre_RSI < temp_RSI) and (temp_Pre_RSI <= temp_RSI_longe) and (temp_RSI_longe < temp_RSI) and (temp_RSI_longe <= RSI_OPEN_LONG) then
            SHOOT_LONG := True
          else
            SHOOT_LONG := False;

          if (temp_Pre_RSI > temp_RSI) and (temp_Pre_RSI >= temp_RSI_longe) and (temp_RSI_longe > temp_RSI) and (temp_RSI_longe >= RSI_OPEN_SHORT) then
            SHOOT_SHORT := True
          else
            SHOOT_SHORT := False;

          Result := True;
        end;
        FreeAndNil(jD);
      end;
    except
      on E: Exception do
      begin
        TextColor(12);
        WriteLn(' ! ERROR > ' + E.Message + ' GetRsiBybitRSIShoot');
        TextColor(15);
        Result := True;
        responce.SaveToFile('GetRsiBybitRSIShoot.log');
      end;
    end;
  finally
    if Assigned(jD3) then FreeAndNil(jD3);
    if Assigned(jD2) then FreeAndNil(jD2);
    if Assigned(jD) then FreeAndNil(jD);
    FreeAndNil(responce);
    FreeAndNil(http);
  end;
end;

function GetMarketPriceBybit(): boolean;
var
  http: THTTPSend;
  responce: TStringStream;
begin
  TextColor(14);
  WriteLn(' >>> GetMarketPriceBybit');
  Result := False;
  try
    http := THTTPSend.Create;
    responce := TStringStream.Create;
    try
      http.Protocol := '1.1';
      http.Timeout := 5000;
      http.Sock.SocksTimeout := 5000;
      http.Sock.ConnectionTimeout := 5000;
      http.KeepAlive := True;
      http.UserAgent := 'ACTBot/MIT';

      if (http.HTTPMethod('GET', 'https://api.bybit.com/v5/market/tickers?category=spot&symbol=' + VAL_2 + VAL_1)) and (http.ResultCode = 200) then
      begin
        http.Document.SaveToStream(responce);
        jD := GetJSON(responce.DataString);

        if Assigned(jD.FindPath('result.list')) then
        begin
          jD2 := GetJSON(jD.FindPath('result.list').AsJSON);
          bids := jD2.FindPath('[0].bid1Price').AsFloat;
          asks := jD2.FindPath('[0].ask1Price').AsFloat;
          FreeAndNil(jD2);
        end;

        if Assigned(jD.FindPath('retMsg')) then
          if jD.FindPath('retMsg').AsString <> 'OK' then
          begin
            WriteLn(' Error code : ' + IntToStr(jD.FindPath('retCode').AsInteger));
            WriteLn(' Error msg : ' + jD.FindPath('retMsg').AsString);
          end;

        FreeAndNil(jD);
        Result := True;
      end;
    except
      on E: Exception do
      begin
        TextColor(12);
        WriteLn(' ! ERROR > ' + E.Message + ' GetMarketPriceBybit');
        TextColor(15);
      end;
    end;
  finally
    if Assigned(jD2) then FreeAndNil(jD2);
    if Assigned(jD) then FreeAndNil(jD);
    FreeAndNil(responce);
    FreeAndNil(http);
  end;
end;

function GetBalanceBybit(): boolean;
var
  http: THTTPSend;
  responce: TStringStream;
  hash, hs: string;
  url: string;
  i: integer;
  locked_val_1: double = 0.0;
  locked_val_2: double = 0.0;
begin
  TextColor(14);
  WriteLn(' >>> BalanceBybit');
  Sleep(HTTP_PAUSE);
  Result := False;
  try
    http := THTTPSend.Create;
    responce := TStringStream.Create();
    try
      http.Protocol := '1.1';
      http.Timeout := 5000;
      http.Sock.SocksTimeout := 5000;
      http.Sock.ConnectionTimeout := 5000;
      http.KeepAlive := True;
      http.UserAgent := 'ACTBot/MIT';
      http.MimeType := 'application/x-www-form-urlencoded';

      url := 'accountType=UNIFIED&coin=' + VAL_1 + ',' + VAL_2;
      hs := IntToStr(GetTime) + GetKey + '5000' + url;
      hash := SHA256DigestToHex(CalcHMAC_SHA256(SECRET_BYBIT, hs));
      http.Headers.Add('X-BAPI-SIGN:' + hash);
      http.Headers.Add('X-BAPI-API-KEY:' + GetKey);
      http.Headers.Add('X-BAPI-TIMESTAMP:' + IntToStr(GetTime));
      http.Headers.Add('X-BAPI-RECV-WINDOW: 5000');
      http.Headers.Add('X-BAPI-SIGN-TYPE: 2');

      if (http.HTTPMethod('GET', 'https://api.bybit.com/v5/account/wallet-balance?' + url)) and (http.ResultCode = 200) then
      begin
        http.Document.SaveToStream(responce);
        jD := GetJSON(responce.DataString);
        val_1_balans := 0;
        val_1_balans := 0;

        if Assigned(jD.FindPath('result.list[0]coin')) then
        begin
          jD2 := GetJSON(jD.FindPath('result.list[0]coin').AsJSON);
          for i := 0 to jD2.Count - 1 do
          begin
            if jD2.FindPath('[' + IntToStr(i) + ']coin').AsString = val_1 then
            begin
              if jD2.FindPath('[' + IntToStr(i) + ']equity').AsString <> '' then
              begin
                val_1_balans := jD2.FindPath('[' + IntToStr(i) + ']equity').AsFloat;
                if jD2.FindPath('[' + IntToStr(i) + ']locked').AsString <> '' then
                  locked_val_1 := jD2.FindPath('[' + IntToStr(i) + ']locked').AsFloat;
                val_1_balans := val_1_balans - locked_val_1;
              end;
            end;

            if jD2.FindPath('[' + IntToStr(i) + ']coin').AsString = val_2 then
            begin
              if jD2.FindPath('[' + IntToStr(i) + ']equity').AsString <> '' then
                val_2_balans := jD2.FindPath('[' + IntToStr(i) + ']equity').AsFloat;
              if jD2.FindPath('[' + IntToStr(i) + ']locked').AsString <> '' then
                locked_val_2 := jD2.FindPath('[' + IntToStr(i) + ']locked').AsFloat;
              val_2_balans := val_2_balans - locked_val_2;
            end;
          end;
          FreeAndNil(jD2);
        end;

        if Assigned(jD.FindPath('retMsg')) then
          if jD.FindPath('retMsg').AsString <> 'OK' then
          begin
            WriteLn(' Error code : ' + IntToStr(jD.FindPath('retCode').AsInteger));
            WriteLn(' Error msg : ' + jD.FindPath('retMsg').AsString);
          end;

        FreeAndNil(jD);
        Result := True;
      end;
    except
      on E: Exception do
      begin
        TextColor(12);
        WriteLn(' ! ERROR > ' + E.Message + ' BalanceBybit');
        TextColor(15);
      end;
    end;
  finally
    if Assigned(jD2) then FreeAndNil(jD2);
    if Assigned(jD) then FreeAndNil(jD);
    FreeAndNil(responce);
    FreeAndNil(http);
  end;
end;

function SearchOrderBybit(type_order: string): string;
var
  http: THTTPSend;
  responce: TStringStream;
  hash, hs: string;
  url: string;
  i: integer;
begin
  TextColor(14);
  WriteLn(' >>> SearchOrderBybit');
  Sleep(HTTP_PAUSE);
  Result := 'FALSE';
  try
    http := THTTPSend.Create;
    responce := TStringStream.Create();
    try
      http.Protocol := '1.1';
      http.Timeout := 5000;
      http.Sock.SocksTimeout := 5000;
      http.Sock.ConnectionTimeout := 5000;
      http.KeepAlive := True;
      http.UserAgent := 'ACTBot/MIT';
      http.MimeType := 'application/x-www-form-urlencoded';

      url := 'category=spot&symbol=' + val_2 + val_1;
      hs := IntToStr(GetTime) + GetKey + '5000' + url;
      hash := SHA256DigestToHex(CalcHMAC_SHA256(SECRET_BYBIT, hs));
      http.Headers.Add('X-BAPI-SIGN:' + hash);
      http.Headers.Add('X-BAPI-API-KEY:' + GetKey);
      http.Headers.Add('X-BAPI-TIMESTAMP:' + IntToStr(GetTime));
      http.Headers.Add('X-BAPI-RECV-WINDOW: 5000');
      http.Headers.Add('X-BAPI-SIGN-TYPE: 2');

      if (http.HTTPMethod('GET', 'https://api.bybit.com/v5/order/realtime?' + url)) and (http.ResultCode = 200) then
      begin
        http.Document.SaveToStream(responce);
        jD := GetJSON(responce.DataString);
        Result := 'NO';
        if jD.FindPath('ret_msg').IsNull = True then
          if jD.Count - 1 >= 0 then
          begin
            for i := jD.Count - 1 downto 0 do
            begin
              if jD.FindPath('[' + IntToStr(i) + '].time').AsInt64 > TIME_FIRST_ORDER then
              begin
                //buy
                if (type_order = 'BUY') and (jD.FindPath('[' + IntToStr(i) + '].side').AsString = 'BUY') then
                begin
                  if val_1_orders.Count > 0 then
                  begin
                    if val_1_orders[val_1_orders.Count - 1] = jD.FindPath('[' + IntToStr(i) + '].orderId').AsString then
                    begin
                      WriteLn(' !' + val_1_orders[val_1_orders.Count - 1] + '=' + jD.FindPath('[' + IntToStr(i) + '].orderId').AsString);
                      Result := 'NO';
                      Break;
                    end
                    else
                    begin
                      WriteLn(' !' + val_1_orders[val_1_orders.Count - 1] + '<>' + jD.FindPath('[' + IntToStr(i) + '].orderId').AsString);
                      Result := jD.FindPath('[' + IntToStr(i) + '].orderId').AsString;
                      Break;
                    end;
                  end
                  else
                  begin
                    Result := jD.FindPath('[' + IntToStr(i) + '].orderId').AsString;
                    Break;
                  end;
                end;
                //sell
                if (type_order = 'SELL') and (jD.FindPath('[' + IntToStr(i) + '].side').AsString = 'SELL') then
                begin
                  if val_2_orders.Count > 0 then
                  begin
                    if val_2_orders[val_2_orders.Count - 1] = jD.FindPath('[' + IntToStr(i) + '].orderId').AsString then
                    begin
                      WriteLn(' !' + val_2_orders[val_2_orders.Count - 1] + '=' + jD.FindPath('[' + IntToStr(i) + '].orderId').AsString);
                      Result := 'NO';
                      Break;
                    end
                    else
                    begin
                      WriteLn(' !' + val_2_orders[val_2_orders.Count - 1] + '<>' + jD.FindPath('[' + IntToStr(i) + '].orderId').AsString);
                      Result := jD.FindPath('[' + IntToStr(i) + '].orderId').AsString;
                      Break;
                    end;
                  end
                  else
                  begin
                    Result := jD.FindPath('[' + IntToStr(i) + '].orderId').AsString;
                    Break;
                  end;
                end;
                //========
              end;
            end;
          end;

        if Assigned(jD.FindPath('retCode')) then
          if jD.FindPath('retCode').AsInteger <> 0 then
          begin
            WriteLn(' Error code : ' + IntToStr(jD.FindPath('retCode').AsInteger));
            WriteLn(' Error msg : ' + jD.FindPath('retMsg').AsString);
          end;

        FreeAndNil(jD);
      end;
    except
      on E: Exception do
      begin
        TextColor(12);
        WriteLn(' ! ERROR > ' + E.Message + ' SearchOrderBybit');
        TextColor(15);
      end;
    end;
  finally
    if Assigned(jD) then FreeAndNil(jD);
    FreeAndNil(responce);
    FreeAndNil(http);
  end;
end;

function CancelOrderBybit(str: string): string;
var
  http: THTTPSend;
  responce: TStringStream;
  hash, hs: string;
  url: string;
  post: TStringStream;
begin
  TextColor(14);
  WriteLn(' >>> CancelOrderBybit');
  Sleep(HTTP_PAUSE);
  Result := 'NO';
  try
    http := THTTPSend.Create;
    responce := TStringStream.Create();
    post := TStringStream.Create();
    try
      http.Protocol := '1.1';
      http.Timeout := 5000;
      http.Sock.SocksTimeout := 5000;
      http.Sock.ConnectionTimeout := 5000;
      http.KeepAlive := True;
      http.UserAgent := 'ACTBot/MIT';
      http.MimeType := 'application/json';

      url := '{"category":"spot","orderId":"' + str + '"}';
      hs := IntToStr(GetTime) + GetKey + '5000' + url;
      hash := SHA256DigestToHex(CalcHMAC_SHA256(SECRET_BYBIT, hs));
      http.Headers.Add('X-BAPI-SIGN:' + hash);
      http.Headers.Add('X-BAPI-API-KEY:' + GetKey);
      http.Headers.Add('X-BAPI-TIMESTAMP:' + IntToStr(GetTime));
      http.Headers.Add('X-BAPI-RECV-WINDOW: 5000');
      http.Headers.Add('X-BAPI-SIGN-TYPE: 2');
      post.WriteString(url);

      http.Document.LoadFromStream(post);

      if (http.HTTPMethod('POST', 'https://api.bybit.com/v5/order/cancel')) and (http.ResultCode = 200) then
      begin
        http.Document.SaveToStream(responce);
        jD := GetJSON(responce.DataString);
        if Assigned(jD.FindPath('result.orderId')) then
        begin
          if jD.FindPath('result.orderId').AsString = str then
            Result := 'YES';
        end
        else
        if jD.FindPath('retMsg').AsString = 'Order does not exist.' then
          Result := 'YES';

        if jD.FindPath('retCode').AsInteger <> 0 then
        begin
          WriteLn(' Error code : ' + IntToStr(jD.FindPath('retCode').AsInteger));
          WriteLn(' Error msg : ' + jD.FindPath('retMsg').AsString);
        end;

        FreeAndNil(jD);
      end;
    except
      on E: Exception do
      begin
        TextColor(12);
        WriteLn(' ! ERROR > ' + E.Message + ' CancelOrderBybit');
        TextColor(15);
      end;
    end;
  finally
    if Assigned(jD) then FreeAndNil(jD);
    FreeAndNil(post);
    FreeAndNil(responce);
    FreeAndNil(http);
  end;
end;

function GetHistoryBybit(): double;
var
  http: THTTPSend;
  responce: TStringStream;
  hash, hs: string;
  url: string;
  tempVal1: double = 0;
  tempVal2: double = 0;
  i: integer;
begin
  TextColor(14);
  WriteLn(' >>> GetHistoryBybit');
  Sleep(HTTP_PAUSE);
  Result := -1;
  try
    http := THTTPSend.Create;
    responce := TStringStream.Create();
    try
      http.Protocol := '1.1';
      http.Timeout := 5000;
      http.Sock.SocksTimeout := 5000;
      http.Sock.ConnectionTimeout := 5000;
      http.KeepAlive := True;
      http.UserAgent := 'ACTBot/MIT';
      http.MimeType := 'application/x-www-form-urlencoded';

      url := 'category=spot&symbol=' + val_2 + val_1;
      hs := IntToStr(GetTime) + GetKey + '5000' + url;
      hash := SHA256DigestToHex(CalcHMAC_SHA256(SECRET_BYBIT, hs));
      http.Headers.Add('X-BAPI-SIGN:' + hash);
      http.Headers.Add('X-BAPI-API-KEY:' + GetKey);
      http.Headers.Add('X-BAPI-TIMESTAMP:' + IntToStr(GetTime));
      http.Headers.Add('X-BAPI-RECV-WINDOW: 5000');
      http.Headers.Add('X-BAPI-SIGN-TYPE: 2');
      http.UserAgent := 'ACTBot/MIT';

      if (http.HTTPMethod('GET', 'https://api.bybit.com/v5/order/history?' + url)) and (http.ResultCode = 200) then
      begin
        http.Document.SaveToStream(responce);
        jD := GetJSON(responce.DataString);
        if Assigned(jD.FindPath('result.list')) then
        begin
          jD2 := GetJSON(jD.FindPath('result.list').AsJSON);

          if STRATEG = 'L' then
          begin
            for i := 0 to jD2.Count - 1 do
            begin
              jD3 := GetJSON(jD2.FindPath('[' + IntToStr(i) + ']').AsJSON);
              if (jD3.FindPath('createdTime').AsInt64 >= TIME_FIRST_ORDER) and (jD3.FindPath('orderStatus').AsString = 'Filled') then
              begin
                if (jD3.FindPath('side').AsString = 'Buy') then
                begin
                  tempVal2 := tempVal2 + jD3.FindPath('qty').AsFloat;  //ETH+
                  tempVal1 := tempVal1 + jD3.FindPath('cumExecValue').AsFloat;
                end;

                if (jD3.FindPath('side').AsString = 'Sell') then
                begin
                  tempVal2 := tempVal2 - jD3.FindPath('qty').AsFloat;  //ETH+
                  tempVal1 := tempVal1 - jD3.FindPath('cumExecValue').AsFloat;
                end;
              end;
              FreeAndNil(jD3);
            end;

            if (tempVal1 > 0) and (tempVal2 > 0) then
            begin
              Result := CutDec((tempVal1 + (tempVal1 * PROFIT / 100)) / tempVal2, DEC_PRICE);
            end;
          end;

          if STRATEG = 'S' then
          begin
            for i := 0 to jD2.Count - 1 do
            begin
              jD3 := GetJSON(jD2.FindPath('[' + IntToStr(i) + ']').AsJSON);
              if (jD3.FindPath('createdTime').AsInt64 >= TIME_FIRST_ORDER) and (jD3.FindPath('orderStatus').AsString = 'Filled') then
              begin
                if (jD3.FindPath('side').AsString = 'Buy') then
                begin
                  tempVal2 := tempVal2 - jD3.FindPath('qty').AsFloat;  //ETH+
                  tempVal1 := tempVal1 - jD3.FindPath('cumExecValue').AsFloat;
                end;

                if (jD3.FindPath('side').AsString = 'Sell') then
                begin
                  tempVal2 := tempVal2 + jD3.FindPath('qty').AsFloat;  //ETH+
                  tempVal1 := tempVal1 + jD3.FindPath('cumExecValue').AsFloat;
                end;
              end;
              FreeAndNil(jD3);
            end;

            tempVal1 := abs(tempVal1);
            tempVal2 := abs(tempVal2);

            if (tempVal1 > 0) and (tempVal2 > 0) then
            begin
              Result := CutDec(tempVal1 / (tempVal2 + (tempVal2 * PROFIT / 100)), DEC_PRICE);
            end;
          end;
          FreeAndNil(jD2);
        end;

        if Assigned(jD.FindPath('retCode')) then
          if jD.FindPath('retCode').AsInteger <> 0 then
          begin
            WriteLn(' Error code : ' + IntToStr(jD.FindPath('retCode').AsInteger));
            WriteLn(' Error msg : ' + jD.FindPath('retMsg').AsString);
          end;

        FreeAndNil(jD);
      end;
    except
      on E: Exception do
      begin
        TextColor(12);
        WriteLn(' ! ERROR > ' + E.Message + ' GetHistoryBybit');
        TextColor(15);
      end;
    end;
  finally
    if Assigned(jD3) then FreeAndNil(jD3);
    if Assigned(jD2) then FreeAndNil(jD2);
    if Assigned(jD) then FreeAndNil(jD);
    FreeAndNil(responce);
    FreeAndNil(http);
  end;
end;

function CheckOrderBybit(str: string): string;
var
  http: THTTPSend;
  responce: TStringStream;
  hash, hs: string;
  url: string;
begin
  TextColor(14);
  WriteLn(' >>> CheckOrderBybit');
  Sleep(HTTP_PAUSE);
  Result := 'FALSE';
  try
    http := THTTPSend.Create;
    responce := TStringStream.Create();
    try
      http.Protocol := '1.1';
      http.Timeout := 5000;
      http.Sock.SocksTimeout := 5000;
      http.Sock.ConnectionTimeout := 5000;
      http.KeepAlive := True;
      http.UserAgent := 'ACTBot/MIT';
      http.MimeType := 'application/x-www-form-urlencoded';

      url := 'category=spot&orderId=' + str;
      hs := IntToStr(GetTime) + GetKey + '5000' + url;
      hash := SHA256DigestToHex(CalcHMAC_SHA256(SECRET_BYBIT, hs));
      http.Headers.Add('X-BAPI-SIGN:' + hash);
      http.Headers.Add('X-BAPI-API-KEY:' + GetKey);
      http.Headers.Add('X-BAPI-TIMESTAMP:' + IntToStr(GetTime));
      http.Headers.Add('X-BAPI-RECV-WINDOW: 5000');
      http.Headers.Add('X-BAPI-SIGN-TYPE: 2');

      http.UserAgent := 'Mozilla/4.0 (compatible; ACTBot)';

      if (http.HTTPMethod('GET', 'https://api.bybit.com/v5/order/realtime?' + url)) then
      begin
        if (http.ResultCode = 200) or (http.ResultCode = 400) then
        begin
          http.Document.SaveToStream(responce);
          jD := GetJSON(responce.DataString);

          if Assigned(jD.FindPath('result.list[0]orderStatus')) then
          begin
            case jD.FindPath('result.list[0]orderStatus').AsString of
              'Cancelled': Result := 'NO';
              'Filled': Result := 'NO';
              'PartiallyFilled': Result := 'YES';
              'New': Result := 'YES';
            end;
          end
          else
          begin
            if Assigned(jD.FindPath('retMsg')) then
              if jD.FindPath('retMsg').AsString = 'Order does not exist.' then
                Result := 'NO';
          end;

          if Assigned(jD.FindPath('retCode')) then
            if jD.FindPath('retCode').AsInteger <> 0 then
            begin
              WriteLn(' Error code : ' + IntToStr(jD.FindPath('retCode').AsInteger));
              WriteLn(' Error msg : ' + jD.FindPath('retMsg').AsString);
            end;

          FreeAndNil(jD);
        end;
      end;
    except
      on E: Exception do
      begin
        TextColor(12);
        WriteLn(' ! ERROR > ' + E.Message + ' CheckOrderBybit');
        TextColor(15);
      end;
    end;
  finally
    if Assigned(jD) then FreeAndNil(jD);
    FreeAndNil(responce);
    FreeAndNil(http);
  end;
end;

function CreateOrderBybit(typeorder, market, quantity, rate, stopprice: string): string;
var
  http: THTTPSend;
  responce: TStringStream;
  jD: TJSONData;
  hash, hs: string;
  url: string;
  post: TStringStream;
begin
  TextColor(14);
  WriteLn(' >>> CreateOrderBybit');
  Sleep(HTTP_PAUSE);
  Result := 'NO';
  try
    http := THTTPSend.Create;
    responce := TStringStream.Create;
    post := TStringStream.Create();
    try
      http.Protocol := '1.1';
      http.Timeout := 5000;
      http.Sock.SocksTimeout := 5000;
      http.Sock.ConnectionTimeout := 5000;
      http.KeepAlive := True;
      http.UserAgent := 'ACTBot/MIT';
      http.MimeType := 'application/json';

      if rate = '' then
      begin
        url := '{"category":"spot","orderType":"Market","qty":"' + quantity + '","side":"' + market + '","symbol":"' + val_2 + val_1 + '","type":"' + typeorder + '"}';
      end
      else
      begin
        url := '{"category":"spot","orderType":"Limit","price":"' + rate + '","qty":"' + quantity + '","side":"' + market + '","symbol":"' + val_2 + val_1 + '","timeInForce":"GTC","type":"' + typeorder + '"}';
      end;

      hs := IntToStr(GetTime) + GetKey + '5000' + url;
      hash := SHA256DigestToHex(CalcHMAC_SHA256(SECRET_BYBIT, hs));
      http.Headers.Add('X-BAPI-SIGN:' + hash);
      http.Headers.Add('X-BAPI-API-KEY:' + GetKey);
      http.Headers.Add('X-BAPI-TIMESTAMP:' + IntToStr(GetTime));
      http.Headers.Add('X-BAPI-RECV-WINDOW: 5000');
      http.Headers.Add('X-BAPI-SIGN-TYPE: 2');
      post.WriteString(url);

      http.Document.LoadFromStream(post);

      if (http.HTTPMethod('POST', 'https://api.bybit.com/v5/order/create')) and (http.ResultCode = 200) then
      begin
        http.Document.SaveToStream(responce);
        jD := GetJSON(responce.DataString);
        if jD.FindPath('result').Count - 1 > 0 then
          Result := jD.FindPath('result.orderId').AsString;

        if Assigned(jD.FindPath('retCode')) then
          if jD.FindPath('retCode').AsInteger <> 0 then
          begin
            WriteLn(' Error code : ' + IntToStr(jD.FindPath('retCode').AsInteger));
            WriteLn(' Error msg : ' + jD.FindPath('retMsg').AsString);
          end;

        FreeAndNil(jD);
      end;
    except
      on E: Exception do
      begin
        TextColor(12);
        WriteLn(' ! ERROR > ' + E.Message + ' CreateOrderBybit');
        TextColor(15);
      end;
    end;
  finally
    if Assigned(jD) then FreeAndNil(jD);
    FreeAndNil(post);
    FreeAndNil(responce);
    FreeAndNil(http);
  end;
end;

function LoadAllOrdersBybit(): boolean;
var
  http: THTTPSend;
  responce: TStringStream;
  jD, jD2: TJSONData;
  hash, hs: string;
  url: string;
  i: integer;
begin
  TextColor(14);
  WriteLn(' >>> LoadAllOrdersBybit');
  Sleep(HTTP_PAUSE);
  Result := False;
  try
    http := THTTPSend.Create;
    responce := TStringStream.Create();
    try
      http.Protocol := '1.1';
      http.Timeout := 5000;
      http.Sock.SocksTimeout := 5000;
      http.Sock.ConnectionTimeout := 5000;
      http.KeepAlive := True;
      http.UserAgent := 'ACTBot/MIT';
      http.MimeType := 'application/x-www-form-urlencoded';

      url := 'category=spot&symbol=' + val_2 + val_1;
      hs := IntToStr(GetTime) + GetKey + '5000' + url;
      hash := SHA256DigestToHex(CalcHMAC_SHA256(SECRET_BYBIT, hs));
      http.Headers.Add('X-BAPI-SIGN:' + hash);
      http.Headers.Add('X-BAPI-API-KEY:' + GetKey);
      http.Headers.Add('X-BAPI-TIMESTAMP:' + IntToStr(GetTime));
      http.Headers.Add('X-BAPI-RECV-WINDOW: 5000');
      http.Headers.Add('X-BAPI-SIGN-TYPE: 2');

      if (http.HTTPMethod('GET', 'https://api.bybit.com/v5/order/realtime?' + url)) and (http.ResultCode = 200) then
      begin
        http.Document.SaveToStream(responce);
        jD := GetJSON(responce.DataString);
        val_1_orders.Clear;
        val_2_orders.Clear;
        if jD.Count - 1 >= 0 then
        begin
          if Assigned(jD.FindPath('retMsg')) then
            if jD.FindPath('retMsg').AsString = 'Order does not exist.' then
              Writeln(' Order does not exist.')
            else
            begin
              if Assigned(jD.FindPath('result.list')) then
              begin
                jD2 := GetJSON(jD.FindPath('result.list').AsJSON);
                for i := 0 to jD2.Count - 1 do
                begin
                  if jD2.FindPath('[' + IntToStr(i) + '].createdTime').AsInt64 >= TIME_FIRST_ORDER then
                  begin
                    if jD2.FindPath('[' + IntToStr(i) + '].side').AsString = 'Buy' then
                    begin
                      val_1_orders.Add(jD2.FindPath('[' + IntToStr(i) + '].orderId').AsString);
                    end;
                    if jD2.FindPath('[' + IntToStr(i) + '].side').AsString = 'Sell' then
                    begin
                      val_2_orders.Add(jD2.FindPath('[' + IntToStr(i) + '].orderId').AsString);
                    end;
                  end;
                end;
                FreeAndNil(jD2);
              end;
            end;
        end;

        if Assigned(jD.FindPath('retCode')) then
          if jD.FindPath('retCode').AsInteger <> 0 then
          begin
            WriteLn(' Error code : ' + IntToStr(jD.FindPath('retCode').AsInteger));
            WriteLn(' Error msg : ' + jD.FindPath('retMsg').AsString);
          end;

        FreeAndNil(jD);
        Result := True;
        WriteLn(' >>> Load all orders complete');
        WriteLn(' Open Buy : ' + IntToStr(val_1_orders.Count));
        WriteLn(' Open Sell : ' + IntToStr(val_2_orders.Count));
      end;
    except
      on E: Exception do
      begin
        TextColor(12);
        WriteLn(' ! ERROR > ' + E.Message + ' LoadAllOrdersBybit');
        TextColor(15);
      end;
    end;
  finally
    if Assigned(jD2) then FreeAndNil(jD2);
    if Assigned(jD) then FreeAndNil(jD);
    FreeAndNil(responce);
    FreeAndNil(http);
  end;
end;

function LoadProfitBybit(): boolean;
var
  http: THTTPSend;
  responce: TStringStream;
  hash, hs: string;
  url: string;
  i: integer;
  tempBuy: double = 0;
  tempSell: double = 0;
begin
  TextColor(14);
  WriteLn(' >>> LoadProfitBybit');
  Sleep(HTTP_PAUSE);
  Result := False;
  LAST_PROFIT := 0;
  try
    http := THTTPSend.Create;
    responce := TStringStream.Create();
    try
      http.Protocol := '1.1';
      http.Timeout := 5000;
      http.Sock.SocksTimeout := 5000;
      http.Sock.ConnectionTimeout := 5000;
      http.KeepAlive := True;
      http.UserAgent := 'ACTBot/MIT';
      http.MimeType := 'application/json';

      url := 'category=spot&symbol=' + val_2 + val_1;
      hs := IntToStr(GetTime) + GetKey + '5000' + url;
      hash := SHA256DigestToHex(CalcHMAC_SHA256(SECRET_BYBIT, hs));
      http.Headers.Add('X-BAPI-SIGN:' + hash);
      http.Headers.Add('X-BAPI-API-KEY:' + GetKey);
      http.Headers.Add('X-BAPI-TIMESTAMP:' + IntToStr(GetTime));
      http.Headers.Add('X-BAPI-RECV-WINDOW: 5000');
      http.Headers.Add('X-BAPI-SIGN-TYPE: 2');

      http.UserAgent := 'Mozilla/4.0 (compatible; ACTBot)';

      if (http.HTTPMethod('GET', 'https://api.bybit.com/v5/order/history?' + url)) and (http.ResultCode = 200) then
      begin
        http.Document.SaveToStream(responce);
        jD := GetJSON(responce.DataString);
        if Assigned(jD.FindPath('result.list')) then
        begin
          jD2 := GetJSON(jD.FindPath('result.list').AsJSON);

          if STRATEG = 'L' then
          begin
            for i := 0 to jD2.Count - 1 do
            begin
              jD3 := GetJSON(jD2.FindPath('[' + IntToStr(i) + ']').AsJSON);

              if ((jD3.FindPath('createdTime').AsInt64 >= TIME_FIRST_ORDER) and (jD3.FindPath('orderStatus').AsString = 'Filled')) then
              begin
                if (jD3.FindPath('side').AsString = 'Buy') then
                begin
                  tempBuy := tempBuy + jD3.FindPath('cumExecValue').AsFloat;
                end;

                if (jD3.FindPath('side').AsString = 'Sell') then
                begin
                  tempSell := tempSell + (jD3.FindPath('cumExecValue').AsFloat - jD3.FindPath('cumExecFee').AsFloat);
                end;
              end;
            end;
            FreeAndNil(jD3);
          end;

          if STRATEG = 'S' then
          begin
            for i := 0 to jD2.Count - 1 do
            begin
              jD3 := GetJSON(jD2.FindPath('[' + IntToStr(i) + ']').AsJSON);

              if ((jD3.FindPath('createdTime').AsInt64 >= TIME_FIRST_ORDER) and (jD3.FindPath('orderStatus').AsString = 'Filled')) then
              begin
                if (jD3.FindPath('side').AsString = 'Buy') then
                begin
                  tempBuy := tempBuy + (jD3.FindPath('cumExecQty').AsFloat - jD3.FindPath('cumExecFee').AsFloat);
                end;

                if (jD3.FindPath('side').AsString = 'Sell') then
                begin
                  tempSell := tempSell + jD3.FindPath('qty').AsFloat;
                end;
              end;
              FreeAndNil(jD3);
            end;
          end;

          if Assigned(jD.FindPath('retCode')) then
            if jD.FindPath('retCode').AsInteger <> 0 then
            begin
              WriteLn(' Error code : ' + IntToStr(jD.FindPath('retCode').AsInteger));
              WriteLn(' Error msg : ' + jD.FindPath('retMsg').AsString);
            end;

          if (STRATEG = 'L') and (tempSell <> 0) and (tempBuy <> 0) then
          begin
            LAST_PROFIT := SimpleRoundTo(tempSell - tempBuy, -8);
            Result := True;
          end;
          if (STRATEG = 'S') and (tempSell <> 0) and (tempBuy <> 0) then
          begin
            LAST_PROFIT := SimpleRoundTo(tempBuy - tempSell, -8);
            Result := True;
          end;
          FreeAndNil(jD2);
        end;
        FreeAndNil(jD);
      end;
    except
      on E: Exception do
      begin
        TextColor(12);
        WriteLn(' ! ERROR > ' + E.Message + ' LoadProfitBybit');
        TextColor(15);
      end;
    end;
  finally
    if Assigned(jD3) then FreeAndNil(jD3);
    if Assigned(jD2) then FreeAndNil(jD2);
    if Assigned(jD) then FreeAndNil(jD);
    FreeAndNil(responce);
    FreeAndNil(http);
  end;
end;

end.
