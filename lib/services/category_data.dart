import 'package:news_app/models/category_model.dart';

List<CategoryModel> getCategories() {
  List<CategoryModel> category = [];
  CategoryModel categoryModel = CategoryModel();

  categoryModel.categoryName  = "Business";
  categoryModel.image ="image/business.jpg";
  category.add(categoryModel);
  categoryModel = CategoryModel();

  categoryModel.categoryName  = "Entertainment";
  categoryModel.image ="image/entertainment.jpg";
  category.add(categoryModel);
  categoryModel = CategoryModel();

  categoryModel.categoryName  = "General";
  categoryModel.image ="image/general.jpg";
  category.add(categoryModel);
  categoryModel = CategoryModel();

  categoryModel.categoryName  = "Health";
  categoryModel.image ="image/health.jpg";
  category.add(categoryModel);
  categoryModel = CategoryModel();

  categoryModel.categoryName  = "Science";
  categoryModel.image ="image/science.jpg";
  category.add(categoryModel);
  categoryModel = CategoryModel();

  categoryModel.categoryName  = "Sports";
  categoryModel.image ="image/sport.jpg";
  category.add(categoryModel);
  categoryModel = CategoryModel();

  return category;
}