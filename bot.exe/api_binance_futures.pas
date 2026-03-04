unit api_binance_futures;

{$mode objfpc}{$H+}

interface

uses
  Classes,
  SysUtils,
  CRT,
  var_bot,
  httpsend,
  ssl_openssl3,
  ssl_openssl3_lib,
  cHash,
  jsonparser,
  fpjson;

function SwitchLevelBinance(): boolean;
function ChangePositionModeBinance(): boolean;
function ChangeMarginTypeBinance(): boolean;
function MarketBinanceFutures(): boolean;
function BalanceBinanceFutures(): boolean;
function LoadAllOrdersBinanceFutures(): boolean;
function GetLimitBinanceFutures(): boolean;
function GetPositionBinance(): boolean;
function GetPositionLSBinance(): boolean;
function GetRsiBinanceFuturesRSIShoot(time_bar: string): boolean;
function CreateOrderBinanceFutures(positionSide, side, f_type, price, quantity, stopPrice: string): string;
function CancelOrderBinanceFutures(str: string): boolean;
function CancelAllOpenOrdersFuturesBinance(): boolean;
function CheckOrderFuturesBinance(order_id: string): boolean;
function GetHistoryFuturesBinance(): double;

implementation

function SwitchLevelBinance(): boolean;
var
  http: THTTPSend;
  responce: TStringStream;
  hash: string;
  url: string;
  post: TStringStream;
begin
  TextColor(14);
  WriteLn(' >>> SwitchLevelBinance');
  Result := False;
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

      url := 'symbol=' + VAL_2 + VAL_1 + '&leverage=' + IntToStr(CREDIT) + '&recvWindow=' + IntToStr(30000) + '&timestamp=' + IntToStr(GetTime);
      hash := SHA256DigestToHex(CalcHMAC_SHA256(SECRET_BINANCE, url));

      post.WriteString(url);

      http.Headers.Add('X-MBX-APIKEY: ' + GetKey);
      http.Document.LoadFromStream(post);


      if (http.HTTPMethod('POST', 'https://fapi.binance.com/fapi/v1/leverage?signature=' + hash)) and (http.ResultCode = 200) then
      begin
        http.Document.SaveToStream(responce);
        jD := GetJSON(responce.DataString);
        if Assigned(jD.FindPath('leverage')) then
          if jD.FindPath('leverage').AsInt64 = CREDIT then
            Result := True;
        FreeAndNil(jD);
      end;
    except
      on E: Exception do
      begin
        TextColor(12);
        WriteLn(' ! ERROR > ' + E.Message + ' SwitchLevelBinance');
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

function ChangePositionModeBinance(): boolean;
var
  http: THTTPSend;
  responce: TStringStream;
  hash: string;
  url: string;
  post: TStringStream;
begin
  TextColor(14);
  WriteLn(' >>> ChangePositionModeBinance');
  Result := False;
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

      case POSITION_MODE of
        'OneWay': url := 'dualSidePosition=false&recvWindow=' + IntToStr(30000) + '&timestamp=' + IntToStr(GetTime);
        'Hedge': url := 'dualSidePosition=true&recvWindow=' + IntToStr(30000) + '&timestamp=' + IntToStr(GetTime);
      end;

      hash := SHA256DigestToHex(CalcHMAC_SHA256(SECRET_BINANCE, url));
      post.WriteString(url);

      http.Headers.Add('X-MBX-APIKEY: ' + GetKey);
      http.Document.LoadFromStream(post);

      if (http.HTTPMethod('POST', 'https://fapi.binance.com/fapi/v1/positionSide/dual?signature=' + hash)) and (http.ResultCode = 200) then
      begin
        http.Document.SaveToStream(responce);
        jD := GetJSON(responce.DataString);
        if Assigned(jD.FindPath('code')) then
          if jD.FindPath('code').AsInteger = 200 then
            Result := True;
        FreeAndNil(jD);
      end;
    except
      on E: Exception do
      begin
        TextColor(12);
        WriteLn(' ! ERROR > ' + E.Message + ' ChangePositionModeBinance');
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

function ChangeMarginTypeBinance(): boolean;
var
  http: THTTPSend;
  responce: TStringStream;
  hash: string;
  url: string;
  post: TStringStream;
