import 'package:flutter/material.dart';
import 'package:meta/meta.dart';
import 'package:unit_converter_app/unit.dart';
import 'package:unit_converter_app/category.dart';

const _padding = EdgeInsets.all(16.0);

/// Converter screen where users can input amounts to convert.
/// Currently, it just displays a list of mock units.
/// While it is named ConverterRoute, a more apt name would be ConverterScreen,
/// because it is responsible for the UI at the route's destination.
class UnitConverter extends StatefulWidget {
  //color for category
  // final Color color;

  // Units for this Category.
  // final List<Unit> units;

  /// The current [Category] for unit conversion.
  final Category category;

  // //This [ConverterRoute] requires the color and units to not be null.
  // const UnitConverter({
  //   @required this.color,
  //   @required this.units,
  // })  : assert(color != null),
  //       assert(units != null);

  /// This [UnitConverter] takes in a [Category] with [Units]. It can't be null.
  const UnitConverter({
    @required this.category,
  }) : assert(category != null);

  @override
  _UnitConverterState createState() => _UnitConverterState();
}

class _UnitConverterState extends State<UnitConverter> {
  bool _showValidationError = false;
  Unit _fromValue;
  Unit _toValue;
  String _convertedValue = '';
  List<DropdownMenuItem> _unitMenuItems;
  double _inputValue;

  @override
  void initState() {
    super.initState();
    _createDropdownMenuItems();
    _setDefaults();
  }

  @override
  void didUpdateWidget(UnitConverter old) {
    super.didUpdateWidget(old);
    // We update our [DropdownMenuItem] units when we switch [Categories].
    if (old.category != widget.category) {
      _createDropdownMenuItems();
      _setDefaults();
    }
  }

  /// Creates fresh list of [DropdownMenuItem] widgets, given a list of [Unit]s.
  void _createDropdownMenuItems() {
    var newItems = <DropdownMenuItem>[];
    for (var unit in widget.category.units) {
      newItems.add(DropdownMenuItem(
        value: unit.name,
        child: Container(
          child: Text(
            unit.name,
            softWrap: true,
          ),
        ),
      ));
    }
    setState(() {
      _unitMenuItems = newItems;
    });
  }

  // Sets the default values for the 'from' and 'to' [Dropdown]s.
  //and updates output value if a user had previously entered an input.
  void _setDefaults() {
    setState(() {
      _fromValue = widget.category.units[0];
      _toValue = widget.category.units[1];
    });
    if (_inputValue != null) {
      _updateConversion();
    }
  }

  String _format(double conversion) {
    var outputNumber = conversion.toStringAsPrecision(7);
    if (outputNumber.contains('.') && outputNumber.endsWith('0')) {
      var index = outputNumber.length - 1;
      while (outputNumber[index] == '0') {
        index--;
      }
      outputNumber = outputNumber.substring(0, index + 1);
    }
    if (outputNumber.endsWith('.')) {
      return outputNumber.substring(0, outputNumber.length - 1);
    }
    return outputNumber;
  }

  void _updateConversion() {
    setState(() {
      _convertedValue =
          _format((_toValue.conversion / _fromValue.conversion) * _inputValue);
    });
  }

  Unit _getUnit(String unit_name) {
    return widget.category.units.firstWhere(
      (Unit unit) {
        return unit.name == unit_name;
      },
      orElse: null,
    );
  }

  void _updateInputValue(String input) {
    setState(() {
      if (input == null || input.isEmpty) {
        _convertedValue = '';
      } else {
        // Even though we are using the numerical keyboard, we still have to check
        // for non-numerical input such as '5..0' or '6 -3'
        try {
          final inputDouble = double.parse(input);
          _showValidationError = false;
          _inputValue = inputDouble;
          _updateConversion();
        } on Exception catch (e) {
          print('Error: $e');
          _showValidationError = true;
        }
      }
    });
  }

  void _updateToConversion(dynamic unit_name) {
    setState(() {
      _toValue = _getUnit(unit_name);
    });
    if (_inputValue != null) {
      _updateConversion();
    }
  }

  void _updateFromConversion(dynamic unit_name) {
    setState(() {
      _fromValue = _getUnit(unit_name);
    });
    if (_inputValue != null) {
      _updateConversion();
    }
  }

  Widget _createDropdownWidget(
      String currentValue, ValueChanged<dynamic> onChanged) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 8.0),
      margin: EdgeInsets.only(top: 16.0),
      decoration: BoxDecoration(
        //sets the color of the DropdownButton
        color: Colors.grey[50],
        border: Border.all(
          color: Colors.grey[400],
          width: 1.0,
        ),
      ),
      child: Theme(
        data: Theme.of(context).copyWith(
          canvasColor: Colors.grey[50],
        ),
        child: DropdownButtonHideUnderline(
          child: ButtonTheme(
            alignedDropdown: true,
            child: DropdownButton(
              value: currentValue,
              items: _unitMenuItems,
              onChanged: onChanged,
              style: Theme.of(context).textTheme.headline6,
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final input = Padding(
      padding: _padding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          // This is the widget that accepts text input.
          TextField(
            keyboardType: TextInputType.number,
            onChanged: _updateInputValue,
            style: Theme.of(context).textTheme.headline4,
            decoration: InputDecoration(
              labelText: 'input',
              labelStyle: Theme.of(context).textTheme.headline4,
              errorText: _showValidationError ? 'Invalid number entered' : null,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(0.0),
              ),
            ),
          ),
          _createDropdownWidget(_fromValue.name, _updateFromConversion),
        ],
      ),
    );

    final output = Padding(
      padding: _padding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          InputDecorator(
            child: Text(
              _convertedValue,
              style: Theme.of(context).textTheme.headline4,
            ),
            decoration: InputDecoration(
                labelText: 'output',
                labelStyle: Theme.of(context).textTheme.headline4,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(0.0),
                )),
          ),
          _createDropdownWidget(_toValue.name, _updateToConversion)
        ],
      ),
    );

    final arrows = RotatedBox(
      quarterTurns: 1,
      child: Icon(
        Icons.compare_arrows,
        size: 40.0,
      ),
    );

    //We ListView instead of a Column to draw the UnitConverter.
    // This ensures that your converter is viewable on all screens,
    // and is scrollable when the screen is too small to fit it all.
    // This also removes the RenderFlex exception while the front
    // panel of the Backdrop is being opened and closed
    // (alternatively, use a SingleChildScrollView).
    final converter = ListView(
      children: [
        input,
        arrows,
        output,
      ],
    );

    return Padding(
      padding: _padding,
      child: OrientationBuilder(
        builder: (BuildContext context, Orientation orientation) {
          if (orientation == Orientation.portrait) {
            return converter;
          } else {
            return Center(
              child: Container(
                width: 450.0,
                child: converter,
              ),
            );
          }
        },
      ),
    );

    // Here is just a placeholder for a list of mock units
    // final unitWidgets = widget.units.map((Unit unit) {
    //   return Container(
    //     color: widget.color,
    //     margin: EdgeInsets.all(8.0),
    //     padding: EdgeInsets.all(16.0),
    //     child: Column(
    //       children: <Widget>[
    //         Text(
    //           unit.name,
    //           style: Theme.of(context).textTheme.headline5,
    //         ),
    //         Text(
    //           'Conversion: ${unit.conversion}',
    //           style: Theme.of(context).textTheme.headline4,
    //         ),
    //       ],
    //     ),
    //   );
    // }).toList();

    // return ListView(
    //   children: unitWidgets,
    // );
  }
}
