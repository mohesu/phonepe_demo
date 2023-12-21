import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import 'package:crypto/crypto.dart';
import 'package:url_launcher/url_launcher.dart';

class PhonepeWeb{
  const PhonepeWeb({

    required this.redirectUrl, required  this.callbackUrl,
    required this.apiEndPoint, required this.url,

        required this.merchantId,
        required this.saltKey,
        required this.saltIndex,



  });



  final String merchantId ;
  final String saltKey;
  final String saltIndex ;

  final String apiEndPoint;
  final Uri  url;
  final String redirectUrl;
  final String callbackUrl;

    pay({
    required String transactionId,
      required String userId,
      required mobileNumber,
      required amount

})   async {





      // TODO merge
      final reqData = {
        "merchantId": merchantId,
        "merchantTransactionId": transactionId,
        "merchantUserId":userId,
        "amount":amount,
        "mobileNumber": mobileNumber,
        "callbackUrl": callbackUrl,
        "redirectUrl": redirectUrl,
        "redirectMode": "REDIRECT",
        "paymentInstrument": {
          "type": "PAY_PAGE",
        },
      };

      // TODO base64
      final String base64Body = base64.encode(utf8.encode(json.encode(reqData)));
      final String checkSum =
      '${sha256.convert(utf8.encode(base64Body + apiEndPoint + saltKey))
          .toString()}###$saltIndex';
      final dataToSend = {"request": base64Body};
      // TODO call phone post


      var response = await http.post(
        url,
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          "X-VERIFY": checkSum,
        },
        body: jsonEncode(dataToSend),
      );
      var res = jsonDecode(response.body);


      // TODO res url open
     var resUrl= res["data"]["instrumentResponse"]["redirectInfo"]["url"] as String;
     if (kDebugMode) {
       print(res);
       print(resUrl);
     }

        if (!await launchUrl(Uri.parse(resUrl)) ) {
          throw Exception('Could not launch $resUrl');
        }

    }
}