begin
  TextColor(14);
  WriteLn(' >>> ChangeMarginTypeBinance');
  Result := False;
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

      url := 'symbol=' + VAL_2 + VAL_1 + '&marginType=CROSSED&recvWindow=' + IntToStr(30000) + '&timestamp=' + IntToStr(GetTime);
      hash := SHA256DigestToHex(CalcHMAC_SHA256(SECRET_BINANCE, url));
      post.WriteString(url);

      http.Headers.Add('X-MBX-APIKEY: ' + GetKey);
      http.Document.LoadFromStream(post);

      if (http.HTTPMethod('POST', 'https://fapi.binance.com/fapi/v1/marginType?signature=' + hash)) and (http.ResultCode = 200) then
      begin
        http.Document.SaveToStream(responce);
        jD := GetJSON(responce.DataString);
        if Assigned(jD.FindPath('code')) then
          if jD.FindPath('code').AsInteger = 200 then
            Result := True;
        FreeAndNil(jD);
      end;
    except
      on E: Exception do
      begin
        TextColor(12);
        WriteLn(' ! ERROR > ' + E.Message + ' ChangeMarginTypeBinance');
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

function MarketBinanceFutures(): boolean;
var
  http: THTTPSend;
  responce: TStringStream;
begin
  TextColor(14);
  WriteLn(' >>> MarketBinanceFutures');
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

      if (http.HTTPMethod('GET', 'https://fapi.binance.com/fapi/v1/ticker/bookTicker?symbol=' + val_2 + val_1)) and (http.ResultCode = 200) then
      begin
        http.Document.SaveToStream(responce);
        jD := GetJSON(responce.DataString);
        if Assigned(jD.FindPath('bidPrice')) then
          BIDS := jD.FindPath('bidPrice').AsFloat;
        if Assigned(jD.FindPath('askPrice')) then
          ASKS := jD.FindPath('askPrice').AsFloat;
        FreeAndNil(jD);
        Result := True;
      end
      else
      if (http.ResultCode = 400) then
      begin
        http.Document.SaveToStream(responce);
        jD := GetJSON(responce.DataString);
        if jD.FindPath('msg').AsString = 'Symbol is on delivering or delivered or settling or closed or pre-trading.' then Halt;
        FreeAndNil(jD);
        Result := False;
      end;
    except
      on E: Exception do
      begin
        TextColor(12);
        WriteLn(' ! ERROR > ' + E.Message + ' MarketBinanceFutures');
        TextColor(15);
      end;
    end;
  finally
    if Assigned(jD) then FreeAndNil(jD);
    FreeAndNil(responce);
    FreeAndNil(http);
  end;
end;

function BalanceBinanceFutures(): boolean;
var
  http: THTTPSend;
  responce: TStringStream;
  hash: string;
  url: string;
  i: integer;
begin
  TextColor(14);
  WriteLn(' >>> BalanceBinanceFutures');
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

      url := 'timestamp=' + IntToStr(GetTime);
      hash := SHA256DigestToHex(CalcHMAC_SHA256(SECRET_BINANCE, url));

      http.Headers.Add('X-MBX-APIKEY: ' + GetKey);

      if (http.HTTPMethod('GET', 'https://fapi.binance.com/fapi/v2/balance?timestamp=' + IntToStr(GetTime) + '&signature=' + hash)) and (http.ResultCode = 200) then
      begin
        http.Document.SaveToStream(responce);
        jD := GetJSON(responce.DataString);
        for i := 0 to jD.Count - 1 do
        begin
          jD2 := GetJSON(jD.FindPath('[' + IntToStr(i) + ']').AsJSON);
          if jD2.FindPath('asset').AsString = val_1 then
            val_1_balans := jD2.FindPath('balance').AsFloat;
          FreeAndNil(jD2);
        end;
        FreeAndNil(jD);
        Result := True;
      end;
    except
      on E: Exception do
      begin
        TextColor(12);
        WriteLn(' ! ERROR > ' + E.Message + ' BalanceBinanceFutures');
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

function LoadAllOrdersBinanceFutures(): boolean;
var
  http: THTTPSend;
  responce: TStringStream;
  hash: string;
  url: string;
  i: integer;
