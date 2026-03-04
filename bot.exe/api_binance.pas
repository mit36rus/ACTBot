unit api_binance;

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

function GetLimitBinance(): boolean;
function GetRsiBinanceRSIShoot(time_bar: string): boolean;
function GetMarketPriceBinance(): boolean;
function GetBalanceBinance(): boolean;
function SearchOrderBinance(type_order: string): string;
function CancelOrderBinance(str: string): string;
function GetHistoryBinance(): double;
function CheckOrderBinance(str: string): string;
function CreateOrderBinance(typeorder, market, quantity, rate, stopprice: string): string;
function LoadAllOrdersBinance(): boolean;
function LoadProfitBinance(): boolean;

implementation

function GetLimitBinance(): boolean;
var
  http: THTTPSend;
  responce: TStringStream;
  TMP: string;
  i: integer;
begin
  TextColor(14);
  WriteLn(' >>> GetLimitBinance');
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

      if (http.HTTPMethod('GET', 'https://api.binance.com/api/v3/exchangeInfo?symbol=' + VAL_2 + VAL_1)) and (http.ResultCode = 200) then
      begin
        http.Document.SaveToStream(responce);
        jD := GetJSON(responce.DataString);
        jD2 := GetJSON(jD.FindPath('symbols[0].filters').AsJSON);

        MIN_VAL_1 := jD2.FindPath('[6].minNotional').AsFloat;
        MIN_VAL_2 := jD2.FindPath('[1].minQty').AsFloat;

        DEC_MIN_VAL_1 := jD2.FindPath('[6].avgPriceMins').AsInteger;

        TMP := string(jD2.FindPath('[0].tickSize').AsString);
        for i := 1 to Length(TMP) do
        begin
          if (TMP[i] <> '0') and (TMP[i] <> '.') then
          begin
            DEC_PRICE := i;
            if DEC_PRICE = 1 then
              DEC_PRICE := 0;
            if DEC_PRICE > 1 then
              DEC_PRICE := DEC_PRICE - 2;
          end;
        end;

        TMP := string(jD2.FindPath('[1].minQty').AsString);
        for i := 1 to Length(TMP) do
        begin
          if (TMP[i] <> '0') and (TMP[i] <> '.') then
          begin
            DEC_MIN_VAL_2 := i;
            if DEC_MIN_VAL_2 = 1 then
              DEC_MIN_VAL_2 := 0;
            if DEC_MIN_VAL_2 > 1 then
              DEC_MIN_VAL_2 := DEC_MIN_VAL_2 - 2;
          end;
        end;

        FreeAndNil(jD2);
        FreeAndNil(jD);
        Result := True;
      end
      else
      begin
        http.Document.SaveToStream(responce);
        jD := GetJSON(responce.DataString);
        if jD.FindPath('code') <> nil then
        begin
          WriteLn(' Error code : ' + IntToStr(jD.FindPath('code').AsInteger));
          WriteLn(' Error msg : ' + jD.FindPath('msg').AsString);
        end;
        FreeAndNil(jD);
      end;
    except
      on E: Exception do
      begin
        TextColor(12);
        WriteLn(' ! ERROR > ' + E.Message + ' GetLimitBinance');
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

