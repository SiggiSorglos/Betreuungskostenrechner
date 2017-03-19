unit Betreuungskostenrechner;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, ComCtrls, StdCtrls, DateUtils, Math, ExtCtrls,
  Printers;   // Unit containing the Printer command;

type
  TForm1 = class(TForm)
    DatePickerBeginnDerBetreuung: TDateTimePicker;
    DatePickerZUEBanBetreuer: TDateTimePicker;
    ButtonBerechnen: TButton;
    RadioButtonVH: TRadioButton;
    RadioButtonVnH: TRadioButton;
    RadioButtonMH: TRadioButton;
    RadioButtonMnH: TRadioButton;
    Label2: TLabel;
    Label3: TLabel;
    MemoErgebnis: TMemo;
    RadioGroup1: TRadioGroup;
    ComboBoxAbrechnungsBeginn: TComboBox;
    Label1: TLabel;
    Label5: TLabel;
    ComboBoxAbrechnungsEnde: TComboBox;
    CheckBoxAltfall: TCheckBox;
    DatePickerHeimstatuswechsel: TDateTimePicker;
    CheckBoxHeimstatuswechsel: TCheckBox;
    ButtonDrucken: TButton;
    procedure ButtonDruckenClick(Sender: TObject);
    procedure OnClickCheckboxHeimstatuswechsel(Sender: TObject);
    procedure OnComboBoxAbrechnungsBeginnExit(Sender: TObject);
    procedure OnComboBoxZUEBanBetreuerExit(Sender: TObject);
    procedure OnDatePickerBeginnDerBetreuungExit(Sender: TObject);
    procedure OnForm1Create(Sender: TObject);
    procedure ButtonBerechnenClick(Sender: TObject);

    private
      { Private-Deklarationen }
    public
      { Public-Deklarationen }
  end;

      BetreuerType = (
      IllegallValueBtT = -1,
      Ungelernt = 0,
      Lehre = 1,
      HochschulAusbildung = 2);

      BetreuungstypType = (
      IllegalValueBT = -1,
      VermoegendHeim = 0,
      VermoegendNichtHeim = 1,
      MittellosHeim = 2,
      MittellosNichtHeim = 3);

    BetreuungsZeitType = (
      IllegalValueBZT = -1,
      Monat1bis3 = 0,
      Monat4bis6 = 1,
      Monat7bis12 = 2,
      Monat13bisUnendlich = 3);

    DatumPunktType = (
      BeginnDerBetreuung = 0,
      BeginnDerAbrechnung = 1,
      EndeDerAbrechnung = 2);

    BeginnEndeIntegerTyp = Record
      Beginn : Integer;
      Ende : Integer;
    End;

    StundenInfoType = Record
      BeginnDerBetreuung : TDate; {ZU/EB der Betreuung}
      Altfall : Boolean; {True => Altfall}
      ZUEBanBetreuer : TDate;     {ZU/EB des Betreuers}
      BeginnDerAbrechnung : TDate;
      EndeDerAbrechnung : TDate;
      BetreuungsTyp : BetreuungsTypType;

      SynchronDatum : TDate;

      {Volle Monate vor der ersten Änderung der Stunden/Monat}
      ErsterVollerMonatVorSync : Integer; {Betreuungsmonat des ersten Monats nach dem Beginn der Abrechnung}
      AnzahlVolleMonateVorSync : Integer;
      VollerMonatVorSync : Array[0..2000] of BeginnEndeIntegerTyp; {Monat der Betreuung zu Beginn und am Ende des Monats}
      StundenImVollenMonatVorSync : Array[0..2000] of Double;
      AnfangsDatumImVollenMonatVorSync : Array[0..2000] of TDate;
      EndDatumImVollenMonatVorSync : Array[0..2000] of TDate;

      {Teilmonat am Anfang}
      AnfangsMonat : Integer; {Betreuungsmonat des ersten nicht vollen Monats}
      BeginnDesAnfangsMonats : TDate; {Beginn des AnfangsTeilmonats}
      BetreuungsTageAnfangsTeilMonat : Integer;
      {Anzahl der Tage vom Beginn der Abrechnung rechnerisch bis zum ersten Monats-Synchron-Tag mit dem Beginn der Betreuung}

      MonatsLaengeAnfang : Integer;

      StundenImAnfangsMonat : Double;
      ErbrachteStundenAnfangsMonatUngerundet : Double;
      ErbrachteStundenAnfangsMonat : Double;

      {Volle Monate}
      ErsterSynchronMonat : Integer; {Betreuungsmonat des ersten Monats nach dem Synchrondatum}
      AnzahlVolleMonate : Integer;
      VollerMonat : Array[0..2000] of Integer; {Monat der Betreuung}
      StundenImVollenMonat : Array[0..2000] of Double;
      AnfangsDatumImVollenMonat : Array[0..2000] of TDate;
      EndDatumImVollenMonat : Array[0..2000] of TDate;

      {Teilmonat am Ende}
      BeginnDesLetztenMonats : TDate; {Datum des Beginns des Letzen Monats}
      EndMonat : Integer; {Betreuungsmonat des letzten nicht vollen Monats}
      BetreuungsTageEndeTeilMonat : Integer;
      {Anzahl der Beteuungstage im letzten nicht voll abgerechneten Monat}

      MonatsLaengeEnde : Integer;

      StundenImEndMonat : Double;
      ErbrachteStundenEndMonatUngerundet: Double;
      ErbrachteStundenEndMonat : Double;

      SummeStunden : Double;

      StundenSatz : Double;
    End;


procedure BerechneStundenInfo(Const BeginnDerBetreuung : TDate;
                              Const Altfall : Boolean;
                              Const ZUEBanBetreuer : TDate;
                              Const BeginnDerAbrechnung : TDate;
                              Const EndeDerAbrechnung : TDate;
                              Const BetreuungsTyp : BetreuungstypType;
                              Const Betreuer : BetreuerType;
                                Var StundenInfo : StundenInfoType);

    Function DateDiffMonth(Const Date1 : TDate; Const Date2 : TDate) : LongInt;
    Function GetMonatsIndex(Const MonatsNr : Integer) : BetreuungsZeitType;
    Procedure EingabeDatenAusgabe(StundenInfo : StundenInfoType);
    Procedure ErgebnisAusgabe(StundenInfo : StundenInfoType);

var
  Form1: TForm1;

Const
  Quartalslaenge = 3;
  AnzEintraege = 40; {Anzahl der Eintäge in den ComboBoxen}