begin
  TextColor(14);
  WriteLn(' >>> LoadAllOrdersBinanceFutures');
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

      url := 'symbol=' + val_2 + val_1 + '&timestamp=' + IntToStr(GetTime);
      hash := SHA256DigestToHex(CalcHMAC_SHA256(SECRET_BINANCE, url));

      http.Headers.Add('X-MBX-APIKEY: ' + GetKey);

      if (http.HTTPMethod('GET', 'https://fapi.binance.com/fapi/v1/openOrders?' + url + '&signature=' + hash)) and (http.ResultCode = 200) then
      begin
        http.Document.SaveToStream(responce);
        OPEN_POSITION_ORDER.Clear;
        CLOSE_POSITION_ORDER.Clear;
        SL_ORDER_SHORT.Clear;

        jD := GetJSON(responce.DataString);
        if jD.Count - 1 >= 0 then
        begin
          if jD.FindPath('[0].positionSide').IsNull = False then
          begin
            for i := 0 to jD.Count - 1 do
            begin
              // long
              if (EXCHANGE = 'BINANCE_F') and (STRATEG = 'L') and (POSITION_MODE = 'OneWay') then
              begin
                if (jD.FindPath('[' + IntToStr(i) + '].time').AsInt64 > TIME_FIRST_ORDER) and (jD.FindPath('[' + IntToStr(i) + '].positionSide').AsString = 'BOTH') then
                begin

                  if (jD.FindPath('[' + IntToStr(i) + '].side').AsString = 'BUY') and (jD.FindPath('[' + IntToStr(i) + '].origType').AsString = 'LIMIT') then
                  begin
                    OPEN_POSITION_ORDER.Add(jD.FindPath('[' + IntToStr(i) + '].orderId').AsString);
                  end;


                  if ((jD.FindPath('[' + IntToStr(i) + '].side').AsString = 'SELL') and (jD.FindPath('[' + IntToStr(i) + '].origType').AsString = 'LIMIT')) or
                    ((jD.FindPath('[' + IntToStr(i) + '].side').AsString = 'SELL') and (jD.FindPath('[' + IntToStr(i) + '].origType').AsString = 'TRAILING_STOP_MARKET')) or
                    ((jD.FindPath('[' + IntToStr(i) + '].side').AsString = 'SELL') and (jD.FindPath('[' + IntToStr(i) + '].origType').AsString = 'STOP')) then
                  begin
                    CLOSE_POSITION_ORDER.Add(jD.FindPath('[' + IntToStr(i) + '].orderId').AsString);
                  end;

                end;
              end;

              // short
              if (EXCHANGE = 'BINANCE_F') and (STRATEG = 'S') and (POSITION_MODE = 'OneWay') then
              begin
                if (jD.FindPath('[' + IntToStr(i) + '].time').AsInt64 > TIME_FIRST_ORDER) and (jD.FindPath('[' + IntToStr(i) + '].positionSide').AsString = 'BOTH') then
                begin

                  if (jD.FindPath('[' + IntToStr(i) + '].side').AsString = 'SELL') and (jD.FindPath('[' + IntToStr(i) + '].origType').AsString = 'LIMIT') then
                  begin
                    OPEN_POSITION_ORDER.Add(jD.FindPath('[' + IntToStr(i) + '].orderId').AsString);
                  end;

                  if (jD.FindPath('[' + IntToStr(i) + '].side').AsString = 'BUY') and (jD.FindPath('[' + IntToStr(i) + '].origType').AsString = 'LIMIT') then
                  begin
                    CLOSE_POSITION_ORDER.Add(jD.FindPath('[' + IntToStr(i) + '].orderId').AsString);
                  end;
                end;
              end;

              // long
              if ((EXCHANGE = 'BINANCE_F') and (STRATEG = 'L') and (POSITION_MODE = 'Hedge')) or ((EXCHANGE = 'BINANCE_F_HG') and (STRATEG = 'L') and (POSITION_MODE = 'Hedge')) then
              begin
                if (jD.FindPath('[' + IntToStr(i) + '].time').AsInt64 > TIME_FIRST_ORDER) and (jD.FindPath('[' + IntToStr(i) + '].positionSide').AsString = 'LONG') then
                begin

                  if (jD.FindPath('[' + IntToStr(i) + '].side').AsString = 'BUY') and (jD.FindPath('[' + IntToStr(i) + '].origType').AsString = 'LIMIT') then
                  begin
                    OPEN_POSITION_ORDER.Add(jD.FindPath('[' + IntToStr(i) + '].orderId').AsString);
                  end;


                  if ((jD.FindPath('[' + IntToStr(i) + '].side').AsString = 'SELL') and (jD.FindPath('[' + IntToStr(i) + '].origType').AsString = 'LIMIT')) or
                    ((jD.FindPath('[' + IntToStr(i) + '].side').AsString = 'SELL') and (jD.FindPath('[' + IntToStr(i) + '].origType').AsString = 'TRAILING_STOP_MARKET')) or
                    ((jD.FindPath('[' + IntToStr(i) + '].side').AsString = 'SELL') and (jD.FindPath('[' + IntToStr(i) + '].origType').AsString = 'STOP')) then
                  begin
                    CLOSE_POSITION_ORDER.Add(jD.FindPath('[' + IntToStr(i) + '].orderId').AsString);
                  end;

                  if (jD.FindPath('[' + IntToStr(i) + '].side').AsString = 'BUY') and (jD.FindPath('[' + IntToStr(i) + '].origType').AsString = 'STOP_MARKET') then
                  begin
                    SL_ORDER_SHORT.Add(jD.FindPath('[' + IntToStr(i) + '].orderId').AsString);
                  end;

                end;
              end;

              // short
              if ((EXCHANGE = 'BINANCE_F') and (STRATEG = 'S') and (POSITION_MODE = 'Hedge')) or ((EXCHANGE = 'BINANCE_F_HG') and (STRATEG = 'S') and (POSITION_MODE = 'Hedge')) then
              begin
                if (jD.FindPath('[' + IntToStr(i) + '].time').AsInt64 > TIME_FIRST_ORDER) and (jD.FindPath('[' + IntToStr(i) + '].positionSide').AsString = 'SHORT') then
                begin

                  if (jD.FindPath('[' + IntToStr(i) + '].side').AsString = 'SELL') and (jD.FindPath('[' + IntToStr(i) + '].origType').AsString = 'LIMIT') then
                  begin
                    OPEN_POSITION_ORDER.Add(jD.FindPath('[' + IntToStr(i) + '].orderId').AsString);
                  end;

                  if (jD.FindPath('[' + IntToStr(i) + '].side').AsString = 'BUY') and (jD.FindPath('[' + IntToStr(i) + '].origType').AsString = 'LIMIT') then
                  begin
                    CLOSE_POSITION_ORDER.Add(jD.FindPath('[' + IntToStr(i) + '].orderId').AsString);
                  end;
                end;
              end;

            end;
          end;
        end;
        FreeAndNil(jD);
        Result := True;
      end;
    except
      on E: Exception do
      begin
        TextColor(12);
        WriteLn(' ! ERROR > ' + E.Message + ' LoadAllOrdersBinanceFutures');
        TextColor(15);
      end;
    end;
  finally
    if Assigned(jD) then FreeAndNil(jD);
    FreeAndNil(responce);
    FreeAndNil(http);
  end;