function GetRsiBinanceRSIShoot(time_bar: string): boolean;
var
  http: THTTPSend;
  responce: TStringStream;
  i, c: integer;
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
  try
    try
      TextColor(14);
      WriteLn(' >>> GetRsiBinanceRSIShoot');
      Sleep(HTTP_PAUSE);
      Result := False;
      http := THTTPSend.Create;
      responce := TStringStream.Create;
      http.Protocol := '1.1';
      http.Timeout := 5000;
      http.Sock.SocksTimeout := 5000;
      http.Sock.ConnectionTimeout := 5000;
      http.KeepAlive := True;
      http.UserAgent := 'ACTBot/MIT';

      if (http.HTTPMethod('GET', 'https://api.binance.com/api/v3/klines?symbol=' + val_2 + val_1 + '&limit=50&interval=' + time_bar)) and (http.ResultCode = 200) then
      begin
        http.Document.SaveToStream(responce);
        jD := GetJSON(responce.DataString);

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
        c := 0;
        for i := jD.Count - (LENGTH_RSI_LOW + 1) to jD.Count - 1 do
        begin
          jD2 := GetJSON(jD.FindPath('[' + IntToStr(i) + ']').AsJSON);
          mas_price[c] := jD2.FindPath('[' + IntToStr(selector) + ']').AsFloat;
          FreeAndNil(jD2);
          c := c + 1;
        end;

        //pre price
        c := 0;
        for i := jD.Count - (LENGTH_RSI_LOW + 2) to jD.Count - 2 do
        begin
          jD2 := GetJSON(jD.FindPath('[' + IntToStr(i) + ']').AsJSON);
          pre_mas_price[c] := jD2.FindPath('[' + IntToStr(selector) + ']').AsFloat;
          FreeAndNil(jD2);
          c := c + 1;
        end;

        //price longe
        c := 0;
        for i := jD.Count - (LENGTH_RSI_HIGH + 1) to jD.Count - 1 do
        begin
          jD2 := GetJSON(jD.FindPath('[' + IntToStr(i) + ']').AsJSON);
          mas_price_longe[c] := jD2.FindPath('[' + IntToStr(selector) + ']').AsFloat;
          FreeAndNil(jD2);
          c := c + 1;
        end;

        //pre price longe
        c := 0;
        for i := jD.Count - (LENGTH_RSI_HIGH + 2) to jD.Count - 2 do
        begin
          jD2 := GetJSON(jD.FindPath('[' + IntToStr(i) + ']').AsJSON);
          pre_mas_price_longe[c] := jD2.FindPath('[' + IntToStr(selector) + ']').AsFloat;
          FreeAndNil(jD2);
          c := c + 1;
        end;

        FreeAndNil(jD);

        RSI_Calculation(pre_mas_price, mas_price, 7);
        temp_Pre_RSI := Pre_RSI;
        temp_RSI := RSI;
        Writeln(' Previous RSI : ' + FloatToStr(temp_Pre_RSI, fs) + ' Current RSI : ' + FloatToStr(temp_RSI, fs));

        RSI_Calculation(pre_mas_price_longe, mas_price_longe, 24);
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
    except
      on E: Exception do
      begin
        TextColor(12);
        WriteLn(' ! ERROR > ' + E.Message + ' GetRsiBinanceRSIShoot');
        TextColor(15);
        Result := True;
      end;
    end;
  finally
    if Assigned(jD2) then FreeAndNil(jD2);
    if Assigned(jD) then FreeAndNil(jD);
    FreeAndNil(responce);
    FreeAndNil(http);
  end;
end;

function GetMarketPriceBinance(): boolean;
var
  http: THTTPSend;
  responce: TStringStream;
  jD: TJSONData;
begin
  TextColor(14);
  WriteLn(' >>> GetMarketPriceBinance');
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

      if (http.HTTPMethod('GET', 'https://api.binance.com/api/v1/depth?limit=5&symbol=' + VAL_2 + VAL_1)) and (http.ResultCode = 200) then
      begin
        http.Document.SaveToStream(responce);
        jD := GetJSON(responce.DataString);
        if jD.FindPath('bids[0][0]').IsNull = False then
        begin
          bids := jD.FindPath('bids[0][0]').AsFloat;
          asks := jD.FindPath('asks[0][0]').AsFloat;
        end;
        FreeAndNil(jD);
        Result := True;
      end
      else
      begin
        http.Document.SaveToStream(responce);
        jD := GetJSON(responce.DataString);
        if jD.FindPath('code') <> nil then
        begin
          WriteLn(' Error code : ' + IntToStr(jD.FindPath('code').AsInteger));
          WriteLn(' Error msg : ' + jD.FindPath('msg').AsString);
        end;
        FreeAndNil(jD);
      end;
    except
      on E: Exception do
      begin
        TextColor(12);
        WriteLn(' ! ERROR > ' + E.Message + ' GetMarketPriceBinance');
        TextColor(15);
      end;
    end;
  finally
    if Assigned(jD) then FreeAndNil(jD);
    FreeAndNil(responce);
    FreeAndNil(http);
  end;
end;

function GetBalanceBinance(): boolean;
var
  http: THTTPSend;
  responce: TStringStream;
  hash: string;
  url: string;
  i: integer;
