unit Main;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs, Menus,
  StdCtrls, ExtCtrls, ComCtrls, About;

type
  { TMainForm }

  TMainForm = class(TForm)
    AboutBtn: TMenuItem;
    HexBox: TMemo;
    MessageList: TComboBox;
    FileName: TLabel;
    LabelFileName: TLabel;
    MainMenu1: TMainMenu;
    FileMenu: TMenuItem;
    DbgMes: TMemo;
    MenuSave: TMenuItem;
    MenuOpen: TMenuItem;
    OpenDialog: TOpenDialog;
    SaveDialog: TSaveDialog;
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
                 {2}'V','W','X','Y','Z','あ','い','う','え','お','か','き','く','け','こ','さ',
                 {3}'し','す','せ','そ','た','ち','つ','て','と','な','に','ぬ','ね','の','は','ひ',
                 {4}'ふ','へ','ほ','ま','み','む','め','も','や','ゆ','よ','ら','り','る','れ','ろ',
                 {5}'わ','を','ん','ぁ','ぃ','ぅ','ぇ','ぉ','0','0','0','0','0','0','0','0',
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

  {StrucMap: array [$00..$35] of String = (
                    'Seed Maker','Big Freezer','Refrigerator','Shelf',
                    'Crop Shipping Bin'
                    );}

var
  MainForm: TMainForm;
  mesFile: TMemoryStream = nil;
  PointerTable: array of Integer;

implementation

{$R *.lfm}

{ TMainForm }

procedure TMainForm.MenuOpenClick(Sender: TObject);
begin
  if OpenDialog.execute then
    begin
      if mesFile = nil then
        mesFile := TMemoryStream.create;

      mesFile.LoadFromFile(UTF8ToSys(OpenDialog.FileName));

      ResetForm;
      ReadPointers;
      FileName.Caption := OpenDialog.FileName;
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
  // Gamecube uses Big Endian, need to convert that to the system's native
  NumMes := BEToN(NumMes);
  SetLength(PointerTable,NumMes);


  // Add lines to MessageList to correspond with the DbgMes in the file
  for I := 0 to (NumMes - 1) do
    MessageList.AddItem('Message ' + IntToStr(I + 1), nil);

  MessageList.Enabled := True;
  // Now we just read the pointers and throw them into the array
  I := 0;
  while I < (NumMes) do
    begin
      // $8 is the location of the first pointer. Four bytes long, Big Endian
      mesFile.Position := $8 + (4 * I);
      mesFile.ReadBuffer(PointerTable[I],4);
      I := I + 1;
    end;
  DbgMes.Lines.Insert(0,'Size of PointerTable: ' + IntToStr(Length(PointerTable)));
end;

procedure TMainForm.ReadMessage(Index: SmallInt);
var
  Location: Integer = 0;
  mesSize: Integer = 0;
  I: Integer;
  mesStr: String = '';
  mesRead: Array of Byte;
begin
  // This is going to get confusing
  // First, work out where we're even going
  Location := BEToN(PointerTable[Index]);

  // Then go there
  mesFile.Position := Location;

  StatusBar1.Panels[0].Text := 'Position: ' + IntToHex(Location,8);
  // Some maths to find out how far to read.
  if Index = MessageList.Items.Count - 1 then // THIS IS BROKEN. FIX IT FUTURE HARRISON
    mesSize := mesFile.Size - Location
  else
    mesSize := BEToN(PointerTable[Index + 1]) - Location;

  // Set the size of the raw message array
  SetLength(mesRead,mesSize);

  //DbgMes.Lines.Insert(0,'mesSize: ' + IntToStr(mesSize));
  //DbgMes.Lines.Insert(1,'Size of MessageList: ' + IntToStr(MessageList.Items.Count));
  mesFile.ReadBuffer(mesRead[0],mesSize);
  for I := 0 to (mesSize - 1) do
    mesStr := mesStr + IntToHex(mesRead[I],2) + ' ';

  ConvertFromHM(mesRead);
  HexBox.Text := MesStr;
  //HexBox.Text := IntToHex(mesRead[mesSize - 1],2);
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
        end
      else
        // It's a special marker
        begin
          case Message[I] of
            $01: Append := sLineBreak;            // Line break
            $02: Append := ' ';                   // Space
            $03: Append := '{ENDPAGE}';           // Page end marker
            $10..$17:                             // Colors
                 Append := '{C' + IntToHex(Message[I],2) + '}';
            { $14: begin                            // Farm name? Seems to be various location names.
                   Append := '{LOCATION}';
                   Incre := 4;
                 end; }
            $20: begin                            // People. Pulls from people.mes
                   ReadChar := Message[I + 1];
                   if Message[I + 1] in [$00..$25] then
                     begin
                       Append := '{' + UpperCase(NameMap[ReadChar]) + '}';
                     end
                   else
                     Append := '{CHARUNK}';       // Odd case where it's not in the array
                   Incre := 2;
                 end;
            $21: begin                            // Previous input? Seems so.
                   Append := '{PREVINPUT}';
                   Incre := 2;
                 end;
            $25: begin                            // Item name from memory. Related to record player and others
                   Append := '{ITEM}';
                   Incre := 3;
                 end;
            $27: begin                            // Seems to be Ordered Items. 3 bytes.
                   Append := '{ORD' + IntToStr(Message[I + 2]) + '}';
                   Incre := 3;
                 end;
            $29: begin                            // Variable marker. 2 bytes
                   //ReadChar := Message[I + 1];    // Apparently texts can be passed variables
                   Append := '{VAR' + IntToStr(Message[I + 1]) + '}';
                   Incre := 2;
                 end;
            $2A: begin                            // Money ** MAYBE NOT. Seems to be anything numeric. 3 bytes
                   Append := '{GOLD}';
                   Incre := 3;
                 end;
            $2B: begin                            // Pulls from structure.mes. 2 bytes.
                   Append := '{STRUC' + IntToStr(Message[I + 1]) + '}';
                   Incre := 2
                 end;
            $30: begin                            // Pause
                   Append := '{PAUSE}';
                 end;
            $32,$34:                              // Sound. 3 bytes
                 begin
                   Incre := 3;
                   Append := '{S_' + IntToHex(Message[I],2) + IntToHex(Message[I + 1],2) + IntToHex(Message[I + 2],2) + '}';
                 end;
            // $35: Incre := 2;                      // Two bytes. Maybe sound? david.mes $D70
            $40: begin                            // Simple Yes/No choice
                   Append := '{CHOICE Y/N DEF' + IntToStr(Message[I + 1]) + '}';      // Second byte is default choice
                   Incre := 2;
                 end;
            $41: begin                            // Custom Player choice
                   ReadChar := Message[I + 1];    // Third byte is default choice
                   Append := '{CHOICE' + IntToStr(Message[I + 1]) + ' DEF' + IntToStr(Message[I + 2]) + '}' + sLineBreak;
                   Incre := 3;
                 end;
            $50: begin                            // Semes to change facial expressions?
                   Append := '{FACE?}';
                   Incre := 4;
                 end;
            else                                  // Unknown byte
              begin
                Append := '{' + IntToHex(Message[I],2) + '}';
              end;
          end;
          //StatusBar1.Panels[1].Text := Append;
        end;
      Result := Result + Append;
      Inc(I,Incre);
    end;

  DbgMes.Text := Result;
end;

end.

