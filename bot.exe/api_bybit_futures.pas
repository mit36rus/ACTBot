unit api_bybit_futures;

{$mode objfpc}{$H+}

interface

uses
  Classes,
  SysUtils,
  CRT,
  DateUtils,
  var_bot,
  httpsend,
  ssl_openssl3,
  ssl_openssl3_lib,
  cHash,
  jsonparser,
  fpjson;

function SwitchLevelBybit(): boolean;
function SetLeverageBybit(): boolean;
function PositionModeSwitchBybit(): boolean;
function MarketBybitFutures(): boolean;
function BalanceBybitFutures(): boolean;
function LoadAllOrdersBybitFutures(): boolean;
function GetLimitBybitFutures(): boolean;
function GetPositionBybit(): boolean;
function GetPositionLSBybit(): boolean;
function GetRsiBybitFuturesRSIShoot(time_bar: string): boolean;
function CreateOrderStopBybitFutures(positionSide, side, f_type, price, quantity, stopPrice: string): string;
function CreateOrderBybitFutures(positionSide, side, f_type, price, quantity, stopPrice: string): string;
function CancelOrderBybitFutures(str: string): boolean;
function CancelAllOpenOrdersFuturesBybit(): boolean;
function CheckOrderFuturesBybit(order_id: string): boolean;

implementation

function SwitchLevelBybit(): boolean;
var
  http: THTTPSend;
  responce: TStringStream;
  jD: TJSONData;
  hash, hs: string;
  url: string;
  post: TStringStream;
begin
  TextColor(14);
  WriteLn(' >>> SwitchLevelBybit');
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
      http.MimeType := 'application/json';

      url := '{"buyLeverage":"' + IntToStr(CREDIT) + '","category":"linear","sellLeverage":"' + IntToStr(CREDIT) + '","symbol":"' + val_2 + val_1 + '"}';
      hs := IntToStr(GetTime) + GetKey + '5000' + url;

      hash := SHA256DigestToHex(CalcHMAC_SHA256(SECRET_BYBIT, hs));
      post.WriteString(url);

      http.Headers.Add('X-BAPI-SIGN:' + hash);
      http.Headers.Add('X-BAPI-API-KEY:' + GetKey);
      http.Headers.Add('X-BAPI-TIMESTAMP:' + IntToStr(GetTime));
      http.Headers.Add('X-BAPI-RECV-WINDOW: 5000');
      http.Headers.Add('X-BAPI-SIGN-TYPE: 2');
      http.Document.LoadFromStream(post);

      if (http.HTTPMethod('POST', url_bybit + '/v5/position/set-leverage')) and (http.ResultCode = 200) then
      begin
        http.Document.SaveToStream(responce);
        jD := GetJSON(responce.DataString);
        WriteLn(' MSG : ' + jD.FindPath('retMsg').AsString);
        FreeAndNil(jD);
        Result := True;
      end;
    except
      on E: Exception do
      begin
        TextColor(12);
        WriteLn(' ! ERROR > ' + E.Message + ' SwitchLevelBybit');
        TextColor(15);
        responce.SaveToFile('SwitchLevelBybit.log');
      end;
    end;
  finally
    if Assigned(jD) then FreeAndNil(jD);
    FreeAndNil(post);
    FreeAndNil(responce);
    FreeAndNil(http);
  end;
end;

function SetLeverageBybit(): boolean;
var
  http: THTTPSend;
  responce: TStringStream;
  jD: TJSONData;
  hash, hs: string;
  url: string;
  post: TStringStream;
begin
  TextColor(14);
  WriteLn(' >>> SetLeverageBybit');
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
      http.MimeType := 'application/json';

      if POSITION_MODE = 'Hedge' then
      begin
        url := '{"buyLeverage":"' + IntToStr(CREDIT) + '","category":"linear","sellLeverage":"' + IntToStr(CREDIT) + '","symbol":"' + val_2 + val_1 + '","tradeMode":"0"}';
        hs := IntToStr(GetTime) + GetKey + '5000' + url;
      end;

      if POSITION_MODE = 'OneWay' then
      begin
        url := '{"buyLeverage":"' + IntToStr(CREDIT) + '","category":"linear","sellLeverage":"' + IntToStr(CREDIT) + '","symbol":"' + val_2 + val_1 + '","tradeMode":"1"}';
        hs := IntToStr(GetTime) + GetKey + '5000' + url;
      end;

      hash := SHA256DigestToHex(CalcHMAC_SHA256(SECRET_BYBIT, hs));
      post.WriteString(url);

      http.Document.LoadFromStream(post);
      http.Headers.Add('X-BAPI-SIGN:' + hash);
      http.Headers.Add('X-BAPI-API-KEY:' + GetKey);
      http.Headers.Add('X-BAPI-TIMESTAMP:' + IntToStr(GetTime));
      http.Headers.Add('X-BAPI-RECV-WINDOW: 5000');
      http.Headers.Add('X-BAPI-SIGN-TYPE: 2');

      if (http.HTTPMethod('POST', url_bybit + '/v5/position/switch-isolated')) and (http.ResultCode = 200) then
      begin
        http.Document.SaveToStream(responce);
        jD := GetJSON(responce.DataString);
        WriteLn(' MSG : ' + jD.FindPath('retMsg').AsString);
        FreeAndNil(jD);
        Result := True;
      end;
    except
      on E: Exception do
      begin
        TextColor(12);
        WriteLn(' ! ERROR > ' + E.Message + ' SetLeverageBybit');
        TextColor(15);
        responce.SaveToFile('SetLeverageBybit.log');
      end;
    end;
  finally
    if Assigned(jD) then FreeAndNil(jD);
    FreeAndNil(post);
    FreeAndNil(responce);
    FreeAndNil(http);
  end;