implementation

{$R *.dfm}

var
      StundenTabelle : Array[BetreuungstypType,BetreuungsZeitType] of Double;

      StundenSatzArray : Array[BetreuerType] of Double;

procedure TForm1.ButtonBerechnenClick(Sender: TObject);

var
  BetreuungsTyp : BetreuungstypType;
  StundenInfo : StundenInfoType;
  BeginnDerBetreuung, ZUEBanBetreuer, BeginnDerAbrechnung, EndeDerAbrechnung, HeimStatuswechselDatum : TDate;
  Altfall : Boolean;
  TempString : String;
  ZwischenSummeStunden1 : Double;

begin
  {Berechne Betreuungstyp}
  If RadioButtonVH.Checked  = True Then
    BetreuungsTyp := VermoegendHeim
  Else If RadioButtonVnH.Checked  = True Then
    BetreuungsTyp := VermoegendNichtHeim
  Else If RadioButtonMH.Checked  = True Then
    BetreuungsTyp := MittellosHeim
  Else If RadioButtonMnH.Checked  = True Then
    BetreuungsTyp := MittellosNichtHeim
  Else
    Begin
      {Fehler ausgeben}
      ShowMessage('Fehler bei der Berecnung des BetreuungsTyps aufgetreten');
      BetreuungsTyp := IllegalValueBT
    End;


  BeginnDerBetreuung := DateOf(Form1.DatePickerBeginnDerBetreuung.Date);
  ZUEBanBetreuer := DateOf(Form1.DatePickerZUEBanBetreuer.Date);
  BeginnDerAbrechnung := StrToDate(Form1.ComboBoxAbrechnungsBeginn.Text);
  EndeDerAbrechnung := StrToDate(Form1.ComboBoxAbrechnungsEnde.Text);
  HeimStatuswechselDatum := Form1.DatePickerHeimstatuswechsel.Date;

  Case CheckBoxAltfall.State of
    cbChecked:              Altfall := true;
    cbUnChecked, cbGrayed:  Altfall := false;
  End;

  {Prüfe Datumsangaben auf Plausibilität}
  If CompareDate(BeginnDerBetreuung, ZUEBanBetreuer) > 0 then
    ShowMessage('Eingabefehler: Das Datum "Beginn der Betreuung (ZU/EB)" muss vor dem Datum "ZU/EB des Betreuuers" liegen oder gleich sein. Bitte korrigieren.')
  Else
  If CompareDate(ZUEBanBetreuer, BeginnDerAbrechnung) >= 0 then
    ShowMessage('Eingabefehler: Das Datum "ZU/EB des Betreuers" muss vor dem Datum "Abrechnungsbeginn" liegen. Bitte korrigieren.')
  Else
  If CompareDate(BeginnDerAbrechnung, EndeDerAbrechnung) > 0 then
    ShowMessage('Eingabefehler: Das Datum "Abrechnungsbeginn" muss vor dem Datum "Abrechnungsende" liegen oder gleich sein. Bitte korrigieren.')
  Else
  If (Form1.CheckBoxHeimstatuswechsel.State = cbChecked)
      and (CompareDate (BeginnDerAbrechnung, HeimStatuswechselDatum) >= 0) then
       ShowMessage('Eingabefehler: Das Datum "Heimstatuswechsel" muss nach dem Datum "Abrechnungbeginn" liegen. Bitte korrigieren.')
  Else
  If (Form1.CheckBoxHeimstatuswechsel.State = cbChecked)
      and (CompareDate (HeimStatuswechselDatum, EndeDerAbrechnung) >= 0) then
       ShowMessage('Eingabefehler: Das Datum "Abrechnungsende" muss nach dem Datum "Heimstatuswechsel" liegen. Bitte korrigieren.')
  Else
  Begin
    If Form1.CheckBoxHeimstatuswechsel.State = cbUnChecked then
    Begin
      {Fall ohne Heimstatuswechsel}
      BerechneStundenInfo(BeginnDerBetreuung,
                          Altfall,
                          ZUEBanBetreuer,
                          BeginnDerAbrechnung,
                          EndeDerAbrechnung,
                          BetreuungsTyp,
                          HochschulAusbildung,
                          StundenInfo
                          );
      EingabeDatenAusgabe(StundenInfo);
      ErgebnisAusgabe (StundenInfo);

      {Ausgabe der Gesamtstunden und des Gesamtbetrags}
      Form1.MemoErgebnis.Lines.Append('');

      Form1.MemoErgebnis.Lines.Append('Gesamtstunden = ' + FloatToStrF(StundenInfo.SummeStunden, ffFixed, 10, 1) + ' Std.');
      Form1.MemoErgebnis.Lines.Append('');
      Form1.MemoErgebnis.Lines.Append('Gesamtbetrag = ' + FloatToStrF(StundenInfo.SummeStunden * StundenInfo.StundenSatz, ffFixed, 10, 2) + ' €');

    End
    Else
    Begin
      {Fall mit Heimstatuswechsel}
      {Vor Statuswechsel}
      BerechneStundenInfo(BeginnDerBetreuung,
                          Altfall,
                          ZUEBanBetreuer,
                          BeginnDerAbrechnung,
                          HeimstatuswechselDatum,
                          BetreuungsTyp,
                          HochschulAusbildung,
                          StundenInfo
                          );
       EingabeDatenAusgabe(StundenInfo);
       ErgebnisAusgabe (StundenInfo);

      {Ausgabe der 1. Zwischensumme Stunden und der Zwischensumme Betrag}
      Form1.MemoErgebnis.Lines.Append('');

      ZwischenSummeStunden1 := StundenInfo.SummeStunden;

      Form1.MemoErgebnis.Lines.Append('1. Zwischensumme Stunden = ' + FloatToStrF(ZwischenSummeStunden1, ffFixed, 10, 1) + ' Std.');
      Form1.MemoErgebnis.Lines.Append('');
      Form1.MemoErgebnis.Lines.Append('1. Zwischensumme Betrag = ' + FloatToStrF(ZwischenSummeStunden1 * StundenInfo.StundenSatz, ffFixed, 10, 2) + ' €');

       {neuen Heimstatus bestimmen}
       Case BetreuungsTyp of
          VermoegendHeim :
          Begin
            BetreuungsTyp := VermoegendNichtHeim;
            TempString := 'Nicht mehr im Heim ab: ';
          End;
          VermoegendNichtHeim :
          Begin
            BetreuungsTyp := VermoegendHeim;
            TempString := 'Heimaufnahme am: ';
          End;
          MittellosHeim :
          Begin
            BetreuungsTyp := MittellosNichtHeim;
            TempString := 'Nicht mehr im Heim ab: ';
          End;
          MittellosNichtHeim :
          Begin
            BetreuungsTyp := MittellosHeim;
            TempString := 'Heimaufnahme am: ';
          End;
       End;

       TempString := TempString + DateToStr(HeimstatuswechselDatum);
       Form1.MemoErgebnis.Lines.Append('');
       Form1.MemoErgebnis.Lines.Append(TempString);
       Form1.MemoErgebnis.Lines.Append('');

       {NachStatuswechsel}
                   BerechneStundenInfo(BeginnDerBetreuung,
                          Altfall,
                          ZUEBanBetreuer,
                          IncDay(HeimstatuswechselDatum, 1),
                          EndeDerAbrechnung,
                          BetreuungsTyp,
                          HochschulAusbildung,
                          StundenInfo
                          );

       ErgebnisAusgabe (StundenInfo);

      {Ausgabe der 2. Zwischensumme Stunden und der Zwischensumme Betrag}
      Form1.MemoErgebnis.Lines.Append('');

      Form1.MemoErgebnis.Lines.Append('2. Zwischensumme Stunden = ' + FloatToStrF(StundenInfo.SummeStunden , ffFixed, 10, 1) + ' Std.');
      Form1.MemoErgebnis.Lines.Append('');
      Form1.MemoErgebnis.Lines.Append('2. Zwischensumme2 Betrag = ' + FloatToStrF(StundenInfo.SummeStunden * StundenInfo.StundenSatz, ffFixed, 10, 2) + ' €');

      {Ausgabe der Gesamtsumme Stunden und der Gesamtsumme Betrag}
      Form1.MemoErgebnis.Lines.Append('');
      Form1.MemoErgebnis.Lines.Append('');

      Form1.MemoErgebnis.Lines.Append('Gesamtsumme Stunden = ' + FloatToStrF(ZwischenSummeStunden1 + StundenInfo.SummeStunden , ffFixed, 10, 1) + ' Std.');
      Form1.MemoErgebnis.Lines.Append('');
      Form1.MemoErgebnis.Lines.Append('Gesamtsumme Betrag = ' + FloatToStrF((ZwischenSummeStunden1 + StundenInfo.SummeStunden) * StundenInfo.StundenSatz, ffFixed, 10, 2) + ' €');

    End

  End;
