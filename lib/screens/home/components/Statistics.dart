import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:pikobar_flutter/components/Skeleton.dart';
import 'package:pikobar_flutter/constants/Colors.dart';
import 'package:pikobar_flutter/constants/Dictionary.dart';
import 'package:pikobar_flutter/constants/Dimens.dart';
import 'package:pikobar_flutter/constants/FontsFamily.dart';
import 'package:pikobar_flutter/environment/Environment.dart';
import 'package:pikobar_flutter/utilities/FormatDate.dart';

class Statistics extends StatefulWidget {
  @override
  _StatisticsState createState() => _StatisticsState();
}

class _StatisticsState extends State<Statistics> {
  @override
  Widget build(BuildContext context) {
    return new StreamBuilder(
        stream: Firestore.instance
            .collection('statistics')
            .document('jabar-dan-nasional')
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Container();
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return _buildLoading();
          } else {
            var userDocument = snapshot.data;
            return _buildContent(userDocument);
          }
        });
  }

  _buildLoading() {
    return Container(
      color: Colors.white,
      padding: EdgeInsets.all(16.0),
      child: Skeleton(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              Dictionary.statistics,
              style: TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.w600,
                  fontFamily: FontsFamily.productSans,
                  fontSize: 16.0),
            ),
            SizedBox(height: Dimens.padding),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                _buildContainer(
                    '',
                    Dictionary.positif,
                    Dictionary.positif,
                    '-',
                    3,
                    Dictionary.people,
                    Colors.grey[600],
                    Colors.grey[600]),
                _buildContainer(
                    '',
                    Dictionary.recover,
                    Dictionary.recover,
                    '-',
                    3,
                    Dictionary.people,
                    Colors.grey[600],
                    Colors.grey[600]),
                _buildContainer(
                    '',
                    Dictionary.die,
                    Dictionary.die,
                    '-',
                    3,
                    Dictionary.people,
                    Colors.grey[600],
                    Colors.grey[600]),
              ],
            ),
            SizedBox(height: Dimens.padding),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                _buildContainer(
                    '',
                    Dictionary.pdpDesc,
                    Dictionary.pdpDesc,
                    '-',
                    2,
                    '(%)',
                    Colors.grey[600],
                    Colors.grey[600]),
                _buildContainer(
                    '',
                    Dictionary.opdDesc,
                    Dictionary.opdDesc,
                    '-',
                    2,
                    '(%)',
                    Colors.grey[600],
                    Colors.grey[600]),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Container _buildContent(DocumentSnapshot data) {
    return Container(
      padding: EdgeInsets.all(16.0),
      decoration: BoxDecoration(color: Colors.white, boxShadow: [
        BoxShadow(
            color: Colors.black.withOpacity(0.1),
            offset: Offset(0.0, 1),
            blurRadius: 4.0),
      ]),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Text(
                Dictionary.statistics,
                style: TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.w600,
                    fontFamily: FontsFamily.productSans,
                    fontSize: 16.0),
              ),
              Text(
                unixTimeStampToDateTimeWithoutDay(data['updated_at'].seconds),
                style: TextStyle(
                    color: Colors.grey[650],
                    fontFamily: FontsFamily.productSans,
                    fontSize: 12.0),
              ),
            ],
          ),
          SizedBox(height: Dimens.padding),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              _buildContainer(
                  '${Environment.imageAssets}bg-positif.png',
                  Dictionary.positif,
                  Dictionary.positif,
                  '${data['aktif']['jabar']}',
                  3,
                  Dictionary.people,
                  Colors.white,
                  Colors.white),
              _buildContainer(
                  '${Environment.imageAssets}bg-sembuh.png',
                  Dictionary.recover,
                  Dictionary.recover,
                  '${data['sembuh']['jabar']}',
                  3,
                  Dictionary.people,
                  Colors.white,
                  Colors.white),
              _buildContainer(
                  '${Environment.imageAssets}bg-meninggal.png',
                  Dictionary.die,
                  Dictionary.die,
                  '${data['meninggal']['jabar']}',
                  3,
                  Dictionary.people,
                  Colors.white,
                  Colors.white),
            ],
          ),
          SizedBox(height: Dimens.padding),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              _buildContainer(
                  '',
                  Dictionary.inMonitoring,
                  Dictionary.opdDesc,
                  getDataProcess(data['odp']['total']['jabar'],
                      data['odp']['selesai']['jabar']),
                  2,
                  getDataProcessPercent(data['odp']['total']['jabar'],
                      data['odp']['selesai']['jabar']),
                  Colors.grey[600],
                  ColorBase.green),
              _buildContainer(
                  '',
                  Dictionary.underSupervision,
                  Dictionary.pdpDesc,
                  getDataProcess(data['pdp']['total']['jabar'],
                      data['pdp']['selesai']['jabar']),
                  2,
                  getDataProcessPercent(data['pdp']['total']['jabar'],
                      data['pdp']['selesai']['jabar']),
                  Colors.grey[600],
                  ColorBase.green),
            ],
          )
        ],
      ),
    );
  }

  String getDataProcess(int totalData, int dataDone) {
    int processData = totalData - dataDone;
    return processData.toString();
  }

  String getDataProcessPercent(int totalData, int dataDone) {
    double processData =
        100 - num.parse(((dataDone / totalData) * 100).toStringAsFixed(2));

    return '('+ processData.toString() + '%)';
  }

  _buildContainer(String image, String title, String description, String count,
      int length, String label, Color colorTextTitle, Color colorNumber) {
    return Expanded(
      child: Container(
        width: (MediaQuery.of(context).size.width / length),
        padding: EdgeInsets.only(left: 5, right: 5.0, top: 10, bottom: 10),
        margin: EdgeInsets.symmetric(horizontal: 2.5),
        decoration: BoxDecoration(
            image: image != '' || image != null
                ? DecorationImage(fit: BoxFit.fill, image: AssetImage(image))
                : null,
            border: image == null || image == ''
                ? Border.all(color: Colors.grey[400])
                : null,
            borderRadius: BorderRadius.circular(8.0)),
        child: Column(
          children: <Widget>[
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
//                Image.asset(icon, width: 16.0, height: 16.0),
                Container(
                  margin: EdgeInsets.only(left: 5.0),
                  child: Text(title,
                      style: TextStyle(
                          fontSize: 13.0,
                          color: colorTextTitle,
                          fontWeight: FontWeight.bold,
                          fontFamily: FontsFamily.productSans)),
                ),
              ],
            ),
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: <Widget>[
                Container(
                  margin: EdgeInsets.only(top: Dimens.padding),
                  child: Text(count,
                      style: TextStyle(
                          fontSize: 22.0,
//                          color: ColorBase.green,
                          color: colorNumber,
                          fontWeight: FontWeight.bold,
                          fontFamily: FontsFamily.productSans)),
                ),
                Container(
                  margin: EdgeInsets.only(
                      top: Dimens.padding, left: 4.0, bottom: 2.0),
                  child: Text(label,
                      style: TextStyle(
                          fontSize: 14.0,
                          color: colorTextTitle,
                          fontWeight: FontWeight.bold,
                          fontFamily: FontsFamily.productSans)),
                )
              ],
            )
          ],
        ),
      ),
    );
  }
}
