object dmConvert: TdmConvert
  OldCreateOrder = False
  Height = 224
  Width = 330
  object BDEdb: TDatabase
    AliasName = 'DBDEMOS'
    Connected = True
    DatabaseName = 'BDEdb'
    SessionName = 'Default'
    Left = 40
    Top = 16
  end
  object dbxConn: TSQLConnection
    ConnectionName = 'BLACKFISHSQLCONNECTION'
    DriverName = 'MySQL'
    GetDriverFunc = 'getSQLDriverMYSQL'
    LibraryName = 'dbxmys.dll'
    LoadParamsOnConnect = True
    VendorLib = 'libmysql.dll'
    Left = 136
    Top = 24
  end
  object bdeTable: TTable
    DatabaseName = 'BDEdb'
    ReadOnly = True
    TableName = 'animals.dbf'
    Left = 40
    Top = 80
  end
end
