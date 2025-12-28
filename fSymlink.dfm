object main: Tmain
  Left = 0
  Top = 0
  BorderIcons = [biSystemMenu]
  BorderStyle = bsSingle
  Caption = #1052#1072#1089#1090#1077#1088' '#1089#1086#1079#1076#1072#1085#1080#1103' '#1089#1080#1084'-'#1083#1080#1085#1082' '#1086#1090' ///LisEd'
  ClientHeight = 147
  ClientWidth = 440
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -12
  Font.Name = 'Segoe UI'
  Font.Style = []
  Position = poMainFormCenter
  TextHeight = 15
  object targ: TLabel
    Left = 15
    Top = 56
    Width = 196
    Height = 15
    Caption = #1062#1077#1083#1100' ('#1089#1091#1097#1077#1089#1090#1074#1091#1102#1097#1072#1103' '#1087#1072#1087#1082#1072'/'#1092#1072#1081#1083'):'
  end
  object Link: TLabel
    Left = 15
    Top = 8
    Width = 225
    Height = 15
    Caption = #1055#1091#1090#1100' '#1082' '#1085#1086#1074#1086#1081' '#1089#1089#1099#1083#1082#1077' ('#1075#1076#1077' '#1089#1086#1079#1076#1072#1090#1100' '#1080' '#1080#1084#1103'):'
    ParentShowHint = False
    ShowHint = False
  end
  object btnDoIt: TButton
    Left = 136
    Top = 102
    Width = 209
    Height = 25
    Caption = #1057#1086#1079#1076#1072#1090#1100' '#1089#1080#1084#1074#1086#1083#1080#1095#1077#1089#1082#1091#1102' '#1089#1089#1099#1083#1082#1091
    TabOrder = 0
    OnClick = btnDoItClick
  end
  object s: TEdit
    Left = 15
    Top = 24
    Width = 330
    Height = 23
    ParentShowHint = False
    ShowHint = True
    TabOrder = 1
  end
  object t: TEdit
    Left = 15
    Top = 72
    Width = 330
    Height = 23
    TabOrder = 2
  end
  object btnPthLink: TButton
    Left = 351
    Top = 23
    Width = 66
    Height = 25
    Caption = #1054#1073#1079#1086#1088'...'
    TabOrder = 3
    OnClick = btnPthLinkClick
  end
  object btnPthSource: TButton
    Left = 351
    Top = 71
    Width = 66
    Height = 25
    Caption = #1054#1073#1079#1086#1088'...'
    TabOrder = 4
    OnClick = btnPthSourceClick
  end
  object rbEN: TRadioButton
    Left = 15
    Top = 112
    Width = 41
    Height = 17
    Caption = 'Eng'
    TabOrder = 5
    OnClick = rbENClick
  end
  object rbRU: TRadioButton
    Left = 70
    Top = 112
    Width = 43
    Height = 17
    Caption = 'Rus'
    Checked = True
    TabOrder = 6
    TabStop = True
    OnClick = rbRUClick
  end
end