end;

procedure TForm1.OnForm1Create(Sender: TObject);
begin;
    {StundenSätze nach VBVG §5, Stand Juli 2005}

    {Stundensatztabelle initialisieren}
    StundenTabelle[VermoegendHeim, Monat1bis3] := 5.5;
    StundenTabelle[VermoegendNichtHeim, Monat1bis3] := 8.5;
    StundenTabelle[MittellosHeim, Monat1bis3] := 4.5;
    StundenTabelle[MittellosNichtHeim, Monat1bis3] := 7;

    StundenTabelle[VermoegendHeim, Monat4bis6] := 4.5;
    StundenTabelle[VermoegendNichtHeim, Monat4bis6] := 7;
    StundenTabelle[MittellosHeim, Monat4bis6] := 3.5;
    StundenTabelle[MittellosNichtHeim, Monat4bis6] := 5.5;

    StundenTabelle[VermoegendHeim, Monat7bis12] := 4;
    StundenTabelle[VermoegendNichtHeim, Monat7bis12] := 6;
    StundenTabelle[MittellosHeim, Monat7bis12] := 3;
    StundenTabelle[MittellosNichtHeim, Monat7bis12] := 5;

    StundenTabelle[VermoegendHeim, Monat13bisUnendlich] := 2.5;
    StundenTabelle[VermoegendNichtHeim, Monat13bisUnendlich] := 4.5;
    StundenTabelle[MittellosHeim, Monat13bisUnendlich] := 2;
    StundenTabelle[MittellosNichtHeim, Monat13bisUnendlich] := 3.5;

    {Stundensatzarray initialisieren}
    StundenSatzArray[Ungelernt] := 0;
    StundenSatzArray[Lehre] := 0;
    StundenSatzArray[HochschulAusbildung] := 50.50;

end;

Function DateDiffMonth(Const Date1 : TDate; Const Date2 : TDate) : LongInt;
Begin
  DateDiffMonth := (12*YearOf(Date2)+MonthOfTheYear(Date2))-(12*YearOf(Date1)+MonthOfTheYear(Date1));
End;

Function GetMonatsIndex(Const MonatsNr : Integer) : BetreuungsZeitType;
    {Gibt den Index in der StundenTabelle für eine MonatsNr zurück}
  Var
    Index : BetreuungsZeitType;

  Begin
    If (MonatsNr >= 1) And (MonatsNr <= 3) Then
            Index := Monat1bis3
        Else If (MonatsNr >= 4) And (MonatsNr <= 6) Then
            Index := Monat4bis6
        Else If (MonatsNr >= 7) And (MonatsNr <= 12) Then
            Index := Monat7bis12
        Else If (MonatsNr >= 13) Then
            Index := Monat13bisUnendlich
        Else
           {Fehler}
          Begin
            ShowMessage ('Fehler bei der Berechnung der Betreuungszeit aufgetreten');
            Index := IllegalValueBZT;
          End;

        GetMonatsIndex := Index;
End;

procedure BerechneStundenInfo(Const BeginnDerBetreuung : TDate;
                              Const Altfall : Boolean;
                              Const ZUEBanBetreuer : TDate;
                              Const BeginnDerAbrechnung : TDate;
                              Const EndeDerAbrechnung : TDate;
                              Const BetreuungsTyp : BetreuungstypType;
                              Const Betreuer : BetreuerType;
                                Var StundenInfo : StundenInfoType);

Var
    BeginnDerBetreuungRechnerisch, ZuEBanBetreuerRechnerisch : TDate;
    DatumsZaehler: TDate; {Datum welches Monatsweise hochgezählt wird}
    StundenImErstenVollenMonat : Double; {Anzahl der Stunden im Ersten vollen Monat}
    MonatsZaehler : Integer; {Monatszähler seit Beginn der Abrechnung}
    VolleMonate : Integer; {Anzahle der Vollen Monate der Betreung}
    AnfangsMonat : Integer; {Monat in dem sich die Betreuung zu Beginn der Abrechnung befindent}
    MonatsIndex : BetreuungsZeitType; {Index des Monats in der StundenTabelle}
    MonatzurTagesberechnungAnfang : TDate;
    MonatZurTagesBerechnungEnde : TDate;
    SynchronDatum : TDate; {Datum des ersten Tages nach Beginn der Abrechnung, der den gleichen Tag, wie der Beginn der Betreuung hat}
    TempDatum : TDate;
    TempYear, TempMonth, TempDay : LongInt;
    i : Integer;