end;

function PositionModeSwitchBybit(): boolean;
var
  http: THTTPSend;
  responce: TStringStream;
  jD: TJSONData;
  hash, hs: string;
  url: string;
  post: TStringStream;
begin
  TextColor(14);
  WriteLn(' >>> PositionModeSwitchBybit');
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
      http.MimeType := 'application/json';

      if POSITION_MODE = 'Hedge' then
      begin
        url := '{"category":"linear","symbol":"' + val_2 + val_1 + '","mode":"3"}';
        hs := IntToStr(GetTime) + GetKey + '5000' + url;
      end;

      if POSITION_MODE = 'OneWay' then
      begin
        url := '{"category":"linear","symbol":"' + val_2 + val_1 + '","mode":"0"}';
        hs := IntToStr(GetTime) + GetKey + '5000' + url;
      end;

      hash := SHA256DigestToHex(CalcHMAC_SHA256(SECRET_BYBIT, hs));
      post.WriteString(url);

      http.Document.LoadFromStream(post);
      http.Headers.Add('X-BAPI-SIGN:' + hash);
      http.Headers.Add('X-BAPI-API-KEY:' + GetKey);
      http.Headers.Add('X-BAPI-TIMESTAMP:' + IntToStr(GetTime));
      http.Headers.Add('X-BAPI-RECV-WINDOW: 5000');
      http.Headers.Add('X-BAPI-SIGN-TYPE: 2');

      if (http.HTTPMethod('POST', url_bybit + '/v5/position/switch-mode')) and (http.ResultCode = 200) then
      begin
        http.Document.SaveToStream(responce);
        jD := GetJSON(responce.DataString);
        WriteLn(' MSG : ' + jD.FindPath('retMsg').AsString);
        FreeAndNil(jD);
        Result := True;
      end;
    except
      on E: Exception do
      begin
        TextColor(12);
        WriteLn(' ! ERROR > ' + E.Message + ' PositionModeSwitchBybit');
        TextColor(15);
        responce.SaveToFile('PositionModeSwitchBybit.log');
      end;
    end;
  finally
    if Assigned(jD) then FreeAndNil(jD);
    FreeAndNil(post);
    FreeAndNil(responce);
    FreeAndNil(http);
  end;
end;

function MarketBybitFutures(): boolean;
var
  http: THTTPSend;
  responce: TStringStream;
begin
  TextColor(14);
  WriteLn(' >>> MarketBybitFutures');
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

      if (http.HTTPMethod('GET', url_bybit + '/v5/market/tickers?category=linear&symbol=' + VAL_2 + VAL_1)) and (http.ResultCode = 200) then
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
        WriteLn(' ! ERROR > ' + E.Message + ' MarketBybitFutures');
        TextColor(15);
        responce.SaveToFile('MarketBybitFutures.log');
      end;
    end;
  finally
    if Assigned(jD2) then FreeAndNil(jD2);
    if Assigned(jD) then FreeAndNil(jD);
    FreeAndNil(responce);
    FreeAndNil(http);
  end;
end;

function BalanceBybitFutures(): boolean;
var
  http: THTTPSend;
  responce: TStringStream;
  hash, hs: string;
  url: string;
  i: integer;
  totalOrderIM: double = 0.0;