end;

function GetLimitBinanceFutures(): boolean;
var
  http: THTTPSend;
  responce: TStringStream;
  TMP: string;
  i, j: integer;
begin
  TextColor(14);
  WriteLn(' >>> GetLimitBinanceFutures');
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

      if (http.HTTPMethod('GET', 'https://fapi.binance.com/fapi/v1/exchangeInfo')) and (http.ResultCode = 200) then
      begin
        http.Document.SaveToStream(responce);
        jD := GetJSON(responce.DataString);
        jD2 := GetJSON(jD.FindPath('symbols').AsJSON);

        for i := 0 to jD2.Count - 1 do
        begin
          jD3 := GetJSON(jD2.FindPath('[' + IntToStr(i) + ']').AsJSON);
          if jD3.FindPath('symbol').AsString = val_2 + val_1 then
          begin
            maintMarginPercent := jD3.FindPath('maintMarginPercent').AsFloat * 2;
            jD4 := GetJSON(jD3.FindPath('filters').AsJSON);

            TMP := jD4.FindPath('[0].tickSize').AsString;
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

            DEC_MIN_VAL_1 := jD4.FindPath('[6].multiplierDecimal').AsInteger;
            DEC_MIN_VAL_2 := jD3.FindPath('quantityPrecision').AsInteger;
            QTY_STEP := jD4.FindPath('[1].stepSize').AsFloat;
            MIN_VAL_1 := jD4.FindPath('[5].notional').AsFloat;
            MIN_VAL_2 := jD4.FindPath('[1].minQty').AsFloat;

            FreeAndNil(jD4);
          end;
          FreeAndNil(jD3);
        end;

        FreeAndNil(jD2);
        FreeAndNil(jD);

        Result := True;
      end;
    except
      on E: Exception do
      begin
        TextColor(12);
        WriteLn(' ! ERROR > ' + E.Message + ' GetLimitBinanceFutures');
        TextColor(15);
      end;
    end;
  finally
    if Assigned(jD4) then FreeAndNil(jD4);
    if Assigned(jD3) then FreeAndNil(jD3);
    if Assigned(jD2) then FreeAndNil(jD2);
    if Assigned(jD) then FreeAndNil(jD);
    FreeAndNil(responce);
    FreeAndNil(http);
  end;
