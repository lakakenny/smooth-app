import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:openfoodfacts/model/Attribute.dart';
import 'package:openfoodfacts/openfoodfacts.dart';
import 'package:smooth_app/data_models/product_image_data.dart';
import 'package:smooth_app/generic_lib/design_constants.dart';
import 'package:smooth_app/generic_lib/widgets/smooth_card.dart';

String getProductName(Product product, AppLocalizations appLocalizations) =>
    product.productName ?? appLocalizations.unknownProductName;

String getProductBrands(Product product, AppLocalizations appLocalizations) {
  final String? brands = product.brands;
  if (brands == null) {
    return appLocalizations.unknownBrand;
  } else {
    return formatProductBrands(brands, appLocalizations);
  }
}

/// Correctly format word separators between words (e.g. comma in English)
String formatProductBrands(String brands, AppLocalizations appLocalizations) {
  final String separator = appLocalizations.word_separator;
  final String separatorChar =
      RegExp.escape(appLocalizations.word_separator_char);
  final RegExp regex = RegExp('\\s*$separatorChar\\s*');
  return brands.replaceAll(regex, separator);
}

/// Padding to be used while building the SmoothCard on any Product card.
const EdgeInsets SMOOTH_CARD_PADDING = EdgeInsets.symmetric(
  horizontal: MEDIUM_SPACE,
  vertical: VERY_SMALL_SPACE,
);

/// A SmoothCard on Product cards using default margin and padding.
Widget buildProductSmoothCard({
  Widget? header,
  required Widget body,
  EdgeInsets? padding = EdgeInsets.zero,
  EdgeInsets? margin = const EdgeInsets.symmetric(
    horizontal: SMALL_SPACE,
  ),
}) {
  return SmoothCard(
    margin: margin,
    padding: padding,
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        if (header != null) header,
        body,
      ],
    ),
  );
}

// used to be in now defunct `AttributeListExpandable`
List<Attribute> getPopulatedAttributes(
  final Product product,
  final List<String> attributeIds,
  final List<String> excludedAttributeIds,
) {
  final List<Attribute> result = <Attribute>[];
  final Map<String, Attribute> attributes = product.getAttributes(attributeIds);
  for (final String attributeId in attributeIds) {
    if (excludedAttributeIds.contains(attributeId)) {
      continue;
    }
    Attribute? attribute = attributes[attributeId];
// Some attributes selected in the user preferences might be unavailable for some products
    if (attribute == null) {
      continue;
    } else if (attribute.id == Attribute.ATTRIBUTE_ADDITIVES) {
// TODO(stephanegigandet): remove that cheat when additives are more standard
      final List<String>? additiveNames = product.additives?.names;
      attribute = Attribute(
        id: attribute.id,
        title: attribute.title,
        iconUrl: attribute.iconUrl,
        descriptionShort: additiveNames == null ? '' : additiveNames.join(', '),
      );
    }
    result.add(attribute);
  }
  return result;
}

Widget addPanelButton(
  final String label, {
  final IconData? iconData,
  required final Function() onPressed,
}) =>
    SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        icon: Icon(iconData ?? Icons.add),
        style: ButtonStyle(
          shape: MaterialStateProperty.all<RoundedRectangleBorder>(
            const RoundedRectangleBorder(
              borderRadius: ROUNDED_BORDER_RADIUS,
            ),
          ),
        ),
        label: Text(label),
        onPressed: onPressed,
      ),
    );

List<ProductImageData> getProductMainImagesData(
  Product product,
  AppLocalizations appLocalizations, {
  final bool includeOther = true,
}) =>
    <ProductImageData>[
      getProductImageData(product, appLocalizations, ImageField.FRONT),
      getProductImageData(product, appLocalizations, ImageField.INGREDIENTS),
      getProductImageData(product, appLocalizations, ImageField.NUTRITION),
      getProductImageData(product, appLocalizations, ImageField.PACKAGING),
      if (includeOther)
        getProductImageData(product, appLocalizations, ImageField.OTHER),
    ];

ProductImageData getProductImageData(
  final Product product,
  final AppLocalizations? appLocalizations,
  final ImageField imageField,
) =>
    ProductImageData(
      imageField: imageField,
      imageUrl: getProductImageUrl(product, imageField),
      title: appLocalizations == null
          ? ''
          : getProductImageTitle(appLocalizations, imageField),
      buttonText: appLocalizations == null
          ? ''
          : getProductImageButtonText(appLocalizations, imageField),
    );

String? getProductImageUrl(
  final Product product,
  final ImageField imageField,
) {
  switch (imageField) {
    case ImageField.FRONT:
      return product.imageFrontUrl;
    case ImageField.INGREDIENTS:
      return product.imageIngredientsUrl;
    case ImageField.NUTRITION:
      return product.imageNutritionUrl;
    case ImageField.PACKAGING:
      return product.imagePackagingUrl;
    case ImageField.OTHER:
      return null;
  }
}

String getProductImageTitle(
  final AppLocalizations appLocalizations,
  final ImageField imageField,
) {
  switch (imageField) {
    case ImageField.FRONT:
      return appLocalizations.product;
    case ImageField.INGREDIENTS:
      return appLocalizations.ingredients;
    case ImageField.NUTRITION:
      return appLocalizations.nutrition;
    case ImageField.PACKAGING:
      return appLocalizations.packaging_information;
    case ImageField.OTHER:
      return appLocalizations.more_photos;
  }
}

String getProductImageButtonText(
  final AppLocalizations appLocalizations,
  final ImageField imageField,
) {
  switch (imageField) {
    case ImageField.FRONT:
      return appLocalizations.front_photo;
    case ImageField.INGREDIENTS:
      return appLocalizations.ingredients_photo;
    case ImageField.NUTRITION:
      return appLocalizations.nutrition_facts_photo;
    case ImageField.PACKAGING:
      return appLocalizations.packaging_information_photo;
    case ImageField.OTHER:
      return appLocalizations.more_photos;
  }
}