begin
  TextColor(14);
  WriteLn(' >>> BalanceBybitFutures');
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

      url := 'accountType=UNIFIED&coin=' + VAL_1;
      hs := IntToStr(GetTime) + GetKey + '5000' + url;
      hash := SHA256DigestToHex(CalcHMAC_SHA256(SECRET_BYBIT, hs));
      http.Headers.Add('X-BAPI-SIGN:' + hash);
      http.Headers.Add('X-BAPI-API-KEY:' + GetKey);
      http.Headers.Add('X-BAPI-TIMESTAMP:' + IntToStr(GetTime));
      http.Headers.Add('X-BAPI-RECV-WINDOW: 5000');
      http.Headers.Add('X-BAPI-SIGN-TYPE: 2');

      if (http.HTTPMethod('GET', url_bybit + '/v5/account/wallet-balance?' + url)) and (http.ResultCode = 200) then
      begin
        http.Document.SaveToStream(responce);
        jD := GetJSON(responce.DataString);

        if Assigned(jD.FindPath('result.list[0]coin')) then
        begin
          jD2 := GetJSON(jD.FindPath('result.list[0]coin').AsJSON);
          for i := 0 to jD2.Count - 1 do
          begin
            if jD2.FindPath('[' + IntToStr(i) + ']coin').AsString = val_1 then
            begin
              if jD2.FindPath('[' + IntToStr(i) + ']equity').AsString <> '' then
                val_1_balans := jD2.FindPath('[' + IntToStr(i) + ']equity').AsFloat;
              if jD2.FindPath('[' + IntToStr(i) + ']totalOrderIM').AsString <> '' then
                totalOrderIM := jD2.FindPath('[' + IntToStr(i) + ']totalOrderIM').AsFloat;
              val_1_balans := val_1_balans - totalOrderIM;
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
        WriteLn(' ! ERROR > ' + E.Message + ' BalanceBybitFutures');
        TextColor(15);
        responce.SaveToFile('BalanceBybitFutures.log');
      end;
    end;
  finally
    if Assigned(jD2) then FreeAndNil(jD2);
    if Assigned(jD) then FreeAndNil(jD);
    FreeAndNil(responce);
    FreeAndNil(http);
  end;
end;

function LoadAllOrdersBybitFutures(): boolean;
var
  http: THTTPSend;
  responce: TStringStream;
  hash, hs: string;
  url: string;
  i: integer;
begin
  TextColor(14);
  WriteLn(' >>> LoadAllOrdersBybitFutures');
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

      url := 'category=linear&symbol=' + val_2 + val_1;
      hs := IntToStr(GetTime) + GetKey + '5000' + url;
      hash := SHA256DigestToHex(CalcHMAC_SHA256(SECRET_BYBIT, hs));
      http.Headers.Add('X-BAPI-SIGN:' + hash);
      http.Headers.Add('X-BAPI-API-KEY:' + GetKey);
      http.Headers.Add('X-BAPI-TIMESTAMP:' + IntToStr(GetTime));
      http.Headers.Add('X-BAPI-RECV-WINDOW: 5000');
      http.Headers.Add('X-BAPI-SIGN-TYPE: 2');



      if (http.HTTPMethod('GET', url_bybit + '/v5/order/realtime?' + url)) and (http.ResultCode = 200) then
      begin
        http.Document.SaveToStream(responce);
        jD := GetJSON(responce.DataString);
        OPEN_POSITION_ORDER.Clear;
        CLOSE_POSITION_ORDER.Clear;
        SL_ORDER_SHORT.Clear;

        if Assigned(jD.FindPath('result.list')) then
        begin
          jD2 := GetJSON(jD.FindPath('result.list').AsJSON);

          for i := 0 to jD2.Count - 1 do
          begin

            if jD2.FindPath('[' + IntToStr(i) + '].createdTime').AsInt64 >= TIME_FIRST_ORDER then
            begin
              if (STRATEG = 'L') then
              begin
                if ((jD2.FindPath('[' + IntToStr(i) + '].side').AsString = 'Buy') and (jD2.FindPath('[' + IntToStr(i) + '].orderStatus').AsString = 'Created')) or
                  ((jD2.FindPath('[' + IntToStr(i) + '].side').AsString = 'Buy') and (jD2.FindPath('[' + IntToStr(i) + '].orderStatus').AsString = 'New')) or
                  ((jD2.FindPath('[' + IntToStr(i) + '].side').AsString = 'Buy') and (jD2.FindPath('[' + IntToStr(i) + '].orderStatus').AsString = 'PartiallyFilled')) then
                begin
                  OPEN_POSITION_ORDER.Add(jD2.FindPath('[' + IntToStr(i) + '].orderId').AsString);
                end;
                if ((jD2.FindPath('[' + IntToStr(i) + '].side').AsString = 'Sell') and (jD2.FindPath('[' + IntToStr(i) + '].orderStatus').AsString = 'Created')) or
                  ((jD2.FindPath('[' + IntToStr(i) + '].side').AsString = 'Sell') and (jD2.FindPath('[' + IntToStr(i) + '].orderStatus').AsString = 'New')) or
                  ((jD2.FindPath('[' + IntToStr(i) + '].side').AsString = 'Sell') and (jD2.FindPath('[' + IntToStr(i) + '].orderStatus').AsString = 'PartiallyFilled')) then
                begin
                  CLOSE_POSITION_ORDER.Add(jD2.FindPath('[' + IntToStr(i) + '].orderId').AsString);
                end;
                if ((jD2.FindPath('[' + IntToStr(i) + '].side').AsString = 'Buy') and (jD2.FindPath('[' + IntToStr(i) + '].orderStatus').AsString = 'Untriggered') and
                  (jD2.FindPath('[' + IntToStr(i) + '].createType').AsString = 'CreateByStopLoss')) then
                begin
                  SL_ORDER_SHORT.Add(jD2.FindPath('[' + IntToStr(i) + '].orderId').AsString);
                end;

              end;

              if (STRATEG = 'S') then
              begin
                if ((jD2.FindPath('[' + IntToStr(i) + '].side').AsString = 'Buy') and (jD2.FindPath('[' + IntToStr(i) + '].orderStatus').AsString = 'Created')) or
                  ((jD2.FindPath('[' + IntToStr(i) + '].side').AsString = 'Buy') and (jD2.FindPath('[' + IntToStr(i) + '].orderStatus').AsString = 'New')) or
                  ((jD2.FindPath('[' + IntToStr(i) + '].side').AsString = 'Buy') and (jD2.FindPath('[' + IntToStr(i) + '].orderStatus').AsString = 'PartiallyFilled')) then
                begin
                  CLOSE_POSITION_ORDER.Add(jD2.FindPath('[' + IntToStr(i) + '].orderId').AsString);
                end;
                if ((jD2.FindPath('[' + IntToStr(i) + '].side').AsString = 'Sell') and (jD2.FindPath('[' + IntToStr(i) + '].orderStatus').AsString = 'Created')) or
                  ((jD2.FindPath('[' + IntToStr(i) + '].side').AsString = 'Sell') and (jD2.FindPath('[' + IntToStr(i) + '].orderStatus').AsString = 'New')) or
                  ((jD2.FindPath('[' + IntToStr(i) + '].side').AsString = 'Sell') and (jD2.FindPath('[' + IntToStr(i) + '].orderStatus').AsString = 'PartiallyFilled')) then
                begin
                  OPEN_POSITION_ORDER.Add(jD2.FindPath('[' + IntToStr(i) + '].orderId').AsString);
                end;
              end;
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
        WriteLn(' ! ERROR > ' + E.Message + ' LoadAllOrdersBybitFutures');
        TextColor(15);
        responce.SaveToFile('LoadAllOrdersBybitFutures.log');
      end;
    end;
  finally
    if Assigned(jD2) then FreeAndNil(jD2);
    if Assigned(jD) then FreeAndNil(jD);
    FreeAndNil(responce);
    FreeAndNil(http);
  end;
