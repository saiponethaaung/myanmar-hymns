import 'package:flutter/material.dart';
import 'package:myanmar_hymns/src/models/base_model.dart';
import 'package:provider/provider.dart';

class ZoomWidget extends StatelessWidget {
  final Widget child;

  const ZoomWidget(this.child, {super.key});

  @override
  Widget build(BuildContext context) {
    BaseModel baseModel = Provider.of<BaseModel>(context);

    return LayoutBuilder(
      builder: (context, constraints) => Stack(
        children: [
          SizedBox(
            height: constraints.maxHeight,
            child: child,
          ),
          Positioned(
            bottom: 20,
            right: 24,
            child: Material(
              elevation: 4,
              shadowColor: Colors.black26,
              borderRadius: BorderRadius.circular(30),
              color: Colors.white,
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(30),
                  border: Border.all(color: Colors.black12, width: 1),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    InkWell(
                      borderRadius: const BorderRadius.horizontal(
                        left: Radius.circular(30),
                      ),
                      onTap: () {
                        if (baseModel.fontScale > 0.9) {
                          baseModel.fontScale -= 0.1;
                        }
                      },
                      child: const Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 10,
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              'A',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                            ),
                            Icon(Icons.remove, size: 14, color: Colors.black54),
                          ],
                        ),
                      ),
                    ),
                    Container(
                      width: 1,
                      height: 24,
                      color: Colors.black12,
                    ),
                    InkWell(
                      borderRadius: const BorderRadius.horizontal(
                        right: Radius.circular(30),
                      ),
                      onTap: () {
                        if (baseModel.fontScale < 2.5) {
                          baseModel.fontScale += 0.1;
                        }
                      },
                      child: const Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 10,
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              'A',
                              style: TextStyle(
                                fontSize: 17,
                                fontWeight: FontWeight.bold,
                                color: Color.fromRGBO(210, 90, 0, 1),
                              ),
                            ),
                            Icon(
                              Icons.add,
                              size: 14,
                              color: Color.fromRGBO(210, 90, 0, 1),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