end;

function GetPositionBinance(): boolean;
var
  http: THTTPSend;
  responce: TStringStream;
  hash: string;
  url: string;
  i: integer;
begin
  TextColor(14);
  WriteLn(' >>> GetPositionBinance');
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

      url := 'symbol=' + val_2 + val_1 + '&timestamp=' + IntToStr(GetTime);
      hash := SHA256DigestToHex(CalcHMAC_SHA256(SECRET_BINANCE, url));

      http.Headers.Add('X-MBX-APIKEY: ' + GetKey);

      if (http.HTTPMethod('GET', 'https://fapi.binance.com/fapi/v2/positionRisk?' + url + '&signature=' + hash)) and (http.ResultCode = 200) then
      begin
        http.Document.SaveToStream(responce);
        jD := GetJSON(responce.DataString);

        for i := 0 to jD.Count - 1 do
        begin
          jD2 := GetJSON(jD.FindPath('[' + IntToStr(i) + ']').AsJSON);

          if (jD2.FindPath('symbol').AsString = val_2 + val_1) then
          begin
            if (POSITION_MODE = 'OneWay') and (jD2.FindPath('positionSide').AsString = 'BOTH') then
            begin
              PRICE_POSITION := jD2.FindPath('entryPrice').AsFloat;
              POSITION_VOLUME := ABS(jD2.FindPath('positionAmt').AsFloat);

              POSITION_NATIONAL := jD2.FindPath('notional').AsFloat;
              PNL := jD2.FindPath('unRealizedProfit').AsFloat;
              MARK_PRICE := jD2.FindPath('markPrice').AsFloat;
              Result := True;
              FreeAndNil(jD2);
              Break;
            end;

            if (POSITION_MODE = 'Hedge') and (jD2.FindPath('positionSide').AsString = 'LONG') and (STRATEG = 'L') then
            begin
              PRICE_POSITION := jD2.FindPath('entryPrice').AsFloat;
              POSITION_VOLUME := ABS(jD2.FindPath('positionAmt').AsFloat);
              POSITION_NATIONAL := jD2.FindPath('notional').AsFloat;
              PNL := jD2.FindPath('unRealizedProfit').AsFloat;
              MARK_PRICE := jD2.FindPath('markPrice').AsFloat;
              Result := True;
              FreeAndNil(jD2);
              Break;
            end;

            if (POSITION_MODE = 'Hedge') and (jD2.FindPath('positionSide').AsString = 'SHORT') and (STRATEG = 'S') then
            begin
              PRICE_POSITION := jD2.FindPath('entryPrice').AsFloat;
              POSITION_VOLUME := ABS(jD2.FindPath('positionAmt').AsFloat);
              POSITION_NATIONAL := jD2.FindPath('notional').AsFloat;
              PNL := jD2.FindPath('unRealizedProfit').AsFloat;
              MARK_PRICE := jD2.FindPath('markPrice').AsFloat;
              Result := True;
              FreeAndNil(jD2);
              Break;
            end;
          end;

        end;
        FreeAndNil(jD);
      end;
    except
      on E: Exception do
      begin
        TextColor(12);
        WriteLn(' ! ERROR > ' + E.Message + ' GetPositionBinance');
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

function GetPositionLSBinance(): boolean;
var
  http: THTTPSend;
  responce: TStringStream;
  hash: string;
  url: string;
  i: integer;