end;

function GetLimitBybitFutures(): boolean;
var
  http: THTTPSend;
  responce: TStringStream;
  TMP: string;
  i, j: integer;
begin
  TextColor(14);
  WriteLn(' >>> GetLimitBybitFutures');
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

      if (http.HTTPMethod('GET', url_bybit + '/v5/market/instruments-info?category=linear&symbol=' + val_2 + val_1)) and (http.ResultCode = 200) then
      begin
        http.Document.SaveToStream(responce);

        jD := GetJSON(responce.DataString);
        jD2 := GetJSON(jD.FindPath('result.list').AsJSON);

        for i := 0 to jD2.Count - 1 do
        begin
          jD3 := GetJSON(jD2.FindPath('[' + IntToStr(i) + ']').AsJSON);
          if jD3.FindPath('symbol').AsString = val_2 + val_1 then
          begin
            MIN_VAL_1 := jD3.FindPath('lotSizeFilter.minNotionalValue').AsFloat;
            MIN_VAL_2 := jD3.FindPath('lotSizeFilter.minOrderQty').AsFloat;
            QTY_STEP := jD3.FindPath('lotSizeFilter.qtyStep').AsFloat;

            TMP := jD3.FindPath('priceFilter.tickSize').AsString;
            if POS('.', TMP) > 0 then
            begin
              j := POS('.', TMP);
              DEC_MIN_VAL_1 := Length(TMP) - j;
            end
            else
              DEC_MIN_VAL_1 := 0;

            TMP := jD3.FindPath('lotSizeFilter.minOrderQty').AsString;
            if POS('.', TMP) > 0 then
            begin
              j := POS('.', TMP);
              DEC_MIN_VAL_2 := Length(TMP) - j;
            end
            else
              DEC_MIN_VAL_2 := 0;

            TMP := string(jD3.GetPath('priceFilter.tickSize').AsString);
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
        WriteLn(' ! ERROR > ' + E.Message + ' GetLimitBybitFutures');
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

function GetPositionBybit(): boolean;
var
  http: THTTPSend;
  responce: TStringStream;
  hash, hs: string;
  url: string;
  i: integer;