begin
    {Eingabeparameter im Ergebnis Record speichern}
    StundenInfo.BeginnDerBetreuung := BeginnDerBetreuung;
    StundenInfo.Altfall := Altfall;
    StundenInfo.ZUEBanBetreuer := ZUEBanBetreuer;

    StundenInfo.BeginnDerAbrechnung := BeginnDerAbrechnung;
    StundenInfo.EndeDerAbrechnung := EndeDerAbrechnung;
    StundenInfo.BetreuungsTyp := BetreuungsTyp;

    StundenInfo.StundenSatz := StundenSatzArray[HochschulAusbildung];

    {Berechne Stunden}

    StundenInfo.SummeStunden := 0;

    VolleMonate := 0;
    StundenInfo.AnzahlVolleMonateVorSync := 0;

    If StundenInfo.Altfall and (CompareDate(BeginnDerBetreuung, StrToDate('30.06.2004')) <= 0) then
      Begin
      {Ein Altfall wird so berechnet, als ob der ZUEBAnBetreuer und}
      {der Betreuungsbeginn der 30.06.2004 wäre}
      BeginnDerBetreuungRechnerisch := StrToDate('30.06.2004');
      ZUEBAnBetreuerRechnerisch := BeginnDerBetreuungRechnerisch;
      End
    Else
      Begin
        BeginnDerBetreuungRechnerisch := BeginnDerBetreuung;
        ZUEBAnBetreuerRechnerisch := ZUEBanBetreuer;
      End;

    If (CompareDate (BeginnDerBetreuungRechnerisch, ZuEBAnBetreuerRechnerisch) <> 0) Then
    Begin
      {Zählen der vollen Monate bis zur Ersten Änderung der Stunden pro Monat}
      StundenInfo.AnfangsDatumImVollenMonatVorSync[0] := BeginnDerAbrechnung;
      DatumsZaehler := StundenInfo.AnfangsDatumImVollenMonatVorSync[0];

      MonatsZaehler := DateDiffMonth(BeginnDerBetreuungRechnerisch, DatumsZaehler);
      If DayOfTheMonth(DatumsZaehler) > DayOfTheMonth(BeginnDerBetreuungRechnerisch) Then
          MonatsZaehler := MonatsZaehler + 1;

      MonatsIndex := GetMonatsIndex(MonatsZaehler);

      If DayOfTheMonth(StundenInfo.BeginnDerAbrechnung)
          <> DayOfTheMonth(IncDay(BeginnDerBetreuungRechnerisch, 1)) Then
      {nur wenn der Abrechnungsbgeinn nicht einen Tag (+ x  ganze Monate) nach dem Betreuungsbeginn liegt}
      Begin
        StundenInfo.ErsterVollerMonatVorSync := Monatszaehler;

        StundenImErstenVollenMonat := StundenTabelle[BetreuungsTyp, MonatsIndex];

        {Zähle volle Monate bis zur ersten Änderung der Stunden pro Monat}
        While (CompareDate(EndeDerAbrechnung, IncDay(IncMonth(DatumsZaehler,1), -1)) >= 0)
          and (StundenImErstenVollenMonat = StundenTabelle[BetreuungsTyp, MonatsIndex]) Do
          Begin
            {Berechne Stunden für volle Monate}

            StundenInfo.StundenImVollenMonatVorSync[VolleMonate] := StundenTabelle[BetreuungsTyp, MonatsIndex];

            StundenInfo.VollerMonatVorSync[VolleMonate].Beginn := DateDiffMonth(BeginnDerBetreuungRechnerisch, DatumsZaehler);
              If DayOfTheMonth(DatumsZaehler) > DayOfTheMonth(BeginnDerBetreuungRechnerisch) Then
                StundenInfo.VollerMonatVorSync[VolleMonate].Beginn := StundenInfo.VollerMonatVorSync[VolleMonate].Beginn + 1;

            StundenInfo.AnfangsDatumImVollenMonatVorSync[VolleMonate] := DatumsZaehler;

            {DatumsZaehler um einen Monat erhoehen}
            DatumsZaehler := IncMonth(StundenInfo.AnfangsDatumImVollenMonatVorSync[0], VolleMonate + 1);
            StundenInfo.EndDatumImVollenMonatVorSync[VolleMonate] := IncDay(DatumsZaehler, -1);

            StundenInfo.VollerMonatVorSync[VolleMonate].Ende := DateDiffMonth(BeginnDerBetreuungRechnerisch, StundenInfo.EndDatumImVollenMonatVorSync[VolleMonate]);
            If DayOfTheMonth(StundenInfo.EndDatumImVollenMonatVorSync[VolleMonate]) > DayOfTheMonth(BeginnDerBetreuungRechnerisch) Then
              StundenInfo.VollerMonatVorSync[VolleMonate].Ende := StundenInfo.VollerMonatVorSync[VolleMonate].Ende + 1;

            VolleMonate := VolleMonate + 1;

            {Berechne MonatsIndex vom letzten Tag des Abrechnungsmonats}
            MonatsZaehler := DateDiffMonth(BeginnDerBetreuungRechnerisch, IncDay(IncMonth(DatumsZaehler, 1), -1));
            If DayOfTheMonth(IncDay(IncMonth(DatumsZaehler,1), -1)) > DayOfTheMonth(BeginnDerBetreuungRechnerisch) Then
              MonatsZaehler := MonatsZaehler + 1;
            MonatsIndex := GetMonatsIndex(MonatsZaehler);
          End;

        {SummeStunden der vollen Monate vor der ersten Änderung der Stunden pro Monat addieren}
        For i := 0 to VolleMonate - 1 Do
          StundenInfo.SummeStunden := StundenInfo.SummeStunden + StundenInfo.StundenImVollenMonatVorSync[i];

        StundenInfo.AnzahlVolleMonateVorSync := VolleMonate;

        StundenInfo.BeginnDesAnfangsMonats := IncMonth(StundenInfo.AnfangsDatumImVollenMonatVorSync[0], VolleMonate);
      End
    End
    Else
    Begin
      StundenInfo.AnzahlVolleMonateVorSync := 0;
      StundenInfo.BeginnDesAnfangsMonats := BeginnDerAbrechnung;
    End;

    {Berechne Tage im ersten Teilmonat nach dem Beginn der Betreuung oder der ersten Änderung des Stundensatzes}
    DatumsZaehler := IncDay(StundenInfo.BeginnDesAnfangsMonats, -1);
    AnfangsMonat := DateDiffMonth(BeginnDerBetreuungRechnerisch, StundenInfo.BeginnDesAnfangsMonats);

    If DayOfTheMonth(StundenInfo.BeginnDesAnfangsMonats) > DayOfTheMonth(BeginnDerBetreuungRechnerisch) Then
        AnfangsMonat := AnfangsMonat + 1;

    StundenInfo.AnfangsMonat := AnfangsMonat;

    TempDatum := 0;
    TempYear := YearOf(DatumsZaehler);
    TempMonth := MonthOfTheYear(DatumsZaehler);
    TempDay := DayOfTheMonth(BeginnDerBetreuungRechnerisch);

    SynchronDatum := DateOf(RecodeDate(TempDatum,
                               TempYear,
                               TempMonth,
                               TempDay));
    If CompareDate(SynchronDatum, DatumsZaehler) < 0 Then
        SynchronDatum := IncMonth(SynchronDatum, 1);

    If  CompareDate(SynchronDatum, DatumsZaehler) = 0 Then
      {Wenn Beginn der Abrechnung Rechnreisch = Synchrondatum}
      Begin
        SynchronDatum := DatumsZaehler;
        StundenInfo.BetreuungsTageAnfangsTeilMonat := 0;
        StundenInfo.ErbrachteStundenAnfangsMonatUngerundet := 0;
        StundenInfo.ErbrachteStundenAnfangsMonat := 0;
      End
    Else if CompareDate(EndeDerAbrechnung, SynchronDatum) < 0 then
      Begin
        {Wenn das Synchrondatum nicht im Abrechnugszeitraum liegt}
        {Synchrondatum 0 setzen}
        SynchronDatum := 0;
        StundenInfo.BetreuungsTageAnfangsTeilMonat := 0;
        StundenInfo.ErbrachteStundenAnfangsMonatUngerundet := 0;
        StundenInfo.ErbrachteStundenAnfangsMonat := 0;
      End
    Else
      Begin
        {Berechne Monat, der für die Berechnung der Anzahl der Tage im Bruchteil relevant ist}
         If DayOfTheMonth(IncDay(DatumsZaehler,1)) > DayOfTheMonth(BeginnDerBetreuungRechnerisch) Then
           MonatzurTagesberechnungAnfang := IncDay(DatumsZaehler,1)
         Else
           MonatzurTagesberechnungAnfang := IncMonth(IncDay(DatumsZaehler,1), -1);

         StundenInfo.BetreuungsTageAnfangsTeilMonat := DaysBetween(DatumsZaehler, SynchronDatum);
         StundenInfo.MonatsLaengeAnfang := DaysInMonth(MonatzurTagesberechnungAnfang);
         MonatsIndex := GetMonatsIndex(AnfangsMonat);
         StundenInfo.StundenImAnfangsMonat := StundenTabelle[BetreuungsTyp, MonatsIndex];
         StundenInfo.ErbrachteStundenAnfangsMonatUngerundet := (StundenInfo.BetreuungsTageAnfangsTeilMonat / StundenInfo.MonatsLaengeAnfang) * StundenInfo.StundenImAnfangsMonat;
         StundenInfo.ErbrachteStundenAnfangsMonat := RoundTo(StundenInfo.ErbrachteStundenAnfangsMonatUngerundet + 0.05, -1);
         StundenInfo.SummeStunden := StundenInfo.SummeStunden + StundenInfo.ErbrachteStundenAnfangsMonat;
       End;

    StundenInfo.SynchronDatum := SynchronDatum;

    If StundenInfo.BetreuungsTageAnfangsTeilMonat = 0 then
      StundenInfo.MonatsLaengeAnfang := 0;

    {Zählen der vollen Monate}
    VolleMonate := 0;

    If Synchrondatum <> 0 then
    Begin
      StundenInfo.AnfangsDatumImVollenMonat[0] := IncDay(SynchronDatum, 1);
      DatumsZaehler := IncMonth(SynchronDatum, 1);
      MonatsZaehler := DateDiffMonth(BeginnDerBetreuungRechnerisch, SynchronDatum) + 1;
      StundenInfo.ErsterSynchronMonat := Monatszaehler;

      {Zähle volle Monate}
      While CompareDate(EndeDerAbrechnung, DatumsZaehler) >= 0 Do
        Begin
          {Berechne Stunden für volle Monate}
          MonatsIndex := GetMonatsIndex(MonatsZaehler);
          StundenInfo.StundenImVollenMonat[VolleMonate] := StundenTabelle[BetreuungsTyp, MonatsIndex];

          StundenInfo.VollerMonat[VolleMonate] := MonatsZaehler;
          StundenInfo.EndDatumImVollenMonat[VolleMonate] := DatumsZaehler;
          VolleMonate := VolleMonate + 1;

          StundenInfo.AnfangsDatumImVollenMonat[VolleMonate] := IncDay(DatumsZaehler, 1);

          MonatsZaehler := MonatsZaehler + 1;
          DatumsZaehler := IncMonth(SynchronDatum, VolleMonate + 1);

        End;

      {SummeStunden der vollen Monate addieren}
      For i := 0 to VolleMonate - 1 Do
        StundenInfo.SummeStunden := StundenInfo.SummeStunden + StundenInfo.StundenImVollenMonat[i];

    End
    Else
      {Wenn das Synchrondatum = 0 gesetzt wurde weil es ausserhalb des Betreuungszeitraums lag}
      Begin
        MonatsZaehler := DateDiffMonth(BeginnDerBetreuungRechnerisch, IncDay(DatumsZaehler,1));
        If DayOfTheMonth(IncDay(DatumsZaehler,1)) > DayOfTheMonth(BeginnDerBetreuungRechnerisch) Then
          MonatsZaehler := MonatsZaehler + 1;
      End;

    StundenInfo.AnzahlVolleMonate := VolleMonate;

    {Berechne Tage im letzten Teilmonat}
    StundenInfo.EndMonat := MonatsZaehler;

    {Setze Datumszaehler auf das Datum ab dem die Tage im lezten Abrechnungsmonat noch nicht berücksichtigt wurden}
    If Synchrondatum <> 0 then
      Begin
        DatumsZaehler := IncMonth(SynchronDatum, VolleMonate);
      End;

    StundenInfo.BeginnDesLetztenMonats := IncDay(DatumsZaehler, 1);

    {Berechne Stunden für den letzten Teilmonat}
    StundenInfo.BetreuungsTageEndeTeilMonat := DaysBetween(DatumsZaehler, EndeDerAbrechnung);

    {Berechne Monat, der für die Berechnung der Anzahl der Tage im Bruchteil relevant ist}
    If DayOfTheMonth(EndeDerAbrechnung) > DayOfTheMonth(BeginnDerBetreuungRechnerisch) Then
        MonatZurTagesBerechnungEnde := EndeDerAbrechnung
    Else
        MonatZurTagesBerechnungEnde := IncMonth(EndeDerAbrechnung, -1);

    StundenInfo.MonatsLaengeEnde := DaysInMonth(MonatZurTagesBerechnungEnde);
    MonatsIndex := GetMonatsIndex(MonatsZaehler);
    StundenInfo.StundenImEndMonat := StundenTabelle[BetreuungsTyp, MonatsIndex];
    StundenInfo.ErbrachteStundenEndMonatUngerundet := (StundenInfo.BetreuungsTageEndeTeilMonat / StundenInfo.MonatsLaengeEnde) * StundenInfo.StundenImEndMonat;
    StundenInfo.ErbrachteStundenEndMonat := RoundTo(StundenInfo.ErbrachteStundenEndMonatUngerundet + 0.05, -1);

    StundenInfo.SummeStunden := StundenInfo.SummeStunden + StundenInfo.ErbrachteStundenEndMonat;