begin
  TextColor(14);
  WriteLn(' >>> GetBalanceBinance');
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
      url := 'recvWindow=' + IntToStr(30000) + '&timestamp=' + IntToStr(GetTime);
      hash := SHA256DigestToHex(CalcHMAC_SHA256(SECRET_BINANCE, url));

      http.Headers.Add('X-MBX-APIKEY: ' + GetKey);

      if (http.HTTPMethod('GET', 'https://api.binance.com/api/v3/account?recvWindow=' + IntToStr(30000) + '&timestamp=' + IntToStr(GetTime) + '&signature=' + hash)) and (http.ResultCode = 200) then
      begin
        http.Document.SaveToStream(responce);
        jD := GetJSON(responce.DataString);

        if Assigned(jD.FindPath('balances')) then
        begin
          jD2 := GetJSON(jD.FindPath('balances').AsJSON);
          for i := 0 to jD2.Count - 1 do
          begin
            jD3 := GetJSON(jD2.FindPath('[' + IntToStr(i) + ']').AsJSON);
            if jD3.FindPath('asset').AsString = val_1 then
              val_1_balans := jD3.FindPath('free').AsFloat;

            if jD3.FindPath('asset').AsString = val_2 then
              val_2_balans := jD3.FindPath('free').AsFloat;
            FreeAndNil(jD3);
          end;

          FreeAndNil(jD2);
          FreeAndNil(jD);
          Result := True;
        end;
      end
      else
      begin
        http.Document.SaveToStream(responce);
        jD := GetJSON(responce.DataString);
        if jD.FindPath('code') <> nil then
        begin
          WriteLn(' Error code : ' + IntToStr(jD.FindPath('code').AsInteger));
          WriteLn(' Error msg : ' + jD.FindPath('msg').AsString);
        end;
        FreeAndNil(jD);
      end;
    except
      on E: Exception do
      begin
        TextColor(12);
        WriteLn(' ! ERROR > ' + E.Message + ' GetBalanceBinance');
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

function SearchOrderBinance(type_order: string): string;
var
  http: THTTPSend;
  responce: TStringStream;
  hash: string;
  url: string;
  i: integer;
begin
  TextColor(14);
  WriteLn(' >>> SearchOrderBinance');
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
      url := 'symbol=' + val_2 + val_1 + '&recvWindow=' + IntToStr(30000) + '&timestamp=' + IntToStr(GetTime);
      hash := SHA256DigestToHex(CalcHMAC_SHA256(SECRET_BINANCE, url));

      http.Headers.Add('X-MBX-APIKEY: ' + GetKey);

      if (http.HTTPMethod('GET', 'https://api.binance.com/api/v3/openOrders?' + url + '&signature=' + hash)) and (http.ResultCode = 200) then
      begin
        http.Document.SaveToStream(responce);
        jD := GetJSON(responce.DataString);
        Result := 'NO';
        if jD.Count - 1 >= 0 then
        begin
          for i := jD.Count - 1 downto 0 do
          begin
            if jD.FindPath('[' + IntToStr(i) + '].time').AsInt64 >= TIME_FIRST_ORDER then
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
        FreeAndNil(jD);
      end
      else
      begin
        http.Document.SaveToStream(responce);
        jD := GetJSON(responce.DataString);
        if jD.FindPath('code') <> nil then
        begin
          WriteLn(' Error code : ' + IntToStr(jD.FindPath('code').AsInteger));
          WriteLn(' Error msg : ' + jD.FindPath('msg').AsString);
        end;
        FreeAndNil(jD);
      end;
    except
      on E: Exception do
      begin
        TextColor(12);
        WriteLn(' ! ERROR > ' + E.Message + ' SearchOrderBinance');
        TextColor(15);
      end;
    end;
  finally
    if Assigned(jD) then FreeAndNil(jD);
    FreeAndNil(responce);
    FreeAndNil(http);
  end;
end;

function CancelOrderBinance(str: string): string;
var
  http: THTTPSend;
  responce: TStringStream;
  hash: string;
  url: string;
  post: TStringStream;