begin
  TextColor(14);
  WriteLn(' >>> GetPositionBybit');
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

      url := 'category=linear&symbol=' + val_2 + val_1;
      hs := IntToStr(GetTime) + GetKey + '5000' + url;
      hash := SHA256DigestToHex(CalcHMAC_SHA256(SECRET_BYBIT, hs));
      http.Headers.Add('X-BAPI-SIGN:' + hash);
      http.Headers.Add('X-BAPI-API-KEY:' + GetKey);
      http.Headers.Add('X-BAPI-TIMESTAMP:' + IntToStr(GetTime));
      http.Headers.Add('X-BAPI-RECV-WINDOW: 5000');
      http.Headers.Add('X-BAPI-SIGN-TYPE: 2');

      if (http.HTTPMethod('GET', url_bybit + '/v5/position/list?' + url)) and (http.ResultCode = 200) then
      begin
        http.Document.SaveToStream(responce);

        jD := GetJSON(responce.DataString);
        if Assigned(jD.FindPath('result.list')) then
        begin
          jD2 := GetJSON(jD.FindPath('result.list').AsJSON);

          PRICE_POSITION := 0;
          POSITION_VOLUME := 0;
          POSITION_NATIONAL := 0;
          PNL := 0;
          MARK_PRICE := 0;

          for i := 0 to jD2.Count - 1 do
          begin
            jD3 := GetJSON(jD2.FindPath('[' + IntToStr(i) + ']').AsJSON);

            if POSITION_MODE = 'OneWay' then
            begin
              if (jD3.FindPath('positionIdx').AsInteger = 0) and (jD3.FindPath('size').AsFloat > 0) then
              begin
                PRICE_POSITION := jD3.FindPath('avgPrice').AsFloat;
                POSITION_NATIONAL := jD3.FindPath('size').AsFloat;
                POSITION_VOLUME := ABS(jD3.FindPath('positionValue').AsFloat);
                PNL := jD3.FindPath('unrealisedPnl').AsFloat;
                MARK_PRICE := jD3.FindPath('markPrice').AsFloat;
                Result := True;
                FreeAndNil(jD3);
                if POSITION_VOLUME <> 0 then
                begin
                  Break;
                end;
              end;
            end;

            if POSITION_MODE = 'Hedge' then
            begin
              if (jD3.FindPath('positionIdx').AsInteger = 1) and (STRATEG = 'L') and (jD3.FindPath('size').AsFloat > 0) then
              begin
                PRICE_POSITION := jD3.FindPath('avgPrice').AsFloat;
                POSITION_NATIONAL := jD3.FindPath('size').AsFloat;
                POSITION_VOLUME := ABS(jD3.FindPath('positionValue').AsFloat);
                PNL := jD3.FindPath('unrealisedPnl').AsFloat;
                MARK_PRICE := jD3.FindPath('markPrice').AsFloat;
                Result := True;
                FreeAndNil(jD3);
                if POSITION_VOLUME <> 0 then
                begin
                  Break;
                end;
              end;
              if (jD3.FindPath('positionIdx').AsInteger = 2) and (STRATEG = 'S') and (jD3.FindPath('size').AsFloat > 0) then
              begin
                PRICE_POSITION := jD3.FindPath('avgPrice').AsFloat;
                POSITION_NATIONAL := jD3.FindPath('size').AsFloat;
                POSITION_VOLUME := ABS(jD3.FindPath('positionValue').AsFloat);
                PNL := jD3.FindPath('unrealisedPnl').AsFloat;
                MARK_PRICE := jD3.FindPath('markPrice').AsFloat;
                Result := True;
                FreeAndNil(jD3);
                if POSITION_VOLUME <> 0 then
                begin
                  Break;
                end;
              end;
            end;
            if Assigned(jD3) then FreeAndNil(jD3);
          end;

          if Assigned(jD2) then FreeAndNil(jD2);
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
        WriteLn(' ! ERROR > ' + E.Message + ' GetPositionBybit');
        TextColor(15);
        responce.SaveToFile('GetPositionBybit.log');
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

function GetPositionLSBybit(): boolean;
var
  http: THTTPSend;
  responce: TStringStream;
  hash, hs: string;
  url: string;
  i: integer;
