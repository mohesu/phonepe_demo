import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:crypto/crypto.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:phonepe_payment_sdk/phonepe_payment_sdk.dart';
import 'package:phonepepayment/phonepe_web.dart';
import 'package:url_launcher/url_launcher_string.dart';


class PhonepeGateway extends StatefulWidget {
  const PhonepeGateway({Key? key}) : super(key: key);

  @override
  State<PhonepeGateway> createState() => _PhonepeGatewayState();
}

class _PhonepeGatewayState extends State<PhonepeGateway> {
  String environment ="UAT_SIM";
  String appId = "";
  String merchantId ="PGTESTPAYUAT";
  bool enableLogging = true;
  String checksum= "";
  String saltKey ="099eb0cd-02cf-4e2a-8aca-3e6c6aff0399";
  String saltIndex="1";
  String callbackUrl= "https://webhook.site/e58643de-e7d5-4a95-9239-3acddd7b8ed5";
  String body ="";
  Object? result;
  String apiEndPoint= "/pg/v1/pay";
  // final PhonePeService phonePayService = PhonePeService();
  getChecksum(){
    final reqData={
      "merchantId": merchantId,
      "merchantTransactionId": "transaction_123",
      "merchantUserId": "90223250",
      "amount": 1000,
      "mobileNumber": "9999999999",
      "callbackUrl": callbackUrl,
      "paymentInstrument": {
        // "type": "UPI_INTENT",
        "type": "PAY_PAGE",
        // "targetApp": "com.phonepe.app"
      },
      // "deviceContext": {
      //   "deviceOS": "ANDROID"
      // }
    };
    String base64Body=base64.encode(utf8.encode(json.encode(reqData)));
    checksum='${sha256.convert(utf8.encode(base64Body+apiEndPoint+saltKey)).toString()}###$saltIndex';
    return base64Body;
  }

  @override
  void initState(){
    super.initState();
    phonepeInit();
    body =getChecksum().toString();

  }
  /*

    url: "https://api-preprod.phonepe.com/apis/pg-sandbox/pg/v1/pay" ,
    merchantId: "PGTESTPAYUAT",
    saltIndex: "1",
    saltKey: "099eb0cd-02cf-4e2a-8aca-3e6c6aff0399",
    apiEndPoint:"/pg/v1/pay",
   */

  final webPhonepe=PhonepeWeb(
      redirectUrl:"https://bc1c-38-137-25-82.ngrok-free.app/redirect" ,
      callbackUrl: 'https://bc1c-38-137-25-82.ngrok-free.app/callback',
      apiEndPoint: '/pg/v1/pay',
      url: Uri.parse("https://api-preprod.phonepe.com/apis/pg-sandbox/pg/v1/pay"),
      merchantId: "PGTESTPAYUAT",
      saltKey: "099eb0cd-02cf-4e2a-8aca-3e6c6aff0399",
      saltIndex: '1');
  @override
  Widget build(BuildContext context) {
    return  Scaffold(
      appBar: AppBar(
          title: const Text("Phonepe Gateway")
      ),
      body: Column(
        children: [
          ElevatedButton(onPressed: (){
            int price=100;
             webPhonepe.pay(transactionId:"transaction_123" , userId: "90223250", mobileNumber:"9999999999" , amount: price*100 );
          }, child: const Text('CheckOut web')),
          const SizedBox(
            height: 10,
          ),
          ElevatedButton(onPressed: (){
            startPgTransaction();
           // phonePayService.pay(transactionId: "1211", price: 100, userId: "123", phone: "1234567890");
          }, child: const Text('CheckOut')),
          const SizedBox(
            height: 10,
          ),
          Text("Result  : $result")
        ],
      ),
    );
  }

  void phonepeInit() {
    PhonePePaymentSdk.init(environment, appId, merchantId, enableLogging)
        .then((val) => {
      setState(() {
        result = 'PhonePe SDK Initialized - $val';
      })
    })
        .catchError((error) {
      handleError(error);
      return <dynamic>{};
    });
  }
  void startPgTransaction() async{
    try {
      var response = PhonePePaymentSdk.startPGTransaction(
          body, callbackUrl, checksum, {}, apiEndPoint, "");
      response
          .then((val) => {
        setState(() {
          if(val != null){
            String status = val['status'].toString();
            String error = val['error'].toString();
            if(status=='SUCCESS'){
              result ="Flow complete -status :SUCCESS";
            }else{
              result ="Flow Complete - status : $status and error $error";
            }
          }
          else{
            result= "Flow Incomplete";
          }
          result = val;
        })
      })
          .catchError((error) {
        handleError(error);
        return <dynamic>{};
      });
    } catch (error) {
      handleError(error);
    }
  }
  void handleError(error) {
    setState(() {
      result={
        "error":error
      };
    });
  }
}


//
// class PhonePeService{
//   static const webPayUrl = "https://87b4-38-137-25-82.ngrok-free.app";
//   pay(
//   {
//     required String transactionId,
//     required double price,
//     required String userId,
//     required String phone
// }
//       ) async{
//
//     if(kIsWeb) {
//       return payWithWeb(transactionId: transactionId,
//           price: price,
//           userId: userId,
//           phone: phone);
//     }
//
//   }
//
//   payWithWeb({
//     required String transactionId,
//     required double price,
//     required String userId,
//     required String phone
//   })async{
//
//     final dataToSend = {
//         "orderId":transactionId,
//         "price":price,
//       "userId":userId,
//       "phone":phone
//     };
//     final encoded = jsonEncode(dataToSend);
//     try{
//       final res = await http.post(Uri.parse("$webPayUrl/pay"),headers:{
//         "content-type":"application/json"
//
//       } ,
//           body: encoded
//       );
//       if(res.statusCode == 200){
//           final decoded = jsonDecode(res.body);
//           final url = decoded["paymentUrl"];
//           if(url!=null){
//               launchUrlString(url);
//           }
//       }else{
//         print(res.statusCode);
//       }
//     }catch(e){
//       print(e);
//     }
//
//
//   }
//
//
// }