begin
  TextColor(14);
  WriteLn(' >>> CancelOrderBinance');
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
      http.MimeType := 'application/x-www-form-urlencoded';

      url := 'symbol=' + val_2 + val_1 + '&orderId=' + str + '&recvWindow=' + IntToStr(30000) + '&timestamp=' + IntToStr(GetTime);
      hash := SHA256DigestToHex(CalcHMAC_SHA256(SECRET_BINANCE, url));
      post.WriteString(url);

      http.Headers.Add('X-MBX-APIKEY: ' + GetKey);
      http.Document.LoadFromStream(post);

      if (http.HTTPMethod('DELETE', 'https://api.binance.com/api/v3/order?&signature=' + hash)) and (http.ResultCode = 200) then
      begin
        http.Document.SaveToStream(responce);
        jD := GetJSON(responce.DataString);
        if jD.FindPath('orderId').IsNull = False then
        begin
          if jD.FindPath('status').AsString = 'CANCELED' then
            Result := 'YES'
          else
          if jD.FindPath('origQty').AsFloat = jD.FindPath('executedQty').AsFloat then
            Result := 'YES';
        end;
        FreeAndNil(jD);
      end
      else
      begin
        http.Document.SaveToStream(responce);
        jD := GetJSON(responce.DataString);
        if jD.FindPath('code') <> nil then
        begin
          WriteLn(' Error code : ' + IntToStr(jD.FindPath('code').AsInteger));
          WriteLn(' Error msg : ' + jD.FindPath('msg').AsString);
        end;
        FreeAndNil(jD);
      end;
    except
      on E: Exception do
      begin
        TextColor(12);
        WriteLn(' ! ERROR > ' + E.Message + ' OrderCancelBinance');
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

function GetHistoryBinance(): double;
var
  http: THTTPSend;
  responce: TStringStream;
  hash: string;
  url: string;
  tempVal1: double = 0;
  tempVal2: double = 0;
  i: integer;
begin
  TextColor(14);
  WriteLn(' >>> GetHistoryBinance');
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

      url := 'symbol=' + val_2 + val_1 + '&startTime=' + IntToStr(TIME_FIRST_ORDER) + '&recvWindow=' + IntToStr(30000) + '&timestamp=' + IntToStr(GetTime);
      hash := SHA256DigestToHex(CalcHMAC_SHA256(SECRET_BINANCE, url));

      http.Headers.Add('X-MBX-APIKEY: ' + GetKey);

      if (http.HTTPMethod('GET', 'https://api.binance.com/api/v3/myTrades?' + url + '&signature=' + hash)) and (http.ResultCode = 200) then
      begin
        http.Document.SaveToStream(responce);
        jD := GetJSON(responce.DataString);
        // LONG
        if STRATEG = 'L' then
        begin
          for i := 0 to jD.Count - 1 do
          begin
            jD2 := GetJSON(jD.FindPath('[' + IntToStr(i) + ']').AsJSON);
            if jD2.FindPath('time').AsInt64 >= TIME_FIRST_ORDER then
            begin
              if jD2.FindPath('isBuyer').AsBoolean = True then
              begin
                tempVal2 := tempVal2 + jD2.FindPath('qty').AsFloat;  //сложили весь купленый POND
                if jD2.FindPath('commissionAsset').AsString = val_2 then tempVal2 := tempVal2 + jD2.FindPath('commission').AsFloat;
                tempVal1 := tempVal1 + jD2.FindPath('quoteQty').AsFloat; // USDT +
              end;
              if jD2.FindPath('isBuyer').AsBoolean = False then
              begin
                tempVal2 := tempVal2 - jD2.FindPath('qty').AsFloat;  //вычитаем проданую часть POND
                tempVal1 := tempVal1 - jD2.FindPath('quoteQty').AsFloat; // USDT -
                if jD2.FindPath('commissionAsset').AsString = val_2 then tempVal1 := tempVal1 - jD2.FindPath('commission').AsFloat;
              end;
            end;
            FreeAndNil(jD2);
          end;
          FreeAndNil(jD);

          if (tempVal1 > 0) and (tempVal2 > 0) then
          begin
            Result := CutDec((tempVal1 + (tempVal1 * (PROFIT + 0.2) / 100)) / tempVal2, DEC_PRICE);
          end;
        end;

        // SHORT
        if STRATEG = 'S' then
        begin
          for i := 0 to jD.Count - 1 do
          begin
            jD2 := GetJSON(jD.FindPath('[' + IntToStr(i) + ']').AsJSON);
            if jD2.FindPath('time').AsInt64 >= TIME_FIRST_ORDER then
            begin
              if jD2.FindPath('isBuyer').AsBoolean = False then
              begin
                tempVal1 := tempVal1 + jD2.FindPath('quoteQty').AsFloat; // складываем USDT
                tempVal2 := tempVal2 + jD2.FindPath('qty').AsFloat; // складываем POND
                if jD2.FindPath('commissionAsset').AsString = val_1 then  // если комиссия USDT то
                  tempVal1 := tempVal1 - jD2.FindPath('commission').AsFloat; // вычитаем комсу отнимаем USDT
              end;
              if jD2.FindPath('isBuyer').AsBoolean = True then
              begin
                tempVal1 := tempVal1 - jD2.FindPath('quoteQty').AsFloat; // складываем USDT
                tempVal2 := tempVal2 - jD2.FindPath('qty').AsFloat; // складываем POND
                if jD2.FindPath('commissionAsset').AsString = val_2 then  // если комиссия USDT то
                  tempVal2 := tempVal2 + jD2.FindPath('commission').AsFloat; // вычитаем комсу отнимаем USDT
              end;
            end;
            FreeAndNil(jD2);
          end;
          FreeAndNil(jD);

          tempVal1 := abs(tempVal1);
          tempVal2 := abs(tempVal2);
          if (tempVal1 > 0) and (tempVal2 > 0) then
          begin
            Result := CutDec(tempVal1 / (tempVal2 + (tempVal2 * PROFIT / 100)), DEC_PRICE);
          end;
        end;
      end
      else
      begin
        http.Document.SaveToStream(responce);
        jD := GetJSON(responce.DataString);
        if jD.FindPath('code').IsNull = False then
        begin
          WriteLn(' Error code : ' + IntToStr(jD.FindPath('code').AsInteger));
          WriteLn(' Error msg : ' + jD.FindPath('msg').AsString);
        end;
        FreeAndNil(jD);
      end;
    except
      on E: Exception do
      begin
        TextColor(12);
        WriteLn(' ! ERROR > ' + E.Message + ' GetHistoryBinance');
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

