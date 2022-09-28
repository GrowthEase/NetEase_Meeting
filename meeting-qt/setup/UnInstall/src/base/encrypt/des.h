// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

#pragma once
#ifndef yxDESH
#define yxDESH
#include <string>
// support CBC ECB mode,you can  padding  PKCS5 or NOPKCS by yuzj 2010 5 10
#define NOPKCS 0  //Ĭ
#define PKCS5 1

#define ECB_MODE 0  //Ĭ
#define CBC_MODE 1

class yxDES {
public:
    static std::string Encrypt(std::string& src, const char* key, int iMode = ECB_MODE, int iPKCS = PKCS5);
    static std::string Decrypt(std::string& src, const char* key, int iMode = ECB_MODE, int iPKCS = PKCS5);

private:
    //๹캯
    yxDES(int length = 8192);

    //
    ~yxDES();

    //:üӽܺģʽûĬģʽ0
    //:
    //: int m_iModeint m_iPkcs
    void SetModeAndPKCS(int iMode = 0, int iPKCS = 0);

    //: IV,ĬΪ{0,0,0,0,0,0,0,0}
    //: 8λַ
    //: char szvi[8]char szviRev[8]
    void SetIV(char* srcBytes);

    //: 1628λkey
    //:Դ8λַ(key),key0-1
    //: private CreateSubKeychar SubKeys[keyN][16][48]
    void InitializeKey(const char* srcBytes, unsigned int keyN);

    //: 8λַ
    //: 8λַ,ʹKey0-1
    //:ܺprivate szCiphertext[16]
    //      ûͨCiphertextõ
    void EncryptData(char* _srcBytes, unsigned int keyN);

    //: 16λʮַ
    //: 16λʮַ,ʹKey0-1
    //:ܺprivate szPlaintext[8]
    //      ûͨPlaintextõ
    void DecryptData(char* _srcBytes, unsigned int keyN);

    //:ⳤַ
    //:ⳤַ,,ʹKey0-1
    //:ܺprivate szFCiphertextAnyLength[8192]
    //      ûͨCiphertextAnyLengthõ
    void EncryptAnyLength(char* _srcBytes, unsigned int _bytesLength, unsigned int keyN);

    //:ⳤʮַ
    //:ⳤַ,,ʹKey0-1
    //:ܺprivate szFPlaintextAnyLength[8192]
    //      ûͨPlaintextAnyLengthõ
    void DecryptAnyLength(char* _srcBytes, unsigned int _bytesLength, unsigned int keyN);

    //: BytesBitsת,
    //:任ַ,Żָ,BitsС
    void Bytes2Bits(const char* srcBytes, char* dstBits, unsigned int sizeBits);

    //: BitsBytesת,
    //:任ַ,Żָ,BitsС
    void Bits2Bytes(char* dstBytes, char* srcBits, unsigned int sizeBits);

    //: IntBitsת,
    //:任ַ,Żָ
    void Int2Bits(unsigned int srcByte, char* dstBits);

    //: BitsHexת
    //:任ַ,Żָ,BitsС
    void Bits2Hex(char* dstHex, char* srcBits, unsigned int sizeBits);

    //: BitsHexת
    //:任ַ,Żָ,BitsС
    void Hex2Bits(char* srcHex, char* dstBits, unsigned int sizeBits);

    // szCiphertextInBinaryget
    char* GetCiphertextInBinary();

    // szCiphertextInHexget
    char* GetCiphertextInHex();

    // Ciphertextget
    char* GetCiphertextInBytes();

    // Plaintextget
    char* GetPlaintext();

    // CiphertextAnyLengthget
    char* GetCiphertextAnyLength();

    // PlaintextAnyLengthget
    char* GetPlaintextAnyLength();

    //ַת16ı
    void ConvertCiphertext2Hex(char* szPlainInBytes);

    // 16תַ
    int ConvertHex2Ciphertext(const char* szCipherInBytes);

    // CiphertextData
    char* GetCiphertextData();

    // hexCiphertextAnyLength
    char* GetHexCipherAnyLengthData();

private:
    int m_iLength;
    char szSubKeys[2][16][48];    // 21648λԿ,23DES
    char szCiphertextRaw[64];     //(64Bits) int 0,1
    char szPlaintextRaw[64];      //(64Bits) int 0,1
    char szCiphertextInBytes[8];  // 8λ
    char szPlaintextInBytes[8];   // 8λַ

    char szCiphertextInBinary[65];  //(64Bits) char '0','1',һλ'\0'
    char szCiphertextInHex[17];     //ʮ,һλ'\0'
    char szPlaintext[9];            // 8λַ,һλ'\0'

    char* szFCiphertextAnyLength;  //ⳤ
    char* szFPlaintextAnyLength;   //ⳤַ

    char* szCiphertextData;
    char* hexCiphertextAnyLength;

    char sziv[8];     // IV
    char szivRev[8];  // IV

    int m_iMode;  //ӽģʽ
    int m_iPkcs;  //ģʽ

    int data_base_length_;  //ڱҪַ泤

    //:Կ
    //: PC1任56λַ,ɵszSubKeys0-1
    //: char szSubKeys[16][48]
    void CreateSubKey(char* sz_56key, unsigned int keyN);

    //: DESеF,
    //: 32λ,32λ,key(0-15),ʹõszSubKeys0-1
    //:ڱ任32λ
    void FunctionF(char* sz_Li, char* sz_Ri, unsigned int iKey, unsigned int keyN);

    //: IP任
    //:ַ,ָ
    //:ıڶ
    void InitialPermuteData(char* _src, char* _dst);

    //: 32λչλ48λ,
    //:ԭ32λַ,չָ
    //:ıڶ
    void ExpansionR(char* _src, char* _dst);

    //:,
    //:Ĳַ1,ַ2,,ָ
    //: ıĸ
    void XOR(char* szParam1, char* szParam2, unsigned int uiParamLength, char* szReturnValueBuffer);

    //: S-BOX , ѹ,
    //: 48λַ,
    //:ؽ:32λַ
    void CompressFuncS(char* _src48, char* _dst32);

    //: IP任,
    //:任ַ,ָ
    //:ıڶ
    void PermutationP(char* _src, char* _dst);
};

#endif
