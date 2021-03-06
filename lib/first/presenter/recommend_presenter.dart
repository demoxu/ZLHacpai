import 'package:zhacpai/first/models/article_entity.dart';
import 'package:zhacpai/first/page/recommend.dart';
import 'package:zhacpai/mvp/base_page_presenter.dart';
import 'package:zhacpai/net/dio_utils.dart';
import 'package:zhacpai/net/http_api.dart';
import 'package:zhacpai/util/log_utils.dart';
import 'package:zhacpai/widgets/state_layout.dart';

class RecommendPresenter extends BasePagePresenter<RecommendPageState> {
  Future getLastArticles(ArticleType type, int page, bool isShowDialog) async {

    Map<String, String> params = Map();
    params['p']=page.toString();

    String url=HttpApi.lastArticles;

    switch(type){
      case ArticleType.good:
        url=url+'/good';
        break;
      case ArticleType.perfect:
        url=url+'/perfect';
        break;
      case ArticleType.reply:
        url=url+'/reply';
        break;
      case ArticleType.hot:
        url=url+'/hot';
        break;
      case ArticleType.none:
        break;
    }
    await requestNetwork<ArticleEntity>(Method.get, url: url,
      queryParameters: params,
      isShow: isShowDialog,
      onSuccess: (data){
          Log.e(data.toString(),tag: 'article');
          if (data != null) {
            /// 一页30条数据，等于30条认为有下一页
            /// 具体的处理逻辑根据具体的接口情况处理，这部分可以抽离出来
            ///
            var hasMore=data.articles.length == data.pagination.paginationPageCount;
            Log.e("hasMore:"+hasMore.toString()+"articles.length:"+data.articles.length.toString()+"pageCount:"+data.pagination.paginationPageCount.toString());
            view.provider.setHasMore(data.articles.length == 20);
            if (page == 1) {
              /// 刷新
              view.provider.list.clear();
              if (data.articles.isEmpty) {
                view.provider.setStateType(StateType.empty);
              } else {
                view.provider.addAll(data.articles);
              }
            } else {
              view.provider.addAll(data.articles);
            }
          } else {
            /// 加载失败
            view.provider.setHasMore(false);
            view.provider.setStateType(StateType.network);
          }
      },
        onError: (_, __) {
          /// 加载失败

        }
    );


  }
}

enum ArticleType { perfect, reply, good, hot,none }


