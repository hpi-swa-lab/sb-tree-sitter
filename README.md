# sb-tree-sitter
Integration of Sandblocks with Tree-Sitter to load block-based languages from grammars

/!\ This README is a work-in-progress.

### Installation
Download Squeak 6.0 and run:

```smalltalk
Metacello new
  baseline: 'SBTreeSitter';
  onConflict: [:ex | ex allow];
  repository: 'github://hpi-swa-lab/sb-tree-sitter:master/packages';
  get; load.
```

(Note that you may be warned about unknown selectors -- just confirm and proceed.)

Then open Sandblocks via the Apps menu and create a new file via the Add menu in the top bar.