begin
  TextColor(14);
  WriteLn(' >>> GetPositionLSBinance');
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

      url := 'symbol=' + val_2 + val_1 + '&timestamp=' + IntToStr(GetTime);
      hash := SHA256DigestToHex(CalcHMAC_SHA256(SECRET_BINANCE, url));

      http.Headers.Add('X-MBX-APIKEY: ' + GetKey);

      if (http.HTTPMethod('GET', 'https://fapi.binance.com/fapi/v2/positionRisk?' + url + '&signature=' + hash)) and (http.ResultCode = 200) then
      begin
        http.Document.SaveToStream(responce);
        jD := GetJSON(responce.DataString);

        PNL_SUM_PERCENT := 0;

        for i := 0 to jD.Count - 1 do
        begin
          jD2 := GetJSON(jD.FindPath('[' + IntToStr(i) + ']').AsJSON);

          if (jD2.FindPath('symbol').AsString = val_2 + val_1) then
          begin
            if (jD2.FindPath('positionSide').AsString = 'LONG') then
            begin
              PRICE_POSITION_LONG := jD2.FindPath('entryPrice').AsFloat;
              POSITION_NATIONAL_LONG := ABS(jD2.FindPath('positionAmt').AsFloat);
              POSITION_VOLUME_LONG := ABS(jD2.FindPath('notional').AsFloat);
              PNL_LONG := jD2.FindPath('unRealizedProfit').AsFloat;
              Result := True;
            end;

            if (jD2.FindPath('positionSide').AsString = 'SHORT') then
            begin
              PRICE_POSITION_SHORT := jD2.FindPath('entryPrice').AsFloat;
              POSITION_NATIONAL_SHORT := ABS(jD2.FindPath('positionAmt').AsFloat);
              POSITION_VOLUME_SHORT := ABS(jD2.FindPath('notional').AsFloat);
              PNL_SHORT := jD2.FindPath('unRealizedProfit').AsFloat;
              Result := True;
            end;
          end;
          FreeAndNil(jD2);
        end;


        if (((PNL_LONG <> 0) or (PNL_SHORT <> 0)) and (POSITION_VOLUME_LONG <> 0)) then
          PNL_SUM_PERCENT := ((PNL_LONG + PNL_SHORT) / POSITION_VOLUME_LONG) * 100 * CREDIT;

        FreeAndNil(jD);
      end;
    except
      on E: Exception do
      begin
        TextColor(12);
        WriteLn(' ! ERROR > ' + E.Message + ' GetPositionLSBinance');
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

function GetRsiBinanceFuturesRSIShoot(time_bar: string): boolean;
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
      WriteLn(' >>> GetRsiBinanceFuturesRSIShoot');
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

      if (http.HTTPMethod('GET', 'https://fapi.binance.com/fapi/v1/klines?symbol=' + val_2 + val_1 + '&limit=50&interval=' + time_bar)) and (http.ResultCode = 200) then
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
        WriteLn(' ! ERROR > ' + E.Message + ' GetRsiBinanceFuturesRSIShoot');
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

function CreateOrderBinanceFutures(positionSide, side, f_type, price, quantity, stopPrice: string): string;
var
  http: THTTPSend;
  responce: TStringStream;
  hash: string;
  url: string;
  post: TStringStream;
begin
  TextColor(14);
  WriteLn(' >>> CreateOrderBinanceFutures');
  Sleep(HTTP_PAUSE);
  Result := 'FALSE';
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

      case f_type of
        'MARKET': url := 'symbol=' + val_2 + val_1 + '&positionSide=' + positionSide + '&side=' + side + '&type=' + f_type + '&quantity=' + quantity + '&recvWindow=' + IntToStr(30000) + '&timestamp=' + IntToStr(GetTime);

        'STOP_MARKET': url := 'symbol=' + val_2 + val_1 + '&positionSide=' + positionSide + '&side=' + side + '&type=' + f_type + '&closePosition=true&priceProtect=true&stopPrice=' +
            stopPrice + '&recvWindow=' + IntToStr(30000) + '&timestamp=' + IntToStr(GetTime);

        'STOP': url := 'symbol=' + val_2 + val_1 + '&positionSide=' + positionSide + '&side=' + side + '&type=' + f_type + '&price=' + price + '&stopPrice=' + stopPrice + '&quantity=' +
            quantity + '&recvWindow=' + IntToStr(30000) + '&priceProtect=true' + '&timestamp=' + IntToStr(GetTime);

        'TAKE_PROFIT': url := 'symbol=' + val_2 + val_1 + '&positionSide=' + positionSide + '&side=' + side + '&type=' + f_type + '&price=' + price + '&stopPrice=' + stopPrice + '&quantity=' +
            quantity + '&recvWindow=' + IntToStr(30000) + '&timestamp=' + IntToStr(GetTime);

        'TAKE_PROFIT_MARKET': url := 'symbol=' + val_2 + val_1 + '&positionSide=' + positionSide + '&side=' + side + '&type=' + f_type + '&closePosition=true&stopPrice=' + stopPrice +
            '&recvWindow=' + IntToStr(30000) + '&timestamp=' + IntToStr(GetTime);
        //=======================
        'TRAILING_STOP_MARKET': url := 'symbol=' + val_2 + val_1 + '&positionSide=' + positionSide + '&side=' + side + '&type=' + f_type + '&price=' + price + '&quantity=' + quantity +
            '&callbackRate=1' + '&recvWindow=' + IntToStr(30000) + '&timestamp=' + IntToStr(GetTime);
        //========================
        'LIMIT': url := 'symbol=' + val_2 + val_1 + '&positionSide=' + positionSide + '&side=' + side + '&type=' + f_type + '&price=' + price + '&quantity=' + quantity + '&recvWindow=' +
            IntToStr(30000) + '&timeInForce=GTC' + '&timestamp=' + IntToStr(GetTime);
      end;

      hash := SHA256DigestToHex(CalcHMAC_SHA256(SECRET_BINANCE, url));
      post.WriteString(url);

      http.Headers.Add('X-MBX-APIKEY: ' + GetKey);
      http.Document.LoadFromStream(post);

      if (http.HTTPMethod('POST', 'https://fapi.binance.com/fapi/v1/order?signature=' + hash)) and (http.ResultCode = 200) then
      begin
        http.Document.SaveToStream(responce);
        jD := GetJSON(responce.DataString);
        if Assigned(jD.FindPath('orderId')) then
          Result := jD.FindPath('orderId').AsString;
        FreeAndNil(jD);
      end;
    except
      on E: Exception do
      begin
        TextColor(12);
        WriteLn(' ! ERROR > ' + E.Message + ' CreateOrderBinanceFutures');
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

