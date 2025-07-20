import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:imath/components/skeleton/video_reply.dart';
import 'package:imath/http/culture.dart';
import 'package:imath/models/mathematician.dart';

import 'mathematician_detail_screen.dart';

class MathematicianListview extends StatefulWidget {
  @override
  MathematicianListviewState createState() => MathematicianListviewState();

}

class MathematicianListviewState extends State<MathematicianListview> with AutomaticKeepAliveClientMixin {
  // List<Mathematician> _mathematicians = [...mathematicians];
  late Future _future;

  @override
  // TODO: implement wantKeepAlive
  bool get wantKeepAlive => false;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Refresh data when widget becomes visible
    // _loadData();
  }

  void _loadData() {
    setState(() {
      _future = fetchData();
    });
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            final items = snapshot.data;
            return ListView.builder(
              itemCount: items?.length,
              itemBuilder: (context, index) {
                final mathematician = items?[index];
                return Card(
                  margin: const EdgeInsets.all(8.0),
                  child: ListTile(
                    leading: ClipRRect(
                      borderRadius: BorderRadius.circular(25),
                      child: Image.network(
                        mathematician?.image??'',
                        width: 50,
                        height: 50,
                        fit: BoxFit.contain,
                        errorBuilder: (context, error, stackTrace) {
                          return SvgPicture.asset(
                            'assets/images/placeholder.svg',
                            width: 50,
                            height: 50,
                          );
                        },
                      ),
                    ),
                    title: Text(mathematician?.name??''),
                    subtitle: Text("${mathematician?.title??''}"),
                    trailing: const Icon(Icons.arrow_forward_ios),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => MathematicianDetailScreen(
                            mathematician: mathematician,
                          ),
                        ),
                      );
                    },
                  ),
                );
              },
            );
          } else {
            // 骨架屏
            return ListView.builder(
              itemBuilder: (context, index) {
                return const VideoReplySkeleton();
              },
              itemCount: 10,
            );
          }


      }

    )
      ;
  }

  Future fetchData() async {
    List<Mathematician> _mathematicians = [];
    final data = await CultureHttp.loadMathematicians();
    for (var item in data) {
      Mathematician m = Mathematician.fromJson(item);
      _mathematicians.add(m);
    }
    return _mathematicians;
  }
 }