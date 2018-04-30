unit UCoreObjects;

{ Copyright (c) 2018 by PascalCoin Project

  Contains common types for Core module.

  Distributed under the MIT software license, see the accompanying file LICENSE
  or visit http://www.opensource.org/licenses/mit-license.php.

  Acknowledgements:
    Herman Schoenfeld <herman@sphere10.com>: unit creator
}

{$mode delphi}

interface

uses
  Classes, SysUtils, UCrypto, UAccounts, UBlockChain, UWallet, UCommon,
  Generics.Collections, Generics.Defaults;

type

  { TBalanceSummary }

  TBalanceSummary = record
    TotalPASC : UInt64;
    TotalPASA : Cardinal;
  end;

  { TExecuteOperationsModel }

  TExecuteOperationsModel = class(TComponent)
    public
      type

      { TExecuteOperationType }

      TExecuteOperationType = (omtAccount, omtSendPasc, omtChangeKey, omtTransferAccount, omtChangeAccountPrivateKey, omtAddKey, omtEnlistAccountForSale);

      { TPayloadEncryptionMode }

      TPayloadEncryptionMode = (akaEncryptWithSender, akaEncryptWithReceiver, akaEncryptWithPassword, akaNotEncrypt);

      { TOperationSigningMode }

      TOperationSigningMode = (akaPrimary, akaSecondary);

      { TChangeKeyMode }

      TChangeKeyMode = (akaTransferAccountOwnership, akaChangeAccountPrivateKey);

      { TSendPASCMode }

      TSendPASCMode = (akaAllBalance, akaSpecifiedAmount);

      { TAccountSaleMode }
      TAccountSaleMode = (akaPublicSale, akaPrivateSale);

      { TOperationExecuteResultHandler }

      TOperationExecuteResultHandler =
      procedure(const ASourceAccount: TAccount; AOpType: TExecuteOperationType; const AOpText: ansistring; Result: boolean; const Message: ansistring) of object;


      { TAccountModel }

      TAccountModel = class(TComponent)
      public
        SelectedAccounts: TArray<TAccount>;
      end;

      { TSendPASCModel }

      TSendPASCModel = class(TComponent)
      public
        SingleAmountToSend: int64;
        DestinationAccount: TAccount;
        SendPASCMode: TSendPASCMode;
      end;

      { TChangeKeyModel }

      TChangeKeyModel = class(TComponent)
      public
        ChangeKeyMode: TChangeKeyMode;
      end;

      { TTransferAccountModel }

      TTransferAccountModel = class(TComponent)
      public
        AccountKey: TAccountKey;
      end;

      { TChangeAccountPrivateKeyModel }

      TChangeAccountPrivateKeyModel = class(TComponent)
      public
        SelectedIndex: integer;
        NewWalletKey: TWalletKey;
      end;

      { TWIZEnlistAccountForSaleModel }
      TEnlistAccountForSaleModel = class(TComponent)
      public
        SalePrice: int64;
        NewOwnerPublicKey: TAccountKey;
        LockedUntilBlock: cardinal;
        SellerAccount: TAccount;
        AccountSaleMode: TAccountSaleMode;
      end;

      { TFeeModel }

      TFeeModel = class(TComponent)
      public
        DefaultFee, SingleOperationFee: int64;
      end;

      { TSignerModel }

      TSignerModel = class(TComponent)
      public
        OperationSigningMode: TOperationSigningMode;
        SignerAccount: TAccount;
        SignerCandidates: TArray<TAccount>;
        SelectedIndex: integer;
      end;

      { TPayloadModel }

      TPayloadModel = class(TComponent)
      public
        HasPayload: boolean;
        Content, Password: string;
        PayloadEncryptionMode: TPayloadEncryptionMode;
        EncodedBytes: TRawBytes;
      end;

    private
      FExecuteOperationType: TExecuteOperationType;
      FAccount: TAccountModel;
      FSendPASC: TSendPASCModel;
      FChangeKey: TChangeKeyModel;
      FTransferAccount: TTransferAccountModel;
      FChangeAccountPrivateKey: TChangeAccountPrivateKeyModel;
      FEnlistAccountForSale: TEnlistAccountForSaleModel;
      FFee: TFeeModel;
      FSigner: TSignerModel;
      FPayload: TPayloadModel;
    public
      constructor Create(AOwner: TComponent; AType: TExecuteOperationType); overload;
      property ExecuteOperationType: TExecuteOperationType read FExecuteOperationType;
      property Account: TAccountModel read FAccount;
      property SendPASC: TSendPASCModel read FSendPASC;
      property ChangeKey: TChangeKeyModel read FChangeKey;
      property TransferAccount: TTransferAccountModel read FTransferAccount;
      property ChangeAccountPrivateKey: TChangeAccountPrivateKeyModel read FChangeAccountPrivateKey;
      property EnlistAccountForSale: TEnlistAccountForSaleModel read FEnlistAccountForSale;
      property Fee: TFeeModel read FFee;
      property Signer: TSignerModel read FSigner;
      property Payload: TPayloadModel read FPayload;
    end;


  { TBlockChainData }

  TBlockChainData = record
    Block: cardinal;
    Timestamp: cardinal;
    BlockProtocolVersion,
    BlockProtocolAvailable: word;
    OperationsCount: integer;
    Volume: int64;
    Reward, Fee: int64;
    Target: cardinal;
    HashRateTargetKhs: int64;
    HashRateKhs: int64;
    MinerPayload: TRawBytes;
    PoW: TRawBytes;
    SafeBoxHash: TRawBytes;
    AccumulatedWork: UInt64;
    TimeAverage200: real;
    TimeAverage150: real;
    TimeAverage100: real;
    TimeAverage75: real;
    TimeAverage50: real;
    TimeAverage25: real;
    TimeAverage10: real;
  end;

const
  CT_BalanceSummary_Nil : TBalanceSummary = (
    TotalPASC : 0;
    TotalPASA : 0;
  );

  CT_TBlockChainData_NUL: TBlockChainData = (
    Block: 0;
    Timestamp: 0;
    BlockProtocolVersion: 0;
    BlockProtocolAvailable: 0;
    OperationsCount: -1;
    Volume: -1;
    Reward: 0;
    Fee: 0;
    Target: 0;
    HashRateTargetKhs: 0;
    HashRateKhs: 0;
    MinerPayload: '';
    PoW: '';
    SafeBoxHash: '';
    AccumulatedWork: 0;
    TimeAverage200: 0;
    TimeAverage150: 0;
    TimeAverage100: 0;
    TimeAverage75: 0;
    TimeAverage50: 0;
    TimeAverage25: 0;
    TimeAverage10: 0
  );

implementation

constructor TExecuteOperationsModel.Create(AOwner: TComponent; AType: TExecuteOperationsModel.TExecuteOperationType);
begin
  inherited Create(AOwner);
  FExecuteOperationType := AType;
  FAccount := TAccountModel.Create(Self);
  FSendPASC := TSendPASCModel.Create(Self);
  FChangeKey := TChangeKeyModel.Create(Self);
  FTransferAccount := TTransferAccountModel.Create(Self);
  FChangeAccountPrivateKey := TChangeAccountPrivateKeyModel.Create(Self);
  FEnlistAccountForSale := TEnlistAccountForSaleModel.Create(Self);
  FFee := TFeeModel.Create(Self);
  FSigner := TSignerModel.Create(Self);
  FPayload := TPayloadModel.Create(Self);
end;

end.