function CheckOrderBinance(str: string): string;
var
  http: THTTPSend;
  responce: TStringStream;
  hash: string;
  url: string;
begin
  TextColor(14);
  WriteLn(' >>> CheckOrderBinance');
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

      url := 'symbol=' + val_2 + val_1 + '&orderId=' + str + '&recvWindow=' + IntToStr(30000) + '&timestamp=' + IntToStr(GetTime);
      hash := SHA256DigestToHex(CalcHMAC_SHA256(SECRET_BINANCE, url));

      http.Headers.Add('X-MBX-APIKEY: ' + GetKey);

      if (http.HTTPMethod('GET', 'https://api.binance.com/api/v3/order?' + url + '&signature=' + hash)) then
      begin
        if (http.ResultCode = 200) or (http.ResultCode = 400) then
        begin
          http.Document.SaveToStream(responce);
          jD := GetJSON(responce.DataString);

          if Assigned(jD.FindPath('status')) then
          begin
            if jD.FindPath('origQty').AsFloat = jD.FindPath('executedQty').AsFloat then
              Result := 'NO'
            else
            begin
              case jD.FindPath('status').AsString of
                'CANCELED': Result := 'NO';
                'FILLED': Result := 'NO';
                'PARTIALLY_FILLED': Result := 'YES';
                'NEW': Result := 'YES';
              end;
            end;
          end
          else
          begin
            if jD.FindPath('msg').AsString = 'Order does not exist.' then Result := 'FALSE';
          end;

          if jD.FindPath('code') <> nil then
          begin
            WriteLn(' Error code : ' + IntToStr(jD.FindPath('code').AsInteger));
            WriteLn(' Error msg : ' + jD.FindPath('msg').AsString);
          end;

          FreeAndNil(jD);
        end;
      end;
    except
      on E: Exception do
      begin
        TextColor(12);
        WriteLn(' ! ERROR > ' + E.Message + ' CheckOrderBinance');
        TextColor(15);
      end;
    end;
  finally
    if Assigned(jD) then FreeAndNil(jD);
    FreeAndNil(responce);
    FreeAndNil(http);
  end;
end;

function CreateOrderBinance(typeorder, market, quantity, rate, stopprice: string): string;
var
  http: THTTPSend;
  responce: TStringStream;
  jD: TJSONData;
  hash: string;
  url: string;
  post: TStringStream;