end;



Procedure EingabeDatenAusgabe(StundenInfo : StundenInfoType);
{Ausgabe der Eingabedaten}
Var
  TempString1, TempString2 : String;

Begin
  {Ausgabe der Eingabedaten}
  Form1.MemoErgebnis.Lines.Clear(); {Inhalt des Memo Felds löschen}

  Form1.MemoErgebnis.Lines.Append('Betreuervergütungsberechnung:');

  Form1.MemoErgebnis.Lines.Append('');

  TempString1 := 'Beginn der Betreuung (ZU/EB): ';
  DateTimeToString(TempString2, 'dd.mm.yyyy', StundenInfo.BeginnDerBetreuung);
  Form1.MemoErgebnis.Lines.Append(TempString1 + TempString2);

  If CompareDate(StundenInfo.BeginnDerBetreuung, StrToDate('30.06.2004')) <= 0 then
  Begin
    If StundenInfo.Altfall then
      Form1.MemoErgebnis.Lines.Append('als Altfall berechnet (individueller Betreuungsbeginn unberücksichtigt)')
    Else
      Form1.MemoErgebnis.Lines.Append('nicht als Altfall berechnet (individueller Betreuungsbeginn berücksichtigt)')
  End;

  TempString1 := 'ZU/EB an den Betreuer       : ';
  DateTimeToString(TempString2, 'dd.mm.yyyy', StundenInfo.ZUEBanBetreuer);
  Form1.MemoErgebnis.Lines.Append(TempString1 + TempString2);

  Case StundenInfo.BetreuungsTyp of
    VermoegendHeim : TempString1 := 'Heimbewohner, vermögend';
    VermoegendnichtHeim : TempString1 := 'Nicht im Heim, vermögend';
    MittellosHeim : TempString1 := 'Heimbewohner, mittellos';
    MittellosNichtHeim : TempString1 := 'Nicht im Heim, mittellos';
  Else
    TempString1 := 'Fehler beim BetreuungsTyp!'
  End;
  Form1.MemoErgebnis.Lines.Append('Betreuungstyp: ' + TempString1);

  Form1.MemoErgebnis.Lines.Append('');

  DateTimeToString(TempString1, 'dd.mm.yyyy', StundenInfo.BeginnDerAbrechnung);
  Form1.MemoErgebnis.Lines.Append('Abrechnungsbeginn:  ' + TempString1);
    DateTimeToString(TempString1, 'dd.mm.yyyy', StundenInfo.EndeDerAbrechnung);
  Form1.MemoErgebnis.Lines.Append('Abrechnungsende:    ' + TempString1);

  Form1.MemoErgebnis.Lines.Append('');