begin
  TextColor(14);
  WriteLn(' >>> GetPositionBybitLS');
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

      url := 'category=linear&symbol=' + val_2 + val_1;
      hs := IntToStr(GetTime) + GetKey + '5000' + url;
      hash := SHA256DigestToHex(CalcHMAC_SHA256(SECRET_BYBIT, hs));
      http.Headers.Add('X-BAPI-SIGN:' + hash);
      http.Headers.Add('X-BAPI-API-KEY:' + GetKey);
      http.Headers.Add('X-BAPI-TIMESTAMP:' + IntToStr(GetTime));
      http.Headers.Add('X-BAPI-RECV-WINDOW: 5000');
      http.Headers.Add('X-BAPI-SIGN-TYPE: 2');

      if (http.HTTPMethod('GET', url_bybit + '/v5/position/list?' + url)) and (http.ResultCode = 200) then
      begin
        http.Document.SaveToStream(responce);

        jD := GetJSON(responce.DataString);
        if Assigned(jD.FindPath('result.list')) then
        begin
          PRICE_POSITION_LONG := 0;
          POSITION_NATIONAL_LONG := 0;
          POSITION_VOLUME_LONG := 0;
          PNL_LONG := 0;

          PRICE_POSITION_SHORT := 0;
          POSITION_NATIONAL_SHORT := 0;
          POSITION_VOLUME_SHORT := 0;
          PNL_SHORT := 0;

          PNL_SUM_PERCENT := 0;

          jD2 := GetJSON(jD.FindPath('result.list').AsJSON);

          for i := 0 to jD2.Count - 1 do
          begin
            jD3 := GetJSON(jD2.FindPath('[' + IntToStr(i) + ']').AsJSON);

            if (jD3.FindPath('positionIdx').AsInteger = 1) and (jD3.FindPath('size').AsFloat > 0) then
            begin
              PRICE_POSITION_LONG := jD3.FindPath('avgPrice').AsFloat;
              POSITION_NATIONAL_LONG := jD3.FindPath('size').AsFloat;
              POSITION_VOLUME_LONG := ABS(jD3.FindPath('positionValue').AsFloat);
              PNL_LONG := jD3.FindPath('unrealisedPnl').AsFloat;
            end;
            if (jD3.FindPath('positionIdx').AsInteger = 2) and (jD3.FindPath('size').AsFloat > 0) then
            begin
              PRICE_POSITION_SHORT := jD3.FindPath('avgPrice').AsFloat;
              POSITION_NATIONAL_SHORT := jD3.FindPath('size').AsFloat;
              POSITION_VOLUME_SHORT := ABS(jD3.FindPath('positionValue').AsFloat);
              PNL_SHORT := jD3.FindPath('unrealisedPnl').AsFloat;
            end;
            FreeAndNil(jD3);
          end;

          FreeAndNil(jD2);

          if (((PNL_LONG <> 0) or (PNL_SHORT <> 0)) and (POSITION_VOLUME_LONG <> 0)) then
            PNL_SUM_PERCENT := ((PNL_LONG + PNL_SHORT) / POSITION_VOLUME_LONG) * 100 * CREDIT;
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
        WriteLn(' ! ERROR > ' + E.Message + ' GetPositionBybitLS');
        TextColor(15);
        responce.SaveToFile('GetPositionBybitLS.log');
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

function GetRsiBybitFuturesRSIShoot(time_bar: string): boolean;
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
  WriteLn(' >>> GetRsiBybitFuturesRSIShoot');
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

      if (http.HTTPMethod('GET', url_bybit + '/v5/market/kline?category=linear&symbol=' + val_2 + val_1 + '&interval=' + time_bar + '&limit=50')) and (http.ResultCode = 200) then
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
        WriteLn(' ! ERROR > ' + E.Message + ' GetRsiBybitFuturesRSIShoot');
        TextColor(15);
        Result := True;
        responce.SaveToFile('GetRsiBybitFuturesRSIShoot.log');
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

function CreateOrderStopBybitFutures(positionSide, side, f_type, price, quantity, stopPrice: string): string;
var
  http: THTTPSend;
  responce: TStringStream;
  jD: TJSONData;
  hash, hs: string;
  url: string;
  post: TStringStream;
begin
  TextColor(14);
  WriteLn(' >>> CreateOrderBybitFutures');
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
      http.MimeType := 'application/json';

      // CLOSE POSITION
      if ((STRATEG = 'L') and (side = 'Sell')) then
        url := '{"category":"linear","positionIdx":"1","tpslMode":"Full","slOrderType":"Market","symbol":"' + val_2 + val_1 + '","stopLoss":"' + stopPrice + '","time_in_force":"GTC"}';

      if ((STRATEG = 'S') and (side = 'Buy')) then
        url := '{"category":"linear","positionIdx":"2","tpslMode":"Full","slOrderType":"Market","symbol":"' + val_2 + val_1 + '","stopLoss":"' + stopPrice + '","time_in_force":"GTC"}';

      hs := IntToStr(GetTime) + GetKey + '5000' + url;
      hash := SHA256DigestToHex(CalcHMAC_SHA256(SECRET_BYBIT, hs));
      http.Headers.Add('X-BAPI-SIGN:' + hash);
      http.Headers.Add('X-BAPI-API-KEY:' + GetKey);
      http.Headers.Add('X-BAPI-TIMESTAMP:' + IntToStr(GetTime));
      http.Headers.Add('X-BAPI-RECV-WINDOW: 5000');
      http.Headers.Add('X-BAPI-SIGN-TYPE: 2');
      post.WriteString(url);

      http.Document.LoadFromStream(post);

      if (http.HTTPMethod('POST', url_bybit + '/v5/position/trading-stop')) and (http.ResultCode = 200) then
      begin
        http.Document.SaveToStream(responce);
        jD := GetJSON(responce.DataString);

        if Assigned(jD.FindPath('retMsg')) then
          if jD.FindPath('retMsg').AsString = 'OK' then
          begin
            Result := 'OK';
          end;

        FreeAndNil(jD);
      end;
    except
      on E: Exception do
      begin
        TextColor(12);
        WriteLn(' ! ERROR > ' + E.Message + ' CreateOrderStopBybitFutures');
        TextColor(15);
        responce.SaveToFile('CreateOrderStopBybitFutures.log');
      end;
    end;
  finally
    if Assigned(jD) then FreeAndNil(jD);
    FreeAndNil(post);
    FreeAndNil(responce);
    FreeAndNil(http);
  end;
