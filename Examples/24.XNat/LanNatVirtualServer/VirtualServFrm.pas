unit VirtualServFrm;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs,
  FMX.Controls.Presentation, FMX.ScrollBox, FMX.Memo, FMX.StdCtrls,
  CoreClasses, PascalStrings, UnicodeMixedLib, CommunicationFramework,
  xNAT_MappingOnVirutalServer, xNATPhysics, CommunicationTest, DoStatusIO, NotifyObjectBase;

type
  TForm2 = class(TForm)
    Memo1: TMemo;
    Timer1: TTimer;
    TestButton: TButton;
    OpenButton: TButton;
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure FormCreate(Sender: TObject);
    procedure OpenButtonClick(Sender: TObject);
    procedure TestButtonClick(Sender: TObject);
    procedure Timer1Timer(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
    XCli: TXNAT_Mapping;
    server: TCommunicationFrameworkServer;
    server_test: TCommunicationTestIntf;

    // ģ�������Կͻ���
    // ����ģ����Կ��Կ�����app���ɣ����ڷ���ֱ������ʵ��
    client: TCommunicationFrameworkClient;
    client_test: TCommunicationTestIntf;
    procedure DoStatusIntf(AText: SystemString; const ID: Integer);
  end;

var
  Form2: TForm2;

implementation

{$R *.fmx}


procedure TForm2.FormCreate(Sender: TObject);
begin
  AddDoStatusHook(Self, DoStatusIntf);

  XCli := TXNAT_Mapping.Create;

  {
    ��͸Э��ѹ��ѡ��
    ����ʹ�ó���:
    ��������������Ѿ�ѹ����������ʹ��https���෽ʽ���ܹ���ѹ������Ч������ѹ�������ݸ���
    ���ʱ������Э�飬����ftp,����s��http,tennet��ѹ�����ؿ��Դ򿪣�����С������
  }
  XCli.ProtocolCompressed := True;

  XCli.RemoteTunnelAddr := '127.0.0.1';             // ������������IP
  XCli.RemoteTunnelPort := '7890';                  // �����������Ķ˿ں�
  XCli.AuthToken := '123456';                       // Э����֤�ַ���
  server := XCli.AddMappingServer('web8000', 1000); // ��������������8000�˿ڷ����������Ϊ���ط�����

  server_test := TCommunicationTestIntf.Create;
  server_test.RegCmd(server);

  client := TXPhysicsClient.Create;
  client_test := TCommunicationTestIntf.Create;
  client_test.RegCmd(client);
end;

procedure TForm2.DoStatusIntf(AText: SystemString; const ID: Integer);
begin
  Memo1.Lines.Add(AText);
  Memo1.GoToTextEnd;
end;

procedure TForm2.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  DisposeObject(XCli);
end;

procedure TForm2.OpenButtonClick(Sender: TObject);
begin
  // ����������͸
  // ��������������͸�������󣬱��ط��������Զ�StartService�����ط��������������κζ˿�
  XCli.OpenTunnel;
end;

procedure TForm2.TestButtonClick(Sender: TObject);
begin
  // ģ����ԣ����ӵ�����������

  // �������õĿͻ��˷������õķ��������ͻ������������ƣ�ע����ѭ��
  // �ܿ���ѭ���ķ���ֱ��ʹ���첽��ʽ
  client.AsyncConnectP('127.0.0.1', 8000, procedure(const cState: Boolean)
    begin
      if cState then
          client_test.ExecuteAsyncTestWithBigStream(client.ClientIO);
      // ���Զ�̷����������������������������޷��շ��ɹ���30���Ժ��ǿ�ƶ���
      client.WaitP(30 * 1000, procedure(const sState: Boolean)
        begin
          client.Disconnect;
        end);
    end);
end;

procedure TForm2.Timer1Timer(Sender: TObject);
begin
  if XCli <> nil then
    begin
      XCli.Progress;
      client.Progress;
    end;
end;

end.