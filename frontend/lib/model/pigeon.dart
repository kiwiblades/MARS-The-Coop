class Pigeon {
  final int id; //to keep track for user
  //each pigeon has a side view, coop view, and profile view
  final String side;
  final String profile;
  final String coop;

  final String name;

  Pigeon({
    required this.id,
    required this.side,
    required this.profile,
    required this.coop,
    required this.name,
  });

  //helper function to get pigeon by id (for rendering purposes)
  static Pigeon? getById(int id) {
    try {
      return allPigeons.firstWhere((p) => p.id == id);
    } catch (e) {
      return null;
    }
  }
}

List<Pigeon> allPigeons = [
  Pigeon(
    id: 1,
    side: 'images/pigeonSide/showRacingHomerSide.png',
    profile: 'images/pigeonProfile/showRacingHomerProfile.png',
    coop: 'images/pigeonCoop/showRacingHomerCoop.png',
    name: 'Show Racing Homer Pigeon',
  ),
  Pigeon(
    id: 2,
    side: 'images/pigeonSide/amStrasserSide.png',
    profile: 'images/pigeonProfile/amStrasserProfile.png',
    coop: 'images/pigeonCoop/amStrasserCoop.png',
    name: 'Am Strasser Pigeon',
  ),
  Pigeon(
    id: 3,
    side: 'images/pigeonSide/ancientPigeonSide.png',
    profile: 'images/pigeonProfile/ancientPigeonProfile.png',
    coop: 'images/pigeonCoop/ancientPigeonCoop.png',
    name: 'Ancient Pigeon',
  ),
  Pigeon(
    id: 4,
    side: 'images/pigeonSide/berneLarkSide.png',
    profile: 'images/pigeonProfile/berneLarkProfile.png',
    coop: 'images/pigeonCoop/berneLarkCoop.png',
    name: 'Berne Lark Pigeon',
  ),
  Pigeon(
    id: 5,
    side: 'images/pigeonSide/chineseOwlChampionSide.png',
    profile: 'images/pigeonProfile/chineseOwlChampionProfile.png',
    coop: 'images/pigeonCoop/chineseOwlChampionCoop.png',
    name: 'Chinese Owl Champion Pigeon',
  ),
  Pigeon(
    id: 6,
    side: 'images/pigeonSide/egyptianSwiftSide.png',
    profile: 'images/pigeonProfile/egyptianSwiftProfile.png',
    coop: 'images/pigeonCoop/egyptianSwiftCoop.png',
    name: 'Egyptian Swift Pigeon',
  ),
  Pigeon(
    id: 7,
    side: 'images/pigeonSide/indianFantailSide.png',
    profile: 'images/pigeonProfile/indianFantailProfile.png',
    coop: 'images/pigeonCoop/indianFantailCoop.png',
    name: 'Indian Fantail Pigeon',
  ),
  Pigeon(
    id: 8,
    side: 'images/pigeonSide/magpiePigeonSide.png',
    profile: 'images/pigeonProfile/magpiePigeonProfile.png',
    coop: 'images/pigeonCoop/magpiePigeonCoop.png',
    name: 'Magpie Pigeon',
  ),
  Pigeon(
    id: 9,
    side: 'images/pigeonSide/mourningDoveSide.png',
    profile: 'images/pigeonProfile/mourningDoveProfile.png',
    coop: 'images/pigeonCoop/mourningDoveCoop.png',
    name: 'Mourning Dove',
  ),
  Pigeon(
    id: 10,
    side: 'images/pigeonSide/pinkNeckedGreenPigeonSide.png',
    profile: 'images/pigeonProfile/pinkNeckedGreenPigeonProfile.png',
    coop: 'images/pigeonCoop/pinkNeckedGreenPigeonCoop.png',
    name: 'Pink-Necked Green Pigeon',
  ),
];