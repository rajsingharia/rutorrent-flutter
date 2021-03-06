import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rutorrentflutter/api/api_conf.dart';
import 'package:rutorrentflutter/api/api_requests.dart';
import 'package:rutorrentflutter/components/add_dialog.dart';
import 'package:rutorrentflutter/components/rss_label_tile.dart';
import 'package:rutorrentflutter/models/mode.dart';
import 'package:rutorrentflutter/models/rss.dart';
import 'package:rutorrentflutter/constants.dart' as Constants;

class RSSFeeds extends StatefulWidget {
  @override
  _RSSFeedsState createState() => _RSSFeedsState();
}

class _RSSFeedsState extends State<RSSFeeds> {
  _getTotalFeeds(List<RSSLabel> rssLabelsList) {
    int feeds = 0;
    for (var rss in rssLabelsList) feeds += rss.items.length;
    return feeds;
  }

  Future<void> _refreshState() async {
    await Future.delayed(Duration(milliseconds: 500),(){});
    setState(() {
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<Api>(
      builder: (context,api,child) {
        return Scaffold(
          floatingActionButton: FloatingActionButton(
            backgroundColor: Provider.of<Mode>(context).isLightMode ? Constants.kBlue : Constants.kIndigo,
            onPressed: () {
              showDialog(
                  context: context,
                  builder: (context) =>
                      AddDialog(
                        dialogHint: 'Enter rss url',
                        apiRequest: (rssUrl) async{
                          await ApiRequests.addRSS(api, rssUrl);
                          _refreshState();
                        },
                      ));
            },
            child: Icon(Icons.add,color: Colors.white,),
          ),
          body: RefreshIndicator(
            color: Provider.of<Mode>(context).isLightMode?Constants.kBlue:Constants.kIndigo,
            onRefresh: _refreshState,
            child: FutureBuilder(
              future: ApiRequests.loadRSS(Provider.of<Api>(context)),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting &&
                    !snapshot.hasData) {
                  return ListTile(
                    title: Text(
                      'Loading...',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                    ),
                  );
                }
                List<RSSLabel> rssLabelsList = snapshot.data ?? [];
                return Column(
                  children: <Widget>[
                    ListTile(
                      title: Text(
                        'All Feeds (${_getTotalFeeds(rssLabelsList)})',
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.w600),
                      ),
                    ),
                    Expanded(
                      child: ListView.builder(
                          itemCount: rssLabelsList.length,
                          itemBuilder: (context, index) {
                            return RSSLabelTile(rssLabelsList[index],_refreshState);
                          }),
                    ),
                  ],
                );
              },
            ),
          ),
        );
      }
    );
  }
}