End;



Procedure ErgebnisAusgabe(StundenInfo : StundenInfoType);
{Ausgabe der Ergebnisse}
Var
  TempString1, TempString2 : String;
  i : Integer;

Begin

  {Ausgabe der vollen Monaten vor dem Synchrondatum}
  For i := 0 to StundenInfo.AnzahlVolleMonateVorSync - 1 do
  Begin
    DateTimeToString(TempString1, 'dd.mm.yyyy', StundenInfo.AnfangsDatumImVollenMonatVorSync[i]);
    DateTimeToString(TempString2, 'dd.mm.yyyy', StundenInfo.EndDatumImVollenMonatVorSync[i]);
    Form1.MemoErgebnis.Lines.Append(TempString1 + ' bis ' + TempString2 + ' = ' +
                                    IntToStr(StundenInfo.VollerMonatVorSync[i].Beginn) + '. und ' +
                                    IntToStr(StundenInfo.VollerMonatVorSync[i].Ende) +
                                    '. Monat der Betreuung ' + ' -> ' +
                                    FloatToStrF(StundenInfo.StundenImVollenMonatVorSync[i], ffFixed, 10, 1) +
                                    ' Std./Monat x ' +
                                    FloatToStrF(StundenInfo.StundenSatz, ffFixed, 10, 2) + ' €' +
                                    ' = ' +
                                    FloatToStrF(StundenInfo.StundenImVollenMonatVorSync[i] * StundenInfo.StundenSatz, ffFixed, 10, 2) + ' €'
                                    );
  End;

  {Ausgabe des ersten Teilmonats bis zum Synchrondatum}
  If StundenInfo.BetreuungsTageAnfangsTeilMonat > 0 then
  Begin

    DateTimeToString(TempString1, 'dd.mm.yyyy', StundenInfo.BeginnDesAnfangsMonats);
    DateTimeToString(TempString2, 'dd.mm.yyyy', StundenInfo.SynchronDatum);
    Form1.MemoErgebnis.Lines.Append(TempString1 + ' bis ' + TempString2 + ' = ' +
                                    IntToStr(StundenInfo.AnfangsMonat) +
                                    '. Monat der Betreuung ' + ' -> ' +
                                    FloatToStrF(StundenInfo.StundenImAnfangsMonat, ffFixed, 10, 1) +
                                    ' Std./Monat');
    Form1.MemoErgebnis.Lines.Append(IntToStr(StundenInfo.BetreuungsTageAnfangsTeilMonat) +
                                    '/' + IntToStr(StundenInfo.MonatsLaengeAnfang) +
                                    ' x ' + FloatToStrF(StundenInfo.StundenImAnfangsMonat, ffFixed, 10, 2) +
                                    ' Std. = ' + FloatToStrF(StundenInfo.ErbrachteStundenAnfangsMonatUngerundet, ffFixed, 10, 3) +
                                    ' gerundet gem. § 5 Abs.4 VBVG = ' +
                                    FloatToStrF(StundenInfo.ErbrachteStundenAnfangsMonat, ffFixed, 10, 1) +
                                    ' x ' + FloatToStrF(StundenInfo.StundenSatz, ffFixed, 10, 2) + ' €' +
                                    ' = ' + FloatToStrF(StundenInfo.ErbrachteStundenAnfangsMonat * StundenInfo.StundenSatz, ffFixed, 10, 2) + ' €'
                                    );
  End;

  Form1.MemoErgebnis.Lines.Append('');

  {Ausgabe der vollen Monaten bzw. Quartale}
  i := 0;
  While i < StundenInfo.AnzahlVolleMonate Do
  Begin
    If (i mod 3 = 0) and (StundenInfo.AnzahlVolleMonate >= (i+3)) then
    Begin
      {Ausgabe Quartalsweise}
      DateTimeToString(TempString1, 'dd.mm.yyyy', StundenInfo.AnfangsDatumImVollenMonat[i]);
      DateTimeToString(TempString2, 'dd.mm.yyyy', StundenInfo.EndDatumImVollenMonat[i+2]);
      Form1.MemoErgebnis.Lines.Append(TempString1 + ' bis ' + TempString2 + ' = ' +
                                      IntToStr((StundenInfo.VollerMonat[i] div 3) + 1) +
                                      '. Quartal der Betreuung ' + ' -> ' +
                                      FloatToStrF(StundenInfo.StundenImVollenMonat[i]*3, ffFixed, 10, 1) +
                                      ' Std./Quartal x ' +
                                      FloatToStrF(StundenInfo.StundenSatz, ffFixed, 10, 2) + ' €' +
                                      ' = ' +
                                      FloatToStrF(StundenInfo.StundenImVollenMonat[i] * 3 * StundenInfo.StundenSatz, ffFixed, 10, 2) + ' €'
                                      );
      i := i + 3; {Zaehler um 3 Monate erhoehen}
    End
    Else
    Begin
      {Ausgabe Monatsweise}
      DateTimeToString(TempString1, 'dd.mm.yyyy', StundenInfo.AnfangsDatumImVollenMonat[i]);
      DateTimeToString(TempString2, 'dd.mm.yyyy', StundenInfo.EndDatumImVollenMonat[i]);
      Form1.MemoErgebnis.Lines.Append(TempString1 + ' bis ' + TempString2 + ' = ' +
                                      IntToStr(StundenInfo.VollerMonat[i]) +
                                      '. Monat der Betreuung ' + ' -> ' +
                                      FloatToStrF(StundenInfo.StundenImVollenMonat[i], ffFixed, 10, 1) +
                                      ' Std./Monat x ' +
                                      FloatToStrF(StundenInfo.StundenSatz, ffFixed, 10, 2) + ' €' +
                                      ' = ' +
                                      FloatToStrF(StundenInfo.StundenImVollenMonat[i] * StundenInfo.StundenSatz, ffFixed, 10, 2) + ' €'
                                      );
      i := i + 1; {Zaehler um einen Monat erhoehen}
    End;
  End;

  {Ausgabe des letzten Monats}
  If StundenInfo.BetreuungsTageEndeTeilMonat > 0 then
  Begin
    Form1.MemoErgebnis.Lines.Append('');
    DateTimeToString(TempString1, 'dd.mm.yyyy', StundenInfo.BeginnDesLetztenMonats);
    DateTimeToString(TempString2, 'dd.mm.yyyy', StundenInfo.EndeDerAbrechnung);
    Form1.MemoErgebnis.Lines.Append(TempString1 + ' bis ' + TempString2 + ' = ' +
                                    IntToStr(StundenInfo.EndMonat) +
                                    '. Monat der Betreuung ' + ' -> ' +
                                    FloatToStrF(StundenInfo.StundenImEndMonat, ffFixed, 10, 1) +
                                    ' Std./Monat');
    Form1.MemoErgebnis.Lines.Append(IntToStr(StundenInfo.BetreuungsTageEndeTeilMonat) +
                                    '/' + IntToStr(StundenInfo.MonatsLaengeEnde) +
                                    ' x ' + FloatToStrF(StundenInfo.StundenImEndMonat, ffFixed, 10, 2) +
                                    ' Std. = ' + FloatToStrF(StundenInfo.ErbrachteStundenEndMonatUngerundet, ffFixed, 10, 3) +
                                    ' gerundet gem. § 5 Abs.4 VBVG = ' +
                                    FloatToStrF(StundenInfo.ErbrachteStundenEndMonat, ffFixed, 10, 1) +
                                    ' x ' + FloatToStrF(StundenInfo.StundenSatz, ffFixed, 10, 2) + ' €' +
                                    ' = ' + FloatToStrF(StundenInfo.ErbrachteStundenEndMonat * StundenInfo.StundenSatz, ffFixed, 10, 2)  + ' €');
  End;

