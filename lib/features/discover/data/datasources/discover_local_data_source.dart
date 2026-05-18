import 'package:echo_explorer/features/discover/domain/entities/god_entity.dart';
import 'package:echo_explorer/features/discover/domain/entities/era_entity.dart';
import 'package:echo_explorer/features/discover/domain/entities/section_card_entity.dart';

abstract class DiscoverLocalDataSource {
  List<GodEntity> getGods();
  List<EraEntity> getEras();
  List<SectionCardEntity> getSectionCards();
}

class DiscoverLocalDataSourceImpl implements DiscoverLocalDataSource {
  @override
  List<GodEntity> getGods() {
    return <GodEntity>[];
  }

  @override
  List<EraEntity> getEras() {
    return <EraEntity>[];
  }

  @override
  List<SectionCardEntity> getSectionCards() {
    return <SectionCardEntity>[];
  }
}
