import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:reactive_forms/models/form_control.dart';
import 'package:reactive_forms/widgets/reactive_form.dart';

typedef ReactiveFieldBuilder = Widget Function(_ReactiveTextFieldState state);

class ReactiveTextField extends StatefulWidget {
  ReactiveFieldBuilder _builder;
  final String formControlName;

  ReactiveTextField({
    Key key,
    this.formControlName,
    InputDecoration decoration = const InputDecoration(),
    TextInputType keyboardType,
    TextCapitalization textCapitalization = TextCapitalization.none,
    TextInputAction textInputAction,
    TextStyle style,
    StrutStyle strutStyle,
    TextDirection textDirection,
    TextAlign textAlign = TextAlign.start,
    TextAlignVertical textAlignVertical,
    bool autofocus = false,
    bool readOnly = false,
    ToolbarOptions toolbarOptions,
    bool showCursor,
    bool obscureText = false,
    bool autocorrect = true,
    SmartDashesType smartDashesType,
    SmartQuotesType smartQuotesType,
    bool enableSuggestions = true,
    bool maxLengthEnforced = true,
    int maxLines = 1,
    int minLines,
    bool expands = false,
    int maxLength,
    ValueChanged<String> onChanged,
    GestureTapCallback onTap,
    VoidCallback onEditingComplete,
    ValueChanged<String> onFieldSubmitted,
    FormFieldSetter<String> onSaved,
    FormFieldValidator<String> validator,
    List<TextInputFormatter> inputFormatters,
    bool enabled = true,
    double cursorWidth = 2.0,
    Radius cursorRadius,
    Color cursorColor,
    Brightness keyboardAppearance,
    EdgeInsets scrollPadding = const EdgeInsets.all(20.0),
    bool enableInteractiveSelection = true,
    InputCounterWidgetBuilder buildCounter,
    ScrollPhysics scrollPhysics,
  }) : _builder = ((_ReactiveTextFieldState state) {
          final InputDecoration effectiveDecoration =
              (decoration ?? const InputDecoration())
                  .applyDefaults(Theme.of(state.context).inputDecorationTheme);

          return TextField(
            controller: state._textController,
            focusNode: state._focusNode,
            decoration:
                effectiveDecoration.copyWith(errorText: state._errorText),
            keyboardType: keyboardType,
            textInputAction: textInputAction,
            style: style,
            strutStyle: strutStyle,
            textAlign: textAlign,
            textAlignVertical: textAlignVertical,
            textDirection: textDirection,
            textCapitalization: textCapitalization,
            autofocus: autofocus,
            toolbarOptions: toolbarOptions,
            readOnly: readOnly,
            showCursor: showCursor,
            obscureText: obscureText,
            autocorrect: autocorrect,
            smartDashesType: smartDashesType ??
                (obscureText
                    ? SmartDashesType.disabled
                    : SmartDashesType.enabled),
            smartQuotesType: smartQuotesType ??
                (obscureText
                    ? SmartQuotesType.disabled
                    : SmartQuotesType.enabled),
            enableSuggestions: enableSuggestions,
            maxLengthEnforced: maxLengthEnforced,
            maxLines: maxLines,
            minLines: minLines,
            expands: expands,
            maxLength: maxLength,
            onChanged: state._onChanged,
            onTap: onTap,
            onEditingComplete: onEditingComplete,
            onSubmitted: onFieldSubmitted,
            inputFormatters: inputFormatters,
            enabled: enabled,
            cursorWidth: cursorWidth,
            cursorRadius: cursorRadius,
            cursorColor: cursorColor,
            scrollPadding: scrollPadding,
            scrollPhysics: scrollPhysics,
            keyboardAppearance: keyboardAppearance,
            enableInteractiveSelection: enableInteractiveSelection,
            buildCounter: buildCounter,
          );
        });

  @override
  _ReactiveTextFieldState createState() => _ReactiveTextFieldState();
}

class _ReactiveTextFieldState extends State<ReactiveTextField> {
  TextEditingController _textController;
  FormControl _control;
  FocusNode _focusNode = FocusNode();
  String _errorText;

  @override
  void initState() {
    final form = ReactiveForm.of(context, listen: false);
    _control = form.formControl(widget.formControlName);
    _textController = TextEditingController(text: _control.value);

    _focusNode.addListener(_onFocusChanged);
    _control.onStatusChanged.listen((_) => _touch());
    _control.onFocusChanged.listen((_) => _onFormControlFocusChanged());
    _control.addListener(_onFormControlValueChanged);

    super.initState();
  }

  void _onChanged(String value) {
    _control.value = value;
    if (_control.touched) {
      _validate();
    }
  }

  void _onFormControlValueChanged() {
    if (_textController.text == _control.value) {
      return;
    }

    _textController.text = _control.value;
    _touch();
  }

  void _onFormControlFocusChanged() {
    if (_control.focused && !_focusNode.hasFocus) {
      _focusNode.requestFocus();
    } else if (!_control.focused && _focusNode.hasFocus) {
      _focusNode.unfocus();
    }
  }

  void _onFocusChanged() {
    if (!_focusNode.hasFocus && !_control.touched) {
      _touch();
    }

    if (_control.focused && !_focusNode.hasFocus) {
      _control.unfocus();
    } else if (!_control.focused && _focusNode.hasFocus) {
      _control.focus();
    }
  }

  void _touch() {
    _control.touched = true;
    _validate();
  }

  void _validate() {
    setState(() {
      if (_control.errors.keys.length > 0) {
        _errorText = _control.errors.keys.first;
      } else {
        _errorText = null;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return widget._builder(this);
  }
}