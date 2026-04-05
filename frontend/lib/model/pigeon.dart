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
    id: 0,
    side: 'images/pigeonSide/defaultPigeonSide.webp',
    profile: 'images/pigeonProfile/defaultPigeonProfile.webp',
    coop: 'images/pigeonCoop/defaultPigeonCoop.webp',
    name: '####',
  ),
  Pigeon(
    id: 1,
    side: 'images/pigeonSide/showRacingHomerSide.webp',
    profile: 'images/pigeonProfile/showRacingHomerProfile.webp',
    coop: 'images/pigeonCoop/showRacingHomerCoop.webp',
    name: 'Show Racing Homer Pigeon',
  ),
  Pigeon(
    id: 2,
    side: 'images/pigeonSide/amStrasserSide.webp',
    profile: 'images/pigeonProfile/amStrasserProfile.webp',
    coop: 'images/pigeonCoop/amStrasserCoop.webp',
    name: 'Am Strasser Pigeon',
  ),
  Pigeon(
    id: 3,
    side: 'images/pigeonSide/ancientPigeonSide.webp',
    profile: 'images/pigeonProfile/ancientPigeonProfile.webp',
    coop: 'images/pigeonCoop/ancientPigeonCoop.webp',
    name: 'Ancient Pigeon',
  ),
  Pigeon(
    id: 4,
    side: 'images/pigeonSide/berneLarkSide.webp',
    profile: 'images/pigeonProfile/berneLarkProfile.webp',
    coop: 'images/pigeonCoop/berneLarkCoop.webp',
    name: 'Berne Lark Pigeon',
  ),
  Pigeon(
    id: 5,
    side: 'images/pigeonSide/chineseOwlChampionSide.webp',
    profile: 'images/pigeonProfile/chineseOwlChampionProfile.webp',
    coop: 'images/pigeonCoop/chineseOwlChampionCoop.webp',
    name: 'Chinese Owl Champion Pigeon',
  ),
  Pigeon(
    id: 6,
    side: 'images/pigeonSide/egyptianSwiftSide.webp',
    profile: 'images/pigeonProfile/egyptianSwiftProfile.webp',
    coop: 'images/pigeonCoop/egyptianSwiftCoop.webp',
    name: 'Egyptian Swift Pigeon',
  ),
  Pigeon(
    id: 7,
    side: 'images/pigeonSide/indianFantailSide.webp',
    profile: 'images/pigeonProfile/indianFantailProfile.webp',
    coop: 'images/pigeonCoop/indianFantailCoop.webp',
    name: 'Indian Fantail Pigeon',
  ),
  Pigeon(
    id: 8,
    side: 'images/pigeonSide/magpiePigeonSide.webp',
    profile: 'images/pigeonProfile/magpiePigeonProfile.webp',
    coop: 'images/pigeonCoop/magpiePigeonCoop.webp',
    name: 'Magpie Pigeon',
  ),
  Pigeon(
    id: 9,
    side: 'images/pigeonSide/mourningDoveSide.webp',
    profile: 'images/pigeonProfile/mourningDoveProfile.webp',
    coop: 'images/pigeonCoop/mourningDoveCoop.webp',
    name: 'Mourning Dove',
  ),
  Pigeon(
    id: 10,
    side: 'images/pigeonSide/pinkNeckedGreenPigeonSide.webp',
    profile: 'images/pigeonProfile/pinkNeckedGreenPigeonProfile.webp',
    coop: 'images/pigeonCoop/pinkNeckedGreenPigeonCoop.webp',
    name: 'Pink-Necked Green Pigeon',
  ),
];