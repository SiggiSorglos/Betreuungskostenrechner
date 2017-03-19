object Form1: TForm1
  Left = 0
  Top = 0
  Caption = 'Betreuerkostenrechner'
  ClientHeight = 563
  ClientWidth = 578
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  OnCreate = OnForm1Create
  PixelsPerInch = 96
  TextHeight = 13
  object Label2: TLabel
    Left = 32
    Top = 16
    Width = 147
    Height = 13
    Caption = 'Beginn der Betreuung  (ZU/EB)'
  end
  object Label3: TLabel
    Left = 32
    Top = 96
    Width = 89
    Height = 13
    Caption = 'ZU/EB an Betreuer'
  end
  object Label1: TLabel
    Left = 32
    Top = 152
    Width = 95
    Height = 13
    Caption = 'Abrechnungsbeginn'
  end
  object Label5: TLabel
    Left = 32
    Top = 200
    Width = 87
    Height = 13
    Caption = 'Abrechnungsende'
  end
  object RadioGroup1: TRadioGroup
    Left = 208
    Top = 16
    Width = 177
    Height = 137
    Caption = 'Betreuungstyp'
    TabOrder = 13
  end
  object DatePickerBeginnDerBetreuung: TDateTimePicker
    Left = 32
    Top = 32
    Width = 97
    Height = 21
    Date = 42005.000000000000000000
    Time = 42005.000000000000000000
    TabOrder = 0
    OnExit = OnDatePickerBeginnDerBetreuungExit
  end
  object DatePickerZUEBanBetreuer: TDateTimePicker
    Left = 32
    Top = 112
    Width = 97
    Height = 21
    Date = 42370.000000000000000000
    Time = 42370.000000000000000000
    TabOrder = 2
    OnExit = OnComboBoxZUEBanBetreuerExit
  end
  object ButtonBerechnen: TButton
    Left = 208
    Top = 208
    Width = 97
    Height = 33
    Caption = '&Berechnen'
    Default = True
    TabOrder = 11
    OnClick = ButtonBerechnenClick
  end
  object RadioButtonVH: TRadioButton
    Left = 224
    Top = 48
    Width = 145
    Height = 17
    Caption = 'Verm'#246'gend, Heim'
    Checked = True
    TabOrder = 5
    TabStop = True
  end
  object RadioButtonVnH: TRadioButton
    Left = 224
    Top = 72
    Width = 145
    Height = 17
    Caption = 'Verm'#246'gend, nicht Heim'
    TabOrder = 6
  end
  object RadioButtonMH: TRadioButton
    Left = 224
    Top = 96
    Width = 145
    Height = 17
    Caption = 'Mittellos,      Heim'
    TabOrder = 7
  end
  object RadioButtonMnH: TRadioButton
    Left = 224
    Top = 120
    Width = 145
    Height = 17
    Caption = 'Mittellos,      nicht Heim'
    TabOrder = 8
  end
  object MemoErgebnis: TMemo
    Left = 17
    Top = 247
    Width = 553
    Height = 289
    Lines.Strings = (
      'Noch keine Berechnung durchgef'#252'hrt.'
      '')
    ReadOnly = True
    ScrollBars = ssBoth
    TabOrder = 12
  end
  object ComboBoxAbrechnungsBeginn: TComboBox
    Left = 32
    Top = 168
    Width = 97
    Height = 21
    TabOrder = 3
    OnExit = OnComboBoxAbrechnungsBeginnExit
  end
  object ComboBoxAbrechnungsEnde: TComboBox
    Left = 32
    Top = 216
    Width = 97
    Height = 21
    TabOrder = 4
  end
  object CheckBoxAltfall: TCheckBox
    Left = 32
    Top = 64
    Width = 121
    Height = 17
    Hint = 'individueller Betreuungsbeginn bleibt unber'#252'cksichtigt'
    Caption = 'Als Altfall behandeln'
    ParentShowHint = False
    ShowHint = True
    TabOrder = 1
  end
  object DatePickerHeimstatuswechsel: TDateTimePicker
    Left = 328
    Top = 168
    Width = 97
    Height = 21
    Date = 36161.000000000000000000
    Time = 36161.000000000000000000
    Enabled = False
    TabOrder = 10
    OnExit = OnComboBoxZUEBanBetreuerExit
  end
  object CheckBoxHeimstatuswechsel: TCheckBox
    Left = 208
    Top = 168
    Width = 113
    Height = 17
    Caption = 'Heimstatuswechsel '
    TabOrder = 9
    OnClick = OnClickCheckboxHeimstatuswechsel
    OnExit = OnClickCheckboxHeimstatuswechsel
  end
  object ButtonDrucken: TButton
    Left = 328
    Top = 208
    Width = 97
    Height = 33
    Caption = '&Drucken'
    Default = True
    TabOrder = 14
    OnClick = ButtonDruckenClick
  end
end
