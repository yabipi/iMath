import 'package:flutter/material.dart';

class NewsTile extends StatelessWidget {
  final String? imgUrl, title, desc, content, posturl;
  final VoidCallback? onTap;

  NewsTile({this.imgUrl, this.desc, this.title, this.content, @required this.posturl, this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: (){
        onTap?.call();
      },
      child: Container(
          margin: EdgeInsets.only(bottom: 24),
          width: MediaQuery.of(context).size.width,
          child: Container(
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 16),
              alignment: Alignment.bottomCenter,
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.only(bottomRight: Radius.circular(6),bottomLeft:  Radius.circular(6))
              ),
              child: _buildSmallMode(context)

            ),
          )),
    );
  }

  Widget _buildSmallMode(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: Image.network(
              imgUrl??'https://www.icodelib.cn/news.png',
              width: 32,
              height: 32,
              // width: MediaQuery.of(context).size.width,
              fit: BoxFit.cover,
            )),
        SizedBox(width: 8,),
        Text(
          title??'无标题',
          maxLines: 2,
          style: TextStyle(
              color: Colors.black87,
              fontSize: 20,
              fontWeight: FontWeight.w500),
        ),
        SizedBox(
          width: 4,
        ),
        Text(
          desc??'',
          maxLines: 2,
          style: TextStyle(color: Colors.black54, fontSize: 14),
        ),
        Spacer(),
      ],
    );
  }

  Widget _buildLargeMode(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: Image.network(
              imgUrl??'https://www.icodelib.cn/news.png',
              width: 32,
              height: 32,
              // width: MediaQuery.of(context).size.width,
              fit: BoxFit.cover,
            )),
        SizedBox(height: 12,),
        Text(
          title??'无标题',
          maxLines: 2,
          style: TextStyle(
              color: Colors.black87,
              fontSize: 20,
              fontWeight: FontWeight.w500),
        ),
        SizedBox(
          height: 4,
        ),
        Text(
          desc??'',
          maxLines: 2,
          style: TextStyle(color: Colors.black54, fontSize: 14),
        )
      ],
    );
  }
}