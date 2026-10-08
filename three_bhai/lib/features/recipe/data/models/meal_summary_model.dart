class MealSummaryModel {
  const MealSummaryModel({required this.id, required this.title});

  final String id;
  final String title;

  factory MealSummaryModel.fromJson(Map<String, dynamic> json) =>
      MealSummaryModel(
        id: json['idMeal'].toString(),
        title: (json['strMeal'] ?? '').toString(),
      );
}
