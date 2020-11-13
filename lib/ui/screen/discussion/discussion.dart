import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:learn_english/util/constant.dart';
import 'package:learn_english/util/util.dart';

final _firestore = FirebaseFirestore.instance;
User loggedInUser;

class DiscussionScreen extends StatefulWidget {
  static const String id = "discussion";

  final String topicId;

  DiscussionScreen({@required this.topicId});

  @override
  _DiscussionScreenState createState() => _DiscussionScreenState();
}

class _DiscussionScreenState extends State<DiscussionScreen> {
  StreamSubscription mStream;
  List<DocumentSnapshot> comments = []; // stores fetched products
  bool isLoading = false; // track if products fetching
  bool hasMore = true; // flag for more products available or not
  int documentLimit = 10; // documents to be fetched per request
  DocumentSnapshot
      lastDocument; // flag for last document from where next 10 records to be fetched
  ScrollController _scrollController =
      ScrollController(); // listener for listview scrolling
  final messageTextController = TextEditingController();
  final _auth = FirebaseAuth.instance;
  String messageText;

  void getCurrentUser() {
    try {
      loggedInUser = _auth.currentUser;
      print(loggedInUser.email);
    } on Exception catch (e) {
      print(e);
    }
  }

  @override
  void initState() {
    super.initState();
    getCurrentUser();
    _scrollController.addListener(() {
      // If the user scroll reacts to 20% of the device height, we will fetch more documents.
      double maxScroll = _scrollController.position.maxScrollExtent;
      double currentScroll = _scrollController.position.pixels;
      double delta = MediaQuery.of(context).size.height * 0.20;
      if (maxScroll - currentScroll <= delta) {
        _getComments();
      }
    });
    _getComments();
    listenForChanges();
  }

