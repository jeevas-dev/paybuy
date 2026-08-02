
import 'package:eshop_multivendor/Helper/Constant.dart';
import 'package:eshop_multivendor/Provider/homePageProvider.dart';
import 'package:eshop_multivendor/Provider/pushNotificationProvider.dart';
import 'package:eshop_multivendor/Screen/ProductList&SectionView/ProductList.dart';
import 'package:eshop_multivendor/Screen/SubCategory/SubCategory.dart';
import 'package:flutter/cupertino.dart';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../Helper/Color.dart';
import '../../../Helper/String.dart';
import '../../../Helper/routes.dart';
import '../../../Model/Notification_Model.dart';
import '../../../widgets/desing.dart';

// ignore: must_be_immutable
class NotiListData extends StatefulWidget {
  int index;
  List<NotificationModel> notiList;

  NotiListData({super.key, required this.index, required this.notiList});

  @override
  State<NotiListData> createState() => _NotiListDataState();
}

class _NotiListDataState extends State<NotiListData> {

  @override
  Widget build(BuildContext context) {
    NotificationModel model = widget.notiList[widget.index];
    return InkWell(
      onTap: () async {
        if (model.type == 'products') {
          Future.delayed(Duration.zero).then((value) => context
              .read<PushNotificationProvider>()
              .getProduct(model.typeId!, 0, 0, true, context));
        } 
        else if (model.type == 'categories') {
          final catList = context.read<HomePageProvider>().catList;
          final catIndex = catList.indexWhere((c) => c.id == model.typeId);

          if (catIndex != -1) {
            final item = catList[catIndex];
            if (item.subList == null || item.subList!.isEmpty) {
              Navigator.push(
                context,
                CupertinoPageRoute(
                  builder: (context) => ProductList(
                    name: item.name,
                    id: item.id,
                    tag: false,
                    fromSeller: false,
                  ),
                ),
              );
            } else {
              Navigator.push(
                context,
                CupertinoPageRoute(
                  builder: (context) => SubCategory(
                    title: item.name!,
                    subList: item.subList,
                    categoryId: item.id!,
                  ),
                ),
              );
            }
          } else {
            Navigator.push(
              context,
              CupertinoPageRoute(
                builder: (context) => ProductList(
                  name: model.title,
                  id: model.typeId,
                  tag: false,
                  fromSeller: false,
                ),
              ),
            );
          }
        } else if (model.type == 'wallet') {
          Routes.navigateToMyWalletScreen(context);
        } else if (model.type == 'order') {
          Routes.navigateToMyOrderScreen(context);
        } else if (model.type == 'ticket_message') {
          Routes.navigateToChatScreen(context, model.id, '');
        } else if (model.type == 'ticket_status') {
          Routes.navigateToCustomerSupportScreen(context);
        } else if (model.type == 'notification') {
        try {
          if (await canLaunchUrl(Uri.parse(model.urlLink!))) {
             launchUrl(
              Uri.parse(model.urlLink!),
              mode: LaunchMode.externalApplication,
            );
          } else {
            throw 'Could not launch ${model.urlLink}';
          }
        } catch (e) {
          throw 'Something went wrong';
        }
        }
        else {
          // setSnackbar(
          //      'It is a normal Notification'), context);
        }
      },
      child: Container(
        color: Theme.of(context).colorScheme.white,
        margin: const EdgeInsets.symmetric(vertical: 5),
        padding: const EdgeInsets.all(10),
        child: Row(
          children: <Widget>[
            model.img != null && model.img != ''
                ? GestureDetector(
                    child: SizedBox(
                      width: 50,
                      height: 50,
                      child: Hero(
                        tag: '$heroTagUniqueString ${model.id!}',
                        child: CircleAvatar(
                          backgroundImage: NetworkImage(
                            model.img!,
                          ),
                          radius: 25,
                        ),
                      ),
                    ),
                    onTap: () {
                      Navigator.of(context).push(
                        PageRouteBuilder(
                          opaque: false,
                          barrierDismissible: true,
                          pageBuilder: (BuildContext context, _, __) {
                            return AlertDialog(
                              elevation: 0,
                              contentPadding: const EdgeInsets.all(0),
                              backgroundColor: Colors.transparent,
                              content: Hero(
                                tag: '$heroTagUniqueString ${model.id!}',
                                child: DesignConfiguration.getCacheNotworkImage(
                                  boxFit: null,
                                  context: context,
                                  heightvalue: null,
                                  widthvalue: null,
                                  imageurlString: model.img!,
                                  placeHolderSize: 150,
                                ),
                              ),
                            );
                          },
                        ),
                      );
                    },
                  )
                : Container(
                    height: 0,
                  ),
            const SizedBox(
              width: 10,
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 5),
                    child: Text(
                      model.title!,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontFamily: 'ubuntu',
                        fontSize: textFontSize16,
                      ),
                    ),
                  ),
                  const SizedBox(
                    height: 2,
                  ),
                  Text(
                    model.desc!,
                    style: const TextStyle(
                      fontFamily: 'ubuntu',
                    ),
                  ),
                  const SizedBox(
                    height: 5,
                  ),
                  Text(
                    model.date!,
                    style: TextStyle(
                        fontFamily: 'ubuntu',
                        fontSize: textFontSize10,
                        color: Theme.of(context)
                            .colorScheme
                            .fontColor
                            .withValues(alpha: 0.4)),
                  ),
                ],
              ),
            ),
            if (model.type == 'ticket_status' ||
                model.type == 'ticket_message' ||
                model.type == 'order' ||
                model.type == 'wallet' ||
                model.type == 'categories' ||
                model.type == 'products' ||
                model.type == 'notification') 
              Icon(Icons.arrow_forward_ios)
          ],
        ),
      ),
    );
  }
}
