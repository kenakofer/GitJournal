/*
 * SPDX-FileCopyrightText: 2026 Kenan Bitikofer
 *
 * SPDX-License-Identifier: AGPL-3.0-or-later
 */

import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:markdown/markdown.dart' as md;

/// Renders inline #tags (emitted as `gjtag` elements by InlineTagSyntax) in a
/// light blue — a little lighter than wiki/page links — so they stand out as
/// tags without competing with navigable links.
class TagBuilder extends MarkdownElementBuilder {
  static const tag = 'gjtag';

  // Light blue, intentionally a touch lighter than the link color.
  static const _color = Color(0xFF7EC4F2);

  @override
  Widget? visitElementAfter(md.Element element, TextStyle? preferredStyle) {
    return Text(
      element.textContent,
      style: (preferredStyle ?? const TextStyle()).copyWith(color: _color),
    );
  }
}