function CancelOrderBinanceFutures(str: string): boolean;
var
  http: THTTPSend;
  responce: TStringStream;
  hash: string;
  url: string;
  post: TStringStream;
begin
  TextColor(14);
  WriteLn(' >>> CancelOrderBinanceFutures');
  Sleep(HTTP_PAUSE);
  Result := False;
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

      if (http.HTTPMethod('DELETE', 'https://fapi.binance.com/fapi/v1/order?signature=' + hash)) and (http.ResultCode = 200) then
      begin
        http.Document.SaveToStream(responce);
        jD := GetJSON(responce.DataString);

        if jD.FindPath('status').AsString = 'CANCELED' then
          Result := True
        else
        if jD.FindPath('origQty').AsFloat = jD.FindPath('executedQty').AsFloat then
          Result := True;

        FreeAndNil(jD);
      end
      else
      begin
        if http.ResultCode = 400 then
        begin
          http.Document.SaveToStream(responce);
          jD := GetJSON(responce.DataString);
          if Assigned(jD.FindPath('code')) then
            if jD.FindPath('code').AsString = '-2011' then Result := True;

          if Assigned(jD.FindPath('code')) then
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
        WriteLn(' ! ERROR > ' + E.Message + ' CancelOrderBinanceFutures');
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


function CheckOrderFuturesBinance(order_id: string): boolean;
var
  http: THTTPSend;
  responce: TStringStream;
  hash: string;
  url: string;
begin
  TextColor(14);
  WriteLn(' >>> CheckOrderFuturesBinance');
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

      url := 'symbol=' + val_2 + val_1 + '&orderId=' + order_id + '&timestamp=' + IntToStr(GetTime);
      hash := SHA256DigestToHex(CalcHMAC_SHA256(SECRET_BINANCE, url));

      http.Headers.Add('X-MBX-APIKEY: ' + GetKey);

      if (http.HTTPMethod('GET', 'https://fapi.binance.com/fapi/v1/order?' + url + '&signature=' + hash)) and (http.ResultCode = 200) then
      begin
        http.Document.SaveToStream(responce);
        jD := GetJSON(responce.DataString);
        if Assigned(jD.FindPath('status')) then
          case jD.FindPath('status').AsString of
            'CANCELED': Result := True;
            'FILLED': Result := True;
            'EXPIRED': Result := True;
            'PARTIALLY_FILLED': Result := False;
            'NEW': Result := False;
          end;
        FreeAndNil(jD);
      end;
    except
      on E: Exception do
      begin
        TextColor(12);
        WriteLn(' ! ERROR > ' + E.Message + ' CheckOrderFuturesBinance');
        TextColor(15);
      end;
    end;
  finally
    if Assigned(jD) then FreeAndNil(jD);
    FreeAndNil(responce);
    FreeAndNil(http);
  end;
end;

