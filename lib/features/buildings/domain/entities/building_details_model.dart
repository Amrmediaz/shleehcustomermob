
class BuildingDetails {
    final int id;
    final String name;
    final String buldingDescrption;
    final String state;
    final String gouvernate;
    final String lat;
    final String lng;
    final bool isActive;
    final bool stopBook;
    final List<Map<String, dynamic>> buldingImages;
     List<Map<String, dynamic>> buldingService;

    BuildingDetails({
        required this.id,
        required this.name,
        required this.buldingDescrption,
        required this.state,
        required this.gouvernate,
        required this.lat,
        required this.lng,
        required this.isActive,
        required this.stopBook,
        required this.buldingImages,
        required this.buldingService,
    });
}