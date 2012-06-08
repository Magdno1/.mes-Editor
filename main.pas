unit Main;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs, Menus,
  StdCtrls, ExtCtrls, ComCtrls, About;

type
  TByte = packed record
    Char: Byte;
  end;

  TPointer = packed record
    First:  Byte;
    Second: Byte;
  end;

  { TMainForm }

  TMainForm = class(TForm)
    AboutBtn: TMenuItem;
    MessageList: TComboBox;
    FileName: TLabel;
    LabelFileName: TLabel;
    MainMenu1: TMainMenu;
    FileMenu: TMenuItem;
    DbgMes: TMemo;
    MenuSave: TMenuItem;
    MenuOpen: TMenuItem;
    OpenDialog1: TOpenDialog;
    SaveDialog1: TSaveDialog;
    StatusBar1: TStatusBar;
    procedure AboutBtnClick(Sender: TObject);
    procedure MenuOpenClick(Sender: TObject);
    procedure MessageListChange(Sender: TObject);
    procedure ResetForm;
    procedure ReadPointers;
    procedure ReadMessage(Index: SmallInt);
    procedure ConvertFromHM(Message: array of Byte);
  private
    { private declarations }
  public
    { public declarations }
  end;

const
  CharMap: array[$80..$81,$00..$FF] of String = (
                    {0} {1} {2} {3} {4} {5} {6} {7} {8} {9} {A} {B} {C} {D} {E} {F}
           {80} ({0}'0','1','2','3','4','5','6','7','8','9','-','A','B','C','D','E',
                 {1}'F','G','H','I','J','K','L','M','N','O','P','Q','R','S','T','U',
                 {2}'V','W','X','Y','Z','0','0','0','0','0','0','0','0','0','0','0',
                 {3}'0','0','0','0','0','0','0','0','0','0','0','0','0','0','0','0',
                 {4}'0','0','0','0','0','0','0','0','0','0','0','0','0','0','0','0',
                 {5}'0','0','0','0','0','0','0','0','0','0','0','0','0','0','0','0',
                 {6}'0','0','0','0','0','0','0','0','0','0','0','0','0','0','0','0',
                 {7}'0','0','0','0','0','0','0','0','0','0','0','0','0','0','0','0',
                 {8}'0','0','0','0','0','0','0','0','0','0','0','0','0','0','0','0',
                 {9}'0','0','0','0','0','0','0','0','0','0','0','0','0','0','0','0',
                 {A}'0','0','0','0','0','0','0','0','0','0','0','0','0','0','0','0',
                 {B}'0','0','0','0','0','0','0','0','0','0','0','0','0','0','0','0',
                 {C}'0','0','0','0','0','0','+','×','.','○','?','!','●','♂','♀','·',
                 {D}'—','&"','/','♪','☆','★','♥','%','a','b','c','d','e','f','g','h',
                 {E}'i','j','k','l','m','n','o','p','q','r','s','t','u','v','w','x',
                 {F}'y','z','''','<','>','(',')','｢','｣','~','*',' ',' ','ä','ö','ü'),

                    {0} {1} {2} {3} {4} {5} {6} {7} {8} {9} {A} {B} {C} {D} {E} {F}
           {81} ({0}'Ä','Ö','Ü','β','"',',',':','0','0','0','0','0','0','0','0','0',
                 {1}'0','0','0','0','0','0','0','0','0','0','0','0','0','0','0','0',
                 {2}'0','0','0','0','0','0','0','0','0','0','0','0','0','0','0','0',
                 {3}'0','0','0','0','0','0','0','0','0','0','0','0','0','0','0','0',
                 {4}'0','0','0','0','0','0','0','0','0','0','0','0','0','0','0','0',
                 {5}'0','0','0','0','0','0','0','0','0','0','0','0','0','0','0','0',
                 {6}'0','0','0','0','0','0','0','0','0','0','0','0','0','0','0','0',
                 {7}'0','0','0','0','0','0','0','0','0','0','0','0','0','0','0','0',
                 {8}'0','0','0','0','0','0','0','0','0','0','0','0','0','0','0','0',
                 {9}'0','0','0','0','0','0','0','0','0','0','0','0','0','0','0','0',
                 {A}'0','0','0','0','0','0','0','0','0','0','0','0','0','0','0','0',
                 {B}'0','0','0','0','0','0','0','0','0','0','0','0','0','0','0','0',
                 {C}'0','0','0','0','0','0','0','0','0','0','0','0','0','0','0','0',
                 {D}'0','0','0','0','0','0','0','0','0','0','0','0','0','0','0','0',
                 {E}'0','0','0','0','0','0','0','0','0','0','0','0','0','0','0','0',
                 {F}'0','0','0','0','0','0','0','0','0','0','0','0','0','0','0','0')
  );

  NameMap: array [$00..$25] of String = (
                    'Pete','Tatsuya','Celia','Muffy','Nami','Murrey','Carter',
                    'Takakura','Romana','Lumina','Sebastian','Wally','Chris',
                    'Hugh','Grant','Samantha','Kate','Galen','Nina','Daryl',
                    'Gustafa','Cody','Kassey','Patrick','Tim','Ruby','Rock',
                    'Griffin','Flora','Vesta','Marlin','Hardy','Nak','Nic',
                    'Flak','Mukumuku','Van','DUMMY'
                    );

var
  MainForm: TMainForm;
  mesFile: TMemoryStream = nil;
  PointerTable: array of TPointer;

implementation

{$R *.lfm}

{ TMainForm }

procedure TMainForm.MenuOpenClick(Sender: TObject);
begin
  if OpenDialog1.execute then
    begin
      if mesFile = nil then
        mesFile := TMemoryStream.create;

      mesFile.LoadFromFile(OpenDialog1.FileName);

      ResetForm;
      ReadPointers;
      FileName.Caption := OpenDialog1.FileName;
    end;
end;

procedure TMainForm.AboutBtnClick(Sender: TObject);
begin
  with TAboutForm.Create(nil) do
    ShowModal;
end;

procedure TMainForm.MessageListChange(Sender: TObject);
begin
  ReadMessage(MessageList.ItemIndex);
end;

procedure TMainForm.ResetForm;
begin
  MessageList.Items.Clear;
  DbgMes.Text := '';
end;

procedure TMainForm.ReadPointers;
var
  I: Integer = 0;
  NumMes: SmallInt = 0;
begin
  // .mes files graciously tell us the number of DbgMes contained within
  mesFile.Position := $6;
  mesFile.ReadBuffer(NumMes,2);
  NumMes := BEToN(NumMes);
  SetLength(PointerTable,NumMes);


  // Add lines to MessageList to correspond with the DbgMes in the file
  for I := 0 to (NumMes - 2) do
    MessageList.AddItem('Message ' + IntToStr(I + 1), nil);

  MessageList.Enabled := True;
  // Now we just read the pointers and throw them into the array
  I := 0;
  while I < (NumMes) do
    begin
      mesFile.Position := $A + (4 * I);
      mesFile.ReadBuffer(PointerTable[I],SizeOf(TPointer));
      //DbgMes.Lines.Insert(I,'$' + IntToHex(PointerTable[I].First,2) + IntToHex(PointerTable[I].Second,2));
      I := I + 1;
    end;
  //DbgMes.Lines.Insert(0,'Size of PointerTable: ' + IntToStr(SizeOf(PointerTable)));
end;

procedure TMainForm.ReadMessage(Index: SmallInt);
var
  Location: String;
  mesSize: Integer = 0;
  I: Integer;
  mesStr: String = '';
  mesRead: Array of Byte;
begin
  // This is going to get confusing
  // First, work out where we're even going
  Location := '$' + IntToHex(PointerTable[Index].First,2) + IntToHex(PointerTable[Index].Second,2);
  // Then go there
  mesFile.Position := StrToInt(Location);
  //DbgMes.Lines.Insert(0,'Position: $' + IntToHex(mesFile.Position,4));
  StatusBar1.Panels[0].Text := 'Position: $' + IntToHex(mesFile.Position,4);
  // Some maths to find out how far to read.
  mesSize := StrToInt('$' + IntToHex(PointerTable[Index + 1].First,2) +
                      IntToHex(PointerTable[Index + 1].Second, 2)) -
                      StrToInt(Location) - 1;

  SetLength(mesRead,mesSize);
  //DbgMes.Lines.Insert(0,'Length of mesRead: ' + IntToStr(Length(mesRead)));

  mesFile.ReadBuffer(mesRead[0],mesSize);
  for I := 0 to mesSize do
    mesStr := mesStr + IntToHex(mesRead[I],2) + ' ';

  ConvertFromHM(mesRead);
  //DbgMes.Lines.Insert(0,MesStr);
end;

procedure TMainForm.ConvertFromHM(Message: array of byte);
var
  I: Integer = 0;
  ReadChar: Byte;
  Result: String = '';
  Append: String = '';
  Incre: Integer;
begin
  while I < Length(Message) do
    begin
      Append := '';
      Incre := 1;
      if Message[I] in [$80..$81] then
        // It's a character
        begin
          ReadChar := Message[I + 1];
          Append := CharMap[Message[I]][ReadChar];
          Incre := 2;
          //I := I + 2;
        end
      else
        // It's a special marker
        begin
          case Message[I] of
            $01: Append := sLineBreak;            // Line break
            $02: Append := ' ';                   // Space
            $03: Append := '{ENDPAGE}';           // Page end marker
            //$14: Incre := 1;
            $14: begin                            // Farm name? Seems to be various location names.
                   Append := '{LOCATION}';
                   Incre := 4;
                 end;
            $20: begin                            // Character name
                   ReadChar := Message[I + 1];
                   Append := '{' + UpperCase(NameMap[ReadChar]) + '}';
                   Incre := 2;
                 end;
            $21: begin                            // Previous input? Seems so.
                   Append := '{PREVINPUT}';
                   Incre := 2;
                 end;
            $29: begin                            // Special marker marker
                   ReadChar := Message[I + 1];
                   case ReadChar of
                     $00: Append := '{???}';      // Unknown currently, seems to have various uses
                     $01: Append := '{ITEM}';
                     $02: Append := '{SEASON}';
                   end;
                   Incre := 2;
                 end;
            $2A: begin                            // Money. 3 bytes
                   Append := '{GOLD}';
                   Incre := 3;
                 end;
            $15,$32,$E8,$2D,$05:
                 begin                            // Unknown, 2 bytes
                   Append := '{UNK_' + IntToHex(Message[I],2) + IntToHex(Message[I + 1],2) + '}';
                   Incre := 2;
                 end;
            //$30: Incre := 2;                      // No clue. At ends of lines? Commented out for now, has random uses.
            $35: Incre := 2;                      // Two bytes. Maybe sound? david.mes $D70
            $41: begin                            // Player choice?
                   ReadChar := Message[I + 1];
                   Append := '{CHOICE' + IntToStr(ReadChar) + '}' + sLineBreak;
                   Incre := 3;
                 end;
            $50: begin                            // Sound marker?, TODO: Expand
                   Append := '{SOUND?}';
                   Incre := 4;
                 end;
          end;
          StatusBar1.Panels[1].Text := Append;
        end;
      Result := Result + Append;
      Inc(I,Incre);
    end;

  DbgMes.Text := Result;
end;

end.

