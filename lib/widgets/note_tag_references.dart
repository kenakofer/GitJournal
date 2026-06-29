/*
 * SPDX-FileCopyrightText: 2026 Kenan Bitikofer
 *
 * SPDX-License-Identifier: AGPL-3.0-or-later
 */

import 'package:flutter/material.dart';
import 'package:gitjournal/core/folder/notes_folder.dart';
import 'package:gitjournal/core/folder/notes_folder_fs.dart';
import 'package:gitjournal/core/note.dart';
import 'package:gitjournal/core/views/inline_tags_view.dart';
import 'package:gitjournal/folder_views/common.dart';
import 'package:gitjournal/widgets/notes_backlinks.dart';
import 'package:gitjournal/widgets/pro_overlay.dart';

/// Logseq-style "Tagged in" section: since a tag behaves like a page, the note
/// named after a tag lists every note that uses that tag (frontmatter `tags:`
/// or inline `#tag`). Mirrors [NoteBacklinkRenderer] but matches on tags rather
/// than wikilink resolution.
class NoteTagReferencesRenderer extends StatefulWidget {
  final Note note;
  final NotesFolderFS rootFolder;
  final NotesFolder parentFolder;
  final InlineTagsView inlineTagsView;

  const NoteTagReferencesRenderer({
    super.key,
    required this.note,
    required this.rootFolder,
    required this.parentFolder,
    required this.inlineTagsView,
  });

  @override
  State<NoteTagReferencesRenderer> createState() =>
      _NoteTagReferencesRendererState();
}

class _NoteTagReferencesRendererState
    extends State<NoteTagReferencesRenderer> {
  List<Note> _taggedNotes = [];

  // The tag a note represents is its filename (e.g. foo.md -> "foo").
  String get _tag => widget.note.fileName.replaceAll(
        RegExp(r'\.[^.]*$'),
        '',
      );

  @override
  void initState() {
    super.initState();
    _initStateAsync();
  }

  Future<void> _initStateAsync() async {
    var tag = _tag;

    Future<bool> predicate(Note n) async {
      if (n.filePath == widget.note.filePath) return false; // not itself
      if (n.tags.contains(tag)) return true;

      var inlineTags = await widget.inlineTagsView.fetch(n);
      return inlineTags.contains(tag);
    }

    var l = await widget.rootFolder.matchNotes(predicate);
    if (!mounted) return;
    setState(() {
      _taggedNotes = l;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_taggedNotes.isEmpty) {
      return Container();
    }

    var num = _taggedNotes.length;
    var textTheme = Theme.of(context).textTheme;
    var c = Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          'Tagged in ($num)',
          style: textTheme.titleLarge,
        ),
        const SizedBox(height: 8.0),
        for (var note in _taggedNotes)
          NoteSnippet(
            note: note,
            parentNote: widget.note,
            onTap: () {
              openNoteEditor(context, note, widget.parentFolder);
            },
          ),
      ],
    );

    var backgroundColor = Colors.grey[200];
    if (Theme.of(context).brightness == Brightness.dark) {
      backgroundColor = Theme.of(context).colorScheme.surface;
    }
    var child = Container(
      color: backgroundColor,
      width: MediaQuery.of(context).size.width,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 16.0),
        child: c,
      ),
    );
    return ProOverlay(child: child);
  }
}