end;

function CreateOrderBybitFutures(positionSide, side, f_type, price, quantity, stopPrice: string): string;
var
  http: THTTPSend;
  responce: TStringStream;
  jD: TJSONData;
  hash, hs: string;
  url: string;
  post: TStringStream;
begin
  TextColor(14);
  WriteLn(' >>> CreateOrderBybitFutures');
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
      http.MimeType := 'application/json';

      case POSITION_MODE of
        'OneWay': begin
          if ((STRATEG = 'L') and (side = 'Sell')) or ((STRATEG = 'S') and (side = 'Buy')) then

            url := '{"category":"linear","closeOnTrigger":"' + positionSide + '","orderType":"' + f_type + '","positionIdx":"0","price":"' + price + '","qty":"' + quantity +
              '","reduceOnly":"true","side":"' + side + '","symbol":"' + val_2 + val_1 + '","time_in_force":"GTC"}';

          if ((STRATEG = 'L') and (side = 'Buy')) or ((STRATEG = 'S') and (side = 'Sell')) then

            url := '{"category":"linear","closeOnTrigger":"' + positionSide + '","orderType":"' + f_type + '","positionIdx":"0","price":"' + price + '","qty":"' + quantity +
              '","reduceOnly":"false","side":"' + side + '","symbol":"' + val_2 + val_1 + '","time_in_force":"GTC"}';
        end;

        'Hedge': begin
          // CLOSE POSITION
          if ((STRATEG = 'L') and (side = 'Sell')) then

            url := '{"category":"linear","closeOnTrigger":"' + positionSide + '","orderType":"' + f_type + '","positionIdx":"1","price":"' + price + '","qty":"' + quantity + '","side":"' +
              side + '","symbol":"' + val_2 + val_1 + '","time_in_force":"GTC"}';

          if ((STRATEG = 'S') and (side = 'Buy')) then

            url := '{"category":"linear","closeOnTrigger":"' + positionSide + '","orderType":"' + f_type + '","positionIdx":"2","price":"' + price + '","qty":"' + quantity + '","side":"' +
              side + '","symbol":"' + val_2 + val_1 + '","time_in_force":"GTC"}';


          // OPEN POSITION
          if ((STRATEG = 'L') and (side = 'Buy')) then

            url := '{"category":"linear","closeOnTrigger":"' + positionSide + '","orderType":"' + f_type + '","positionIdx":"1","price":"' + price + '","qty":"' + quantity +
              '","reduceOnly":"false","side":"' + side + '","symbol":"' + val_2 + val_1 + '","time_in_force":"GTC"}';

          if ((STRATEG = 'S') and (side = 'Sell')) then
            url := '{"category":"linear","closeOnTrigger":"' + positionSide + '","orderType":"' + f_type + '","positionIdx":"2","price":"' + price + '","qty":"' + quantity +
              '","reduceOnly":"false","side":"' + side + '","symbol":"' + val_2 + val_1 + '","time_in_force":"GTC"}';
        end;
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

      if (http.HTTPMethod('POST', url_bybit + '/v5/order/create')) and (http.ResultCode = 200) then
      begin
        http.Document.SaveToStream(responce);
        jD := GetJSON(responce.DataString);
        if Assigned(jD.FindPath('result.orderId')) then
          Result := jD.FindPath('result.orderId').AsString;

        if Assigned(jD.FindPath('retMsg')) then
          if jD.FindPath('retMsg').AsString <> 'OK' then
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
        WriteLn(' ! ERROR > ' + E.Message + ' CreateOrderBybitFutures');
        TextColor(15);
        responce.SaveToFile('CreateOrderBybitFutures.log');
      end;
    end;
  finally
    if Assigned(jD) then FreeAndNil(jD);
    FreeAndNil(post);
    FreeAndNil(responce);
    FreeAndNil(http);
  end;
end;

function CancelOrderBybitFutures(str: string): boolean;
var
  http: THTTPSend;
  responce: TStringStream;
  hash, hs: string;
  url: string;
  post: TStringStream;
