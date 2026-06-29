/*
 * SPDX-FileCopyrightText: 2026 Kenan Bitikofer
 *
 * SPDX-License-Identifier: AGPL-3.0-or-later
 */

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:markdown/markdown.dart' as md;

/// Renders inline #tags (emitted as `gjtag` elements by InlineTagSyntax) in a
/// light blue — a little lighter than wiki/page links — so they stand out as
/// tags. Tapping a tag invokes [onTagTapped] with the bare tag name (no '#'),
/// which the renderer wires to a filtered list of notes carrying that tag.
class TagBuilder extends MarkdownElementBuilder {
  static const tag = 'gjtag';

  // Light blue, intentionally a touch lighter than the link color.
  static const _color = Color(0xFF7EC4F2);

  final void Function(String tag) onTagTapped;

  TagBuilder({required this.onTagTapped});

  @override
  Widget? visitElementAfter(md.Element element, TextStyle? preferredStyle) {
    var tagName = element.attributes['tag'] ?? '';

    return RichText(
      text: TextSpan(
        text: element.textContent,
        style: (preferredStyle ?? const TextStyle()).copyWith(color: _color),
        recognizer: TapGestureRecognizer()..onTap = () => onTagTapped(tagName),
      ),
    );
  }
}