begin
  TextColor(14);
  WriteLn(' >>> CreateOrderBinance');
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
      http.MimeType := 'application/x-www-form-urlencoded';

      if (market = 'SELL') and (typeorder = 'MARKET') then
      begin
        url := 'symbol=' + val_2 + val_1 + '&side=' + market + '&type=' + typeorder + '&quantity=' + quantity + '&recvWindow=' + IntToStr(30000) + '&timestamp=' + IntToStr(GetTime);
      end;

      if (market = 'BUY') and (typeorder = 'MARKET') then
      begin
        url := 'symbol=' + val_2 + val_1 + '&side=' + market + '&type=' + typeorder + '&quoteOrderQty=' + quantity + '&recvWindow=' + IntToStr(30000) + '&timestamp=' + IntToStr(GetTime);
      end;

      if (typeorder = 'LIMIT') then
      begin
        url := 'symbol=' + val_2 + val_1 + '&side=' + market + '&type=' + typeorder + '&quantity=' + quantity + '&price=' + rate + '&timeInForce=GTC' + '&recvWindow=' + IntToStr(30000) + '&timestamp=' + IntToStr(GetTime);
      end;
      hash := SHA256DigestToHex(CalcHMAC_SHA256(SECRET_BINANCE, url));
      post.WriteString(url);

      http.Headers.Add('X-MBX-APIKEY: ' + GetKey);
      http.Document.LoadFromStream(post);

      if (http.HTTPMethod('POST', 'https://api.binance.com/api/v3/order?&signature=' + hash)) and (http.ResultCode = 200) then
      begin
        http.Document.SaveToStream(responce);
        jD := GetJSON(responce.DataString);

        if jD.FindPath('orderId').IsNull = False then
        begin
          Result := jD.FindPath('orderId').AsString;
        end;

        FreeAndNil(jD);
      end
      else
      begin
        if http.ResultCode = 400 then
        begin
          http.Document.SaveToStream(responce);
          jD := GetJSON(responce.DataString);
          if jD.FindPath('code').IsNull = False then
          begin
            Result := 'NO';
          end;

          if jD.FindPath('code').IsNull = False then
          begin
            WriteLn(' Error code : ' + IntToStr(jD.FindPath('code').AsInteger));
            WriteLn(' Error msg : ' + jD.FindPath('msg').AsString);
          end;

          FreeAndNil(jD);
        end;
      end;
    except
      on E: Exception do
      begin
        TextColor(12);
        WriteLn(' ! ERROR > ' + E.Message + ' OrderCreateBinance');
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

function LoadAllOrdersBinance(): boolean;
var
  http: THTTPSend;
  responce: TStringStream;
  hash: string;
  url: string;
  i: integer;
begin
  TextColor(14);
  WriteLn(' >>> LoadAllOrdersBinance');
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

      url := 'symbol=' + val_2 + val_1 + '&recvWindow=' + IntToStr(30000) + '&timestamp=' + IntToStr(GetTime);
      hash := SHA256DigestToHex(CalcHMAC_SHA256(SECRET_BINANCE, url));

      http.Headers.Add('X-MBX-APIKEY: ' + GetKey);

      if (http.HTTPMethod('GET', 'https://api.binance.com/api/v3/openOrders?' + url + '&signature=' + hash)) and (http.ResultCode = 200) then
      begin
        http.Document.SaveToStream(responce);
        jD := GetJSON(responce.DataString);
        VAL_1_ORDERS.Clear;
        VAL_2_ORDERS.Clear;

        if jD.Count - 1 >= 0 then
        begin
          for i := 0 to jD.Count - 1 do
          begin
            if jD.FindPath('[' + IntToStr(i) + '].time').AsInt64 >= TIME_FIRST_ORDER then
            begin
              if jD.FindPath('[' + IntToStr(i) + '].side').AsString = 'BUY' then
              begin
                VAL_1_ORDERS.Add(jD.FindPath('[' + IntToStr(i) + '].orderId').AsString);
              end;
              if jD.FindPath('[' + IntToStr(i) + '].side').AsString = 'SELL' then
              begin
                VAL_2_ORDERS.Add(jD.FindPath('[' + IntToStr(i) + '].orderId').AsString);
              end;
            end;
          end;
        end;
        FreeAndNil(jD);

        Result := True;
        TextColor(10);
        WriteLn(' >>> Load all orders complete');
        WriteLn(' Open Buy : ' + IntToStr(VAL_1_ORDERS.Count));
        WriteLn(' Open Sell : ' + IntToStr(VAL_2_ORDERS.Count));
        WriteLn('');
      end
      else
      begin
        http.Document.SaveToStream(responce);
        jD := GetJSON(responce.DataString);
        if jD.FindPath('code') <> nil then
        begin
          WriteLn(' Error code : ' + IntToStr(jD.FindPath('code').AsInteger));
          WriteLn(' Error msg : ' + jD.FindPath('msg').AsString);
        end;
        FreeAndNil(jD);
      end;
    except
      on E: Exception do
      begin
        TextColor(12);
        WriteLn(' ! ERROR > ' + E.Message + ' LoadAllOrdersBinance');
        TextColor(15);
      end;
    end;
  finally
    if Assigned(jD) then FreeAndNil(jD);
    FreeAndNil(responce);
    FreeAndNil(http);
  end;