End;

procedure TForm1.OnDatePickerBeginnDerBetreuungExit(Sender: TObject);

Var
  BeginnDerBetreuung : TDate;

begin
  BeginnDerBetreuung := DatePickerBeginnDerBetreuung.DateTime;
  Form1.DatePickerZUEBanBetreuer.DateTime := BeginnDerBetreuung;

  {Fälle mit Betreuungsbeginn vor 30.06.2004 können als Altfälle behandelt werden}
  {d. h. sie werden Quartalsweise ab 01.07.2005 abgerechnet}
  If CompareDate(BeginnDerBetreuung, StrToDate('30.06.2004')) >= 0 then
  {Keine Behandlung als Altfall möglich}
  Begin
    CheckBoxAltfall.State := cbUnchecked;
    CheckBoxAltfall.Enabled := False;
    DatePickerZUEBanBetreuer.SetFocus();
  End Else
  Begin
    {Standardmässig werden Fälle mit Betreuungsbeginn vor dem 30.06.04}
    {als Altfälle behandelt}
    CheckBoxAltfall.State := cbChecked;
    CheckBoxAltfall.Enabled := True;
    CheckBoxAltfall.SetFocus();
  End;
end;

procedure TForm1.OnComboBoxZUEBanBetreuerExit(Sender: TObject);
Var
  StartDatum : TDate;
  TempDatum1 : TDate;
  i : Integer;
  TempString1 : String;

