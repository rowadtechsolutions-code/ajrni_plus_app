class BannerModel {
  final String id;
  final String title;
  final String imageUrl;
  final String? linkUrl;
  final String? officeId;

  const BannerModel({
    required this.id,
    required this.title,
    required this.imageUrl,
    this.linkUrl,
    this.officeId,
  });

  factory BannerModel.fromJson(Map<String, dynamic> json) {
    return BannerModel(
      id: json['id']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      imageUrl: json['image_url']?.toString() ?? '',
      linkUrl: json['link_url']?.toString(),
      officeId: json['office_id']?.toString(),
    );
  }
}
