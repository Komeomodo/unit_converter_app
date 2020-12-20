
import 'package:flutter/material.dart';
// @required is defined in the meta.dart package
import 'package:meta/meta.dart';
import 'package:unit_converter_app/unit.dart';
// import 'package:unit_converter_app/unit_converter.dart';

//an underscore to indicate that these variables are private.
final _rowHeight = 100.0;
final _borderRadius = BorderRadius.circular(_rowHeight / 2);

// A custom [Category] widget.
//The widget is composed on an [Icon] and [Text]. Tapping on the widget shows
//a colored [InkWell] animation.
// A [Category] keeps track of a list of [Unit]s.
class Category {
  final String name;
  final ColorSwatch color;
  final List<Unit> units;
  final IconData iconLocation;

  /// Information about a [Category].
  ///
  /// A [Category] saves the name of the Category (e.g. 'Length'), a list of its
  /// its color for the UI, units for conversions (e.g. 'Millimeter', 'Meter'),
  /// and the icon that represents it (e.g. a ruler).
  const Category({
    @required this.name,
    @required this.color,
    @required this.units,
    @required this.iconLocation,
  })  : assert(name != null),
        assert(color != null),
        assert(units != null),
        assert(iconLocation != null);
}