end;

function LoadProfitBinance(): boolean;
var
  http: THTTPSend;
  responce: TStringStream;
  hash: string;
  url: string;
  i: integer;
  tempBuy: double = 0;
  tempSell: double = 0;
begin
  TextColor(14);
  WriteLn(' >>> LoadProfitBinance');
  Sleep(HTTP_PAUSE);
  LAST_PROFIT := 0;
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

      url := 'symbol=' + val_2 + val_1 + '&startTime=' + IntToStr(TIME_FIRST_ORDER) + '&recvWindow=' + IntToStr(30000) + '&timestamp=' + IntToStr(GetTime);
      hash := SHA256DigestToHex(CalcHMAC_SHA256(SECRET_BINANCE, url));

      http.Headers.Add('X-MBX-APIKEY: ' + GetKey);

      if (http.HTTPMethod('GET', 'https://api.binance.com/api/v3/myTrades?' + url + '&signature=' + hash)) and (http.ResultCode = 200) then
      begin
        http.Document.SaveToStream(responce);
        jD := GetJSON(responce.DataString);

        //LONG
        if STRATEG = 'L' then
          for i := 0 to jD.Count - 1 do
          begin
            jD2 := GetJSON(jD.FindPath('[' + IntToStr(i) + ']').AsJSON);

            if (jD2.FindPath('isBuyer').AsBoolean = True) and (jD2.FindPath('time').AsInt64 >= TIME_FIRST_ORDER) then
            begin
              tempBuy := jD2.FindPath('quoteQty').AsFloat + tempBuy;
            end;

            if (jD2.FindPath('isBuyer').AsBoolean = False) and (jD2.FindPath('time').AsInt64 >= TIME_FIRST_ORDER) then
            begin
              tempSell := jD2.FindPath('quoteQty').AsFloat + tempSell;
              if jD2.FindPath('commissionAsset').AsString = Val_1 then
                tempSell := tempSell - jD2.FindPath('commission').AsFloat;
            end;

            FreeAndNil(jD2);
          end;

        //SHORT
        if STRATEG = 'S' then
          for i := 0 to jD.Count - 1 do
          begin
            jD2 := GetJSON(jD.FindPath('[' + IntToStr(i) + ']').AsJSON);
            if (jD2.FindPath('isBuyer').AsBoolean = True) and (jD2.FindPath('time').AsInt64 >= TIME_FIRST_ORDER) then
            begin
              tempBuy := SimpleRoundTo(jD2.FindPath('qty').AsFloat, -8) + tempBuy;
            end;
            if (jD2.FindPath('isBuyer').AsBoolean = False) and (jD2.FindPath('time').AsInt64 >= TIME_FIRST_ORDER) then
            begin
              tempSell := SimpleRoundTo(jD2.FindPath('qty').AsFloat, -8) + tempSell;
            end;

            FreeAndNil(jD2);
          end;
        FreeAndNil(jD);

        if (STRATEG = 'L') and (tempSell <> 0) and (tempBuy <> 0) then
        begin
          LAST_PROFIT := SimpleRoundTo(tempSell - tempBuy, -8);
          Result := True;
        end
        else
        begin
          WriteLn(' ! No found profit');
          Result := True;
        end;
        if (STRATEG = 'S') and (tempSell <> 0) and (tempBuy <> 0) then
        begin
          LAST_PROFIT := SimpleRoundTo(tempBuy - tempSell, -8);
          Result := True;
        end
        else
        begin
          WriteLn(' ! No found profit');
          Result := True;
        end;
      end
      else
      begin
        http.Document.SaveToStream(responce);
        jD := GetJSON(responce.DataString);
        if jD.FindPath('code') <> nil then
        begin
          WriteLn(' Error code : ' + IntToStr(jD.FindPath('code').AsInteger));
          WriteLn(' Error msg : ' + jD.FindPath('msg').AsString);
        end;
        FreeAndNil(jD);
      end;
    except
      on E: Exception do
      begin
        TextColor(12);
        WriteLn(' ! ERROR > ' + E.Message + ' LoadProfitBinance');
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

end.