function GetHistoryFuturesBinance(): double;
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
  WriteLn(' >>> GetHistoryFuturesBinance');
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

      if (http.HTTPMethod('GET', 'https://fapi.binance.com/fapi/v1/userTrades?' + url + '&signature=' + hash)) and (http.ResultCode = 200) then
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
              if (jD2.FindPath('side').AsString = 'BUY') and (jD2.FindPath('positionSide').AsString = 'LONG') then
              begin
                tempVal2 := jD2.FindPath('qty').AsFloat + tempVal2;  //сложили весь купленый MATIC
                tempVal1 := jD2.FindPath('quoteQty').AsFloat + tempVal1; //сложили весь потраченый USDT
                if jD2.FindPath('commissionAsset').AsString = val_1 then  tempVal1 := tempVal1 + jD2.FindPath('commission').AsFloat;
              end;

              if (jD2.FindPath('side').AsString = 'SELL') and (jD2.FindPath('positionSide').AsString = 'LONG') then
              begin
                tempVal2 := tempVal2 - jD2.FindPath('qty').AsFloat;  //вычитаем часть проданого MATIC
                tempVal1 := tempVal1 - jD2.FindPath('quoteQty').AsFloat; //сложили весь потраченый USDT
                if jD2.FindPath('commissionAsset').AsString = val_1 then  tempVal1 := tempVal1 - jD2.FindPath('commission').AsFloat;
              end;

            end;
            FreeAndNil(jD2);
          end;
          FreeAndNil(jD);

          if (tempVal1 > 0) and (tempVal2 > 0) then
          begin
            Result := CutDec((tempVal1 + (tempVal1 * PROFIT / 100)) / tempVal2, DEC_PRICE);
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
              if (jD2.FindPath('side').AsString = 'SELL') and (jD2.FindPath('positionSide').AsString = 'SHORT') then
              begin
                tempVal2 := jD2.FindPath('qty').AsFloat + tempVal2;  //сложили весь купленый MATIC
                tempVal1 := jD2.FindPath('quoteQty').AsFloat + tempVal1; //сложили весь потраченый USDT
                if jD2.FindPath('commissionAsset').AsString = val_1 then  tempVal1 := tempVal1 + jD2.FindPath('commission').AsFloat;
              end;

              if (jD2.FindPath('side').AsString = 'BUY') and (jD2.FindPath('positionSide').AsString = 'SHORT') then
              begin
                tempVal2 := tempVal2 - jD2.FindPath('qty').AsFloat;  //вычитаем часть проданого MATIC
                tempVal1 := tempVal1 - jD2.FindPath('quoteQty').AsFloat; //сложили весь потраченый USDT
                if jD2.FindPath('commissionAsset').AsString = val_1 then  tempVal1 := tempVal1 - jD2.FindPath('commission').AsFloat;
              end;

            end;
            FreeAndNil(jD2);
          end;
          FreeAndNil(jD);

          if (tempVal1 > 0) and (tempVal2 > 0) then
          begin
            Result := CutDec((tempVal1 - (tempVal1 * PROFIT / 100)) / tempVal2, DEC_PRICE);
          end;
        end;
        if Result = -1 then Result := PRICE_POSITION;
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
        WriteLn(' ! ERROR > ' + E.Message + ' GetHistoryFuturesBinance');
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

function CancelAllOpenOrdersFuturesBinance(): boolean;
var
  http: THTTPSend;
  responce: TStringStream;
  hash: string;
  url: string;
  post: TStringStream;
begin
  TextColor(14);
  WriteLn(' >>> CancelOrderBinanceFutures');
  Sleep(HTTP_PAUSE);
  Result := False;
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

      url := 'symbol=' + val_2 + val_1 + '&recvWindow=' + IntToStr(30000) + '&timestamp=' + IntToStr(GetTime);
      hash := SHA256DigestToHex(CalcHMAC_SHA256(SECRET_BINANCE, url));
      post.WriteString(url);

      http.Headers.Add('X-MBX-APIKEY: ' + GetKey);
      http.Document.LoadFromStream(post);

      if (http.HTTPMethod('DELETE', 'https://fapi.binance.com/fapi/v1/allOpenOrders?signature=' + hash)) and (http.ResultCode = 200) then
      begin
        http.Document.SaveToStream(responce);
        jD := GetJSON(responce.DataString);
        if Assigned(jD.FindPath('code')) then
          if (jD.FindPath('code').AsString = '200') and (jD.FindPath('msg').AsString = 'The operation of cancel all open order is done.') then
          begin
            Result := True;
          end;
        FreeAndNil(jD);
      end
      else
      begin
        if http.ResultCode = 400 then
        begin
          http.Document.SaveToStream(responce);
          jD := GetJSON(responce.DataString);
          if Assigned(jD.FindPath('msg')) then
            if jD.FindPath('msg').AsString = 'Unknown order sent.' then
              Result := True;

          if Assigned(jD.FindPath('code')) then
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
        WriteLn(' ! ERROR > ' + E.Message + ' CancelAllOpenOrdersFutures');
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

end.
