import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/cupertino.dart';
import 'package:pikobar_flutter/repositories/AuthRepository.dart';
import 'package:pikobar_flutter/repositories/SelfReportRepository.dart';

part 'SelfReportListEvent.dart';

part 'SelfReportListState.dart';

class SelfReportListBloc
    extends Bloc<SelfReportListEvent, SelfReportListState> {
  StreamSubscription _subscription;
  @override
  SelfReportListState get initialState => SelfReportListInitial();

  @override
  Stream<SelfReportListState> mapEventToState(
    SelfReportListEvent event,
  ) async* {
    if (event is SelfReportListLoad) {
      yield* _loadSelfReportListToState();
    } else if (event is SelfReportListUpdated) {
      yield* _selfReportListToState(event);
    }

  }

 

  Stream<SelfReportListState> _loadSelfReportListToState() async* {
    yield SelfReportListLoading();
    _subscription?.cancel();
    String userId = await AuthRepository().getToken();

    _subscription = SelfReportRepository()
        .getSelfReportList(userId: userId)
        .listen((event) {
      add(SelfReportListUpdated(event));
    });
  }



  Stream<SelfReportListState> _selfReportListToState(
      SelfReportListUpdated event) async* {
      yield SelfReportListLoaded(
          querySnapshot: event.selfReportList);
    
  }

 
}