  @override
  void dispose() {
    if (mStream != null) {
      mStream.cancel();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Communication'),
      ),
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Expanded(
                child: Column(
              children: [
                Expanded(
                  child: comments.length == 0
                      ? Center(
                          child: Text('No Data...'),
                        )
                      : RefreshIndicator(
                          onRefresh: () {
                            return Future.value(_refresh());
                          },
                          child: ListView.builder(
                            controller: _scrollController,
                            itemCount: comments.length,
                            itemBuilder: (context, index) {
                              return Dismissible(
                                key: Key(comments[index].id),
                                onDismissed: (direction) {
                                  commentRef.doc(comments[index].id).delete();
                                },
                                child: ListTile(
                                  contentPadding: EdgeInsets.all(5),
                                  title: Text(
                                    comments[index].data()['comment'],
                                    style: kTextStyleBlackDefault.copyWith(
                                        fontSize: 20),
                                  ),
                                  subtitle: Column(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        comments[index].data()['sender'],
                                        style: TextStyle(
                                            color: Colors.grey,
                                            fontStyle: FontStyle.italic),
                                      ),
                                      Text(
                                        Utils.getDateStringFromMilis(
                                            comments[index].data()['time']),
                                        style: TextStyle(
                                            color: Colors.grey,
                                            fontStyle: FontStyle.italic),
                                      ),
                                    ],
                                  ),
                                  onTap: () {
                                    showDialog(
                                        context: context,
                                        builder: (context) {
                                          return AlertDialog(
                                            content: DialogEditComment(
                                              comment: comments[index]
                                                  .data()['comment'],
                                              updateComment: (newComment) {
                                                commentRef.doc(comments[index].id).update({
                                                  'comment': newComment
                                                });
                                                Navigator.of(context,
                                                        rootNavigator: true)
                                                    .pop('dialog');
                                              },
                                            ),
                                          );
                                        });
                                  },
                                ),
                              );
                            },
                          ),
                        ),
                ),
                isLoading
                    ? Container(
                        width: MediaQuery.of(context).size.width,
                        padding: EdgeInsets.all(5),
                        color: Colors.yellowAccent,
                        child: Text(
                          'Loading',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      )
                    : Container(),
              ],
            )),
            Container(
              decoration: kMessageContainerDecoration,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Expanded(
                    child: TextField(
                      maxLines: 4,
                      controller: messageTextController,
                      style: TextStyle(
                        color: Colors.black,
                      ),
                      onChanged: (value) {
                        messageText = value;
                      },
                      decoration: kMessageTextFieldDecoration,
                    ),
                  ),
                  FlatButton(
                    onPressed: () {
                      messageTextController.clear();
                      if (messageText.isNotEmpty) {
                        commentRef.add({
                          'comment': messageText,
                          'sender': loggedInUser.email,
                          'time': new DateTime.now().millisecondsSinceEpoch
                        });
                        messageText = '';
                        // _refresh();
                      }
                    },
                    child: Text(
                      'Send',
                      style: kSendButtonTextStyle,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  _refresh() async {
    hasMore = true;
    lastDocument = null;
    comments = [];
    _getComments();
  }

  _getComments() async {
    if (!hasMore) {
      print('No More Comments');
      return;
    }
    if (isLoading) {
      return;
    }
    setState(() {
      isLoading = true;
    });
    QuerySnapshot querySnapshot;
    print(documentLimit);
    if (lastDocument == null) {
      querySnapshot = await commentRef
          .orderBy('time', descending: true)
          .limit(documentLimit)
          .get();
      // print(11111);
    } else {
      querySnapshot = await commentRef
          .orderBy('time', descending: true)
          .startAfterDocument(lastDocument)
          .limit(documentLimit)
          .get();
      // print(22222);
    }
    print('querySnapshot.docs.length: ${querySnapshot.docs.length}');
    print('get comments: querySnapshot.metadata.isFromCache - ${querySnapshot.metadata.isFromCache}');
    if (querySnapshot.docs.length < documentLimit) {
      hasMore = false;
    }
    if (querySnapshot.docs.length > 0) {
      lastDocument = querySnapshot.docs[querySnapshot.docs.length - 1];
      comments.addAll(querySnapshot.docs);
    }
    setState(() {
      isLoading = false;
    });
  }

  listenForChanges() {
    mStream = commentRef.snapshots(includeMetadataChanges: false).listen((event) {
      print('event.docChanges.length ${event.docChanges.length}');
      print('event.metadata.hasPendingWrites ${event.metadata.hasPendingWrites}');
      print('event.metadata.isFromCache ${event.metadata.isFromCache}');
      if (event.metadata.isFromCache) {
        return;
      }
      event.docChanges.asMap().forEach((index, documentChange) {
        print('index: $index - ${documentChange.doc} - ${documentChange.type}');
        if (documentChange.type == DocumentChangeType.added) {
          setState(() {
            comments.insert(0, documentChange.doc);
          });
        } else if (documentChange.type == DocumentChangeType.modified) {
          final docPosition =
              comments.indexWhere((doc) => doc.id == documentChange.doc.id);
          if (docPosition >= 0) {
            setState(() {
              comments[docPosition] = documentChange.doc;
            });
          }
        } else if (documentChange.type == DocumentChangeType.removed) {
          setState(() {
            comments.removeWhere(
                (document) => document.id == documentChange.doc.id);
          });
        }
      });
    });
  }
}

class DialogEditComment extends StatefulWidget {
  final String comment;
  final Function(String newcomment) updateComment;

  DialogEditComment({@required this.comment, @required this.updateComment});

  @override
  _DialogEditCommentState createState() => _DialogEditCommentState();
}

class _DialogEditCommentState extends State<DialogEditComment> {
  String newComment;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Flexible(
            child: TextField(
              controller: TextEditingController()..text = widget.comment,
              style: kTextStyleBlackDefault,
              onChanged: (value) {
                newComment = value;
              },
            ),
          ),
          FlatButton(
            onPressed: () {
              widget.updateComment(newComment);
            },
            child: Text('Update'),
          ),
        ],
      ),
    );
  }
}

final commentRef =
    _firestore.collection('discussion').doc(docsId).collection('comments');
const docsId = 'docsId';
