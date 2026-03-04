unit main;

{$mode objfpc}{$H+}

interface

uses
  Classes, Windows, SysUtils, Forms, Controls, Graphics, Dialogs, ExtCtrls,
  StdCtrls, Spin, ComCtrls, Menus, INIFiles;

type

  { TFormMain }

  TFormMain = class(TForm)
    CB_DATA_FOR_RSI: TComboBox;
    CB_TIME_FRAME: TComboBox;
    CB_NEXT_ORDER_RSI: TCheckBox;
    CB_XM: TCheckBox;
    CB_FIRST_RSI_ORDER: TCheckBox;
    Credit: TSpinEdit;
    SE_LENGTH_RSI_HIGH: TSpinEdit;
    Strateg: TComboBox;
    LabelRsiOrders: TLabel;
    LabelHttpsTimeout: TLabel;
    LabelInitialLeverage: TLabel;
    LabelProfit: TLabel;
    LabelStoploss: TLabel;
    LABEL_DATA_FOR_RSI: TLabel;
    L_RSI_OPEN_ORDER_SHORT: TLabel;
    MenuItem1: TMenuItem;
    MenuItem2: TMenuItem;
    MenuItem3: TMenuItem;
    MenuItem4: TMenuItem;
    MenuItem5: TMenuItem;
    MenuItemRemoveAll: TMenuItem;
    MenuItemDonatMe: TMenuItem;
    MenuItem7: TMenuItem;
    MenuItemHelp: TMenuItem;
    MenuRemoveLimit: TMenuItem;
    MenuItemFastStop: TMenuItem;
    RSI_SHORT_OPEN: TSpinEdit;
    HTTP_TIMEOUT: TSpinEdit;
    Stoploss: TFloatSpinEdit;
    Profit: TFloatSpinEdit;
    GB3: TGroupBox;
    ImageBG: TImage;
    L_RSI_OPEN_ORDER_LONG: TLabel;
    LABEL_BAR_FOR_RSI: TLabel;
    LABEL_LENGTH_RSI: TLabel;
    SE_LENGTH_RSI_LOW: TSpinEdit;
    RSI_LONG_OPEN: TSpinEdit;
    LabelEnableRsi: TLabel;
    LabelPair: TLabel;
    LabelStrateg: TLabel;
    MainMenuTop: TMainMenu;
    MenuItemMiniSteps: TMenuItem;
    MenuItemStandart: TMenuItem;
    MenuItemFastDown: TMenuItem;
    MenuItemFastPump: TMenuItem;
    MenuItemProbel: TMenuItem;
    MenuItemRemove: TMenuItem;
    MenuItemReload: TMenuItem;
    MenuItemStop: TMenuItem;
    MenuItemStart: TMenuItem;
    PopupMenuItems: TPopupMenu;
    StatusBar: TStatusBar;
    FirstStep: TFloatSpinEdit;
    GB1: TGroupBox;
    GB2: TGroupBox;
    GB4: TGroupBox;
    LabelOpenOrders: TLabel;
    LabelSettingsLoad: TLabel;
    LabelFirstStep: TLabel;
    LabelDepositOrder: TLabel;
    LabelMartingale: TLabel;
    LabelDepositLimit: TLabel;
    LabelReload: TLabel;
    LabelOrdersStep: TLabel;
    LabelPlusStep: TLabel;
    LBSettings: TListBox;
    DepositLimit: TFloatSpinEdit;
    DepositOrder: TFloatSpinEdit;
    OpenOrders: TSpinEdit;
    OrdersStep: TFloatSpinEdit;
    RATIO: TFloatSpinEdit;
    Martingale: TFloatSpinEdit;
    ReloadOrders: TFloatSpinEdit;
    Exchange: TComboBox;
    POSITION_MODE: TComboBox;
    TimerClear: TTimer;
    Val1: TEdit;
    Val2: TEdit;
    procedure CB_XMMouseLeave(Sender: TObject);
    procedure ExchangeChange(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure LabelDepositLimitMouseLeave(Sender: TObject);
    procedure LabelDepositOrderMouseLeave(Sender: TObject);
    procedure LabelEnableRsiMouseLeave(Sender: TObject);
    procedure LabelFirstStepMouseLeave(Sender: TObject);
    procedure LabelHttpsTimeoutMouseLeave(Sender: TObject);
    procedure LabelInitialLeverageMouseLeave(Sender: TObject);
    procedure LabelMartingaleMouseLeave(Sender: TObject);
    procedure LabelOpenOrdersMouseLeave(Sender: TObject);
    procedure LabelOrdersStepMouseLeave(Sender: TObject);
    procedure LabelPairMouseLeave(Sender: TObject);
    procedure LabelPlusStepMouseLeave(Sender: TObject);
    procedure LabelProfitMouseLeave(Sender: TObject);
    procedure LabelReloadMouseLeave(Sender: TObject);
    procedure LabelRsiOrdersMouseLeave(Sender: TObject);
    procedure LabelStoplossMouseLeave(Sender: TObject);
    procedure LabelStrategMouseLeave(Sender: TObject);
    procedure LABEL_BAR_FOR_RSIMouseLeave(Sender: TObject);
    procedure LABEL_DATA_FOR_RSIMouseLeave(Sender: TObject);
    procedure LABEL_LENGTH_RSIMouseLeave(Sender: TObject);
    procedure LBSettingsDblClick(Sender: TObject);
    procedure L_RSI_OPEN_ORDER_LONGMouseLeave(Sender: TObject);
    procedure L_RSI_OPEN_ORDER_SHORTMouseLeave(Sender: TObject);
    procedure MenuItemDonatMeClick(Sender: TObject);
    procedure MenuItemFastStopClick(Sender: TObject);
    procedure MenuItemHelpClick(Sender: TObject);
    procedure MenuItemReloadClick(Sender: TObject);
    procedure MenuItemRemoveAllClick(Sender: TObject);
    procedure MenuItemRemoveClick(Sender: TObject);
    procedure MenuItemScreenerTGClick(Sender: TObject);
    procedure MenuItemStartClick(Sender: TObject);
    procedure MenuItemStopClick(Sender: TObject);
    procedure MenuItemTelegramClick(Sender: TObject);
    procedure MenuItemTradingViewClick(Sender: TObject);
    procedure MenuRemoveLimitClick(Sender: TObject);
    procedure PopupMenuItemsPopup(Sender: TObject);
    procedure TimerClearTimer(Sender: TObject);
  private

  public
    procedure RefreshSettingsFolder;
  end;



var
  FormMain: TFormMain;
  fs: TFormatSettings;

implementation

{$R *.frm}

{ TFormMain }


procedure TFormMain.FormCreate(Sender: TObject);
begin
  fs.DecimalSeparator := '.';
  RefreshSettingsFolder();
end;

procedure TFormMain.LabelDepositLimitMouseLeave(Sender: TObject);
begin
  ShowHint := True;
end;

procedure TFormMain.LabelDepositOrderMouseLeave(Sender: TObject);
begin
  ShowHint := True;
end;

procedure TFormMain.LabelEnableRsiMouseLeave(Sender: TObject);
begin
  ShowHint := True;
end;

procedure TFormMain.LabelFirstStepMouseLeave(Sender: TObject);
begin
  LabelFirstStep.ShowHint := True;
end;

procedure TFormMain.LabelHttpsTimeoutMouseLeave(Sender: TObject);
begin
  ShowHint := True;
end;

procedure TFormMain.LabelInitialLeverageMouseLeave(Sender: TObject);
begin
  ShowHint := True;
end;

procedure TFormMain.LabelMartingaleMouseLeave(Sender: TObject);
begin
  ShowHint := True;
end;

procedure TFormMain.LabelOpenOrdersMouseLeave(Sender: TObject);
begin
  LabelOpenOrders.ShowHint := True;
end;

procedure TFormMain.LabelOrdersStepMouseLeave(Sender: TObject);
begin
  LabelOrdersStep.ShowHint := True;
end;

procedure TFormMain.LabelPairMouseLeave(Sender: TObject);
begin
  ShowHint := True;
end;

procedure TFormMain.LabelPlusStepMouseLeave(Sender: TObject);
begin
  LabelPlusStep.ShowHint := True;
end;

procedure TFormMain.LabelProfitMouseLeave(Sender: TObject);
begin
  LabelProfit.ShowHint := True;
end;

procedure TFormMain.LabelReloadMouseLeave(Sender: TObject);
begin
  LabelReload.ShowHint := True;
end;

procedure TFormMain.LabelRsiOrdersMouseLeave(Sender: TObject);
begin
  ShowHint := True;
end;

procedure TFormMain.LabelStoplossMouseLeave(Sender: TObject);
begin
  ShowHint := True;
end;

procedure TFormMain.LabelStrategMouseLeave(Sender: TObject);
begin
  ShowHint := True;
end;

procedure TFormMain.LABEL_BAR_FOR_RSIMouseLeave(Sender: TObject);
begin
  ShowHint := True;
end;

procedure TFormMain.LABEL_DATA_FOR_RSIMouseLeave(Sender: TObject);
begin
  ShowHint := True;
end;

procedure TFormMain.LABEL_LENGTH_RSIMouseLeave(Sender: TObject);
begin
  ShowHint := True;
end;

procedure TFormMain.ExchangeChange(Sender: TObject);
begin
  if (Exchange.Text = 'BINANCE_F_LS') or (Exchange.Text = 'BYBIT_F_LS') or (Exchange.Text = 'BYBIT_F_HG') or (Exchange.Text = 'BINANCE_F_HG') then
    Strateg.Enabled := False
  else
    Strateg.Enabled := True;

  if (Exchange.Text = 'BINANCE_F_HG') or (Exchange.Text = 'BYBIT_F_HG') then
    LabelStoploss.Caption := 'HEDG ORDER START'
  else
    LabelStoploss.Caption := 'STOPLOSS';
end;

procedure TFormMain.CB_XMMouseLeave(Sender: TObject);
begin
  ShowHint := True;
end;

procedure TFormMain.LBSettingsDblClick(Sender: TObject);
var
  ini: TIniFile;
begin
  if FormMain.LBSettings.ItemIndex <> -1 then
  begin
    if DirectoryExists('SETTINGS') then
    begin
      ini := TInifile.Create(extractfilepath(ParamStr(0)) + 'SETTINGS\' + LBSettings.Items.Strings[LBSettings.ItemIndex]);

      if ini.ReadInteger('BOT', 'STOP', 0) = 0 then
        MenuItemStop.Default := False
      else
        MenuItemStop.Default := True;

      if ini.ReadInteger('BOT', 'FASTSTOP', 0) = 0 then
        MenuItemFastStop.Default := False
      else
        MenuItemFastStop.Default := True;

      OpenOrders.Value := ini.ReadInteger('SETTINGS', 'OPEN_ORDERS', 0);
      FirstStep.Value := StrToFloat(ini.ReadString('SETTINGS', 'FIRST_STEP', '0'), fs);
      OrdersStep.Value := StrToFloat(ini.ReadString('SETTINGS', 'ORDERS_STEP', '0'), fs);
      RATIO.Value := StrToFloat(ini.ReadString('SETTINGS', 'RATIO', '0'), fs);
      ReloadOrders.Value := StrToFloat(ini.ReadString('SETTINGS', 'RELOAD_ORDERS', '0'), fs);
      DepositOrder.Value := StrToFloat(ini.ReadString('SETTINGS', 'DEPOSIT_ORDER', '0'), fs);
      Martingale.Value := StrToFloat(ini.ReadString('SETTINGS', 'MARTINGALE', '0'), fs);
      DepositLimit.Value := StrToFloat(ini.ReadString('SETTINGS', 'DEPOSIT_LIMIT', '0'), fs);
      Profit.Value := StrToFloat(ini.ReadString('SETTINGS', 'PROFIT', '0'), fs);
      Stoploss.Value := StrToFloat(ini.ReadString('SETTINGS', 'STOPLOSS', '0.1'), fs);
      CB_XM.Checked := ini.ReadBool('SETTINGS', 'X2', CB_XM.Checked);

      Val1.Text := ini.ReadString('PAIR', 'ONE', '');
      Val2.Text := ini.ReadString('PAIR', 'TWO', '');

      Exchange.Text := ini.ReadString('PAIR', 'EXCHANGE', 'BINANCE');

      Strateg.Text := ini.ReadString('PAIR', 'STRATEG', 'L');

      CB_FIRST_RSI_ORDER.Checked := ini.ReadBool('RSI', 'FIRST_RSI_ORDER', CB_FIRST_RSI_ORDER.Checked);
      CB_NEXT_ORDER_RSI.Checked := ini.ReadBool('RSI', 'NEXT_ORDER_RSI', CB_NEXT_ORDER_RSI.Checked);

      SE_LENGTH_RSI_LOW.Value := ini.ReadInteger('RSI', 'LENGTH_RSI_LOW', SE_LENGTH_RSI_LOW.Value);
      SE_LENGTH_RSI_HIGH.Value := ini.ReadInteger('RSI', 'LENGTH_RSI_HIGH', SE_LENGTH_RSI_HIGH.Value);

      CB_DATA_FOR_RSI.Text := ini.ReadString('RSI', 'DATA_FOR_RSI', CB_DATA_FOR_RSI.Text);
      CB_TIME_FRAME.Text := ini.ReadString('RSI', 'CB_TIME_FRAME', CB_TIME_FRAME.Text);

      RSI_LONG_OPEN.Value := ini.ReadInteger('RSI', 'RSI_OPEN_LONG', RSI_LONG_OPEN.Value);
      RSI_SHORT_OPEN.Value := ini.ReadInteger('RSI', 'RSI_OPEN_SHORT', RSI_SHORT_OPEN.Value);

      Credit.Value := ini.ReadInteger('MARGIN SETTINGS', 'CREDIT', Credit.Value);
      POSITION_MODE.Text := ini.ReadString('MARGIN SETTINGS', 'POSITION_MODE', POSITION_MODE.Text);

      HTTP_TIMEOUT.Value := ini.ReadInteger('TIMEOUT SETTINGS', 'HTTP_TIMEOUT', HTTP_TIMEOUT.Value);

      ini.Free;
      StatusBar.Panels[1].Text := 'Load ' + LBSettings.Items.Strings[LBSettings.ItemIndex];
      TimerClear.Enabled := True;

      if (Exchange.Text = 'BINANCE_F_LS') or (Exchange.Text = 'BYBIT_F_LS') or (Exchange.Text = 'BYBIT_F_HG') or (Exchange.Text = 'BINANCE_F_HG') then
        Strateg.Enabled := False
      else
        Strateg.Enabled := True;

      if (Exchange.Text = 'BINANCE_F_HG') or (Exchange.Text = 'BYBIT_F_HG') then
        LabelStoploss.Caption := 'HEDG ORDER START'
      else
        LabelStoploss.Caption := 'STOPLOSS';

    end;
  end;
end;

procedure TFormMain.L_RSI_OPEN_ORDER_LONGMouseLeave(Sender: TObject);
begin
  ShowHint := True;
end;

procedure TFormMain.L_RSI_OPEN_ORDER_SHORTMouseLeave(Sender: TObject);
begin
  ShowHint := True;
end;

procedure TFormMain.MenuItemDonatMeClick(Sender: TObject);
begin
  ShellExecute(Handle, 'open', 'https://yoomoney.ru/fundraise/1G9OL5QU7DI.260304', nil, nil, SW_NORMAL);
  StatusBar.Panels[1].Text := 'https://yoomoney.ru/fundraise/1G9OL5QU7DI.260304';
  TimerClear.Enabled := True;
end;

procedure TFormMain.MenuItemFastStopClick(Sender: TObject);
var
  ini: TINIFile;
begin
  if LBSettings.GetSelectedText <> '' then
  begin
    ini := TINIFile.Create(extractfilepath(ParamStr(0)) + 'SETTINGS\' + LBSettings.Items.Strings[LBSettings.ItemIndex]);
    if MenuItemFastStop.Default = False then
    begin
      ini.WriteInteger('BOT', 'FASTSTOP', 1);
      MenuItemFastStop.Default := True;
    end
    else
    begin
      ini.WriteInteger('BOT', 'FASTSTOP', 0);
      MenuItemFastStop.Default := False;
    end;
    ini.Free;
  end;
end;

procedure TFormMain.MenuItemHelpClick(Sender: TObject);
begin
  ShellExecute(Handle, 'open', 'help.txt', nil, nil, SW_NORMAL);
  StatusBar.Panels[1].Text := 'Open file  help.txt';
  TimerClear.Enabled := True;
end;

procedure TFormMain.MenuItemReloadClick(Sender: TObject);
var
  ini: TINIFile;
begin
  if FormMain.LBSettings.ItemIndex <> -1 then
  begin
    if MessageDlg('Change settings ' + LBSettings.Items.Strings[LBSettings.ItemIndex] + ' ? ', mtConfirmation, [mbYes, mbNo], 0) = mrYes then
    begin

      ini := TINIFile.Create(extractfilepath(ParamStr(0)) + 'SETTINGS\' + LBSettings.Items.Strings[LBSettings.ItemIndex]);

      ini.WriteInteger('SETTINGS', 'OPEN_ORDERS', OpenOrders.Value);
      ini.WriteString('SETTINGS', 'FIRST_STEP', FloatToStr(FirstStep.Value, fs));
      ini.WriteString('SETTINGS', 'ORDERS_STEP', FloatToStr(OrdersStep.Value, fs));
      ini.WriteString('SETTINGS', 'RATIO', FloatToStr(RATIO.Value, fs));
      ini.WriteString('SETTINGS', 'RELOAD_ORDERS', FloatToStr(ReloadOrders.Value, fs));
      ini.WriteString('SETTINGS', 'DEPOSIT_ORDER', FloatToStr(DepositOrder.Value, fs));
      ini.WriteString('SETTINGS', 'MARTINGALE', FloatToStr(Martingale.Value, fs));
      ini.WriteString('SETTINGS', 'DEPOSIT_LIMIT', FloatToStr(DepositLimit.Value, fs));
      ini.WriteString('SETTINGS', 'PROFIT', FloatToStr(Profit.Value, fs));
      ini.WriteString('SETTINGS', 'STOPLOSS', FloatToStr(Stoploss.Value, fs));
      ini.WriteBool('SETTINGS', 'X2', CB_XM.Checked);

      ini.WriteBool('RSI', 'FIRST_RSI_ORDER', CB_FIRST_RSI_ORDER.Checked);
      ini.WriteBool('RSI', 'NEXT_ORDER_RSI', CB_NEXT_ORDER_RSI.Checked);
      ini.WriteInteger('RSI', 'LENGTH_RSI_LOW', SE_LENGTH_RSI_LOW.Value);
      ini.WriteInteger('RSI', 'LENGTH_RSI_HIGH', SE_LENGTH_RSI_HIGH.Value);
      ini.WriteString('RSI', 'DATA_FOR_RSI', CB_DATA_FOR_RSI.Text);
      ini.WriteString('RSI', 'CB_TIME_FRAME', CB_TIME_FRAME.Text);
      ini.WriteInteger('RSI', 'RSI_OPEN_LONG', RSI_LONG_OPEN.Value);
      ini.WriteInteger('RSI', 'RSI_OPEN_SHORT', RSI_SHORT_OPEN.Value);

      ini.WriteInteger('MARGIN SETTINGS', 'CREDIT', Credit.Value);
      ini.WriteString('MARGIN SETTINGS', 'POSITION_MODE', POSITION_MODE.Text);

      ini.WriteInteger('TIMEOUT SETTINGS', 'HTTP_TIMEOUT', HTTP_TIMEOUT.Value);

      ini.Free;

      ShowMessage('Settings ' + LBSettings.Items.Strings[LBSettings.ItemIndex] + ' changed');
      TimerClear.Enabled := True;

      if (Exchange.Text = 'BINANCE_F_LS') or (Exchange.Text = 'BYBIT_F_LS') or (Exchange.Text = 'BYBIT_F_HG') or (Exchange.Text = 'BINANCE_F_HG') then
        Strateg.Enabled := False
      else
        Strateg.Enabled := True;

      if (Exchange.Text = 'BINANCE_F_HG') or (Exchange.Text = 'BYBIT_F_HG') then
        LabelStoploss.Caption := 'HEDG ORDER START'
      else
        LabelStoploss.Caption := 'STOPLOSS';
    end;

  end;
end;

procedure TFormMain.MenuItemRemoveAllClick(Sender: TObject);
var
  s: string;
begin
  repeat
    if LBSettings.Items.Count > 0 then
    begin
      s := ExtractFilePath(ParamStr(0)) + 'SETTINGS\' + LBSettings.Items[0];
      DeleteFile(s);
      LBSettings.Items.Delete(0);
    end;
  until LBSettings.Items.Count = 0;
  RefreshSettingsFolder();
  StatusBar.Panels[1].Text := 'Remove all settings .ini ';
  TimerClear.Enabled := True;
end;

procedure TFormMain.MenuItemRemoveClick(Sender: TObject);
var
  s: string;
begin
  if LBSettings.GetSelectedText <> '' then
  begin
    s := ExtractFilePath(ParamStr(0)) + 'SETTINGS\' + LBSettings.Items.Strings[LBSettings.ItemIndex];
    StatusBar.Panels[1].Text := 'Remove ' + LBSettings.Items.Strings[LBSettings.ItemIndex];
    TimerClear.Enabled := True;
    DeleteFile(s);
    LBSettings.DeleteSelected;
    RefreshSettingsFolder();
  end;
end;

procedure TFormMain.MenuItemScreenerTGClick(Sender: TObject);
begin

end;

procedure TFormMain.MenuItemStartClick(Sender: TObject);
var
  ini: TINIFile;
begin
  if (Exchange.Text = 'BYBIT_F_LS') or (Exchange.Text = 'BINANCE_F_LS') or (Exchange.Text = 'BYBIT_F_HG') or (Exchange.Text = 'BINANCE_F_HG') then
    ini := TINIFile.Create(extractfilepath(ParamStr(0)) + 'SETTINGS\' + Val1.Text + '_' + Val2.Text + '_' + Exchange.Text + '.ini')
  else
    ini := TINIFile.Create(extractfilepath(ParamStr(0)) + 'SETTINGS\' + Val1.Text + '_' + Val2.Text + '_' + Exchange.Text + '_' + Strateg.Text + '.ini');

  ini.WriteInteger('SETTINGS', 'OPEN_ORDERS', OpenOrders.Value);
  ini.WriteString('SETTINGS', 'FIRST_STEP', FloatToStr(FirstStep.Value, fs));
  ini.WriteString('SETTINGS', 'ORDERS_STEP', FloatToStr(OrdersStep.Value, fs));
  ini.WriteString('SETTINGS', 'RATIO', FloatToStr(RATIO.Value, fs));
  ini.WriteString('SETTINGS', 'RELOAD_ORDERS', FloatToStr(ReloadOrders.Value, fs));
  ini.WriteString('SETTINGS', 'DEPOSIT_ORDER', FloatToStr(DepositOrder.Value, fs));
  ini.WriteString('SETTINGS', 'MARTINGALE', FloatToStr(Martingale.Value, fs));
  ini.WriteString('SETTINGS', 'DEPOSIT_LIMIT', FloatToStr(DepositLimit.Value, fs));
  ini.WriteString('SETTINGS', 'PROFIT', FloatToStr(Profit.Value, fs));
  ini.WriteString('SETTINGS', 'STOPLOSS', FloatToStr(Stoploss.Value, fs));
  ini.WriteBool('SETTINGS', 'X2', CB_XM.Checked);

  ini.WriteString('PAIR', 'ONE', Val1.Text);
  ini.WriteString('PAIR', 'TWO', Val2.Text);

  ini.WriteString('PAIR', 'EXCHANGE', Exchange.Text);
  ini.WriteString('PAIR', 'STRATEG', Strateg.Text);

  ini.WriteBool('RSI', 'FIRST_RSI_ORDER', CB_FIRST_RSI_ORDER.Checked);
  ini.WriteBool('RSI', 'NEXT_ORDER_RSI', CB_NEXT_ORDER_RSI.Checked);
  ini.WriteInteger('RSI', 'LENGTH_RSI_LOW', SE_LENGTH_RSI_LOW.Value);
  ini.WriteInteger('RSI', 'LENGTH_RSI_HIGH', SE_LENGTH_RSI_HIGH.Value);
  ini.WriteString('RSI', 'DATA_FOR_RSI', CB_DATA_FOR_RSI.Text);
  ini.WriteString('RSI', 'CB_TIME_FRAME', CB_TIME_FRAME.Text);
  ini.WriteInteger('RSI', 'RSI_OPEN_LONG', RSI_LONG_OPEN.Value);
  ini.WriteInteger('RSI', 'RSI_OPEN_SHORT', RSI_SHORT_OPEN.Value);

  ini.WriteInteger('MARGIN SETTINGS', 'CREDIT', Credit.Value);
  ini.WriteString('MARGIN SETTINGS', 'POSITION_MODE', POSITION_MODE.Text);
  ini.WriteInteger('TIMEOUT SETTINGS', 'HTTP_TIMEOUT', HTTP_TIMEOUT.Value);

  ini.WriteInteger('BOT', 'STOP', 0);
  ini.WriteInteger('BOT', 'FASTSTOP', 0);

  ini.Free;
  RefreshSettingsFolder;

  MenuItemStop.Default := False;
  MenuItemFastStop.Default := False;

  ShellExecute(Handle, 'Open', 'bot.exe',
    PChar(Val1.Text + ' ' + Val2.Text + ' ' + Exchange.Text + ' ' + Strateg.Text), nil, 1);

  StatusBar.Panels[1].Text := 'Run new consol : ' + Val1.Text + '/' + Val2.Text;
  TimerClear.Enabled := True;

  if (Exchange.Text = 'BINANCE_F_LS') or (Exchange.Text = 'BYBIT_F_LS') or (Exchange.Text = 'BYBIT_F_HG') or (Exchange.Text = 'BINANCE_F_HG') then
    Strateg.Enabled := False
  else
    Strateg.Enabled := True;

  if (Exchange.Text = 'BINANCE_F_HG') or (Exchange.Text = 'BYBIT_F_HG') then
    LabelStoploss.Caption := 'HEDG ORDER START'
  else
    LabelStoploss.Caption := 'STOPLOSS';
end;

procedure TFormMain.MenuItemStopClick(Sender: TObject);
var
  ini: TINIFile;
begin
  if LBSettings.GetSelectedText <> '' then
  begin
    ini := TINIFile.Create(extractfilepath(ParamStr(0)) + 'SETTINGS\' + LBSettings.Items.Strings[LBSettings.ItemIndex]);
    if MenuItemStop.Default = False then
    begin
      ini.WriteInteger('BOT', 'STOP', 1);
      MenuItemStop.Default := True;
    end
    else
    begin
      ini.WriteInteger('BOT', 'STOP', 0);
      MenuItemStop.Default := False;
    end;
    ini.Free;
  end;
end;

procedure TFormMain.MenuItemTelegramClick(Sender: TObject);
begin
  ShellExecute(Handle, 'open', 'https://t.me/CryptoCrazyInfo', nil, nil, SW_NORMAL);
  StatusBar.Panels[1].Text := 'Open site  https://t.me/CryptoCrazyInfo';
  TimerClear.Enabled := True;
end;

procedure TFormMain.MenuItemTradingViewClick(Sender: TObject);
begin
  ShellExecute(Handle, 'Open', 'bot.exe',
    PChar('.' + ' ' + '.' + ' ' + Exchange.Text + ' ' + 'TRADINGVIEW'), nil, 1);
end;

procedure TFormMain.MenuRemoveLimitClick(Sender: TObject);
var
  ini: TINIFile;
begin
  if LBSettings.GetSelectedText <> '' then
  begin
    ini := TINIFile.Create(ExtractFilePath(ParamStr(0)) + 'SETTINGS\' + LBSettings.Items.Strings[LBSettings.ItemIndex]);
    ini.WriteString('SAVE', 'USES_DEPOSIT', '999999999');
    ini.Free;
    StatusBar.Panels[1].Text := 'Remove limit deposit';
    TimerClear.Enabled := True;
  end;
end;

procedure TFormMain.PopupMenuItemsPopup(Sender: TObject);
begin
  if LBSettings.GetSelectedText <> '' then
  begin
    MenuRemoveLimit.Visible := True;
    MenuItemRemove.Visible := True;
    MenuItemRemoveAll.Visible := True;
  end
  else
  begin
    MenuRemoveLimit.Visible := False;
    MenuItemRemove.Visible := False;
    MenuItemRemoveAll.Visible := True;
  end;
end;

procedure TFormMain.TimerClearTimer(Sender: TObject);
begin
  StatusBar.Panels[1].Text := '';
  TimerClear.Enabled := False;
  ;
end;

procedure TFormMain.RefreshSettingsFolder;
var
  sr: TSearchRec;
begin
  if DirectoryExists(extractfilepath(ParamStr(0)) + 'SETTINGS') then
  begin
    FormMain.LBSettings.Clear;
    if FindFirst(ExtractFilePath(ParamStr(0)) + 'SETTINGS\' + '*.ini', faAnyFile, sr) = 0 then
      repeat
        FormMain.LBSettings.Items.Add(sr.Name);
      until FindNext(sr) <> 0;
    FindClose(sr);
  end
  else
    ShowMessage('NO FOUND SETTINGS FOLDER');
end;

end.