begin
    Form1.ComboBoxAbrechnungsBeginn.Clear();

    If CheckBoxAltfall.State = cbUnchecked then
    Begin

      TempDatum1 := IncDay(Form1.DatePickerZUEBanBetreuer.Date, 1);

      if (CompareDate(TempDatum1, StrToDate('01.07.2005')) < 0) then
      Begin
        {1.7.2005 zusätzlich eintragen}
        ComboBoxAbrechnungsBeginn.Items.Add('01.07.2005');
      End;

      i := 0;
      Repeat
        {StartDatum solange monatsweise hochzählen, bis es nach dem 30.06.2005 liegt}
        StartDatum := IncMonth(TempDatum1, i);
        i := i + 1;
      Until CompareDate(StartDatum, StrToDate('01.07.2005')) > 0;
    End
    Else
      StartDatum := StrToDate('01.07.2005');

    For i := 0 to AnzEintraege - 1 Do
    Begin
      TempDatum1 := IncMonth(StartDatum, (i*Quartalslaenge)); {Abrechngbeginn Quartalsweise: 1 Quartal = 3 Monate}
      DateTimeToString(TempString1, 'dd.mm.yyyy', TempDatum1);
      ComboBoxAbrechnungsBeginn.Items.Add(TempString1);
    End;

    {Ersten Eintrag automatisch auswählen}
    Form1.ComboBoxAbrechnungsBeginn.ItemIndex := 0;
end;

procedure TForm1.OnComboBoxAbrechnungsBeginnExit(Sender: TObject);
Var
  BasisDatum : TDate;
  TempDatum1 : TDate;
  i : Integer;
  TempString1 : String;

begin
    Form1.ComboBoxAbrechnungsEnde.Clear();

    If CheckBoxAltfall.State = cbChecked then
      BasisDatum := StrToDate('01.10.2005')
    Else
    If CompareDate (StrToDate(ComboBoxAbrechnungsBeginn.Text), StrToDate('01.07.2005')) > 0 then
      BasisDatum := IncMonth(StrToDate(Form1.ComboBoxAbrechnungsBeginn.Text), QuartalsLaenge) {+3 Monate}
    Else
      BasisDatum := StrToDate(Form1.ComboBoxAbrechnungsBeginn.Items.Strings[1]); {Zweiter Eintrag in der ComboBoxListe +3 Monate}

    For i := 0 to AnzEintraege - 1 Do
    Begin
      TempDatum1 := IncDay(IncMonth(BasisDatum, (i*Quartalslaenge)), -1); {Abrechnungsende Quartalsweise: 1 Quartal = 3 Monate, -1 Tag, da immer der letzte des Monats das Ende ist, wenn der Anfang der Erste Tag eines Monats ist}
      DateTimeToString(TempString1, 'dd.mm.yyyy', TempDatum1);
      ComboBoxAbrechnungsEnde.Items.Add(TempString1);
    End;

    {Esten Eintrag automatisch auswählen}
    Form1.ComboBoxAbrechnungsEnde.ItemIndex := 0;
end;

procedure TForm1.OnClickCheckboxHeimstatuswechsel(Sender: TObject);
Var
  Tempstr : String;

begin
    If CheckboxHeimstatuswechsel.State = cbChecked then
    Begin
      DatePickerHeimstatuswechsel.Enabled := True;
      TempStr := Form1.ComboBoxAbrechnungsBeginn.Text;
      If Tempstr <> '' then
      Begin
        DatePickerHeimstatuswechsel.Date :=  IncDay(StrToDate(TempStr), 1);
      End;
    End
    Else
    Begin
      DatePickerHeimstatuswechsel.Enabled := False;
      DatePickerHeimstatuswechsel.Date :=  StrToDate('01.01.1999');
    End
end;

procedure TForm1.ButtonDruckenClick(Sender: TObject);
var
   printDialog    : TPrintDialog;
   page, endpage : Integer;
   ObererRand, UntererRand, LinkerRand, ZeilenAbstand, Xpos, Ypos, i   : Integer;
   TempString : String;

begin

  // Create a printer selection dialog
  printDialog := TPrintDialog.Create(Form1);

  // If the user has selected a printer (or default), then print!
  if printDialog.Execute then
  begin
    Printer.Orientation := poPortrait;
    // Set the printjob title - as it it appears in the print job manager
    Printer.Title := 'Betreuungskostenrechner';
    Printer.Copies := printDialog.Copies;
    // Start printing
    Printer.BeginDoc;

    page := 1;
    endpage := 1;
    LinkerRand := 200;
    ObererRand := 200;
    UntererRand := 200;
    ZeilenAbstand := 120;

    XPos := LinkerRand;
    Ypos := ObererRand;

    // Keep printing while all OK
    while (not Printer.Aborted) and Printer.Printing
    and (page <= endPage) do
    begin
     // Set up a medium sized font
     Printer.Canvas.Font.Size   := 10;

     // Allow Windows to keep processing messages
     Application.ProcessMessages;

     // Write out the page number
     Printer.Canvas.Font.Color := clBlack;

     For i := 0 to MemoErgebnis.Lines.Count-1 Do
     Begin
       TempString := MemoErgebnis.Lines.Strings[i];
       Printer.Canvas.TextOut(Xpos, Ypos, TempString);
       YPos := YPos + ZeilenAbstand;
     End;

     // weglassen, da nicht erwünscht
     {
     Printer.Canvas.Font.Size   := 8;
     Printer.Canvas.Font.Style := [fsItalic];
     TempString := 'Berechnet mit Programm: ' + Form1.Caption;
     Printer.Canvas.TextOut(Xpos, Printer.PageHeight-UntererRand, TempString);
     }

     //    Printer.PageWidth;
     //    Printer.PageHeight

     // Increment the page number
     Inc(page);

     // Now start a new page - if not the last
     if (page <= endPage) and (not Printer.Aborted)
     then Printer.NewPage;
    end;

    // Finish printing
    Printer.EndDoc;

  end;

end;

end.