begin
  TextColor(14);
  WriteLn(' >>> CancelOrderBybitFutures');
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
      http.MimeType := 'application/json';

      url := '{"category":"linear","orderId":"' + str + '","symbol":"' + VAL_2 + VAL_1 + '"}';
      hs := IntToStr(GetTime) + GetKey + '5000' + url;
      hash := SHA256DigestToHex(CalcHMAC_SHA256(SECRET_BYBIT, hs));
      http.Headers.Add('X-BAPI-SIGN:' + hash);
      http.Headers.Add('X-BAPI-API-KEY:' + GetKey);
      http.Headers.Add('X-BAPI-TIMESTAMP:' + IntToStr(GetTime));
      http.Headers.Add('X-BAPI-RECV-WINDOW: 5000');
      http.Headers.Add('X-BAPI-SIGN-TYPE: 2');
      post.WriteString(url);

      http.Document.LoadFromStream(post);

      if (http.HTTPMethod('POST', url_bybit + '/v5/order/cancel')) and (http.ResultCode = 200) then
      begin
        http.Document.SaveToStream(responce);
        jD := GetJSON(responce.DataString);
        if Assigned(jD.FindPath('result.orderId')) then
          Result := True;

        if Assigned(jD.FindPath('retCode')) then
          if jD.FindPath('retCode').AsInteger = 110001 then
            Result := True;

        FreeAndNil(jD);
      end;
    except
      on E: Exception do
      begin
        TextColor(12);
        WriteLn(' ! ERROR > ' + E.Message + ' CancelOrderBybitFutures');
        TextColor(15);
        responce.SaveToFile('CancelOrderBybitFutures.log');
      end;
    end;
  finally
    if Assigned(jD) then FreeAndNil(jD);
    FreeAndNil(post);
    FreeAndNil(responce);
    FreeAndNil(http);
  end;
end;

function CancelAllOpenOrdersFuturesBybit(): boolean;
var
  http: THTTPSend;
  responce: TStringStream;
  hash, hs: string;
  url: string;
  post: TStringStream;
begin
  TextColor(14);
  WriteLn(' >>> CancelAllOpenOrdersFuturesBybit');
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
      http.MimeType := 'application/json';

      url := '{"category":"linear","symbol":"' + VAL_2 + VAL_1 + '"}';
      hs := IntToStr(GetTime) + GetKey + '5000' + url;
      hash := SHA256DigestToHex(CalcHMAC_SHA256(SECRET_BYBIT, hs));
      http.Headers.Add('X-BAPI-SIGN:' + hash);
      http.Headers.Add('X-BAPI-API-KEY:' + GetKey);
      http.Headers.Add('X-BAPI-TIMESTAMP:' + IntToStr(GetTime));
      http.Headers.Add('X-BAPI-RECV-WINDOW: 5000');
      http.Headers.Add('X-BAPI-SIGN-TYPE: 2');
      post.WriteString(url);

      http.Document.LoadFromStream(post);

      if (http.HTTPMethod('POST', url_bybit + '/v5/order/cancel-all')) and (http.ResultCode = 200) then
      begin
        http.Document.SaveToStream(responce);
        jD := GetJSON(responce.DataString);
        if jD.FindPath('result') <> nil then  Result := True;

        if Assigned(jD.FindPath('retMsg')) then
          if jD.FindPath('retMsg').AsString <> 'OK' then
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
        WriteLn(' ! ERROR > ' + E.Message + ' CancelAllOpenOrdersFuturesBybit');
        TextColor(15);
        responce.SaveToFile('CancelAllOpenOrdersFuturesBybit.log');
      end;
    end;
  finally
    if Assigned(jD) then FreeAndNil(jD);
    FreeAndNil(post);
    FreeAndNil(responce);
    FreeAndNil(http);
  end;
end;

function CheckOrderFuturesBybit(order_id: string): boolean;
var
  http: THTTPSend;
  responce: TStringStream;
  hash, hs: string;
  url: string;
begin
  TextColor(14);
  WriteLn(' >>> CheckOrderFuturesBybit');
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

      url := 'category=linear&orderId=' + order_id + '&symbol=' + val_2 + val_1;
      hs := IntToStr(GetTime) + GetKey + '5000' + url;
      hash := SHA256DigestToHex(CalcHMAC_SHA256(SECRET_BYBIT, hs));
      http.Headers.Add('X-BAPI-SIGN:' + hash);
      http.Headers.Add('X-BAPI-API-KEY:' + GetKey);
      http.Headers.Add('X-BAPI-TIMESTAMP:' + IntToStr(GetTime));
      http.Headers.Add('X-BAPI-RECV-WINDOW: 5000');
      http.Headers.Add('X-BAPI-SIGN-TYPE: 2');

      if (http.HTTPMethod('GET', url_bybit + '/v5/order/realtime?' + url)) then
      begin
        if http.ResultCode = 200 then
        begin
          http.Document.SaveToStream(responce);
          jD := GetJSON(responce.DataString);

          if Assigned(jD.FindPath('result.list[0]orderStatus')) then
          begin
            case jD.FindPath('result.list[0]orderStatus').AsString of
              'Cancelled': Result := True;
              'Filled': Result := True;
              'PartiallyFilled': Result := False;
              'New': Result := False;
              'Deactivated': Result := True;
            end;
          end;

          if Assigned(jD.FindPath('retMsg')) then
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
        WriteLn(' ! ERROR > ' + E.Message + ' CheckOrderFuturesBybit');
        TextColor(15);
        responce.SaveToFile('CheckOrderFuturesBybit.log');
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
