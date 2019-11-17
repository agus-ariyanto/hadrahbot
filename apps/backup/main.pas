unit main;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, ComCtrls, ExtCtrls,
  Menus, Grids, StdCtrls, Buttons, Spin, SpinEx, Types;

type

  { TMainFrm }

  TMainFrm = class(TForm)
    Label3: TLabel;
    OpenDlg: TOpenDialog;
    PaternListAdd1: TSpeedButton;
    PaternListDelete1: TSpeedButton;
    PaternPlaylist: TListBox;
    Panel3: TPanel;
    PaternDelete1: TSpeedButton;
    PaternListAdd: TSpeedButton;
    PaternPaternListUp: TSpeedButton;
    PaternPaternListDown: TSpeedButton;
    PaternListPause: TSpeedButton;
    PaternListPlay: TSpeedButton;
    PaternListDelete: TSpeedButton;
    PaternSelect: TComboBox;
    PaternListSelect: TComboBox;
    PaternListStop: TSpeedButton;
    PortSelect: TComboBox;
    Label1: TLabel;
    Label2: TLabel;
    PageControlSelect: TPageControl;
    Panel1: TPanel;
    MainPanel: TPanel;
    Patern: TStringGrid;
    PaternList: TStringGrid;
    PaternAdd: TSpeedButton;
    PaternRename: TSpeedButton;
    PaternDelete: TSpeedButton;
    PaternStop: TSpeedButton;
    PaternPlayBtn: TSpeedButton;
    PaternPause: TSpeedButton;
    RefreshBtn: TSpeedButton;
    Bpm: TSpinEditEx;
    RefreshBtn1: TSpeedButton;
    SaveDlg: TSaveDialog;
    SpeedButton10: TSpeedButton;
    SpeedButton7: TSpeedButton;
    SpeedButton8: TSpeedButton;
    SpeedButton9: TSpeedButton;
    Splitter2: TSplitter;
    TabSheet1: TTabSheet;
    TabSheet2: TTabSheet;
    Player: TTimer;
    procedure BpmChange(Sender: TObject);
    procedure ConnectClick(Sender: TObject);
    procedure FormCloseQuery(Sender: TObject; var CanClose: boolean);
    procedure FormCreate(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure OpenFileClick(Sender: TObject);
    procedure PaternAddColumnClick(Sender: TObject);
    procedure PaternExit(Sender: TObject);
    procedure PaternDelColumnClick(Sender: TObject);
    procedure PaternListDrawCell(Sender: TObject; aCol, aRow: Integer;
      aRect: TRect; aState: TGridDrawState);
    procedure PaternListExit(Sender: TObject);
    procedure PaternPlaylistClick(Sender: TObject);
    procedure PlaylistDownClick(Sender: TObject);
    procedure SaveAsClick(Sender: TObject);
    procedure SaveClick(Sender: TObject);
    procedure PlaylistUpClick(Sender: TObject);
    procedure PaternSelectDropDown(Sender: TObject);
    procedure PlayerTimer(Sender: TObject);
    procedure PlaylistAddClick(Sender: TObject);
    procedure PlaylistDeleteClick(Sender: TObject);
    procedure RefreshBtnClick(Sender: TObject);

    { patern page }
    procedure PaternClick(Sender: TObject);
    procedure PaternDrawCell(Sender: TObject; aCol, aRow: Integer;
      aRect: TRect; aState: TGridDrawState);
    procedure PaternAddClick(Sender: TObject);
    procedure PaternAddCopyClick(Sender: TObject);
    procedure PaternDeleteClick(Sender: TObject);
    procedure PaternEditClick(Sender: TObject);
    procedure PaternChangeClick(Sender: TObject);
    procedure PaternStopClick(Sender: TObject);
    procedure PaternPauseClick(Sender: TObject);
    procedure PaternPlayClick(Sender: TObject);

    procedure PaternClear;
    procedure PaternSave;
    procedure PaternOpen;
    procedure PaternPlay;
    procedure PaternInit;

    procedure PlaylistInit;
    procedure PlaylistPlay;
    procedure PlaylistSave;
    procedure PlaylistOpen(s:String);

    procedure ProjectSave;
    procedure ProjectOpen;
    procedure ProjectNewClick(Sender: TObject);
  private

  public

  end;

var
  MainFrm: TMainFrm;

implementation

{$R *.lfm}

{ TMainFrm }
uses
  synaser, IniFiles,SectionDialog;
const
  darkgreen=$00005900;
  litegrey=$00E5E5E5;


var
  appversion:String='Hadrahbot 0.0.1';
  openfile:String;
  paternfile:TIniFile;
  playlistfile:TIniFile;
  ptntmp:String;
  plstmp:String;
  playcol:Integer=0;
  serial:TBlockSerial;
  online:Boolean=false;
  current_index:Integer=-1;
  modified:Boolean;
  chname:String='CH_1A,CH_1B,CH_2A,CH_2B,CH_3A,CH_3B,CH_4A,CH_4B';
  columncount:Integer;
procedure TMainFrm.FormCreate(Sender: TObject);
var
  x,y:Integer;
  s:String;
  sl:TStringlist;
begin

  Application.Title:=appversion;
  Caption:=appversion;
  openfile:='';
  modified:=false;
  s:=GetTempDir;
  if s[length(s)]<>PathDelim then s:=s+PathDelim;
  ptntmp:=s+'hbptn.tmp';
  plstmp:=s+'hbpls.tmp';

  sl:=TStringList.create;
  sl.SaveToFile(ptntmp);
  sl.SaveToFile(plstmp);
  paternfile:=TIniFile.Create(ptntmp);
  playlistfile:=TIniFile.Create(plstmp);
  serial:=TBlockSerial.Create;
  columncount:=4*4+1;
  PaternInit;
  PlaylistInit;
end;

procedure TMainFrm.FormShow(Sender: TObject);
begin
  Width:=1024;
  Height:=480;
end;


procedure TMainFrm.OpenFileClick(Sender: TObject);
var
  mr:TModalResult;
begin
  if modified then begin
     mr:=MessageDlg('Save','Save Proyek ?',mtConfirmation,mbYesNoCancel,0);
     if mr=mrOk then SaveClick(Sender);
     if mr=mrCancel then Exit;
  end;
  with OpenDlg do begin
     FileName:='';
     if Execute then begin
        openfile:=FileName;
        ProjectOpen;
     end;
  end;
end;


procedure TMainFrm.PaternAddColumnClick(Sender: TObject);
begin
  with Patern do begin
    ColCount:=Patern.ColCount+1;
    Cols[Patern.Colcount-1].CommaText:='0,0,0,0,0,0,0,0';
  end;
end;

procedure TMainFrm.PaternExit(Sender: TObject);
begin
  PaternSave;
end;

procedure TMainFrm.PaternDelColumnClick(Sender: TObject);
begin
  with Patern do begin
    if ColCount<5 then Exit;
    ColCount:=ColCount-1;
  end;
end;

procedure TMainFrm.PaternListDrawCell(Sender: TObject; aCol, aRow: Integer;
  aRect: TRect; aState: TGridDrawState);
var
    c:TColor;
begin
    if aCol<1 then Exit;
    c:=clWhite;
    if aCol mod 4 = 1 then c:=litegrey;
    if playcol=aCol then c:=clGray;

    with PaternList do begin
         if Cells[aCol,aRow]='1' then c:=clGreen;
         if Cells[aCol,aRow]='2' then c:=clYellow;
         if Cells[aCol,aRow]='3' then c:=clRed;
         Canvas.Brush.Color:=c;
         Canvas.FillRect(aRect);
    end;
end;

procedure TMainFrm.PaternListExit(Sender: TObject);
begin
  PaternSave;
end;

procedure TMainFrm.PaternPlaylistClick(Sender: TObject);
begin
  with PaternPlaylist do if ItemIndex>-1
  then PlaylistOpen(Items[ItemIndex]);
end;

procedure TMainFrm.PlaylistDownClick(Sender: TObject);
var
    s:String;
begin
   with PaternPlaylist do begin
       if ItemIndex>Items.Count-2 then Exit;
       s:=Items[ItemIndex+1];
       Items[ItemIndex+1]:=Items[ItemIndex];
       Items[ItemIndex]:=s;
       ItemIndex:=ItemIndex+1;
  end;
end;


procedure TMainFrm.SaveAsClick(Sender: TObject);
begin
  with SaveDlg do
      if Execute then begin
         openfile:=FileName;
         ProjectSave;
      end;

end;

procedure TMainFrm.SaveClick(Sender: TObject);
begin
  if openfile='' then
     with SaveDlg do
      if Execute then openfile:=FileName;
  ProjectSave;
end;

procedure TMainFrm.PlaylistUpClick(Sender: TObject);
var
  s:String;
begin
  with PaternPlaylist do begin
       if ItemIndex<1 then Exit;
       s:=Items[ItemIndex-1];
       Items[ItemIndex-1]:=Items[ItemIndex];
       Items[ItemIndex]:=s;
       ItemIndex:=ItemIndex-1;
  end;
end;

procedure TMainFrm.PaternSelectDropDown(Sender: TObject);
begin
  current_index:=PaternSelect.ItemIndex;
end;

procedure TMainFrm.PaternChangeClick(Sender: TObject);
var
  i:Integer;
begin
  i:=PaternSelect.ItemIndex;
  if current_index>-1 then PaternSelect.ItemIndex:=current_index;
  PaternSave;
  PaternSelect.ItemIndex:=i;
  PaternOpen;
end;

procedure TMainFrm.PaternAddCopyClick(Sender: TObject);
var
  sd:TSectionDlg;
  s:String;
begin
  sd:=TSectionDlg.Create(Self);
  with sd do begin
       s:=Open;
       Free;
  end;
  if(s<>'') then begin
     PaternSave;
     PaternSelect.Items.Add(s);
     PaternSelect.ItemIndex:=PaternSelect.Items.Count-1;
     PaternSave;
     PaternListSelect.Items.Assign(PaternSelect.Items);
  end;
end;


procedure TMainFrm.PaternClick(Sender: TObject);
var
  s:String;
begin
  s:='0';
  with Patern do begin
       if Cells[Col,Row]='0' then s:='1';
       //if Cells[Col,Row]='1' then s:='2';
       //if Cells[Col,Row]='2' then s:='3';

       Cells[Col,Row]:=s;
  end;
end;

procedure TMainFrm.PaternPlayClick(Sender: TObject);
begin
  if PageControlSelect.ActivePageIndex=0 then
     with PaternPlaylist do if Items.Count>0 then
        ItemIndex:=0;
  Player.Interval:=round(60000/(Bpm.Value*4));
  Player.Enabled:=true;

end;


procedure TMainFrm.BpmChange(Sender: TObject);

begin
  if Bpm.Value >220 then Bpm.Value:=220;
  if Bpm.Value <30 then Bpm.Value:=30;
end;

procedure TMainFrm.ConnectClick(Sender: TObject);
begin
  MainPanel.Caption:='Not Connected';
  PaternStopClick(Sender);
  if online then begin
     serial.CloseSocket;
     online:=False;
  end else begin
     if PortSelect.Text='' then Exit;
     serial.Connect(PortSelect.Text);
     // 115200,9600
     serial.Config(115200,8,'N',SB1,False,False);
     online:=True;
  end;
  if online then MainPanel.Caption:='Connected';
end;

procedure TMainFrm.FormCloseQuery(Sender: TObject; var CanClose: boolean);
begin
  paternfile.Free;
  Player.Enabled:=false;
  serial.Free;
end;

procedure TMainFrm.PaternAddClick(Sender: TObject);
var
  sd:TSectionDlg;
  s:String;
begin
  sd:=TSectionDlg.Create(Self);
  with sd do begin
       s:=Open;
       Free;
  end;
  if(s<>'') then begin
     PaternSave;
     PaternSelect.Items.Add(s);
     PaternSelect.ItemIndex:=PaternSelect.Items.Count-1;
     PaternClear;
     PaternSave;
     PaternListSelect.Items.Assign(PaternSelect.Items);
  end;
end;

procedure TMainFrm.PaternDeleteClick(Sender: TObject);
var
  i:Integer;
begin
  with PaternSelect do begin
     i:=ItemIndex;
     if i<0 then Exit;
     paternfile.EraseSection(Items[i]);
     Items.Delete(i);
     if Items.Count<1 then begin
        Items.Add('untitle');
        ItemIndex:=0;
        PaternClear;
        PaternSave;
     end else begin
        if i<Items.Count-1 then ItemIndex:=i else ItemIndex:=Items.Count-1;
        PaternOpen;
     end;
  end;
  PaternListSelect.Items.Assign(PaternSelect.Items);
  modified:=true;
end;

procedure TMainFrm.PaternEditClick(Sender: TObject);
var
  sd:TSectionDlg;
  p,s:String;
begin
  if PaternSelect.ItemIndex<0 then Exit;
  sd:=TSectionDlg.Create(Self);
  p:=PaternSelect.Items[PaternSelect.ItemIndex];
  with sd do begin
    s:=sd.open(p);
    sd.Free;
  end;
  if s<>'' then begin
     paternfile.EraseSection(p);
     PaternSelect.Items[PaternSelect.ItemIndex]:=s;
     PaternSave;
  end;
  PaternListSelect.Items.Assign(PaternSelect.Items);
end;

procedure TMainFrm.PaternStopClick(Sender: TObject);
begin
  Player.Enabled:=False;
  playcol:=-1;
  Patern.Repaint;
  PaternList.Repaint;
  if PaternPlaylist.Items.Count>0 then PaternPlaylist.ItemIndex:=0;
end;

procedure TMainFrm.PaternPauseClick(Sender: TObject);
begin
  Player.Enabled:=False;
end;

procedure TMainFrm.PaternDrawCell(Sender: TObject; aCol, aRow: Integer;
  aRect: TRect; aState: TGridDrawState);
var
  c:TColor;
begin
  if aCol=0 then Exit;
  c:=clWhite;
  if aCol mod 4 = 1 then c:=litegrey;
  if playcol=aCol then c:=clGray;
  with Patern do begin
      if Cells[aCol,aRow]='1' then c:=clGreen;
      if Cells[aCol,aRow]='2' then c:=clYellow;
      if Cells[aCol,aRow]='3' then c:=clRed;
      Canvas.Brush.Color:=c;
      Canvas.FillRect(aRect);
  end;
end;

procedure TMainFrm.PlayerTimer(Sender: TObject);

begin
  if PageControlSelect.PageIndex=1 then PaternPlay else PlaylistPlay;
end;

procedure TMainFrm.PlaylistAddClick(Sender: TObject);
begin
  PaternPlaylist.Items.Add(PaternListSelect.Items[PaternListSelect.ItemIndex]);
end;

procedure TMainFrm.PlaylistDeleteClick(Sender: TObject);
begin
  with PaternPlaylist do begin
      if (Items.Count<1) or (ItemIndex<0) then Exit;
      PaternPlaylist.Items.Delete(ItemIndex);
  end;
end;

procedure TMainFrm.RefreshBtnClick(Sender: TObject);
begin
  with PortSelect do begin
       Items.CommaText:=GetserialPortNames;
       ItemIndex:=Items.Count-1;
  end;
end;


procedure TMainFrm.PaternClear;
var
  x,y:Integer;
begin
  with Patern do
  for x:=1 to ColCount-1 do
       for y:=0 to RowCount-1 do Cells[x,y]:='0';
end;

procedure TMainFrm.PaternSave;
var
  i:Integer;
begin
  paternfile.WriteInteger(PaternSelect.Items[PaternSelect.ItemIndex],'count',Patern.ColCount);
  for i:=0 to Patern.RowCount-1 do
       paternfile.WriteString(PaternSelect.Items[PaternSelect.ItemIndex],'ch'+IntToStr(i),Patern.Rows[i].CommaText);
  paternfile.UpdateFile;
  modified:=True;
end;

procedure TMainFrm.PaternOpen;
var
  i:Integer;
begin
  PaternClear;
  Patern.ColCount:=paternfile.ReadInteger(PaternSelect.Items[PaternSelect.ItemIndex],
                                 'count',columncount);
  for i:=0 to Patern.RowCount-1 do
       Patern.Rows[i].CommaText:=paternfile.ReadString(PaternSelect.Items[PaternSelect.ItemIndex],
                                 'ch'+IntToStr(i),Patern.Rows[i].CommaText);
end;




procedure TMainFrm.PaternPlay;
var
  i:Integer;
  s:String;
begin
  inc(playcol);
  with Patern do begin
       if playcol<1 then playcol:=1;
       if playcol>=Patern.ColCount then playcol:=1;
       //s:=Cols[playcol].Text;
       s:='';
       for i:=0 to RowCount-1 do s:=s+Cells[playcol,i];
       i:=StrToInt(s);
       if online and (i>0) then serial.SendString(s);
       Repaint;
  end;
end;

procedure TMainFrm.PaternInit;
var
  x,y:Integer;
begin
  with Patern do begin
       DefaultColWidth:=14;
       DefaultRowHeight:=32;
       ColCount:=columncount;
       ColWidths[0]:=56;
       RowCount:=8;
       PaternClear;
       for x:=1 to ColCount-1 do
           for y:=0 to RowCount-1 do Cells[x,y]:='0';
       Cols[0].CommaText:=chname;
       Repaint;
  end;
  with PaternSelect do begin
      Clear;
      Items.Add('untitled');
      ItemIndex:=0;
  end;
end;

procedure TMainFrm.PlaylistInit;
var
  x,y:Integer;
begin
  with PaternList do begin
       DefaultColWidth:=14;
       DefaultRowHeight:=32;
       ColCount:=columncount;
       ColWidths[0]:=56;
       RowCount:=8;
       for x:=1 to ColCount-1 do
           for y:=0 to RowCount-1 do Cells[x,y]:='0';
       Cols[0].CommaText:=chname;
       Repaint;
  end;
  with PaternListSelect do begin
       Clear;
       Items.Add('untiled');
       ItemIndex:=0;
  end;
  PaternPlayList.Clear;
end;

procedure TMainFrm.PlaylistPlay;
var
  i:Integer;
  s:String;
begin
  inc(playcol);
  with PaternList do begin
       if playcol<1 then begin
          if PaternPlaylist.Count<1 then Exit ;
          PaternPlaylist.ItemIndex:=0;
          playcol:=1;
       end;
       if playcol>=ColCount then begin
          i:=PaternPlaylist.ItemIndex+1;
          if i>PaternPlaylist.Count-1 then begin
             PaternStopClick(Self);
             Exit;
          end;
          PaternPlaylist.ItemIndex:=i;
          PaternPlaylistClick(PaternPlaylist);
          playcol:=1;
       end;

       s:='';
       for i:=0 to RowCount-1 do s:=s+Cells[playcol,i];
       i:=StrToInt(s);
       if online and (i>0) then serial.SendString(s);
       Repaint;
  end;
end;

procedure TMainFrm.PlaylistSave;
var
  i:Integer;
begin
  with playlistfile do begin
       WriteInteger('cfg_default','bpm',Bpm.Value);
       WriteString('cfg_default','port',PortSelect.Text);
       WriteInteger('cfg_default','count',PaternPlaylist.Count);
       for i:=0 to PaternPlaylist.Count-1 do
           WriteString('item_play_list','i'+IntToStr(i),PaternPlayList.Items[i]);
       UpdateFile;
  end;
end;


procedure TMainFrm.PlaylistOpen(s: String);
var
  i:Integer;
begin
  with PaternList do begin
       PaternList.ColCount:=paternfile.ReadInteger(s,'count',columncount);
       for i:=0 to RowCount-1 do
           Rows[i].CommaText:= paternfile.ReadString(s,'ch'+IntToStr(i),Rows[i].CommaText);
  end;
end;

procedure TMainFrm.ProjectSave;
var
  slpatern,slplaylist:TStringList;
  i:Integer;
begin
  if openfile='' then Exit;
  PaternSave;
  PlaylistSave;
  paternfile.free;
  playlistfile.free;

  slpatern:=TStringList.Create;
  slplaylist:=TStringList.Create;
  slpatern.LoadFromFile(ptntmp);
  slplaylist.LoadFromFile(plstmp);

  for i:=0 to slpatern.Count-1 do slplaylist.Add(slpatern[i]);
  slplaylist.SaveToFile(openfile);

  paternfile:=TIniFile.Create(ptntmp);
  playlistfile:=TIniFile.Create(plstmp);
  slpatern.Free;
  slplaylist.Free;

  modified:=false;
end;

procedure TMainFrm.ProjectOpen;
var
  sl:TStringList;
  tmp:TIniFile;
  s:String;
  i,ii:Integer;
begin
  PaternInit;
  PlaylistInit;

  playlistfile.Free;
  paternfile.free;


  sl:=TStringList.Create;
  sl.SaveToFile(plstmp);

  tmp:=TIniFile.Create(openfile);
  playlistfile:=TIniFile.Create(plstmp);

    with playlistfile do begin
         i:=tmp.ReadInteger('cfg_default','bpm',60);
         WriteInteger('cfg_default','bpm',i);
         s:=tmp.ReadString('cfg_default','port','');
         WriteString('cfg_default','port',s);
         ii:=tmp.ReadInteger('cfg_default','count',-1);
         WriteInteger('cfg_default','count',ii);

       for i:=0 to ii do begin
          s:=tmp.ReadString('item_play_list','i'+IntToStr(i),'');
          WriteString('item_play_list','i'+IntToStr(i),s);
          if s<>'' then sl.Add(s);
       end;
       UpdateFile;
       PaternPlaylist.Items.Assign(sl);
       if sl.Count>0 then begin
          PaternPlaylist.ItemIndex:=0;
          PlaylistOpen(sl[0]);
       end;
  end;

  sl.Clear;
  tmp.Free;

  sl.LoadFromFile(openfile);
  sl.SaveToFile(ptntmp);
  paternfile:=TIniFile.Create(ptntmp);
  with paternfile do begin
     if SectionExists('cfg_default') then EraseSection('cfg_default');
     if SectionExists('item_play_list') then EraseSection('item_play_list');
     sl.CLear;
     ReadSections(sl);
  end;

  if sl.Count<1 then Exit;
  with PaternSelect do begin
      Items.Assign(sl);
      ItemIndex:=0;
  end;
  with PaternListSelect do begin
      Items.Assign(sl);
      ItemIndex:=0;
  end;
  PaternOpen;
  sl.Free;
end;

procedure TMainFrm.ProjectNewClick(Sender: TObject);
begin
  PaternInit;
  PlaylistInit;
end;



end.

